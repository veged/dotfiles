#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
skill_dir="$repo_root/ai/skills/openspec-archive"
skill="$skill_dir/SKILL.md"

fail() {
  print -u2 -- "$1"
  exit 1
}

[[ -f "$skill" ]] || fail 'нет SKILL.md'

required=(
  'только по явному запросу'
  'после слияния'
  'основную ветку'
  'чистую рабочую копию'
  'openspec status'
  'openspec instructions apply'
  'openspec archive'
  'не переключай ветки'
  'не сливай'
  'не создавай коммит'
  'влияние на реализацию'
  'openspec.defaultBranch'
  'refs/remotes/{remote}/HEAD'
  'Не используй upstream текущей ветки'
  'точно совпадает с основной веткой'
  'git merge-base --is-ancestor'
  'N активных изменений'
  'пользователь выбирает одно'
  '../openspec-development/scripts/openspec-orchestrate'
)

for phrase in "${required[@]}"; do
  ugrep -Fq -- "$phrase" "$skill" || fail "нет правила: $phrase"
done

if ugrep -Eq '(^|[^[:alnum:]_-])main([^[:alnum:]_-]|$)' "$skill"; then
  fail 'основная ветка закреплена как main'
fi

if ugrep -Fq -- '--skip-specs' "$skill"; then
  fail 'навык пропускает спецификации'
fi

if ugrep -Fq -- '--no-validate' "$skill"; then
  fail 'навык отключает проверку'
fi

[[ ! -e "$skill_dir/agents/openai.yaml" ]] \
  || fail 'добавлены чуждые локальной конвенции метаданные UI'

if ugrep -Fq 'description: Use when' "$skill"; then
  fail 'описание навыка не локализовано'
fi

print 'test-openspec-archive-skill: ok'
