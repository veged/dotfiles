#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/skill-layering.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

fixture_root="$tmp_root/repo"
home_dir="$tmp_root/home"
bin_dir="$tmp_root/bin"

mkdir -p \
  "$fixture_root/ai/skills/local-one" \
  "$fixture_root/scripts/lib" \
  "$fixture_root/scripts/tests" \
  "$home_dir" \
  "$bin_dir"

cp "$repo_root/scripts/install-skills" "$fixture_root/scripts/install-skills"
cp "$repo_root/scripts/lib/install-common.zsh" "$fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/scripts/bootstrap-agent-skills" "$fixture_root/scripts/bootstrap-agent-skills"

cat > "$fixture_root/ai/skills/local-one/SKILL.md" <<'EOF'
# local-one
EOF

cat > "$fixture_root/ai/skills/skills.json" <<'EOF'
{
  "example/source": "external-one"
}
EOF

cat > "$bin_dir/npx" <<'EOF'
#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

[[ $# -ge 3 ]] || {
  print -u2 "unexpected npx invocation"
  exit 1
}

[[ "$1" == "skills" && "$2" == "add" ]] || {
  print -u2 "unexpected npx command: $*"
  exit 1
}

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

for skill_name in "${requested_skills[@]}"; do
  mkdir -p ".agents/skills/$skill_name"
  print -r -- "# $skill_name" > ".agents/skills/$skill_name/SKILL.md"
done
EOF

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

assert_symlink_target() {
  local path=$1
  local expected_target=$2
  local label=$3
  local actual_target

  [[ -L "$path" ]] || fail "expected symlink: $label ($path)"
  actual_target=$(/usr/bin/readlink "$path")
  [[ "$actual_target" == "$expected_target" ]] || fail "unexpected symlink target for $label: $actual_target"
}

mkdir -p "$home_dir/.codex/skills/.system"
print -r -- "keep" > "$home_dir/.codex/skills/.system/keep.txt"

mkdir -p "$home_dir/.codex/skills/codex-primary-runtime/slides"
print -r -- "# slides" > "$home_dir/.codex/skills/codex-primary-runtime/slides/SKILL.md"

mkdir -p "$home_dir/.codex/skills/unmanaged"
mkdir -p "$home_dir/.claude/skills"
ln -s "$home_dir/.agents/skills/missing" "$home_dir/.claude/skills/stale"

PATH="$bin_dir:$PATH" HOME="$home_dir" zsh "$fixture_root/scripts/install-skills"

assert_path_exists "$home_dir/.agents/skills/local-one" "canonical local skill"
assert_path_exists "$home_dir/.agents/skills/external-one" "canonical external skill"
assert_path_exists "$home_dir/.agents/skills/codex-primary-runtime/slides/SKILL.md" "migrated codex-primary-runtime bundle"
assert_symlink_target "$home_dir/.claude/skills/local-one" "$home_dir/.agents/skills/local-one" "claude local skill link"
assert_symlink_target "$home_dir/.codex/skills/local-one" "$home_dir/.agents/skills/local-one" "codex local skill link"
assert_symlink_target "$home_dir/.codex/skills/codex-primary-runtime" "$home_dir/.agents/skills/codex-primary-runtime" "codex shared bundle link"
assert_path_exists "$home_dir/.codex/skills/.system/keep.txt" "codex system bundle"
assert_path_exists "$home_dir/.codex/skills/unmanaged" "unmanaged codex entry"
assert_not_exists "$home_dir/.claude/skills/stale" "stale claude link"

PATH="$bin_dir:$PATH" HOME="$home_dir" zsh "$fixture_root/scripts/install-skills"

assert_path_exists "$home_dir/.agents/skills/codex-primary-runtime/slides/SKILL.md" "preserved canonical bundle"

print "test-skill-layering: ok"
