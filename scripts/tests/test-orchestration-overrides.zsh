#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
executing="$repo_root/ai/skills/executing-plans/SKILL.md"
review="$repo_root/ai/skills/code-review/SKILL.md"
registry="$repo_root/ai/skills/skills.json"

fail() {
  print -u2 -- "$1"
  exit 1
}

for phrase in \
  'Один связный блок выполняй локально' \
  'Два и более независимых блока' \
  'coordination budget' \
  'Нулевой `nested` означает' \
  '`max` и `ultra` требуют записанного обоснования'; do
  ugrep -Fq -- "$phrase" "$executing" \
    || fail "нет правила исполнения планов: $phrase"
done

for phrase in \
  'Если ты уже запущен как проверяющий' \
  'выполни ревью сам' \
  'Две оси оправданы для широкого или высокорискового diff' \
  'Не создавай метапроверяющего' \
  'не выделил ей бюджет' \
  'Не повторяй тесты'; do
  ugrep -Fq -- "$phrase" "$review" \
    || fail "нет правила ревью: $phrase"
done

if ugrep -Fqi 'if subagents are available' "$executing" "$review"; then
  fail 'осталось безусловное требование запускать сабагентов'
fi

for skill in executing-plans code-review; do
  metadata="$repo_root/ai/skills/$skill/agents/openai.yaml"
  ugrep -Fq "\$$skill" "$metadata" \
    || fail "default_prompt не упоминает \$$skill"
done

jq -e '
  ."mattpocock/skills" | index("!code-review") != null
' "$registry" >/dev/null \
  || fail 'внешний code-review не исключён из установки'

jq -e '
  ."obra/superpowers" | index("!executing-plans") != null
' "$registry" >/dev/null \
  || fail 'внешний executing-plans не исключён из установки'

print 'test-orchestration-overrides: ok'
