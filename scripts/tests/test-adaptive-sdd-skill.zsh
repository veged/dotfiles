#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
skill_dir="$repo_root/ai/skills/subagent-driven-development"
skill="$skill_dir/SKILL.md"

fail() {
  print -u2 -- "$1"
  exit 1
}

required=(
  'fork_turns: "none"'
  'fresh-agent budget'
  'agent-turn budget'
  'coordination budget'
  'nested-turns'
  'Агентский ход'
  'минимум два независимых рабочих блока'
  '{DELEGATION_POLICY}'
  'один раунд исправлений'
  'Не закладывай три или пять раундов заранее'
  'state=frozen'
  'координатор и исполнители не меняют'
  'свежего узкого'
  'human-signoff'
  'ровно одно итоговое ревью'
  'SDD_REVIEW_PACKAGE_MAX_BYTES'
  'Excluded-content validation'
  '{REPORT_FILES}'
  'готовые файлы кратких заданий'
  '{REQUIREMENT_FILES}'
  'final-reviewer-prompt.md'
  'второе полное ревью'
  'Вызывающий навык получает итоговый отчёт'
  'не запускает второго проверяющего'
  '{CALLER_CONTROLLED_RETURN}'
  'сохрани рабочую область и отчёты'
  'верни управление'
  '`finishing-a-development-branch`'
  '`fresh-verification`'
  '`ready-for-merge`'
  '`wait_agent`'
  '`list_agents`'
  '`send_message`'
  '`max` и `ultra`'
)

for phrase in "${required[@]}"; do
  ugrep -Fq -- "$phrase" "$skill" \
    || fail "нет обязательного правила: $phrase"
done

final_reviewer="$skill_dir/final-reviewer-prompt.md"
for phrase in \
  '{REQUIREMENT_FILES}' \
  '{REPORT_FILES}' \
  '{DIFF_FILE}' \
  '{DELEGATION_POLICY}' \
  'BASE' \
  'HEAD' \
  'artifact {id}' \
  'implementation' \
  'external' \
  'Critical' \
  'Important' \
  'Minor' \
  'file:line' \
  'единственное разрешённое изменение'; do
  ugrep -Fq -- "$phrase" "$final_reviewer" \
    || fail "нет обязательного правила итогового проверяющего: $phrase"
done

for obsolete in \
  'Fresh subagent per task + task review' \
  'Never skip the task review' \
  'Продолжение живого агента через `followup_task` не расходует бюджет' \
  'По умолчанию допустимы три раунда' \
  'Продление до пяти раундов'; do
  if ugrep -Fq -- "$obsolete" "$skill"; then
    fail "осталось безусловное правило: $obsolete"
  fi
done

for phrase in \
  'fork_turns: "none"' \
  'новый узкий контекст' \
  'STALE_SNAPSHOT' \
  '{REQUIREMENT_EXCERPTS}' \
  '{DELEGATION_POLICY}'; do
  ugrep -Fq -- "$phrase" "$skill_dir/re-review-prompt.md" \
    || fail "нет обязательного правила узкой перепроверки: $phrase"
done

for prompt in \
  implementer-prompt.md \
  task-reviewer-prompt.md; do
  prompt_path="$skill_dir/$prompt"
  ugrep -Eq 'рабоч(ий|его) блок' "$prompt_path" \
    || fail "шаблон $prompt не использует русский термин рабочего блока"
  ugrep -Fq '{BRIEF_FILES}' "$prompt_path" \
    || fail "шаблон $prompt не принимает список brief-файлов"
  ugrep -Fq '{DELEGATION_POLICY}' "$prompt_path" \
    || fail "шаблон $prompt не задаёт политику делегирования"
  if ugrep -Fq 'Work Unit' "$prompt_path"; then
    fail "шаблон $prompt содержит нелокализованный термин Work Unit"
  fi
done

for prompt in \
  task-reviewer-prompt.md \
  re-review-prompt.md \
  final-reviewer-prompt.md; do
  ugrep -Fq 'STALE_SNAPSHOT' "$skill_dir/$prompt" \
    || fail "шаблон $prompt не отклоняет устаревший снимок"
done

instructions="$repo_root/ai/instructions/agents.md"
for phrase in \
  'Агентский ход' \
  'один агент получает один рабочий ход' \
  'второй раунд исправлений' \
  'Неизменяемый снимок' \
  'Не превращай одну агентскую сессию в постоянную роль валидатора' \
  'один цикл' \
  '`wait_agent`' \
  '`list_agents`' \
  '`send_message`' \
  '«заверши сейчас»' \
  '`nested turns` не запрещает вложенную делегацию вообще' \
  '`max` и `ultra` не являются значением по умолчанию'; do
  ugrep -Fq -- "$phrase" "$instructions" \
    || fail "нет глобального правила оркестрации: $phrase"
done

print 'test-adaptive-sdd-skill: ok'
