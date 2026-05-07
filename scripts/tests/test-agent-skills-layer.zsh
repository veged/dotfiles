#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/agent-skills-layer.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

home_dir="$tmp_root/home"

mkdir -p \
  "$home_dir/.agents/skills" \
  "$home_dir/.claude/skills" \
  "$home_dir/.codex/skills"

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

HOME="$home_dir" source "$repo_root/scripts/lib/agent-skills-layer.zsh"

mkdir -p "$home_dir/.agents/skills/local-one"
print -r -- "# local-one" > "$home_dir/.agents/skills/local-one/SKILL.md"

mkdir -p "$home_dir/.codex/skills/codex-primary-runtime/slides"
print -r -- "# slides" > "$home_dir/.codex/skills/codex-primary-runtime/slides/SKILL.md"

mkdir -p "$home_dir/.codex/skills/unmanaged"
print -r -- "keep" > "$home_dir/.codex/skills/unmanaged/value.txt"

mkdir -p "$home_dir/.claude/skills/local-one"
print -r -- "# local-one" > "$home_dir/.claude/skills/local-one/SKILL.md"

ln -s "$home_dir/.agents/skills/missing" "$home_dir/.claude/skills/stale"

typeset -Ua managed_names
managed_names=(local-one)

agent_skills_append_preserved_bundles managed_names

[[ " ${managed_names[*]} " == *" codex-primary-runtime "* ]] || fail "preserved bundle was not appended"

agent_skills_reconcile_layer

assert_path_exists "$home_dir/.agents/skills/codex-primary-runtime/slides/SKILL.md" "migrated shared bundle"
assert_symlink_target "$home_dir/.claude/skills/local-one" "$home_dir/.agents/skills/local-one" "claude local projection"
assert_symlink_target "$home_dir/.codex/skills/local-one" "$home_dir/.agents/skills/local-one" "codex local projection"
assert_symlink_target "$home_dir/.codex/skills/codex-primary-runtime" "$home_dir/.agents/skills/codex-primary-runtime" "codex shared bundle projection"
assert_path_exists "$home_dir/.codex/skills/unmanaged/value.txt" "unmanaged codex entry"
assert_not_exists "$home_dir/.claude/skills/stale" "stale claude projection"

agent_skills_reconcile_layer

assert_symlink_target "$home_dir/.claude/skills/local-one" "$home_dir/.agents/skills/local-one" "idempotent claude local projection"
assert_symlink_target "$home_dir/.codex/skills/codex-primary-runtime" "$home_dir/.agents/skills/codex-primary-runtime" "idempotent codex shared projection"

print "test-agent-skills-layer: ok"
