#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/personal.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

script_path="$repo_root/scripts/personal"
required_path="$tmp_root/personal.required"
store_dir="$tmp_root/store"

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
GIT_NAME
GIT_EMAIL
AWS_PROFILE
SOURCECRAFT_PAT
EOF

unset GIT_NAME GIT_EMAIL AWS_PROFILE SOURCECRAFT_PAT
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL

personal_env=(
  PERSONAL_BACKEND=file
  PERSONAL_REQUIRED_PATH="$required_path"
  PERSONAL_STORE_DIR="$store_dir"
)

env $personal_env "$script_path" check >/dev/null 2>&1 && fail "check unexpectedly passed with missing values"

env $personal_env "$script_path" set GIT_NAME "Test User"
env $personal_env "$script_path" set GIT_EMAIL "test@example.com"
env $personal_env "$script_path" set AWS_PROFILE "test-profile"
env $personal_env "$script_path" set SOURCECRAFT_PAT "pat secret"

assert_eq "Test User" "$(env $personal_env "$script_path" get GIT_NAME)" "get GIT_NAME"
assert_eq "pat secret" "$(env $personal_env "$script_path" get SOURCECRAFT_PAT)" "get SOURCECRAFT_PAT"

env $personal_env "$script_path" check >/dev/null

exports="$(env $personal_env "$script_path" export)"
[[ "$exports" == *"export GIT_NAME="* ]] || fail "export output misses GIT_NAME"
[[ "$exports" == *"export SOURCECRAFT_PAT="* ]] || fail "export output misses SOURCECRAFT_PAT"

(
  export PERSONAL_BACKEND=file
  export PERSONAL_REQUIRED_PATH="$required_path"
  export PERSONAL_STORE_DIR="$store_dir"
  source "$script_path"
  personal_load_env

  assert_eq "Test User" "$GIT_NAME" "personal_load_env GIT_NAME"
  assert_eq "Test User" "$GIT_AUTHOR_NAME" "personal_load_env GIT_AUTHOR_NAME"
  assert_eq "test@example.com" "$GIT_COMMITTER_EMAIL" "personal_load_env GIT_COMMITTER_EMAIL"
)

env $personal_env "$script_path" unset SOURCECRAFT_PAT
env $personal_env "$script_path" check >/dev/null 2>&1 && fail "check unexpectedly passed after unset"

SOURCECRAFT_PAT="env pat" env $personal_env "$script_path" setup >/dev/null
unset SOURCECRAFT_PAT
assert_eq "env pat" "$(env $personal_env "$script_path" get SOURCECRAFT_PAT)" "setup stores env value"

print "test-personal: ok"
