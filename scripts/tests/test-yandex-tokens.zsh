#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/yandex-tokens.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

script_path="$repo_root/scripts/yandex-tokens"
personal_script_path="$repo_root/scripts/personal"
required_path="$tmp_root/personal.required.yandex-tokens"
store_dir="$tmp_root/store"
home_dir="$tmp_root/home"
bin_dir="$tmp_root/bin"

mkdir -p "$home_dir" "$bin_dir"

fail() {
  print -u2 -- "$1"
  exit 1
}

assert_eq() {
  local expected=$1
  local actual=$2
  local label=$3

  [[ "$actual" == "$expected" ]] || fail "$label: expected '$expected', got '$actual'"
}

cat > "$required_path" <<'EOF'
ABT_TOKEN
ACHIEVERY_TOKEN
ARC_TOKEN
BILIM_TOKEN
CI_TOKEN
DATACATALOG_TOKEN
DATALENS_TOKEN
DEEPAGENT_TOKEN
DOCS_TOKEN
IDM_TOKEN
IDP_MCP_TOKEN
INTRASEARCH_TOKEN
LABA_TOKEN
MEETING_NOTES_TOKEN
NIRVANA_TOKEN
QUQU_TOKEN
STAFF_TOKEN
STARTREK_TOKEN
TANKER_MCP_TOKEN
TANKER_TOKEN
TARIFF_EDITOR_TOKEN
WIKI_TOKEN
YANDEX_CALENDAR_TOKEN
YANDEX_FORMS_TOKEN
YA_TOKEN
YQL_TOKEN
YT_TOKEN
YANDEX_TOKENS_MCP_STORE_CLIENT_SECRET
YANDEX_TOKENS_MULTITOOL_CLIENT_SECRET
EOF

cat > "$bin_dir/ya" <<'EOF'
#!/usr/bin/env zsh
set -euo pipefail

if (( $# >= 2 )) && [[ "$1" == "tool" && "$2" == "fetch-token" ]]; then
  shift 2
  case "$1" in
    -client-id)
      client_id=$2
      if [[ "$client_id" == "949451ff7a7c49b59fe25860d36f2187" ]]; then
        print "multi-token-secret-1234567890"
        exit 0
      fi
      if [[ "$client_id" == "ff5e570368ff4c80a70c569edffabcd9" ]]; then
        print "mcp-token-secret-1234567890"
        exit 0
      fi
      ;;
  esac
fi

if (( $# >= 2 )) && [[ "$1" == "whoami" && "$2" == "--save-token" ]]; then
  mkdir -p "$HOME"
  print -r -- "ya-file-token-1234567890" > "$HOME/.ya_token"
  exit 0
fi

exit 1
EOF
chmod +x "$bin_dir/ya"

base_env=(
  PERSONAL_BACKEND=file
  PERSONAL_PUBLISH_LAUNCHCTL=0
  PERSONAL_STORE_DIR="$store_dir"
  YANDEX_TOKENS_REQUIRED_PATH="$required_path"
  HOME="$home_dir"
  PATH="$bin_dir:$PATH"
  YANDEX_TOKENS_MCP_STORE_CLIENT_SECRET="test-mcp-client-secret-1234567890"
  YANDEX_TOKENS_MULTITOOL_CLIENT_SECRET="test-multitool-client-secret-1234567890"
)

env $base_env "$script_path" sync >/dev/null
env $base_env YANDEX_TOKENS_DATALENS_TOKEN="datalens-secret-1234567890" "$script_path" manual >/dev/null
env $base_env "$script_path" check >/dev/null

assert_eq "multi-token-secret-1234567890" "$(env $base_env "$personal_script_path" get ABT_TOKEN)" "ABT_TOKEN after sync"
assert_eq "multi-token-secret-1234567890" "$(env $base_env "$personal_script_path" get YT_TOKEN)" "YT_TOKEN after sync"
assert_eq "mcp-token-secret-1234567890" "$(env $base_env "$personal_script_path" get IDP_MCP_TOKEN)" "IDP_MCP_TOKEN after sync"
assert_eq "mcp-token-secret-1234567890" "$(env $base_env "$personal_script_path" get TANKER_MCP_TOKEN)" "TANKER_MCP_TOKEN after sync"
assert_eq "ya-file-token-1234567890" "$(env $base_env "$personal_script_path" get YA_TOKEN)" "YA_TOKEN after sync"
assert_eq "datalens-secret-1234567890" "$(env $base_env "$personal_script_path" get DATALENS_TOKEN)" "DATALENS_TOKEN after manual"

(
  export PERSONAL_BACKEND=file
  export PERSONAL_PUBLISH_LAUNCHCTL=0
  export PERSONAL_STORE_DIR="$store_dir"
  export YANDEX_TOKENS_REQUIRED_PATH="$required_path"
  export HOME="$home_dir"
  export PATH="$bin_dir:$PATH"
  source "$script_path"
  yandex_tokens_load_env

  assert_eq "multi-token-secret-1234567890" "$ABT_TOKEN" "yandex_tokens_load_env ABT_TOKEN"
  assert_eq "mcp-token-secret-1234567890" "$IDP_MCP_TOKEN" "yandex_tokens_load_env IDP_MCP_TOKEN"
  assert_eq "datalens-secret-1234567890" "$DATALENS_TOKEN" "yandex_tokens_load_env DATALENS_TOKEN"
)

env $base_env \
  ABT_TOKEN="legacy-main-token-1234567890" \
  ACHIEVERY_TOKEN="legacy-main-token-1234567890" \
  ARC_TOKEN="legacy-main-token-1234567890" \
  BILIM_TOKEN="legacy-main-token-1234567890" \
  CI_TOKEN="legacy-main-token-1234567890" \
  DATACATALOG_TOKEN="legacy-main-token-1234567890" \
  DATALENS_TOKEN="legacy-datalens-token-1234567890" \
  DEEPAGENT_TOKEN="legacy-main-token-1234567890" \
  DOCS_TOKEN="legacy-main-token-1234567890" \
  IDM_TOKEN="legacy-main-token-1234567890" \
  IDP_MCP_TOKEN="legacy-mcp-token-1234567890" \
  INTRASEARCH_TOKEN="legacy-main-token-1234567890" \
  LABA_TOKEN="legacy-main-token-1234567890" \
  MEETING_NOTES_TOKEN="legacy-main-token-1234567890" \
  NIRVANA_TOKEN="legacy-main-token-1234567890" \
  QUQU_TOKEN="legacy-main-token-1234567890" \
  STAFF_TOKEN="legacy-main-token-1234567890" \
  STARTREK_TOKEN="legacy-main-token-1234567890" \
  TANKER_MCP_TOKEN="legacy-mcp-token-1234567890" \
  TANKER_TOKEN="legacy-main-token-1234567890" \
  TARIFF_EDITOR_TOKEN="legacy-main-token-1234567890" \
  WIKI_TOKEN="legacy-main-token-1234567890" \
  YANDEX_CALENDAR_TOKEN="legacy-main-token-1234567890" \
  YANDEX_FORMS_TOKEN="legacy-main-token-1234567890" \
  YA_TOKEN="legacy-ya-token-1234567890" \
  YQL_TOKEN="legacy-main-token-1234567890" \
  YT_TOKEN="legacy-main-token-1234567890" \
  "$script_path" import-current >/dev/null

assert_eq "legacy-main-token-1234567890" "$(env $base_env "$personal_script_path" get STAFF_TOKEN)" "STAFF_TOKEN after import-current"
assert_eq "legacy-datalens-token-1234567890" "$(env $base_env "$personal_script_path" get DATALENS_TOKEN)" "DATALENS_TOKEN after import-current"
assert_eq "legacy-mcp-token-1234567890" "$(env $base_env "$personal_script_path" get TANKER_MCP_TOKEN)" "TANKER_MCP_TOKEN after import-current"
assert_eq "legacy-ya-token-1234567890" "$(env $base_env "$personal_script_path" get YA_TOKEN)" "YA_TOKEN after import-current"

print "test-yandex-tokens: ok"
