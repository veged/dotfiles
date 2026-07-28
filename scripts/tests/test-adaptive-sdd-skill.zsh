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
  'минимум два независимых рабочих блока'
  'human-signoff'
  'ровно одно итоговое ревью'
  'SDD_REVIEW_PACKAGE_MAX_BYTES'
  'Excluded-content validation'
  '[REPORT_FILES]'
)

for phrase in "${required[@]}"; do
  ugrep -Fq -- "$phrase" "$skill" \
    || fail "нет обязательного правила: $phrase"
done

for obsolete in \
  'Fresh subagent per task + task review' \
  'Never skip the task review'; do
  if ugrep -Fq -- "$obsolete" "$skill"; then
    fail "осталось безусловное правило: $obsolete"
  fi
done

if ugrep -Fq 'description: "Повторно проверить Work Unit' \
  "$skill_dir/re-review-prompt.md"; then
  fail 'основной re-review всё ещё оформлен как новый dispatch'
fi

for prompt in \
  implementer-prompt.md \
  task-reviewer-prompt.md \
  re-review-prompt.md; do
  prompt_path="$skill_dir/$prompt"
  ugrep -Fq 'Work Unit' "$prompt_path" \
    || fail "шаблон $prompt не переведён на Work Unit"
  ugrep -Fq '[BRIEF_FILES]' "$prompt_path" \
    || fail "шаблон $prompt не принимает список brief-файлов"
done

print 'test-adaptive-sdd-skill: ok'
