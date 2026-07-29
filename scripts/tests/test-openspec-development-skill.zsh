#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
skill_dir="$repo_root/ai/skills/openspec-development"
skill="$skill_dir/SKILL.md"

fail() {
  print -u2 -- "$1"
  exit 1
}

[[ -f "$skill" ]] || fail 'нет SKILL.md'

required=(
  'явно просит применить OpenSpec'
  'просит продолжить, реализовать или проверить конкретное активное изменение'
  'простое упоминание имени изменения'
  'не включается только из-за наличия каталога'
  '0 активных изменений'
  '1 активное изменение'
  'N активных изменений'
  'пользователь выбирает одно'
  'fork_turns: "none"'
  'state.md'
  'сохраняй ID'
  'только дельту нового входа'
  'восстанови из файлов'
  'причину замены'
  'пересчитай `fresh-agent budget`'
  'готовые файлы кратких заданий'
  'один постоянный исполнитель'
  'несколько ID рабочих пунктов'
  'ровно одно итоговое ревью'
  'итоговый проверяющий SDD одновременно'
  'не запускай второе полное ревью'
  'artifact {id}'
  'implementation'
  'external'
  'OBSOLETE'
  'fresh-verification'
  'текущего `HEAD`'
  'openspec list'
  'openspec status'
  'openspec instructions apply'
  'соответствие OpenSpec'
  'не запускает второго проверяющего'
  'все замечания к реализации'
  'одним пакетом'
  'В режиме `single` проведи ровно одно итоговое ревью'
  'В режиме `sdd` итоговый проверяющий SDD'
  'требования OpenSpec и контекст'
  'единственным полным проверяющим'
  'верни процесс в `planning`'
  'сними `done` только с затронутых'
  'только проверяющий присваивает `OBSOLETE`'
)

for phrase in "${required[@]}"; do
  ugrep -Fq -- "$phrase" "$skill" || fail "нет правила: $phrase"
done

implementer="$skill_dir/implementer-prompt.md"
for field in \
  '{STATE_FILE}' \
  '{REPORT_FILE}' \
  '{TASK_IDS}' \
  '[BRIEF_FILES]'; do
  ugrep -Fq -- "$field" "$implementer" \
    || fail "исполнитель не получает поле: $field"
done

reviewer="$skill_dir/reviewer-prompt.md"
for field in \
  '[REQUIREMENT_FILES]' \
  '[REPORT_FILES]' \
  '[DIFF_FILE]' \
  '[BASE]' \
  '[HEAD]' \
  '[REVIEW_REPORT]' \
  'Critical' \
  'Important' \
  'Minor' \
  'file:line' \
  'риск' \
  'исправление' \
  'единственное разрешённое изменение'; do
  ugrep -Fq -- "$field" "$reviewer" \
    || fail "итоговый проверяющий single не получает контракт: $field"
done

for file in \
  planner-prompt.md \
  implementer-prompt.md \
  reviewer-prompt.md \
  re-review-prompt.md \
  scripts/openspec-orchestrate \
  scripts/openspec-workspace \
  scripts/openspec-task-brief; do
  [[ -f "$skill_dir/$file" ]] || fail "нет файла: $file"
  ugrep -Fq -- "$file" "$skill" || fail "нет ссылки: $file"
done

if ugrep -R -Eq '^[[:space:]]*model:' "$skill_dir"; then
  fail 'в навыке закреплена модель'
fi

if ugrep -R -Eq 'npm[[:space:]]+install|npx[[:space:]]+--yes' "$skill_dir"; then
  fail 'навык способен автоматически установить OpenSpec'
fi

[[ ! -e "$skill_dir/agents/openai.yaml" ]] \
  || fail 'добавлены чуждые локальной конвенции метаданные UI'

if ugrep -Fq 'description: Use when' "$skill"; then
  fail 'описание навыка не локализовано'
fi

for prose in \
  'final reviewer' \
  'OpenSpec compliance' \
  'implementation findings' \
  'одним batch' \
  'Вызывающий skill'; do
  if ugrep -R -Fq -- "$prose" "$skill_dir"; then
    fail "не локализована обычная проза: $prose"
  fi
done

print 'test-openspec-development-skill: ok'
