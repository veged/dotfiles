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
duplicate_marker_fixture_root="$tmp_root/duplicate-marker-repo"
duplicate_marker_home_dir="$tmp_root/duplicate-marker-home"

mkdir -p \
  "$fixture_root/ai" \
  "$fixture_root/config/opencode" \
  "$fixture_root/codex" \
  "$fixture_root/scripts/lib" \
  "$fixture_root/scripts/tests" \
  "$home_dir" \
  "$bad_fixture_root/ai" \
  "$bad_fixture_root/codex" \
  "$bad_fixture_root/scripts/lib" \
  "$bad_fixture_root/scripts/tests" \
  "$bad_home_dir" \
  "$duplicate_marker_fixture_root/ai" \
  "$duplicate_marker_fixture_root/codex" \
  "$duplicate_marker_fixture_root/scripts/lib" \
  "$duplicate_marker_fixture_root/scripts/tests" \
  "$duplicate_marker_home_dir"

cp "$repo_root/scripts/install-mcp" "$fixture_root/scripts/install-mcp"
cp "$repo_root/scripts/lib/install-common.zsh" "$fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/ai/mcp.json" "$fixture_root/ai/mcp.json"
cp "$repo_root/config/opencode/.opencode.template.jsonc" "$fixture_root/config/opencode/.opencode.template.jsonc"
cp "$repo_root/codex/.config.template.toml" "$fixture_root/codex/.config.template.toml"
cp "$repo_root/scripts/install-mcp" "$bad_fixture_root/scripts/install-mcp"
cp "$repo_root/scripts/lib/install-common.zsh" "$bad_fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/ai/mcp.json" "$bad_fixture_root/ai/mcp.json"
cp "$repo_root/codex/.config.template.toml" "$bad_fixture_root/codex/.config.template.toml"
cp "$repo_root/scripts/install-mcp" "$duplicate_marker_fixture_root/scripts/install-mcp"
cp "$repo_root/scripts/lib/install-common.zsh" "$duplicate_marker_fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/ai/mcp.json" "$duplicate_marker_fixture_root/ai/mcp.json"
cp "$repo_root/codex/.config.template.toml" "$duplicate_marker_fixture_root/codex/.config.template.toml"

jq '.sourcecraft.clients.cursor.type = "sse"' "$fixture_root/ai/mcp.json" > "$fixture_root/ai/mcp.json.tmp"
mv "$fixture_root/ai/mcp.json.tmp" "$fixture_root/ai/mcp.json"

jq '.fff.install.check_path = "/tmp/fff-mcp-mismatch"' "$bad_fixture_root/ai/mcp.json" > "$bad_fixture_root/ai/mcp.json.tmp"
mv "$bad_fixture_root/ai/mcp.json.tmp" "$bad_fixture_root/ai/mcp.json"

cat >> "$duplicate_marker_fixture_root/codex/.config.template.toml" <<'EOF'

# __MCP_SERVERS__
EOF

cursor_manifest_path="$home_dir/.cursor/mcp.json"
codex_config_path="$home_dir/.codex/config.toml"
opencode_config_path="$home_dir/.config/opencode/opencode.jsonc"

HOME="$home_dir" zsh "$fixture_root/scripts/install-mcp" --sync-only

fail() {
  print -u2 "$1"
  exit 1
}

[[ -f "$cursor_manifest_path" ]] || fail "missing generated cursor manifest: $cursor_manifest_path"
[[ -f "$codex_config_path" ]] || fail "missing generated codex config: $codex_config_path"
[[ -f "$opencode_config_path" ]] || fail "missing generated opencode config: $opencode_config_path"
[[ "$(jq -r '.mcpServers.fff.command' "$cursor_manifest_path")" == "/Users/veged/.local/bin/fff-mcp" ]] || fail "unexpected fff command"
[[ "$(jq -r '.mcpServers.context7.disabled' "$cursor_manifest_path")" == "true" ]] || fail "context7 must be disabled"
[[ "$(jq -r '.mcpServers.playwright.disabled' "$cursor_manifest_path")" == "true" ]] || fail "playwright must be disabled"
[[ "$(jq -r '.mcpServers.sourcecraft.url' "$cursor_manifest_path")" == "https://api.sourcecraft.tech/mcp" ]] || fail "unexpected sourcecraft url"
[[ "$(jq -r '.mcpServers.sourcecraft.type' "$cursor_manifest_path")" == "sse" ]] || fail "unexpected sourcecraft type"
[[ "$(jq -r '.mcpServers.sourcecraft.headers.Authorization' "$cursor_manifest_path")" == 'Bearer ${env:SOURCECRAFT_PAT}' ]] || fail "unexpected sourcecraft auth header"
grep -Fq 'personality = "pragmatic"' "$codex_config_path" || fail "missing codex personality"
grep -Fq '[mcp_servers.fff]' "$codex_config_path" || fail "missing fff codex block"
grep -Fq 'command = "/Users/veged/.local/bin/fff-mcp"' "$codex_config_path" || fail "missing fff codex command"
grep -Fq '[mcp_servers.sourcecraft]' "$codex_config_path" || fail "missing sourcecraft codex block"
grep -Fq 'bearer_token_env_var = "SOURCECRAFT_PAT"' "$codex_config_path" || fail "missing sourcecraft bearer token env"
grep -Fq '[mcp_servers.sourcecraft.tools.GetCubeLogs]' "$codex_config_path" || fail "missing sourcecraft tool approvals"
awk '
  $0 == "[mcp_servers.sourcecraft.tools.GetCubeLogs]" { in_block = 1; next }
  /^\[/ && in_block { exit !found }
  in_block && $0 == "approval_mode = \"approve\"" { found = 1 }
  END { exit !(in_block && found) }
' "$codex_config_path" || fail "missing GetCubeLogs approval mode in codex output"
if grep -Fq '[mcp_servers.context7]' "$codex_config_path"; then
  fail "context7 must be absent from codex output"
fi
if grep -Fq '[mcp_servers.playwright]' "$codex_config_path"; then
  fail "playwright must be absent from codex output"
fi
grep -Fq '"plugin": ["oh-my-openagent"]' "$opencode_config_path" || fail "missing opencode plugin section"
grep -Fq '"sourcecraft"' "$opencode_config_path" || fail "missing sourcecraft in opencode output"
grep -Fq '"fff"' "$opencode_config_path" || fail "missing fff in opencode output"
grep -Fq '"type": "remote"' "$opencode_config_path" || fail "missing remote type in opencode output"
grep -Fq '"type": "local"' "$opencode_config_path" || fail "missing local type in opencode output"
grep -Fq '"command": [' "$opencode_config_path" || fail "missing opencode local command array"
grep -Fq '"Authorization": "Bearer {env:SOURCECRAFT_PAT}"' "$opencode_config_path" || fail "missing sourcecraft auth header in opencode output"
grep -Fq '"timeout": 60000' "$opencode_config_path" || fail "missing sourcecraft timeout in opencode output"
grep -Fq '"/Users/veged/.local/bin/fff-mcp"' "$opencode_config_path" || fail "missing fff command in opencode output"

if HOME="$bad_home_dir" zsh "$bad_fixture_root/scripts/install-mcp" --sync-only >/dev/null 2>&1; then
  fail "expected install-mcp to reject mismatched fff install.check_path"
fi

if HOME="$duplicate_marker_home_dir" zsh "$duplicate_marker_fixture_root/scripts/install-mcp" --sync-only >/dev/null 2>&1; then
  fail "expected install-mcp to reject duplicate codex marker"
fi

print "test-install-mcp: cursor, codex, and opencode sync ok"
