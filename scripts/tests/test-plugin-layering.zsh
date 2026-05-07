#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/plugin-layering.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

fixture_root="$tmp_root/repo"
home_dir="$tmp_root/home"
bin_dir="$tmp_root/bin"

mkdir -p \
  "$fixture_root/ai/plugins" \
  "$fixture_root/scripts/lib" \
  "$fixture_root/scripts/tests" \
  "$home_dir" \
  "$bin_dir"

cp "$repo_root/scripts/install-plugins" "$fixture_root/scripts/install-plugins"
cp "$repo_root/scripts/lib/install-common.zsh" "$fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/scripts/lib/skill-acquisition.zsh" "$fixture_root/scripts/lib/skill-acquisition.zsh"

cat > "$fixture_root/ai/plugins/plugins.json" <<'JSON'
{
  "sample": {
    "source": "example/source",
    "skills": ["alpha", "beta"]
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
      [[ "$2" == "codex" ]] || {
        print -u2 "unexpected agent: $2"
        exit 1
      }
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
print -r -- "$source_arg" > .source

for skill_name in "${requested_skills[@]}"; do
  mkdir -p ".agents/skills/$skill_name"
  print -r -- "# $skill_name" > ".agents/skills/$skill_name/SKILL.md"
done
ZSH

chmod +x "$bin_dir/npx"

fail() {
  print -u2 "$1"
  exit 1
}

assert_path_exists() {
  local path=$1
  local label=$2

  [[ -e "$path" || -L "$path" ]] || fail "missing: $label ($path)"
}

assert_not_exists() {
  local path=$1
  local label=$2

  [[ ! -e "$path" && ! -L "$path" ]] || fail "unexpected entry: $label ($path)"
}

PATH="$bin_dir:$PATH" HOME="$home_dir" zsh "$fixture_root/scripts/install-plugins"

plugin_dir="$home_dir/.codex/plugins/dotfiles-local/sample"
marketplace_path="$home_dir/.agents/plugins/marketplace.json"

assert_path_exists "$plugin_dir/.codex-plugin/plugin.json" "plugin manifest"
assert_path_exists "$plugin_dir/skills/alpha/SKILL.md" "alpha skill"
assert_path_exists "$plugin_dir/skills/beta/SKILL.md" "beta skill"
assert_path_exists "$marketplace_path" "marketplace"

jq -e '.name == "sample"' "$plugin_dir/.codex-plugin/plugin.json" >/dev/null
jq -e '.repository == "https://github.com/example/source"' "$plugin_dir/.codex-plugin/plugin.json" >/dev/null
jq -e '.plugins[0].name == "sample"' "$marketplace_path" >/dev/null
jq -e '.plugins[0].source.path == "./.codex/plugins/dotfiles-local/sample"' "$marketplace_path" >/dev/null

mkdir -p "$home_dir/.codex/plugins/dotfiles-local/stale"
PATH="$bin_dir:$PATH" HOME="$home_dir" zsh "$fixture_root/scripts/install-plugins"
assert_not_exists "$home_dir/.codex/plugins/dotfiles-local/stale" "stale plugin"

print "test-plugin-layering: ok"
