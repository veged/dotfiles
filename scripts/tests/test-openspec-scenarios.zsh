#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
orchestrate="$repo_root/ai/skills/openspec-development/scripts/openspec-orchestrate"
workspace="$repo_root/ai/skills/openspec-development/scripts/openspec-workspace"
task_brief="$repo_root/ai/skills/openspec-development/scripts/openspec-task-brief"
sdd_workspace="$repo_root/ai/skills/subagent-driven-development/scripts/sdd-workspace"
fixture_dir="$repo_root/scripts/tests/fixtures/openspec-orchestration"
fake_openspec="$fixture_dir/fake-openspec"

fail() {
  print -u2 -- "$1"
  exit 1
}

[[ -x "$orchestrate" ]] || fail 'нет исполняемого интерфейса openspec-orchestrate'
[[ -x "$fake_openspec" ]] || fail 'нет подменённого CLI OpenSpec'

tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/openspec-scenarios.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

repo="$tmp_root/repo"
mkdir -p "$repo"
git -C "$repo" init -q -b main
git -C "$repo" config user.name Test
git -C "$repo" config user.email test@example.com
print '# Проверка OpenSpec' >"$repo/README.md"
git -C "$repo" add README.md
git -C "$repo" commit -q -m init

state_dir=$(cd "$repo" && "$workspace" add-dark-mode)
state_file="$state_dir/state.md"
print 'custom-note: сохранить' >>"$state_file"
command_log="$tmp_root/openspec.log"

write_snapshot() {
  local name=$1
  local json=$2
  local path="$tmp_root/$name.json"

  print -r -- "$json" >"$path"
  print -r -- "$path"
}

run_orchestrate() {
  local snapshot=$1
  local list_fixture=${2:-list-one.json}

  OPEN_SPEC_FIXTURE_DIR="$fixture_dir" \
    OPEN_SPEC_LIST_FIXTURE="$list_fixture" \
    OPEN_SPEC_COMMAND_LOG="$command_log" \
    "$orchestrate" "$snapshot" "$state_file" "$fake_openspec"
}

assert_json() {
  local label=$1
  local result=$2
  local predicate=$3

  jq -e "$predicate" >/dev/null <<<"$result" \
    || fail "$label: неожиданный результат: $result"
}

# 1. Обычная задача не включает OpenSpec и не вызывает CLI.
: >"$command_log"
state_before=$(shasum -a 256 "$state_file")
ordinary=$(write_snapshot ordinary \
  '{"event":"discover","explicit":false,"request":"обычная задача"}')
result=$(run_orchestrate "$ordinary")
assert_json 1 "$result" '.decision == "disabled" and .stage == "unchanged"'
[[ ! -s "$command_log" ]] || fail 'сценарий 1: обычная задача вызвала OpenSpec'
[[ "$(shasum -a 256 "$state_file")" == "$state_before" ]] \
  || fail 'сценарий 1: обычная задача изменила state.md'

# 2. Явный запрос создаёт изменение при 0 активных и продолжает при одном.
: >"$command_log"
create=$(write_snapshot create \
  '{"event":"discover","explicit":true,"newChange":"add-dark-mode"}')
result=$(run_orchestrate "$create" list-zero.json)
assert_json 2 "$result" \
  '.decision == "create-change" and .changeName == "add-dark-mode"'
[[ "$(<"$command_log")" == 'list --json' ]] \
  || fail 'сценарий 2: неверные команды для 0 изменений'

: >"$command_log"
continue=$(write_snapshot continue \
  '{"event":"discover","explicit":true,"selectedChange":"add-dark-mode"}')
result=$(run_orchestrate "$continue" list-one.json)
assert_json 2 "$result" \
  '.decision == "continue-change" and .stage == "planning"'
expected_commands=$'list --json\nstatus add-dark-mode --json\ninstructions apply add-dark-mode --json'
[[ "$(<"$command_log")" == "$expected_commands" ]] \
  || fail 'сценарий 2: продолжение не прочитало полный снимок OpenSpec'
ugrep -Fq 'active-change: add-dark-mode' "$state_file" \
  || fail 'сценарий 2: изменение не записано в state.md'

# 3. При N активных изменениях решение остаётся за пользователем.
: >"$command_log"
choose=$(write_snapshot choose '{"event":"discover","explicit":true}')
result=$(run_orchestrate "$choose" list-many.json)
assert_json 3 "$result" \
  '.decision == "choose-change" and (.candidates | length) == 2'
[[ "$(<"$command_log")" == 'list --json' ]] \
  || fail 'сценарий 3: до выбора выполнены лишние команды'

# 4. Потерянный ID заменяется один раз с файловым восстановлением и бюджетом.
recover=$(write_snapshot recover \
  '{"event":"recover","role":"executor","idAvailable":false,"currentBudget":1,"reason":"ID недоступен","files":["report.md","state.md"]}')
result=$(run_orchestrate "$recover")
assert_json 4 "$result" \
  '.decision == "replace-role" and .freshAgentBudget == 2 and .restoreFromFiles == true'
ugrep -Fq 'executor: replacement-pending' "$state_file" \
  || fail 'сценарий 4: замена исполнителя не записана'
ugrep -Fq 'fresh-agent-budget: 2' "$state_file" \
  || fail 'сценарий 4: бюджет не обновлён'

# 5. Одноимённые планы используют настоящий sdd-workspace и не сталкиваются.
mkdir -p "$repo/docs/a" "$repo/docs/b"
print '# План A' >"$repo/docs/a/tasks.md"
print '# План B' >"$repo/docs/b/tasks.md"
git -C "$repo" add docs
git -C "$repo" commit -q -m plans
sdd_a=$(cd "$repo" && "$sdd_workspace" docs/a/tasks.md)
sdd_b=$(cd "$repo" && "$sdd_workspace" docs/b/tasks.md)
[[ "$sdd_a" != "$sdd_b" ]] || fail 'сценарий 5: рабочие области SDD столкнулись'

# 6 и 8. Связный блок получает одного исполнителя и внешние краткие задания.
brief_1="$tmp_root/task-1.md"
brief_2="$tmp_root/task-2.md"
(cd "$repo" && "$task_brief" "$fixture_dir/apply.json" 1 "$brief_1") >/dev/null
(cd "$repo" && "$task_brief" "$fixture_dir/apply.json" 2 "$brief_2") >/dev/null
single=$(write_snapshot single \
  "$(jq -nc --arg first "$brief_1" --arg second "$brief_2" \
    '{event:"route",blocks:[{taskIds:["1","2"],briefFiles:[$first,$second]}]}')")
result=$(run_orchestrate "$single")
assert_json 6 "$result" \
  '.decision == "execute" and .mode == "single" and .executorCount == 1'
jq -e --arg first "$brief_1" --arg second "$brief_2" \
  '.briefFiles == [$first,$second]' >/dev/null <<<"$result" \
  || fail 'сценарий 8: внешние краткие задания потеряны'

# 7. Два независимых блока выбирают SDD и его реальную рабочую область.
sdd=$(write_snapshot sdd \
  "$(jq -nc --arg first "$brief_1" --arg second "$brief_2" --arg workspace "$sdd_a" \
    '{event:"route",sddWorkspace:$workspace,blocks:[
      {taskIds:["1"],briefFiles:[$first]},
      {taskIds:["2"],briefFiles:[$second]}
    ]}')")
result=$(run_orchestrate "$sdd")
assert_json 7 "$result" \
  '.decision == "execute" and .mode == "sdd" and .executorCount == 2 and .callerControlledReturn'
ugrep -Fq "sdd-workspace: $sdd_a" "$state_file" \
  || fail 'сценарий 7: рабочая область SDD не записана'

# 9. Встроенный SDD проводит одну проверку и возвращает управление вызывающему навыку.
review=$(write_snapshot review \
  '{"event":"review","mode":"sdd","callerControlledReturn":true}')
result=$(run_orchestrate "$review")
assert_json 9 "$result" \
  '.reviewerCount == 1 and .reviewerOwner == "sdd" and .callerControlledReturn'

review_complete=$(write_snapshot review-complete \
  '{"event":"review-complete","mode":"sdd","clean":true,"callerControlledReturn":true}')
result=$(run_orchestrate "$review_complete")
assert_json 9 "$result" \
  '.decision == "caller-return" and .stage == "fresh-verification" and .newReviewerCount == 0 and (.cleanup | not)'

# 10 и 11. Смешанные замечания возвращают планирование и открывают только затронутые пункты.
findings=$(write_snapshot findings \
  '{"event":"findings","artifactFindings":["artifact design"],"implementationFindings":["implementation ui"],"affectedTaskIds":["2"]}')
result=$(run_orchestrate "$findings")
assert_json 10 "$result" \
  '.actions == ["planner","reopen-affected-tasks","executor-batch","re-review"] and .newReviewerCount == 0'
assert_json 11 "$result" \
  '.reopenedTaskIds == ["2"] and .stage == "planning"'
ugrep -Fq 'reopened-tasks: 2' "$state_file" \
  || fail 'сценарий 11: затронутый пункт не открыт повторно'

# 12. Только свежая проверка фактического HEAD завершает процесс.
current_head=$(git -C "$repo" rev-parse HEAD)
stale=$(write_snapshot stale \
  "$(jq -nc --arg current "$current_head" \
    '{event:"verify",reviewedHead:"deadbeef",currentHead:$current,checksPassed:true}')")
result=$(run_orchestrate "$stale")
assert_json 12 "$result" \
  '.decision == "stale-verification" and .stage == "fresh-verification"'

fresh=$(write_snapshot fresh \
  "$(jq -nc --arg current "$current_head" \
    '{event:"verify",reviewedHead:$current,currentHead:$current,checksPassed:true}')")
result=$(run_orchestrate "$fresh")
jq -e --arg current "$current_head" \
  '.decision == "verified" and .stage == "ready-for-merge" and .verifiedHead == $current' \
  >/dev/null <<<"$result" \
  || fail 'сценарий 12: свежий HEAD не подтверждён'

# 13. Архивирование блокируется до слияния и разрешается в чистой основной ветке.
git -C "$repo" switch -q -c feature
print 'готово' >"$repo/feature.txt"
git -C "$repo" add feature.txt
git -C "$repo" commit -q -m feature
change_head=$(git -C "$repo" rev-parse HEAD)
git -C "$repo" switch -q main

archive_guard=$(write_snapshot archive-guard \
  "$(jq -nc --arg repo "$repo" --arg head "$change_head" \
    '{event:"archive-guard",repo:$repo,defaultBranch:"main",changeHead:$head,tasksComplete:true}')")
result=$(run_orchestrate "$archive_guard")
assert_json 13 "$result" \
  '.decision == "archive-blocked" and (.reasons | index("not-merged")) != null'

git -C "$repo" merge -q --ff-only feature
result=$(run_orchestrate "$archive_guard")
assert_json 13 "$result" \
  '.decision == "archive-ready" and (.reasons | length) == 0'

print 'грязно' >>"$repo/README.md"
result=$(run_orchestrate "$archive_guard")
assert_json 13 "$result" \
  '.decision == "archive-blocked" and (.reasons | index("dirty-worktree")) != null'
git -C "$repo" restore README.md

# 14. Влияние исправления архива возвращает изменение в разработку.
archive_impact=$(write_snapshot archive-impact \
  '{"event":"archive-impact","implementationAffected":true}')
result=$(run_orchestrate "$archive_impact")
assert_json 14 "$result" \
  '.decision == "return-development" and .stage == "planning" and (.retryArchive | not)'

ugrep -Fq 'custom-note: сохранить' "$state_file" \
  || fail 'обновление state.md уничтожило пользовательское содержимое'

print 'test-openspec-scenarios: ok'
