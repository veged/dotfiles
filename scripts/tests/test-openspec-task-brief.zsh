#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
task_brief="$repo_root/ai/skills/openspec-development/scripts/openspec-task-brief"
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/openspec-task-brief.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

fail() {
  print -u2 -- "$1"
  exit 1
}

assert_rejected_json() {
  local label=$1
  local json=$2
  local task_id=${3:-1}
  local rejected_output="$tmp_root/rejected-${label}.md"
  local exit_code

  set +e
  (cd "$repo" && "$task_brief" "$json" "$task_id" "$rejected_output") \
    >"$tmp_root/rejected-${label}.out" 2>"$tmp_root/rejected-${label}.err"
  exit_code=$?
  set -e

  [[ "$exit_code" -eq 3 ]] \
    || fail "$label: ожидался код 3, получен $exit_code"
  [[ ! -e "$rejected_output" ]] \
    || fail "$label: отклонённый JSON создал файл"
}

repo="$tmp_root/repo"
mkdir -p "$repo"
git -C "$repo" init -q
apply_json='{
  "changeName": "add-dark-mode",
  "state": "ready",
  "contextFiles": {
    "proposal": ["openspec/changes/add-dark-mode/proposal.md"],
    "specs": ["openspec/changes/add-dark-mode/specs/theme/spec.md"],
    "design": ["openspec/changes/add-dark-mode/design.md"],
    "tasks": ["openspec/changes/add-dark-mode/tasks.md"]
  },
  "tasks": [
    {"id": "1", "description": "Добавить хранилище темы", "done": false},
    {"id": "2", "description": "Добавить переключатель", "done": true}
  ]
}'

output="$tmp_root/task-1.md"
(cd "$repo" && "$task_brief" "$apply_json" 1 "$output")
for expected in \
  'add-dark-mode' \
  'Добавить хранилище темы' \
  'done: false' \
  'openspec/changes/add-dark-mode/proposal.md' \
  'openspec/changes/add-dark-mode/specs/theme/spec.md' \
  'openspec/changes/add-dark-mode/design.md' \
  'openspec/changes/add-dark-mode/tasks.md'; do
  ugrep -Fq -- "$expected" "$output" || fail "нет: $expected"
done

for task_id in 2 999; do
  set +e
  (cd "$repo" && "$task_brief" "$apply_json" "$task_id") \
    >"$tmp_root/invalid.out" 2>"$tmp_root/invalid.err"
  exit_code=$?
  set -e
  [[ "$exit_code" -eq 3 ]] || fail "задача $task_id не отклонена кодом 3"
done

for invalid_change in '../escape' 'with/slash'; do
  invalid_json=$(jq -c --arg change "$invalid_change" \
    '.changeName = $change' <<<"$apply_json")
  set +e
  (cd "$repo" && "$task_brief" "$invalid_json" 1) \
    >"$tmp_root/change.out" 2>"$tmp_root/change.err"
  exit_code=$?
  set -e
  [[ "$exit_code" -eq 3 ]] \
    || fail "имя изменения $invalid_change не отклонено кодом 3"
done

[[ ! -e "$repo/.superpowers/escape/task-1-brief.md" ]] \
  || fail 'traversal создал файл вне рабочей области OpenSpec'
[[ ! -e "$repo/.superpowers/openspec/with/slash/task-1-brief.md" ]] \
  || fail 'некорректное имя создало вложенную рабочую область'

set +e
(cd "$repo" && "$task_brief" '{invalid' 1) \
  >"$tmp_root/json.out" 2>"$tmp_root/json.err"
exit_code=$?
set -e
[[ "$exit_code" -eq 3 ]] || fail 'невалидный JSON не отклонён кодом 3'

assert_rejected_json \
  context-order-first \
  "$(jq -c '.contextFiles = {broken: "not-an-array", last: []}' <<<"$apply_json")"
assert_rejected_json \
  context-order-last \
  "$(jq -c '.contextFiles = {first: [], broken: "not-an-array"}' <<<"$apply_json")"
assert_rejected_json \
  context-non-string \
  "$(jq -c '.contextFiles.proposal = [42]' <<<"$apply_json")"
assert_rejected_json \
  context-traversal \
  "$(jq -c '.contextFiles.proposal = ["../proposal.md"]' <<<"$apply_json")"
assert_rejected_json \
  context-absolute \
  "$(jq -c '.contextFiles.proposal = ["/tmp/proposal.md"]' <<<"$apply_json")"
assert_rejected_json \
  task-id-type \
  "$(jq -c '.tasks[0].id = []' <<<"$apply_json")"
assert_rejected_json \
  task-description-type \
  "$(jq -c '.tasks[0].description = 42' <<<"$apply_json")"
assert_rejected_json \
  task-done-type \
  "$(jq -c '.tasks[0].done = "false"' <<<"$apply_json")"
assert_rejected_json \
  unsafe-selected-id \
  "$apply_json" \
  '../1'
assert_rejected_json \
  duplicate-selected-id \
  "$(jq -c '.tasks += [.tasks[0]]' <<<"$apply_json")"

print 'test-openspec-task-brief: ok'
