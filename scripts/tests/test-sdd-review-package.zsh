#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
review_package="$repo_root/ai/skills/subagent-driven-development/scripts/review-package"
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/sdd-review-package.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

fail() {
  print -u2 -- "$1"
  exit 1
}

assert_contains() {
  local file=$1
  local text=$2
  ugrep -Fq -- "$text" "$file" || fail "нет ожидаемого текста '$text' в $file"
}

assert_not_contains() {
  local file=$1
  local text=$2
  if ugrep -Fq -- "$text" "$file"; then
    fail "неожиданный текст '$text' найден в $file"
  fi
}

fixture="$tmp_root/repo"
mkdir -p "$fixture/dist" "$fixture/build" "$fixture/assets"
git -C "$fixture" init -q
git -C "$fixture" config user.name Test
git -C "$fixture" config user.email test@example.com

print '# План' > "$fixture/plan.md"
print 'export const value = 1' > "$fixture/app.js"
print '{"lockfileVersion": 3}' > "$fixture/package-lock.json"
print 'console.log("old")' > "$fixture/dist/app.min.js"
print 'export const generated = "old"' > "$fixture/build/generated.js"
printf '\x00\x01old-binary' > "$fixture/assets/logo.bin"
git -C "$fixture" add .
git -C "$fixture" commit -qm base
base=$(git -C "$fixture" rev-parse HEAD)

print 'export const value = 2' > "$fixture/app.js"
{
  repeat 12000 print '{"integrity":"sha512-secret-lock-content"}'
} > "$fixture/package-lock.json"
{
  repeat 8000 print 'console.log("secret-minified-content");'
} > "$fixture/dist/app.min.js"
print 'export const generated = "secret-generated-content"' \
  > "$fixture/build/generated.js"
printf '\x00\x01new-binary-secret' > "$fixture/assets/logo.bin"
git -C "$fixture" add .
git -C "$fixture" commit -qm head
head_commit=$(git -C "$fixture" rev-parse HEAD)

review_out="$tmp_root/review.diff"
(
  cd "$fixture"
  "$review_package" plan.md "$base" "$head_commit" "$review_out"
)

assert_contains "$review_out" 'export const value = 2'
assert_contains "$review_out" 'path=package-lock.json category=lock-file'
assert_contains "$review_out" 'path=dist/app.min.js category=minified'
assert_contains "$review_out" 'path=build/generated.js category=generated'
assert_contains "$review_out" 'path=assets/logo.bin category=binary'
assert_not_contains "$review_out" 'secret-lock-content'
assert_not_contains "$review_out" 'secret-minified-content'
assert_not_contains "$review_out" 'secret-generated-content'
assert_not_contains "$review_out" 'new-binary-secret'

lock_size=$(git -C "$fixture" cat-file -s "$head_commit:package-lock.json")
lock_sha_line=$(git -C "$fixture" show "$head_commit:package-lock.json" | shasum -a 256)
lock_sha=${lock_sha_line%% *}
assert_contains "$review_out" "size=${lock_size}"
assert_contains "$review_out" "sha256=${lock_sha}"

base_short=$(git -C "$fixture" rev-parse --short "$base")
head_short=$(git -C "$fixture" rev-parse --short "$head_commit")
(
  cd "$fixture"
  "$review_package" plan.md "$base" "$head_commit"
)
default_out="$fixture/.superpowers/sdd/plan/review-${base_short}..${head_short}.diff"
[[ -f "$default_out" ]] || fail 'не создан совместимый OUTFILE по умолчанию'

{
  repeat 2000 print 'export const overflow = "ordinary source must not be truncated";'
} > "$fixture/large-source.js"
git -C "$fixture" add large-source.js
git -C "$fixture" commit -qm large-source
large_head=$(git -C "$fixture" rev-parse HEAD)

set +e
(
  cd "$fixture"
  SDD_REVIEW_PACKAGE_MAX_BYTES=512 \
    "$review_package" plan.md "$head_commit" "$large_head" "$tmp_root/too-small.diff"
) 2>"$tmp_root/too-small.err"
exit_code=$?
set -e

[[ $exit_code -eq 4 ]] || fail "ожидался код 4 при переполнении, получен $exit_code"
assert_contains "$tmp_root/too-small.err" 'превышает предел 512 байт'
[[ ! -e "$tmp_root/too-small.diff" ]] \
  || fail 'после переполнения остался готовый OUTFILE'

print 'сохранить прежний пакет' > "$tmp_root/preserved.diff"
set +e
(
  cd "$fixture"
  SDD_REVIEW_PACKAGE_MAX_BYTES=512 \
    "$review_package" plan.md "$head_commit" "$large_head" "$tmp_root/preserved.diff"
) 2>"$tmp_root/preserved.err"
exit_code=$?
set -e

[[ $exit_code -eq 4 ]] \
  || fail "ожидался код 4 при повторном переполнении, получен $exit_code"
[[ "$(<"$tmp_root/preserved.diff")" == 'сохранить прежний пакет' ]] \
  || fail 'переполнение заменило существующий OUTFILE'

set +e
(
  cd "$fixture"
  SDD_REVIEW_PACKAGE_MAX_BYTES=wrong \
    "$review_package" plan.md "$base" "$head_commit" "$tmp_root/invalid.diff"
) 2>"$tmp_root/invalid.err"
exit_code=$?
set -e

[[ $exit_code -eq 2 ]] || fail "ожидался код 2 для некорректного предела, получен $exit_code"
assert_contains "$tmp_root/invalid.err" 'SDD_REVIEW_PACKAGE_MAX_BYTES'
[[ ! -e "$tmp_root/invalid.diff" ]] \
  || fail 'при некорректном пределе создан OUTFILE'

print 'test-sdd-review-package: ok'
