#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/skill-acquisition.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

fixture_root="$tmp_root/repo"
stage_dir="$tmp_root/stage"
bin_dir="$tmp_root/bin"

mkdir -p \
  "$fixture_root/ai/skills" \
  "$fixture_root/ai/plugins" \
  "$fixture_root/scripts/lib" \
  "$stage_dir" \
  "$bin_dir"

cp "$repo_root/scripts/lib/install-common.zsh" "$fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/scripts/lib/skill-acquisition.zsh" "$fixture_root/scripts/lib/skill-acquisition.zsh"

cat > "$fixture_root/ai/skills/skills.json" <<'JSON'
{
  "org/all": "*",
  "org/one": "alpha",
  "https://example.com/skills.git": ["beta", "gamma"],
  "~/arcadia/ai/artifacts/skills/infra/arc": "*",
  "/opt/local-skills/custom": "local-custom",
  "./local-skills/relative": "relative-local"
}
JSON

cat > "$fixture_root/ai/plugins/plugins.json" <<'JSON'
{
  "string-plugin": "org/plugin-all",
  "selected-plugin": {
    "source": "org/plugin-selected",
    "skills": ["delta", "epsilon"]
  },
  "implicit-all-plugin": {
    "source": "https://example.com/plugin.git"
  }
}
JSON

cat > "$bin_dir/npx" <<'ZSH'
#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

[[ "$1" == "skills" && "$2" == "add" ]] || {
  print -u2 "unexpected npx command: $*"
  exit 1
}

source_arg=$3
shift 3
typeset -a requested_skills
requested_skills=()

while (( $# > 0 )); do
  case "$1" in
    -a)
      shift 2
      ;;
    -y)
      shift
      ;;
    --skill)
      requested_skills+=("$2")
      shift 2
      ;;
    *)
      print -u2 "unexpected npx argument: $1"
      exit 1
      ;;
  esac
done

mkdir -p .agents/skills

if (( ${#requested_skills[@]} == 0 )); then
  requested_skills=(all-one all-two)
fi

for skill_name in "${requested_skills[@]}"; do
  mkdir -p ".agents/skills/$skill_name"
  print -r -- "# $skill_name from $source_arg" > ".agents/skills/$skill_name/SKILL.md"
done
ZSH

chmod +x "$bin_dir/npx"

SCRIPT_NAME=test-skill-acquisition
ACQUISITION_SOURCE_BASE_DIR="$fixture_root"
source "$fixture_root/scripts/lib/install-common.zsh"
source "$fixture_root/scripts/lib/skill-acquisition.zsh"

fail() {
  print -u2 "$1"
  exit 1
}

assert_json() {
  local json=$1
  local filter=$2
  local label=$3

  jq -e "$filter" <<<"$json" >/dev/null || fail "json assertion failed: $label"
}

skill_specs=("${(@f)$(acquisition_skill_specs "$fixture_root/ai/skills/skills.json")}")
[[ ${#skill_specs[@]} == 6 ]] || fail "expected 6 skill specs, got ${#skill_specs[@]}"
assert_json "${skill_specs[1]}" '.source == "https://github.com/org/all" and .install_all == true and (.skills | length) == 0' "skill all spec"
assert_json "${skill_specs[2]}" '.source == "https://github.com/org/one" and .install_all == false and .skills == ["alpha"]' "single skill spec"
assert_json "${skill_specs[3]}" '.source == "https://example.com/skills.git" and .install_all == false and .skills == ["beta", "gamma"]' "array skill spec"

expected_arc_source="$HOME/arcadia/ai/artifacts/skills/infra/arc"
jq -e --arg source "$expected_arc_source" \
  '.source == $source and .install_all == true and (.skills | length) == 0' \
  <<<"${skill_specs[4]}" >/dev/null || fail "json assertion failed: tilde local skill source"
assert_json "${skill_specs[5]}" '.source == "/opt/local-skills/custom" and .install_all == false and .skills == ["local-custom"]' "absolute local skill source"
expected_relative_source="$fixture_root/local-skills/relative"
expected_relative_source="${expected_relative_source:A}"
jq -e --arg source "$expected_relative_source" \
  '.source == $source and .install_all == false and .skills == ["relative-local"]' \
  <<<"${skill_specs[6]}" >/dev/null || fail "json assertion failed: relative local skill source"

plugin_specs=("${(@f)$(acquisition_plugin_specs "$fixture_root/ai/plugins/plugins.json")}")
[[ ${#plugin_specs[@]} == 3 ]] || fail "expected 3 plugin specs, got ${#plugin_specs[@]}"
assert_json "${plugin_specs[1]}" '.name == "string-plugin" and .source == "https://github.com/org/plugin-all" and .install_all == true and (.skills | length) == 0' "string plugin spec"
assert_json "${plugin_specs[2]}" '.name == "selected-plugin" and .source == "https://github.com/org/plugin-selected" and .install_all == false and .skills == ["delta", "epsilon"]' "selected plugin spec"
assert_json "${plugin_specs[3]}" '.name == "implicit-all-plugin" and .source == "https://example.com/plugin.git" and .install_all == true and (.skills | length) == 0' "implicit all plugin spec"

selected=("${(@f)$(acquisition_spec_skills "${plugin_specs[2]}")}")
[[ "${selected[*]}" == "delta epsilon" ]] || fail "unexpected selected skills: ${selected[*]}"

PATH="$bin_dir:$PATH" acquisition_stage_skills "$stage_dir" "https://github.com/org/plugin-selected" "${selected[@]}"
staged_paths=("${(@f)$(acquisition_staged_skill_paths "$stage_dir")}")
[[ ${#staged_paths[@]} == 2 ]] || fail "expected 2 staged paths, got ${#staged_paths[@]}"
[[ -d "$stage_dir/.agents/skills/delta" ]] || fail "missing staged delta"
[[ -d "$stage_dir/.agents/skills/epsilon" ]] || fail "missing staged epsilon"

acquisition_has_selected_skills "$stage_dir/.agents/skills" delta epsilon || fail "selected skills should be present"
if acquisition_has_selected_skills "$stage_dir/.agents/skills" delta missing; then
  fail "missing selected skill was reported as present"
fi

cat > "$fixture_root/ai/skills/invalid-skills.json" <<'JSON'
{
  "org/bad": 42
}
JSON

if (acquisition_skill_specs "$fixture_root/ai/skills/invalid-skills.json") >/dev/null 2>"$tmp_root/invalid-skills.err"; then
  fail "invalid skill spec unexpectedly passed"
fi

ugrep -q 'invalid skill source spec: https://github.com/org/bad' "$tmp_root/invalid-skills.err" || {
  print -u2 "unexpected invalid skill error:"
  cat "$tmp_root/invalid-skills.err" >&2
  exit 1
}

cat > "$fixture_root/ai/plugins/invalid-plugin.json" <<'JSON'
{
  "bad-plugin": {
    "skills": ["missing-source"]
  }
}
JSON

if (acquisition_plugin_specs "$fixture_root/ai/plugins/invalid-plugin.json") >/dev/null 2>"$tmp_root/invalid-plugin.err"; then
  fail "invalid plugin spec unexpectedly passed"
fi

ugrep -q 'missing source for plugin: bad-plugin' "$tmp_root/invalid-plugin.err" || {
  print -u2 "unexpected invalid plugin error:"
  cat "$tmp_root/invalid-plugin.err" >&2
  exit 1
}

print "test-skill-acquisition: ok"
