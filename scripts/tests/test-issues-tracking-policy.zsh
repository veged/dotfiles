#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
instructions="$repo_root/ai/instructions/issues-tracking.md"
projection="$repo_root/codex/AGENTS.md"
example_file_url='https://sourcecraft.dev/veged/dotfiles/browse/ai/instructions/issues-tracking.md?rev=master&plain=true'

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
  assert_contains "$file" '/browse/<path>?rev=<url-encoded-revision>' \
    'формат ссылки на файл SourceCraft'
  assert_contains "$file" '`plain=true`' \
    'режим исходного текста SourceCraft'
  assert_contains "$file" '`l=<line>`' \
    'локатор одной строки SourceCraft'
  assert_contains "$file" '`src browse <path>:<line> --no-browser`' \
    'подтверждённый формат одной строки SourceCraft'
  assert_contains "$file" '`l=<start>-<end>`' \
    'локатор диапазона строк SourceCraft'
  assert_contains "$file" '`feature%2Fdocs`' \
    'URL-кодирование имени ветки SourceCraft'
  assert_contains "$file" "$example_file_url" \
    'пример ссылки на файл SourceCraft'
  assert_contains "$file" '`&l=6-10`' \
    'пример ссылки на диапазон строк SourceCraft'
  assert_contains "$file" 'отдельной вкладке или панели полноценного встроенного' \
    'отдельное открытие ссылки SourceCraft'
  assert_contains "$file" 'а не внутри инлайновой визуализации' \
    'сохранение инлайновой визуализации'
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
