#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
instructions="$repo_root/ai/instructions/issues-tracking.md"
projection="$repo_root/codex/AGENTS.md"

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

for file in "$instructions" "$projection"; do
  [[ -f "$file" ]] || fail "нет долговечного источника или проекции: $file"

  assert_contains "$file" 'Явный URL или название продукта имеет приоритет' \
    'приоритет явной системы'
  assert_contains "$file" 'над словами «задача», «тикет», `issue`, «эпик» и «трекер»' \
    'приоритет явной системы над общими словами'
  assert_contains "$file" '`sourcecraft.dev`' \
    'маршрутизация SourceCraft'
  assert_contains "$file" 'явно названного SourceCraft используй только' \
    'нативные инструменты SourceCraft'
  assert_contains "$file" '`mcp__sourcecraft__*`' \
    'нативные инструменты SourceCraft'
  assert_contains "$file" 'комментариев, меток и связей' \
    'сущности SourceCraft'
  assert_contains "$file" '`st.yandex-team.ru`' \
    'маршрутизация Yandex Tracker'
  assert_contains "$file" 'запросов с TQL' \
    'маршрутизация TQL'
  assert_contains "$file" 'навык `tracker` и `mcp__tracker__*`' \
    'нативные инструменты Yandex Tracker'
  assert_contains "$file" '`gh` или GitHub MCP' \
    'маршрутизация GitHub'
  assert_contains "$file" 'подменяй её другим трекером, веб-интерфейсом или CLI' \
    'запрет межсистемной подмены'
done

print 'test-issues-tracking-policy: ok'
