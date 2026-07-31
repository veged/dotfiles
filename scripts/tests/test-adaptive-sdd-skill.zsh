#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
sdd_dir="$repo_root/ai/skills/subagent-driven-development"
instructions="$repo_root/ai/instructions/agents.md"

fail() {
  print -u2 -- "$1"
  exit 1
}

skill_files=(
  "$repo_root/ai/skills/executing-plans/SKILL.md"
  "$repo_root/ai/skills/code-review/SKILL.md"
  "$sdd_dir/SKILL.md"
)

prompt_files=(
  "$sdd_dir/implementer-prompt.md"
  "$sdd_dir/task-reviewer-prompt.md"
  "$sdd_dir/re-review-prompt.md"
  "$sdd_dir/final-reviewer-prompt.md"
)

metadata_files=(
  "$repo_root/ai/skills/executing-plans/agents/openai.yaml"
  "$repo_root/ai/skills/code-review/agents/openai.yaml"
)

documents=(
  "$instructions"
  "${skill_files[@]}"
  "${prompt_files[@]}"
  "${metadata_files[@]}"
)

service_words='благодаря|вместо|вокруг|вдоль|между|около|перед|после|прежде|против|сквозь|спустя|среди|через|возле|из-за|из-под|кроме|мимо|ради|или|без|для|над|под|при|про|как|обо|во|до|за|из|ко|на|не|ни|но|об|от|по|со|а|в|да|и|к|ли|о|с|у'

for file in "${documents[@]}"; do
  [[ -f "$file" ]] || fail "нет файла: $file"
done

for script in sdd-workspace task-brief review-package; do
  [[ -x "$sdd_dir/scripts/$script" ]] \
    || fail "скрипт не исполняемый: $script"
done

for spec in \
  "executing-plans:$repo_root/ai/skills/executing-plans/SKILL.md" \
  "code-review:$repo_root/ai/skills/code-review/SKILL.md" \
  "subagent-driven-development:$sdd_dir/SKILL.md"; do
  name=${spec%%:*}
  file=${spec#*:}
  ugrep -Fq -- "name: $name" "$file" \
    || fail "неверное имя навыка: $name"
done

for file in "${documents[@]}"; do
  if ugrep -Pn '\{[^}\n]*[A-Za-z][^}\n]*\}' "$file" >/dev/null; then
    fail "английский плейсхолдер: $file"
  fi

  if ugrep -Pn '\[(?![ xX]\])[^]]+\](?!\()' "$file" >/dev/null; then
    fail "квадратный плейсхолдер: $file"
  fi

  if ugrep -Fq ' — ' "$file"; then
    fail "обычный пробел перед тире: $file"
  fi

  if ugrep -Pni "(^|[[:space:]]| )(${service_words})( |$)" "$file" >/dev/null; then
    fail "обычный пробел после служебного слова: $file"
  fi
done

for token in wait_agent list_agents send_message fork_turns; do
  if ugrep -Fq -- "$token" "$instructions"; then
    fail "общая политика зависит от платформенного поля: $token"
  fi
done

for phrase in \
  'agent-turn budget' \
  'coordination budget' \
  'fresh-agent budget' \
  'Excluded-content validation' \
  'task-review skipped' \
  'normal risk' \
  'high-risk review clean' \
  'Cannot verify'; do
  if ugrep -Fq -- "$phrase" "${documents[@]}"; then
    fail "остался англоязычный пользовательский текст: $phrase"
  fi
done

registry="$repo_root/ai/skills/skills.json"
jq -e '
  (."mattpocock/skills" | index("!code-review") != null)
  and
  (."obra/superpowers" | index("!executing-plans") != null)
' "$registry" >/dev/null \
  || fail 'локальные навыки не исключают одноимённые внешние копии'

for index in {1..${#metadata_files[@]}}; do
  skill=${skill_files[$index]:h:t}
  metadata=${metadata_files[$index]}
  ugrep -Fq "\$$skill" "$metadata" \
    || fail "начальный запрос не активирует навык: $skill"
done

print 'test-adaptive-sdd-skill: ok'
