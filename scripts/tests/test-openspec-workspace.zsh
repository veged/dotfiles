#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
workspace="$repo_root/ai/skills/openspec-development/scripts/openspec-workspace"
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/openspec-workspace.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

fail() {
  print -u2 -- "$1"
  exit 1
}

repo="$tmp_root/repo"
mkdir -p "$repo"
git -C "$repo" init -q
repo=$(cd "$repo" && pwd -P)

dir=$(cd "$repo" && "$workspace" 'add-dark-mode')
[[ "$dir" == "$repo/.superpowers/openspec/add-dark-mode" ]] \
  || fail 'неверный путь рабочей области'
ugrep -Fq 'stage: discover' "$dir/state.md" || fail 'не задана стадия discover'
ugrep -Fq 'implementation: unset' "$dir/state.md" \
  || fail 'не задано состояние реализации'
ugrep -Fq 'verified-head: none' "$dir/state.md" \
  || fail 'не задана проверенная ревизия'

print 'журнал сохраняется' >> "$dir/state.md"
again=$(cd "$repo" && "$workspace" 'add-dark-mode')
[[ "$again" == "$dir" ]] || fail 'путь рабочей области нестабилен'
ugrep -Fq 'журнал сохраняется' "$dir/state.md" \
  || fail 'повторный вызов перезаписал состояние'

race_repo="$tmp_root/race-repo"
mkdir -p "$race_repo"
git -C "$race_repo" init -q
race_repo=$(cd "$race_repo" && pwd -P)
fake_bin="$tmp_root/fake-bin"
mkdir -p "$fake_bin"
real_ln=$(command -v ln)
cat > "$fake_bin/ln" <<EOF
#!/usr/bin/env bash
printf 'журнал конкурента\\n' >> "\$2"
exec "$real_ln" "\$@"
EOF
chmod +x "$fake_bin/ln"

race_dir=$(cd "$race_repo" && PATH="$fake_bin:$PATH" "$workspace" 'add-dark-mode')
ugrep -Fq 'журнал конкурента' "$race_dir/state.md" \
  || fail 'конкурентное состояние было перезаписано'
if ugrep -Fq 'stage: discover' "$race_dir/state.md"; then
  fail 'скрипт продолжил небезопасную последовательность после гонки'
fi

for invalid_name in '../escape' 'with/slash' ''; do
  set +e
  (
    cd "$repo"
    "$workspace" "$invalid_name"
  ) >"$tmp_root/invalid.out" 2>"$tmp_root/invalid.err"
  exit_code=$?
  set -e
  [[ "$exit_code" -eq 2 ]] || fail "имя $invalid_name не отклонено кодом 2"
done

print 'test-openspec-workspace: ok'
