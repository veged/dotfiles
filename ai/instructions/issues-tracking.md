# Маршрутизация систем управления задачами и хостингов

Сначала определи нативную систему по явному URL или названию продукта, затем
выбирай навык и инструменты. Явный URL или название продукта имеет приоритет
над словами «задача», «тикет», `issue`, «эпик» и «трекер».

* Для URL на `sourcecraft.dev` и явно названного SourceCraft используй только
  `mcp__sourcecraft__*` для `issues`, Pull Requests, комментариев, меток и связей
  SourceCraft.
* Для URL на `st.yandex-team.ru`, явно названного Yandex Tracker и запросов с TQL
  используй навык `tracker` и `mcp__tracker__*`.
* Для URL на `github.com` и явно названного GitHub используй `gh` или GitHub MCP.

Если нативный инструмент выбранной системы недоступен, сообщи об этом и не
подменяй её другим трекером, веб-интерфейсом или CLI.

## Веб-ссылки SourceCraft на файлы и строки

Формат:
`https://sourcecraft.dev/<organization>/<repository>/browse/<path>?rev=<url-encoded-revision>`.
Для исходника добавляй `plain=true`. Строку задавай как `l=<line>`, диапазон —
как `l=<start>-<end>`. `src browse <path>:<line> --no-browser` подтверждает
одиночный `l=<line>`. URL-кодируй ревизию: `feature/docs` → `feature%2Fdocs`.

Пример файла:
`https://sourcecraft.dev/veged/dotfiles/browse/ai/instructions/issues-tracking.md?rev=master&plain=true`.
Для строк 6–10 добавь `&l=6-10`.

Открывай ссылки в отдельной вкладке или панели полноценного встроенного
браузера, а не внутри инлайновой визуализации, чтобы сохранить виджет.
