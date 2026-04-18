#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/install-mcp.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT
export ELIZA_API_HOST="eliza.test.internal"

fixture_root="$tmp_root/repo"
home_dir="$tmp_root/home"
bad_fixture_root="$tmp_root/bad-repo"
bad_home_dir="$tmp_root/bad-home"
duplicate_marker_fixture_root="$tmp_root/duplicate-marker-repo"
duplicate_marker_home_dir="$tmp_root/duplicate-marker-home"
opencode_duplicate_marker_fixture_root="$tmp_root/opencode-duplicate-marker-repo"
opencode_duplicate_marker_home_dir="$tmp_root/opencode-duplicate-marker-home"

mkdir -p \
  "$fixture_root/ai" \
  "$fixture_root/claude" \
  "$fixture_root/config/opencode" \
  "$fixture_root/codex" \
  "$fixture_root/scripts/lib" \
  "$fixture_root/scripts/tests" \
  "$home_dir" \
  "$bad_fixture_root/ai" \
  "$bad_fixture_root/claude" \
  "$bad_fixture_root/config/opencode" \
  "$bad_fixture_root/codex" \
  "$bad_fixture_root/scripts/lib" \
  "$bad_fixture_root/scripts/tests" \
  "$bad_home_dir" \
  "$duplicate_marker_fixture_root/ai" \
  "$duplicate_marker_fixture_root/claude" \
  "$duplicate_marker_fixture_root/config/opencode" \
  "$duplicate_marker_fixture_root/codex" \
  "$duplicate_marker_fixture_root/scripts/lib" \
  "$duplicate_marker_fixture_root/scripts/tests" \
  "$duplicate_marker_home_dir" \
  "$opencode_duplicate_marker_fixture_root/ai" \
  "$opencode_duplicate_marker_fixture_root/claude" \
  "$opencode_duplicate_marker_fixture_root/config/opencode" \
  "$opencode_duplicate_marker_fixture_root/codex" \
  "$opencode_duplicate_marker_fixture_root/scripts/lib" \
  "$opencode_duplicate_marker_fixture_root/scripts/tests" \
  "$opencode_duplicate_marker_home_dir"

cp "$repo_root/scripts/install-mcp" "$fixture_root/scripts/install-mcp"
cp "$repo_root/scripts/lib/install-common.zsh" "$fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/ai/mcp.json" "$fixture_root/ai/mcp.json"
cp "$repo_root/claude/.settings.template.json" "$fixture_root/claude/.settings.template.json"
cp "$repo_root/config/opencode/.opencode.template.jsonc" "$fixture_root/config/opencode/.opencode.template.jsonc"
cp "$repo_root/codex/.config.template.toml" "$fixture_root/codex/.config.template.toml"
cp "$repo_root/scripts/install-mcp" "$bad_fixture_root/scripts/install-mcp"
cp "$repo_root/scripts/lib/install-common.zsh" "$bad_fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/ai/mcp.json" "$bad_fixture_root/ai/mcp.json"
cp "$repo_root/claude/.settings.template.json" "$bad_fixture_root/claude/.settings.template.json"
cp "$repo_root/config/opencode/.opencode.template.jsonc" "$bad_fixture_root/config/opencode/.opencode.template.jsonc"
cp "$repo_root/codex/.config.template.toml" "$bad_fixture_root/codex/.config.template.toml"
cp "$repo_root/scripts/install-mcp" "$duplicate_marker_fixture_root/scripts/install-mcp"
cp "$repo_root/scripts/lib/install-common.zsh" "$duplicate_marker_fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/ai/mcp.json" "$duplicate_marker_fixture_root/ai/mcp.json"
cp "$repo_root/claude/.settings.template.json" "$duplicate_marker_fixture_root/claude/.settings.template.json"
cp "$repo_root/config/opencode/.opencode.template.jsonc" "$duplicate_marker_fixture_root/config/opencode/.opencode.template.jsonc"
cp "$repo_root/codex/.config.template.toml" "$duplicate_marker_fixture_root/codex/.config.template.toml"
cp "$repo_root/scripts/install-mcp" "$opencode_duplicate_marker_fixture_root/scripts/install-mcp"
cp "$repo_root/scripts/lib/install-common.zsh" "$opencode_duplicate_marker_fixture_root/scripts/lib/install-common.zsh"
cp "$repo_root/ai/mcp.json" "$opencode_duplicate_marker_fixture_root/ai/mcp.json"
cp "$repo_root/claude/.settings.template.json" "$opencode_duplicate_marker_fixture_root/claude/.settings.template.json"
cp "$repo_root/config/opencode/.opencode.template.jsonc" "$opencode_duplicate_marker_fixture_root/config/opencode/.opencode.template.jsonc"
cp "$repo_root/codex/.config.template.toml" "$opencode_duplicate_marker_fixture_root/codex/.config.template.toml"

jq '
  .sourcecraft.clients.cursor.type = "sse"
  | .sourcecraft.clients.claude.allow_tools += ["mcp__fff__grep"]
' "$fixture_root/ai/mcp.json" > "$fixture_root/ai/mcp.json.tmp"
mv "$fixture_root/ai/mcp.json.tmp" "$fixture_root/ai/mcp.json"

jq '
  .permissions.allow =
    ["mcp__sourcecraft__GetOrganization"]
    + .permissions.allow
    + ["mcp__fff__grep"]
' "$fixture_root/claude/.settings.template.json" > "$fixture_root/claude/.settings.template.json.tmp"
mv "$fixture_root/claude/.settings.template.json.tmp" "$fixture_root/claude/.settings.template.json"

jq '.fff.install.check_path = "/tmp/fff-mcp-mismatch"' "$bad_fixture_root/ai/mcp.json" > "$bad_fixture_root/ai/mcp.json.tmp"
mv "$bad_fixture_root/ai/mcp.json.tmp" "$bad_fixture_root/ai/mcp.json"

cat >> "$duplicate_marker_fixture_root/codex/.config.template.toml" <<'EOF'

# __MCP_SERVERS__
EOF

cat >> "$opencode_duplicate_marker_fixture_root/config/opencode/.opencode.template.jsonc" <<'EOF'
"mcp": __MCP_JSON__
EOF

cursor_manifest_path="$home_dir/.cursor/mcp.json"
claude_settings_path="$home_dir/.claude/settings.json"
codex_config_path="$home_dir/.codex/config.toml"
opencode_config_path="$home_dir/.config/opencode/opencode.jsonc"
fixture_runtime_path="$home_dir/.local/bin/fff-mcp"

HOME="$home_dir" zsh "$fixture_root/scripts/install-mcp" --sync-only

fail() {
  print -u2 -- "$1"
  exit 1
}

install_conf_path="$repo_root/install.conf.yaml"

[[ -f "$install_conf_path" ]] || fail "missing install.conf.yaml"
grep -Fq './scripts/install-mcp' "$install_conf_path" || fail "install.conf.yaml does not invoke ./scripts/install-mcp"
grep -Fq '~/.config/opencode/:' "$install_conf_path" || fail "install.conf.yaml must link ~/.config/opencode/ explicitly"
grep -Fq 'exclude: [config/opencode]' "$install_conf_path" || fail "install.conf.yaml must exclude config/opencode from the ~/.config/ glob"
if grep -Fq '~/.codex/config.toml:' "$install_conf_path"; then
  fail "install.conf.yaml must not link ~/.codex/config.toml directly"
fi
if grep -Fq '~/.cursor/mcp.json:' "$install_conf_path"; then
  fail "install.conf.yaml must not link ~/.cursor/mcp.json directly"
fi
[[ ! -e "$repo_root/cursor/mcp.json" ]] || fail "cursor/mcp.json must not remain as a committed source file"

[[ -f "$cursor_manifest_path" ]] || fail "missing generated cursor manifest: $cursor_manifest_path"
[[ -f "$claude_settings_path" ]] || fail "missing generated claude settings: $claude_settings_path"
[[ -f "$codex_config_path" ]] || fail "missing generated codex config: $codex_config_path"
[[ -f "$opencode_config_path" ]] || fail "missing generated opencode config: $opencode_config_path"

expected_claude_mcp_tools="$(
  jq -c '
    reduce (
      to_entries[]
      | select(.value.enabled)
      | (((.value.clients // {} | .claude // {} | .allow_tools) // [])[])
    ) as $item (
      [];
      if index($item) then
        .
      else
        . + [$item]
      end
    )
  ' "$fixture_root/ai/mcp.json"
)"

actual_claude_mcp_tools="$(
  jq -c '
    [.permissions.allow[] | select(type == "string" and startswith("mcp__"))]
  ' "$claude_settings_path"
)"

jq -e . "$claude_settings_path" >/dev/null || fail "generated claude settings must be valid JSON"
jq -e . "$opencode_config_path" >/dev/null || fail "generated opencode config must be valid JSON"
[[ "$(jq -r '.enabledPlugins["superpowers@claude-plugins-official"]' "$claude_settings_path")" == "true" ]] || fail "missing preserved claude plugin"
[[ "$(jq -r '.extraKnownMarketplaces["visual-explainer-marketplace"].source.repo' "$claude_settings_path")" == "nicobailon/visual-explainer" ]] || fail "missing preserved claude marketplace"
[[ "$(jq -r '.permissions.additionalDirectories[0]' "$claude_settings_path")" == "/private/tmp" ]] || fail "missing preserved claude additional directory"
[[ "$(jq -r '.permissions.allow[]' "$claude_settings_path" | grep -Fx 'Bash(ugrep:*)')" == 'Bash(ugrep:*)' ]] || fail "missing preserved non-MCP claude permission"
[[ "$actual_claude_mcp_tools" == "$expected_claude_mcp_tools" ]] || fail "unexpected claude MCP permission set"
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
[[ "$(jq -c '.plugin' "$opencode_config_path")" == '["oh-my-openagent"]' ]] || fail "unexpected opencode plugin section"
[[ "$(jq -r '.mcp.sourcecraft.type' "$opencode_config_path")" == "remote" ]] || fail "unexpected opencode sourcecraft type"
[[ "$(jq -r '.mcp.sourcecraft.url' "$opencode_config_path")" == "https://api.sourcecraft.tech/mcp" ]] || fail "unexpected opencode sourcecraft url"
[[ "$(jq -r '.mcp.sourcecraft.headers.Authorization' "$opencode_config_path")" == 'Bearer {env:SOURCECRAFT_PAT}' ]] || fail "unexpected opencode sourcecraft auth header"
[[ "$(jq -r '.mcp.sourcecraft.timeout' "$opencode_config_path")" == "60000" ]] || fail "unexpected opencode sourcecraft timeout"
initial_opencode_baseurl="$(jq -r '.provider["eliza-anthropic"].options.baseURL' "$opencode_config_path")"
[[ "$initial_opencode_baseurl" != *"ELIZA_API_HOST"* ]] || fail "unexpected opencode eliza anthropic baseURL"
[[ "$(jq -r '.mcp.fff.type' "$opencode_config_path")" == "local" ]] || fail "unexpected opencode fff type"
[[ "$(jq -r '.mcp.fff.enabled' "$opencode_config_path")" == "true" ]] || fail "unexpected opencode fff enabled flag"
[[ "$(jq -r '.mcp.fff.command[0]' "$opencode_config_path")" == "/Users/veged/.local/bin/fff-mcp" ]] || fail "unexpected opencode fff command"
[[ "$(jq -r '.mcp.fff.command | length' "$opencode_config_path")" == "1" ]] || fail "unexpected opencode fff command length"
[[ "$(jq -r '.mcp.playwright.type' "$opencode_config_path")" == "local" ]] || fail "unexpected opencode playwright type"
[[ "$(jq -r '.mcp.playwright.command[2]' "$opencode_config_path")" == "@playwright/mcp@latest" ]] || fail "unexpected opencode playwright command"
if grep -Fq 'ELIZA_API_HOST' "$opencode_config_path"; then
  fail "opencode ELIZA_API_HOST placeholder leaked into generated config"
fi
if grep -Fq '__MCP_JSON__' "$opencode_config_path"; then
  fail "opencode marker leaked into generated config"
fi

if HOME="$bad_home_dir" zsh "$bad_fixture_root/scripts/install-mcp" --sync-only >/dev/null 2>&1; then
  fail "expected install-mcp to reject mismatched fff install.check_path"
fi

if HOME="$duplicate_marker_home_dir" zsh "$duplicate_marker_fixture_root/scripts/install-mcp" --sync-only >/dev/null 2>&1; then
  fail "expected install-mcp to reject duplicate codex marker"
fi

if HOME="$opencode_duplicate_marker_home_dir" zsh "$opencode_duplicate_marker_fixture_root/scripts/install-mcp" --sync-only >/dev/null 2>&1; then
  fail "expected install-mcp to reject duplicate opencode marker"
fi
sd -s '"plugin": ["oh-my-openagent"]' '"plugin": ["changed-plugin"]' "$fixture_root/config/opencode/.opencode.template.jsonc"
expected_opencode_baseurl="$(jq -r '.provider["eliza-anthropic"].options.baseURL' "$opencode_config_path")"
env -u ELIZA_API_HOST HOME="$home_dir" zsh "$fixture_root/scripts/install-mcp" --sync-only >/dev/null 2>&1 || fail "--sync-only must not fail when ELIZA_API_HOST is unset"
[[ "$(jq -r '.provider["eliza-anthropic"].options.baseURL' "$opencode_config_path")" == "$expected_opencode_baseurl" ]] || fail "--sync-only must preserve resolved opencode baseURL when ELIZA_API_HOST is unset"
[[ "$(jq -c '.plugin' "$opencode_config_path")" == '["changed-plugin"]' ]] || fail "--sync-only must still propagate non-MCP opencode template changes when ELIZA_API_HOST is unset"
env -u ELIZA_API_HOST HOME="$home_dir" zsh "$fixture_root/scripts/install-mcp" --check >/dev/null 2>&1 || fail "--check must not report drift when ELIZA_API_HOST is unset"

expected_opencode_baseurl="$initial_opencode_baseurl"

jq \
  --arg fixture_runtime_path "$fixture_runtime_path" \
  '
    .fff.command = $fixture_runtime_path
    | .fff.install.check_path = $fixture_runtime_path
    | .fff.install.argv = [
        "/bin/sh",
        "-lc",
        "mkdir -p \"$HOME/.local/bin\" && printf \"#!/bin/sh\\necho fff\\n\" > \"$HOME/.local/bin/fff-mcp\" && chmod +x \"$HOME/.local/bin/fff-mcp\""
      ]
    | .playwright.enabled = true
    | .playwright.command = "zsh"
    | .playwright.args = []
  ' "$fixture_root/ai/mcp.json" > "$fixture_root/ai/mcp.json.tmp"
mv "$fixture_root/ai/mcp.json.tmp" "$fixture_root/ai/mcp.json"

HOME="$home_dir" zsh "$fixture_root/scripts/install-mcp" --sync-only

rm -f "$fixture_runtime_path"
HOME="$home_dir" zsh "$fixture_root/scripts/install-mcp" --tools-only
[[ -x "$fixture_runtime_path" ]] || fail "fff runtime was not installed by --tools-only"

rm -f "$fixture_runtime_path"
jq '.mcpServers.fff.command = "/tmp/default-mode-drift"' "$cursor_manifest_path" > "$cursor_manifest_path.tmp"
mv "$cursor_manifest_path.tmp" "$cursor_manifest_path"
HOME="$home_dir" zsh "$fixture_root/scripts/install-mcp"
[[ -x "$fixture_runtime_path" ]] || fail "fff runtime was not installed by default mode"
[[ "$(jq -r '.mcpServers.fff.command' "$cursor_manifest_path")" == "$fixture_runtime_path" ]] || fail "default mode did not resync generated files"

HOME="$home_dir" zsh "$fixture_root/scripts/install-mcp" --check

jq '.mcpServers.fff.command = "/tmp/drifted-fff"' "$cursor_manifest_path" > "$cursor_manifest_path.tmp"
mv "$cursor_manifest_path.tmp" "$cursor_manifest_path"

if HOME="$home_dir" zsh "$fixture_root/scripts/install-mcp" --check >/dev/null 2>&1; then
  fail "--check unexpectedly passed with drifted generated files"
fi

HOME="$home_dir" zsh "$fixture_root/scripts/install-mcp" --sync-only
rm -f "$fixture_runtime_path"

if HOME="$home_dir" zsh "$fixture_root/scripts/install-mcp" --check >/dev/null 2>&1; then
  fail "--check unexpectedly passed without fff runtime"
fi

print "test-install-mcp: install, check, and sync ok"
