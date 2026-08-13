#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
instructions="$repo_root/ai/instructions/worktrees.md"
start_skill="$repo_root/ai/skills/using-git-worktrees/SKILL.md"
finish_skill="$repo_root/ai/skills/finishing-a-development-branch/SKILL.md"
sdd_skill="$repo_root/ai/skills/subagent-driven-development/SKILL.md"
registry="$repo_root/ai/skills/skills.json"

fail() {
  print -u2 -- "$1"
  exit 1
}

assert_contains() {
  local file=$1
  local phrase=$2
  local scenario=$3

  ugrep -Fq -- "$phrase" "$file" \
    || fail "не описан сценарий «$scenario»: $phrase ($file)"
}

assert_not_contains() {
  local file=$1
  local phrase=$2
  local scenario=$3

  if ugrep -Fq -- "$phrase" "$file"; then
    fail "нарушен сценарий «$scenario»: найдено $phrase ($file)"
  fi
}

assert_ordered() {
  local file=$1
  local scenario=$2
  local phrase hit line
  local previous=0
  shift 2

  for phrase in "$@"; do
    hit=$(ugrep -n -m1 -F -- "$phrase" "$file") \
      || fail "не описан шаг сценария «$scenario»: $phrase ($file)"
    line=${hit%%:*}
    (( line > previous )) \
      || fail "нарушен порядок сценария «$scenario»: $phrase ($file)"
    previous=$line
  done
}

for file in "$instructions" "$start_skill" "$finish_skill" "$sdd_skill" "$registry"; do
  [[ -f "$file" ]] || fail "нет долговечного источника: $file"
done

# Исходный сценарий 1: обычная и последовательная работа остаётся в текущей области.
assert_contains "$instructions" 'Обычная однопоточная работа начинается в текущей рабочей области' \
  'один пишущий исполнитель'
assert_contains "$sdd_skill" 'Последовательные пишущие исполнители' \
  'последовательные исполнители'
assert_contains "$sdd_skill" 'Текущая рабочая область' \
  'последовательные исполнители'

# Исходный сценарий 2: конкурентная запись изолирована, чтение снимка — нет.
assert_contains "$instructions" 'Параллельные пишущие исполнители' \
  'параллельные пишущие исполнители'
assert_contains "$instructions" 'отдельную ветку и отдельный worktree' \
  'параллельные пишущие исполнители'
assert_contains "$instructions" 'Читающие проверяющие одного неизменяемого снимка' \
  'параллельные читающие проверяющие'
assert_contains "$sdd_skill" 'отдельной рабочей области' \
  'параллельные пишущие исполнители'

# Исходный сценарий 3: изоляция создаётся предсказуемо и не даёт прав на интеграцию.
assert_contains "$start_skill" 'автоматически из задачи' \
  'автоматическое имя ветки и пути'
assert_contains "$start_skill" 'Выбор рабочей области не разрешает' \
  'раздельные шлюзы рабочей области и интеграции'
assert_contains "$start_skill" 'техническая контрольная точка' \
  'обязательная промежуточная фиксация'

# Исходный сценарий 4: завершение без отдельной ветки не предлагает фиктивное слияние.
assert_contains "$finish_skill" 'Работа без отдельной ветки' \
  'завершение в текущей ветке'
assert_contains "$finish_skill" 'Создать ветку из текущих изменений' \
  'Pull Request после работы без отдельной ветки'

# Исходный сценарий 5: именованная ветка различает локальное слияние и слияние с `push` базовой ветки.
assert_contains "$finish_skill" 'Слить локально в' \
  'локальное слияние именованной ветки'
assert_contains "$finish_skill" 'слить локально в' \
  'локальное слияние с отправкой базовой ветки'
assert_contains "$finish_skill" 'отправить базовую ветку' \
  'локальное слияние с отправкой базовой ветки'

# Исходный сценарий 6: отказ `push` сохраняет все пути восстановления.
assert_contains "$finish_skill" 'При отказавшем `push`' \
  'отказ отправки'
assert_contains "$finish_skill" 'сохрани ветку и worktree' \
  'отказ отправки'
assert_contains "$finish_skill" 'git push --force' \
  'запрет автоматической принудительной отправки'

# Исходный сценарий 7: техническая ветка возвращается на базовую в той же области.
assert_ordered "$finish_skill" 'техническая ветка и локальное слияние' \
  'Для технической ветки, созданной текущим процессом в обычной рабочей области' \
  'git switch <базовая_ветка>' \
  'git merge <рабочая_ветка>' \
  'оставь эту рабочую область на базовой ветке'

# Исходный сценарий 8: очистка не затрагивает ранее существовавшие объекты.
assert_not_contains "$finish_skill" 'git worktree prune' \
  'сохранение посторонних записей worktree'
assert_contains "$finish_skill" 'Не удаляй ветку, если процесс не записал её как созданную им' \
  'сохранение ранее существовавшей ветки'
assert_contains "$finish_skill" 'Ранее существовавшие ветки и worktree сохраняются' \
  'сохранение ранее существовавших объектов'

# Исходный сценарий 9: Superpowers больше не управляет двумя локальными навыками.
jq -e '
  [to_entries[] | select(.key | startswith("obra/superpowers#")) | .value][0] as $skills
  | ($skills | index("!using-git-worktrees") != null)
    and ($skills | index("!finishing-a-development-branch") != null)
' "$registry" >/dev/null \
  || fail 'локальные Git-навыки не исключены из obra/superpowers'

print 'test-git-workspace-policy: ok'
