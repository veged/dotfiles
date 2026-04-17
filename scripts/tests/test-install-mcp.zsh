#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/install-mcp.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

fixture_root="$tmp_root/repo"
home_dir="$tmp_root/home"
bad_fixture_root="$tmp_root/bad-repo"
bad_home_dir="$tmp_root/bad-home"

mkdir -p \
  "$fixture_root/ai" \
  "$fixture_root/scripts/lib" \
  "$fixture_root/scripts/tests" \
  "$home_dir" \
  "$bad_fixture_root/ai" \
  "$bad_fixture_root/scripts/lib" \
  "$bad_fixture_root/scripts/tests" \
  "$bad_home_dir"

cp "$repo_root/scripts/install-mcp" "$fixture_root/scripts/install-mcp"
cp "$repo_root/scripts/lib/install-common.zsh" "$fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/ai/mcp.json" "$fixture_root/ai/mcp.json"
cp "$repo_root/scripts/install-mcp" "$bad_fixture_root/scripts/install-mcp"
cp "$repo_root/scripts/lib/install-common.zsh" "$bad_fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/ai/mcp.json" "$bad_fixture_root/ai/mcp.json"

jq '.sourcecraft.clients.cursor.type = "sse"' "$fixture_root/ai/mcp.json" > "$fixture_root/ai/mcp.json.tmp"
mv "$fixture_root/ai/mcp.json.tmp" "$fixture_root/ai/mcp.json"

jq '.fff.install.check_path = "/tmp/fff-mcp-mismatch"' "$bad_fixture_root/ai/mcp.json" > "$bad_fixture_root/ai/mcp.json.tmp"
mv "$bad_fixture_root/ai/mcp.json.tmp" "$bad_fixture_root/ai/mcp.json"

cursor_manifest_path="$home_dir/.cursor/mcp.json"

HOME="$home_dir" zsh "$fixture_root/scripts/install-mcp" --sync-only

fail() {
  print -u2 "$1"
  exit 1
}

[[ -f "$cursor_manifest_path" ]] || fail "missing generated cursor manifest: $cursor_manifest_path"
[[ "$(jq -r '.mcpServers.fff.command' "$cursor_manifest_path")" == "/Users/veged/.local/bin/fff-mcp" ]] || fail "unexpected fff command"
[[ "$(jq -r '.mcpServers.context7.disabled' "$cursor_manifest_path")" == "true" ]] || fail "context7 must be disabled"
[[ "$(jq -r '.mcpServers.playwright.disabled' "$cursor_manifest_path")" == "true" ]] || fail "playwright must be disabled"
[[ "$(jq -r '.mcpServers.sourcecraft.url' "$cursor_manifest_path")" == "https://api.sourcecraft.tech/mcp" ]] || fail "unexpected sourcecraft url"
[[ "$(jq -r '.mcpServers.sourcecraft.type' "$cursor_manifest_path")" == "sse" ]] || fail "unexpected sourcecraft type"
[[ "$(jq -r '.mcpServers.sourcecraft.headers.Authorization' "$cursor_manifest_path")" == 'Bearer ${env:SOURCECRAFT_PAT}' ]] || fail "unexpected sourcecraft auth header"

if HOME="$bad_home_dir" zsh "$bad_fixture_root/scripts/install-mcp" --sync-only >/dev/null 2>&1; then
  fail "expected install-mcp to reject mismatched fff install.check_path"
fi

print "test-install-mcp: cursor sync ok"
