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
  "$fixture_root/local-plugin-root/.codex-plugin" \
  "$fixture_root/local-plugin-root/.claude-plugin" \
  "$fixture_root/local-plugin-root/agents" \
  "$fixture_root/local-plugin-root/commands" \
  "$fixture_root/local-plugin-root/skills/presentation" \
  "$fixture_root/local-plugin-root/knowledge-notes" \
  "$fixture_root/project-kit/.claude/commands" \
  "$fixture_root/project-kit/.claude/agents" \
  "$fixture_root/project-kit/.claude/skills/design-kit" \
  "$fixture_root/agent-kit/.claude/agents" \
  "$fixture_root/agent-kit/.claude/skills/agent-skill" \
  "$fixture_root/project-kit/tokens" \
  "$fixture_root/project-kit/scripts" \
  "$fixture_root/remote-plugin-src/.codex-plugin" \
  "$fixture_root/remote-plugin-src/commands" \
  "$fixture_root/remote-plugin-src/assets" \
  "$fixture_root/scripts/lib" \
  "$fixture_root/scripts/tests" \
  "$home_dir" \
  "$bin_dir"

cp "$repo_root/scripts/install-plugins" "$fixture_root/scripts/install-plugins"
cp "$repo_root/scripts/lib/install-common.zsh" "$fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/scripts/lib/skill-acquisition.zsh" "$fixture_root/scripts/lib/skill-acquisition.zsh"

remote_src="$fixture_root/remote-plugin-src"
remote_url="file://${remote_src:A}"

cat > "$fixture_root/ai/plugins/plugins.json" <<JSON
{
  "sample": {
    "source": "example/source",
    "skills": ["alpha", "beta"]
  },
  "sample-exclude": {
    "source": "example/source-exclude",
    "skills": ["!beta"]
  },
  "presentation-craft": {
    "source": "./local-plugin-root"
  },
  "project-kit": {
    "source": "./project-kit"
  },
  "agent-kit": {
    "source": "./agent-kit"
  },
  "remote-deck": {
    "source": "$remote_url"
  },
  "broken-remote": {
    "source": "file:///nonexistent-codex-plugin-xyz/repo.git"
  }
}
JSON

cat > "$fixture_root/local-plugin-root/.codex-plugin/plugin.json" <<'JSON'
{
  "name": "presentation-craft",
  "version": "0.1.0",
  "skills": "./skills/",
  "interface": {
    "displayName": "PresentationCraft",
    "category": "Productivity"
  }
}
JSON

cat > "$fixture_root/local-plugin-root/.claude-plugin/plugin.json" <<'JSON'
{
  "name": "presentation-craft",
  "version": "0.1.0",
  "description": "Legacy Claude manifest",
  "agents": "./agents/"
}
JSON

cat > "$fixture_root/local-plugin-root/agents/reviewer.md" <<'MD'
# Reviewer
MD

cat > "$fixture_root/local-plugin-root/skills/presentation/SKILL.md" <<'MD'
# Presentation
MD

cat > "$fixture_root/local-plugin-root/commands/deck.md" <<'MD'
# Deck

Read ${CLAUDE_PLUGIN_ROOT}/knowledge-notes/shared.md.
MD

cat > "$fixture_root/local-plugin-root/knowledge-notes/shared.md" <<'MD'
# Shared
MD

cat > "$fixture_root/project-kit/.claude/commands/gate.md" <<'MD'
# Gate

Run `node scripts/check.mjs` and read `tokens/colors.json`.
MD

cat > "$fixture_root/project-kit/.claude/skills/design-kit/SKILL.md" <<'MD'
---
name: design-kit
description: Use the complete project kit.
---

# Design kit

Read `tokens/colors.json` and run `node scripts/check.mjs`.
MD

cat > "$fixture_root/project-kit/.claude/agents/reviewer.md" <<'MD'
# Reviewer
MD

cat > "$fixture_root/project-kit/tokens/colors.json" <<'JSON'
{"brand":"blue"}
JSON

cat > "$fixture_root/project-kit/scripts/check.mjs" <<'JS'
console.log('ok')
JS

cat > "$fixture_root/agent-kit/.claude/skills/agent-skill/SKILL.md" <<'MD'
---
name: agent-skill
description: Skill shipped with a Claude agent.
---

# Agent skill
MD

cat > "$fixture_root/agent-kit/.claude/agents/reviewer.md" <<'MD'
# Reviewer
MD

cat > "$remote_src/.codex-plugin/plugin.json" <<'JSON'
{
  "name": "remote-deck",
  "version": "0.2.0",
  "interface": {
    "displayName": "Remote Deck",
    "category": "Productivity"
  }
}
JSON

cat > "$remote_src/commands/remote.md" <<'MD'
# Remote
MD

cat > "$remote_src/assets/icon.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg"/>
SVG

git -C "$remote_src" init -q
git -C "$remote_src" add -A
git -C "$remote_src" -c user.email=test@example.com -c user.name=test commit -q -m init
remote_revision=$(git -C "$remote_src" rev-parse HEAD)
jq --arg source "$remote_url#$remote_revision" \
  '."remote-deck".source = $source' \
  "$fixture_root/ai/plugins/plugins.json" > "$fixture_root/ai/plugins/plugins.json.tmp"
mv "$fixture_root/ai/plugins/plugins.json.tmp" "$fixture_root/ai/plugins/plugins.json"

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

if (( ${#requested_skills[@]} == 0 )); then
  requested_skills=(alpha beta)
fi

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

assert_symlink_target() {
  local path=$1
  local target=$2
  local label=$3

  [[ -L "$path" ]] || fail "not a symlink: $label ($path)"
  [[ "${path:A}" == "${target:A}" ]] || fail "unexpected symlink target for $label: ${path:A}"
}

PATH="$bin_dir:$PATH" HOME="$home_dir" zsh "$fixture_root/scripts/install-plugins"

plugin_dir="$home_dir/.codex/plugins/dotfiles-local/sample"
excluded_plugin_dir="$home_dir/.codex/plugins/dotfiles-local/sample-exclude"
linked_plugin_dir="$home_dir/.codex/plugins/dotfiles-local/presentation-craft"
marketplace_path="$home_dir/.agents/plugins/marketplace.json"
local_plugin_root="$fixture_root/local-plugin-root"
remote_plugin_dir="$home_dir/.codex/plugins/dotfiles-local/remote-deck"
project_kit_dir="$home_dir/.codex/plugins/dotfiles-local/project-kit"
agent_kit_dir="$home_dir/.codex/plugins/dotfiles-local/agent-kit"
claude_marketplace_path="$home_dir/.agents/plugins/dotfiles-local/.claude-plugin/marketplace.json"
cursor_project_kit="$home_dir/.cursor/plugins/local/project-kit"

assert_path_exists "$plugin_dir/.codex-plugin/plugin.json" "plugin manifest"
assert_path_exists "$plugin_dir/skills/alpha/SKILL.md" "alpha skill"
assert_path_exists "$plugin_dir/skills/beta/SKILL.md" "beta skill"
assert_path_exists "$excluded_plugin_dir/skills/alpha/SKILL.md" "included skill in exclusion plugin"
assert_not_exists "$excluded_plugin_dir/skills/beta" "excluded skill in exclusion plugin"
[[ -d "$linked_plugin_dir" && ! -L "$linked_plugin_dir" ]] || fail "adapted plugin root must be a real directory"
assert_path_exists "$linked_plugin_dir/commands/deck.md" "plugin-root command"
assert_path_exists "$linked_plugin_dir/skills/presentation/SKILL.md" "plugin-root skill"
assert_path_exists "$linked_plugin_dir/knowledge-notes/shared.md" "plugin-root shared knowledge"
ugrep -Fq "$linked_plugin_dir/knowledge-notes/shared.md" "$linked_plugin_dir/commands/deck.md" \
  || fail "Claude plugin root variable was not adapted for the portable bundle"
if ugrep -Fq '${CLAUDE_PLUGIN_ROOT}' "$linked_plugin_dir/commands/deck.md"; then
  fail "Claude plugin root variable remained in the adapted command"
fi
assert_path_exists "$linked_plugin_dir/.claude-plugin/plugin.json" "preserved legacy Claude manifest"
assert_path_exists "$linked_plugin_dir/.cursor-plugin/plugin.json" "generated Cursor manifest"
assert_path_exists "$marketplace_path" "marketplace"

assert_path_exists "$project_kit_dir/.codex-plugin/plugin.json" "project-kit Codex manifest"
assert_path_exists "$project_kit_dir/.claude-plugin/plugin.json" "project-kit Claude manifest"
assert_path_exists "$project_kit_dir/.cursor-plugin/plugin.json" "project-kit Cursor manifest"
assert_path_exists "$project_kit_dir/commands/gate.md" "project-kit projected command"
assert_symlink_target "$project_kit_dir/skills" "$project_kit_dir/.claude/skills" \
  "project-kit canonical Codex skills projection"
assert_path_exists "$project_kit_dir/.claude/skills/design-kit/SKILL.md" "project-kit skill"
assert_path_exists "$project_kit_dir/.claude/agents/reviewer.md" "project-kit agent"
jq -e 'has("agents") | not' "$project_kit_dir/.claude-plugin/plugin.json" >/dev/null \
  || fail "generated Claude manifest must rely on agent autodiscovery"
jq -e '
  (.interface.longDescription | type == "string" and length > 0)
  and (.interface.defaultPrompt | type == "array" and length > 0)
' "$project_kit_dir/.codex-plugin/plugin.json" >/dev/null \
  || fail "generated Codex manifest lacks required interface metadata"
assert_path_exists "$project_kit_dir/tokens/colors.json" "project-kit tokens"
assert_path_exists "$project_kit_dir/scripts/check.mjs" "project-kit script"
assert_path_exists "$agent_kit_dir/.claude/skills/agent-skill/SKILL.md" "agent-kit skill"
assert_path_exists "$agent_kit_dir/.claude/agents/reviewer.md" "agent-kit agent"
assert_path_exists "$claude_marketplace_path" "Claude marketplace"
jq -e '.plugins[] | select(.name == "project-kit") | .source == "./plugins/project-kit"' "$claude_marketplace_path" >/dev/null
jq -e '[.plugins[].name] | index("presentation-craft") == null' "$claude_marketplace_path" >/dev/null \
  || fail "incompatible legacy Claude manifest was published"
assert_symlink_target "$cursor_project_kit" "$project_kit_dir" "Cursor project-kit projection"

jq -e '.name == "sample"' "$plugin_dir/.codex-plugin/plugin.json" >/dev/null
jq -e '.repository == "https://github.com/example/source"' "$plugin_dir/.codex-plugin/plugin.json" >/dev/null
jq -e '.plugins[0].name == "sample"' "$marketplace_path" >/dev/null
jq -e '.plugins[0].source.path == "./.codex/plugins/dotfiles-local/sample"' "$marketplace_path" >/dev/null
jq -e '.plugins[] | select(.name == "presentation-craft") | .source.path == "./.codex/plugins/dotfiles-local/presentation-craft" and .category == "Productivity"' "$marketplace_path" >/dev/null

[[ -d "$remote_plugin_dir" && ! -L "$remote_plugin_dir" ]] || fail "remote plugin must be a real directory"
assert_path_exists "$remote_plugin_dir/.codex-plugin/plugin.json" "remote plugin manifest"
assert_path_exists "$remote_plugin_dir/commands/remote.md" "remote plugin command"
assert_path_exists "$remote_plugin_dir/assets/icon.svg" "remote plugin asset"
assert_path_exists "$remote_plugin_dir/.claude-plugin/plugin.json" "remote generated Claude manifest"
assert_not_exists "$remote_plugin_dir/.git" "remote plugin .git stripped"
expected_remote_version="0.2.0+source.${remote_revision[1,12]}"
for manifest_path in \
  "$remote_plugin_dir/.codex-plugin/plugin.json" \
  "$remote_plugin_dir/.claude-plugin/plugin.json" \
  "$remote_plugin_dir/.cursor-plugin/plugin.json"; do
  [[ "$(jq -r '.version' "$manifest_path")" == "$expected_remote_version" ]] \
    || fail "pinned plugin revision missing from manifest version: $manifest_path"
done
jq -e '.plugins[] | select(.name == "remote-deck") | .source.path == "./.codex/plugins/dotfiles-local/remote-deck" and .category == "Productivity"' "$marketplace_path" >/dev/null

assert_not_exists "$home_dir/.codex/plugins/dotfiles-local/broken-remote" "broken remote plugin skipped"
jq -e '[.plugins[].name] | index("broken-remote") == null' "$marketplace_path" >/dev/null

mkdir -p "$home_dir/.codex/plugins/dotfiles-local/stale"
mkdir -p \
  "$home_dir/.codex/plugins/dotfiles-local/broken-remote/.codex-plugin" \
  "$home_dir/.codex/plugins/dotfiles-local/broken-remote/.claude-plugin" \
  "$home_dir/.codex/plugins/dotfiles-local/broken-remote/.cursor-plugin"
for client in codex claude cursor; do
  cp "$remote_plugin_dir/.$client-plugin/plugin.json" \
    "$home_dir/.codex/plugins/dotfiles-local/broken-remote/.$client-plugin/plugin.json"
done
print -r -- "previous-version" > "$home_dir/.codex/plugins/dotfiles-local/broken-remote/preserved.txt"
print -r -- "previous-spec" > "$home_dir/.codex/plugins/dotfiles-local/broken-remote/.dotfiles-spec"
mkdir -p "$excluded_plugin_dir/skills/beta"
print -r -- "# stale beta" > "$excluded_plugin_dir/skills/beta/SKILL.md"
PATH="$bin_dir:$PATH" HOME="$home_dir" zsh "$fixture_root/scripts/install-plugins"
assert_not_exists "$home_dir/.codex/plugins/dotfiles-local/stale" "stale plugin"
assert_not_exists "$excluded_plugin_dir/skills/beta" "stale excluded plugin skill"
assert_path_exists "$linked_plugin_dir/knowledge-notes/shared.md" "plugin-root bundle after resync"
ugrep -Fq "previous-version" "$home_dir/.codex/plugins/dotfiles-local/broken-remote/preserved.txt" \
  || fail "previous plugin version was overwritten after a source failure"
[[ "$(<"$home_dir/.codex/plugins/dotfiles-local/broken-remote/.dotfiles-spec")" == "previous-spec" ]] \
  || fail "failed update was recorded as the installed plugin spec"
assert_not_exists "$home_dir/.codex/plugins/dotfiles-local/broken-remote/assets" \
  "stale source reused after a source failure"

# A manual symlink at the remote plugin dir is a dev override and must survive re-install.
override_target="$fixture_root/remote-override"
mkdir -p "$override_target/.codex-plugin"
cp "$remote_src/.codex-plugin/plugin.json" "$override_target/.codex-plugin/plugin.json"
rm -rf "$remote_plugin_dir"
ln -s "$override_target" "$remote_plugin_dir"
PATH="$bin_dir:$PATH" HOME="$home_dir" zsh "$fixture_root/scripts/install-plugins"
assert_symlink_target "$remote_plugin_dir" "$override_target" "remote plugin dev override preserved"

print "test-plugin-layering: ok"
