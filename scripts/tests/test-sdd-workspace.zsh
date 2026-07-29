#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
workspace="$repo_root/ai/skills/subagent-driven-development/scripts/sdd-workspace"
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/sdd-workspace.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

fail() {
  print -u2 -- "$1"
  exit 1
}

repo="$tmp_root/repo"
mkdir -p "$repo/docs/a" "$repo/docs/b" "$repo/docs/с пробелом"
git -C "$repo" init -q
print '# План A' > "$repo/docs/a/tasks.md"
print '# План B' > "$repo/docs/b/tasks.md"
print '# План с пробелом' > "$repo/docs/с пробелом/tasks.md"
ln -s tasks.md "$repo/docs/a/тот-же-план.md"
outside_plan="$tmp_root/внешний-план.md"
print '# Внешний план' > "$outside_plan"
ln -s "$outside_plan" "$repo/docs/a/внешняя-ссылка.md"

first=$(cd "$repo" && "$workspace" docs/a/tasks.md)
first_again=$(cd "$repo" && "$workspace" docs/a/tasks.md)
second=$(cd "$repo" && "$workspace" docs/b/tasks.md)
spaced=$(cd "$repo" && "$workspace" 'docs/с пробелом/tasks.md')
same_plan=$(cd "$repo" && "$workspace" docs/a/тот-же-план.md)

set +e
(
  cd "$repo"
  "$workspace" docs/a/внешняя-ссылка.md
) >"$tmp_root/outside.out" 2>"$tmp_root/outside.err"
outside_status=$?
set -e

[[ "$first" == "$first_again" ]] || fail 'путь рабочей области нестабилен'
[[ "$first" != "$second" ]] || fail 'одноимённые планы столкнулись'
[[ "$second" != "$spaced" ]] || fail 'план с пробелом столкнулся с другим планом'
[[ "$first" == "$same_plan" ]] || fail 'внутренняя ссылка создала другую рабочую область'
[[ "$outside_status" -eq 2 ]] || fail 'внешняя ссылка не отклонена'
ugrep -Fq 'вне корня Git' "$tmp_root/outside.err" \
  || fail 'нет диагностики внешней ссылки'
[[ "$first" == /* ]] || fail 'путь рабочей области не абсолютный'
[[ -f "$repo/.superpowers/sdd/.gitignore" ]] || fail 'нет .gitignore'
print '*' > "$tmp_root/expected-gitignore"
cmp -s "$tmp_root/expected-gitignore" "$repo/.superpowers/sdd/.gitignore" \
  || fail 'некорректное содержимое .gitignore'
[[ "${first:t}" =~ '^tasks-[[:xdigit:]]{8}$' ]] \
  || fail 'путь не содержит tasks- и восьмисимвольный хеш'

print 'test-sdd-workspace: ok'
