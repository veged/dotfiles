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
  "$fixture_root/local-plugin-root/commands" \
  "$fixture_root/local-plugin-root/skills/presentation" \
  "$fixture_root/remote-plugin-src/.codex-plugin" \
  "$fixture_root/remote-plugin-src/commands" \
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
  "presentation-craft": {
    "source": "./local-plugin-root",
    "kind": "plugin"
  },
  "remote-deck": {
    "source": "$remote_url",
    "kind": "plugin"
  },
  "broken-remote": {
    "source": "file:///nonexistent-codex-plugin-xyz/repo.git",
    "kind": "plugin"
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

cat > "$fixture_root/local-plugin-root/skills/presentation/SKILL.md" <<'MD'
# Presentation
MD

cat > "$fixture_root/local-plugin-root/commands/deck.md" <<'MD'
# Deck
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

git -C "$remote_src" init -q
git -C "$remote_src" add -A
git -C "$remote_src" -c user.email=test@example.com -c user.name=test commit -q -m init

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

assert_symlink_target() {
  local path=$1
  local target=$2
  local label=$3

  [[ -L "$path" ]] || fail "not a symlink: $label ($path)"
  [[ "${path:A}" == "${target:A}" ]] || fail "unexpected symlink target for $label: ${path:A}"
}

PATH="$bin_dir:$PATH" HOME="$home_dir" zsh "$fixture_root/scripts/install-plugins"

plugin_dir="$home_dir/.codex/plugins/dotfiles-local/sample"
linked_plugin_dir="$home_dir/.codex/plugins/dotfiles-local/presentation-craft"
linked_plugin_cache_dir="$home_dir/.codex/plugins/cache/dotfiles-local/presentation-craft/0.1.0"
marketplace_path="$home_dir/.agents/plugins/marketplace.json"
local_plugin_root="$fixture_root/local-plugin-root"
remote_plugin_dir="$home_dir/.codex/plugins/dotfiles-local/remote-deck"

assert_path_exists "$plugin_dir/.codex-plugin/plugin.json" "plugin manifest"
assert_path_exists "$plugin_dir/skills/alpha/SKILL.md" "alpha skill"
assert_path_exists "$plugin_dir/skills/beta/SKILL.md" "beta skill"
assert_symlink_target "$linked_plugin_dir" "$local_plugin_root" "plugin-root bundle"
[[ -d "$linked_plugin_cache_dir" && ! -L "$linked_plugin_cache_dir" ]] || fail "plugin-root cache must be a real directory"
assert_symlink_target "$linked_plugin_cache_dir/.codex-plugin/plugin.json" "$local_plugin_root/.codex-plugin/plugin.json" "plugin-root cache manifest"
assert_symlink_target "$linked_plugin_cache_dir/commands" "$local_plugin_root/commands" "plugin-root cache commands"
assert_symlink_target "$linked_plugin_cache_dir/skills" "$local_plugin_root/skills" "plugin-root cache skills"
assert_path_exists "$linked_plugin_dir/commands/deck.md" "plugin-root command"
assert_path_exists "$linked_plugin_dir/skills/presentation/SKILL.md" "plugin-root skill"
assert_path_exists "$marketplace_path" "marketplace"

jq -e '.name == "sample"' "$plugin_dir/.codex-plugin/plugin.json" >/dev/null
jq -e '.repository == "https://github.com/example/source"' "$plugin_dir/.codex-plugin/plugin.json" >/dev/null
jq -e '.plugins[0].name == "sample"' "$marketplace_path" >/dev/null
jq -e '.plugins[0].source.path == "./.codex/plugins/dotfiles-local/sample"' "$marketplace_path" >/dev/null
jq -e '.plugins[] | select(.name == "presentation-craft") | .source.path == "./.codex/plugins/dotfiles-local/presentation-craft" and .category == "Productivity"' "$marketplace_path" >/dev/null

[[ -d "$remote_plugin_dir" && ! -L "$remote_plugin_dir" ]] || fail "remote plugin must be a real directory"
assert_path_exists "$remote_plugin_dir/.codex-plugin/plugin.json" "remote plugin manifest"
assert_path_exists "$remote_plugin_dir/commands/remote.md" "remote plugin command"
assert_not_exists "$remote_plugin_dir/.git" "remote plugin .git stripped"
jq -e '.plugins[] | select(.name == "remote-deck") | .source.path == "./.codex/plugins/dotfiles-local/remote-deck" and .category == "Productivity"' "$marketplace_path" >/dev/null

assert_not_exists "$home_dir/.codex/plugins/dotfiles-local/broken-remote" "broken remote plugin skipped"
jq -e '[.plugins[].name] | index("broken-remote") == null' "$marketplace_path" >/dev/null

mkdir -p "$home_dir/.codex/plugins/dotfiles-local/stale"
PATH="$bin_dir:$PATH" HOME="$home_dir" zsh "$fixture_root/scripts/install-plugins"
assert_not_exists "$home_dir/.codex/plugins/dotfiles-local/stale" "stale plugin"
assert_symlink_target "$linked_plugin_dir" "$local_plugin_root" "plugin-root bundle after resync"
assert_symlink_target "$linked_plugin_cache_dir/skills" "$local_plugin_root/skills" "plugin-root cache after resync"

# A manual symlink at the remote plugin dir is a dev override and must survive re-install.
override_target="$fixture_root/remote-override"
mkdir -p "$override_target/.codex-plugin"
cp "$remote_src/.codex-plugin/plugin.json" "$override_target/.codex-plugin/plugin.json"
rm -rf "$remote_plugin_dir"
ln -s "$override_target" "$remote_plugin_dir"
PATH="$bin_dir:$PATH" HOME="$home_dir" zsh "$fixture_root/scripts/install-plugins"
assert_symlink_target "$remote_plugin_dir" "$override_target" "remote plugin dev override preserved"

print "test-plugin-layering: ok"
