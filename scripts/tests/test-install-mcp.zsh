#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/install-mcp.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

fixture_root="$tmp_root/repo"
home_dir="$tmp_root/home"

mkdir -p \
  "$fixture_root/ai" \
  "$fixture_root/scripts/lib" \
  "$fixture_root/scripts/tests" \
  "$home_dir"

cp "$repo_root/scripts/install-mcp" "$fixture_root/scripts/install-mcp"
cp "$repo_root/scripts/lib/install-common.zsh" "$fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/ai/mcp.json" "$fixture_root/ai/mcp.json"

cursor_manifest_path="$home_dir/.cursor/mcp.json"

HOME="$home_dir" zsh "$fixture_root/scripts/install-mcp" --sync-only

fail() {
  print -u2 "$1"
  exit 1
}

[[ -f "$cursor_manifest_path" ]] || fail "missing generated cursor manifest: $cursor_manifest_path"
[[ "$(jq -r '.mcpServers.fff.command' "$cursor_manifest_path")" == "/Users/veged/.local/bin/fff-mcp" ]] || fail "unexpected fff command"
[[ "$(jq -r '.mcpServers.sourcecraft.url' "$cursor_manifest_path")" == "https://api.sourcecraft.tech/mcp" ]] || fail "unexpected sourcecraft url"
[[ "$(jq -r '.mcpServers.sourcecraft.headers.Authorization' "$cursor_manifest_path")" == 'Bearer ${env:SOURCECRAFT_PAT}' ]] || fail "unexpected sourcecraft auth header"

print "test-install-mcp: cursor sync ok"
