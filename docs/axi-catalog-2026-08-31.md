# Каталог AXI на 31 августа 2026 года

## Снимок и границы исследования

Отчёт основан на ветке `main` официального репозитория `kunchenguid/axi`, зафиксированной на коммите [`d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb`](https://github.com/kunchenguid/axi/commit/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb) от 28 августа 2026 года. `catalog.yaml` объявлен единым источником истины, а README и сайт генерируются из него с проверкой расхождений в CI ([`catalog.yaml`, строки 1–8](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L1-L8)).

Использованы только первичные материалы этого репозитория на указанном SHA: `catalog.yaml`, `principles.yaml`, `VISION.md`, README и спецификация навыка AXI. Связанные репозитории отдельных инструментов и локальные конфигурации не исследовались. Поэтому назначения ниже — переводы заявлений самого каталога, а не независимо проверенные возможности или рекомендации.

Машинный разбор YAML дал 50 записей: 4 в `official`, 46 в `community`, 49 уникальных имён и 50 уникальных URL. README называет `official` эталонными реализациями, которые поддерживает проект AXI, а `community` — реализациями сообщества ([README, строки 95–118](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/README.md#L95-L118)).

В колонке статуса:

- `admission: не задан` означает только отсутствие поля `admission` у записи. Это не означает ни положительной проверки, ни отказа
- `admission: admitted` и `admission: exception` воспроизводят буквальные значения каталога
- у `superbee` положительный вердикт записан YAML-комментарием, а не полем данных

## Инструменты по предметным областям

Группы ниже — редакционная укрупнённая классификация. Внутри каждой строки назначение и статус взяты только из соответствующей записи `catalog.yaml`.

### Разработка и жизненный цикл ПО

| Инструмент | Заявленное назначение | Статус каталога |
| --- | --- | --- |
| [`gh-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L11-L14) | Задачи, запросы на слияние, запуски рабочих процессов, релизы и другие операции GitHub через обёртку над официальным `gh`. | `official` · `admission: не задан` |
| [`jj-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L29-L33) | Просмотр и преобразование истории Jujutsu детерминированными неинтерактивными командами, компактный TOON и отмена с учётом операций. | `community` · `admission: не задан` |
| [`specops`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L59-L63) | Разработка по спецификациям для агентов и пример AXI, встроенного в навык, а не поставляемого отдельным исполняемым пакетом npm. | `community` · `admission: не задан` |
| [`glab-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L154-L158) | Задачи, запросы на слияние, конвейеры CI/CD, переменные, секреты, релизы и прямой доступ к API GitLab через обёртку над `glab`. | `community` · `admission: не задан` |
| [`ado-axi` (`dtabolich`)](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L197-L201) | Запросы на слияние, ветки, репозитории и запуски конвейеров Azure DevOps через `az devops` и `az repos`. | `community` · `admission: не задан` |
| [`ado-axi` (`jeffreyhaen`)](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L202-L225) | Рабочие элементы, запросы на слияние, ссылки Git, конвейеры и прямые вызовы REST API Azure DevOps с защищёнными изменениями и профилями. | `community` · `admission: admitted` |
| [`cargo-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L241-L245) | Просмотр рабочих областей Rust и безопасный запуск `check` или Clippy, компактный TOON и необязательный контекст сессии. | `community` · `admission: не задан` |
| [`forgejo-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L246-L250) | Жизненный цикл запросов на слияние, задачи и прямой доступ к API самостоятельно размещённого Forgejo, неинтерактивные согласующие изменения. | `community` · `admission: не задан` |
| [`axi-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L256-L260) | Создание каркаса совместимого AXI, чтение десяти принципов порциями, рассчитанными по токенам, и проверки соответствия CLI только на чтение. | `community` · `admission: не задан` |

### Облака, контейнеры и выполнение задач

| Инструмент | Заявленное назначение | Статус каталога |
| --- | --- | --- |
| [`databricks-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L89-L93) | Запуск заданий Databricks, наблюдение за запусками и получение журналов сбоев через официальный CLI Databricks. В описании оговорено, что дополнительные области появятся позднее. | `community` · `admission: не задан` |
| [`aws-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L94-L98) | Обнаружение, планирование, подготовка, развёртывание и просмотр сервисов AWS для веб-приложений, серверной части, баз данных и нагрузок ИИ. | `community` · `admission: не задан` |
| [`docker-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L99-L103) | Обнаружение, сборка, запуск, отладка, публикация, просмотр и очистка приложений Docker. | `community` · `admission: не задан` |
| [`doctl-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L104-L108) | Один AXI поверх `doctl` для DigitalOcean с выводом TOON. | `community` · `admission: не задан` |
| [`kubernetes-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L129-L133) | Обнаружение, просмотр, развёртывание, отладка, масштабирование, обновление, публикация и очистка нагрузок Kubernetes. | `community` · `admission: не задан` |
| [`celery-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L139-L143) | Обнаружение, просмотр, запуск, отладка, наблюдение, планирование и управление очередями задач Celery. | `community` · `admission: не задан` |
| [`az-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L271-L275) | Обнаружение, просмотр, запросы и защищённые изменения Azure через модули `az`. | `community` · `admission: не задан` |

### Данные, базы данных и аналитика

| Инструмент | Заявленное назначение | Статус каталога |
| --- | --- | --- |
| [`sqlite-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L39-L43) | Просмотр схем и образцов строк, ограниченные запросы SQLite только на чтение. | `community` · `admission: не задан` |
| [`gitsheets-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L64-L68) | Чтение и изменение табличных записей, хранимых в Git, из оболочки, вывод TOON и идемпотентные коммиты. | `community` · `admission: не задан` |
| [`metabase-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L69-L73) | Запросы, исследование и экспорт из Metabase, SQL/MBQL, сохранённые вопросы, просмотр схемы и экспорт полных данных. | `community` · `admission: не задан` |
| [`dynamodb-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L109-L113) | Обнаружение, просмотр, запросы, сканирование, создание, обновление, резервное копирование, восстановление, экспорт, импорт и эксплуатация таблиц DynamoDB. | `community` · `admission: не задан` |
| [`pg-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L114-L118) | Обнаружение, создание, просмотр, запросы, резервное копирование, восстановление и обслуживание PostgreSQL. | `community` · `admission: не задан` |
| [`mongodb-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L119-L123) | Обнаружение, создание, просмотр, запросы, экспорт, импорт, обслуживание и диагностика MongoDB. | `community` · `admission: не задан` |
| [`elasticsearch-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L124-L128) | Обнаружение, просмотр, запросы, индексирование, отображения, снимки, восстановление, диагностика и эксплуатация кластеров Elasticsearch. | `community` · `admission: не задан` |
| [`redis-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L134-L138) | Обнаружение, просмотр, запросы, экспорт, импорт, обслуживание и диагностика Redis. | `community` · `admission: не задан` |
| [`oracle-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L149-L153) | Обнаружение, создание, просмотр, запросы, экспорт, импорт, обслуживание и диагностика Oracle Database. | `community` · `admission: не задан` |
| [`supabase-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L226-L230) | Просмотр схем, запуск SQL и аудит RLS, индексов и журналов в проектах Supabase через Management API. | `community` · `admission: не задан` |
| [`mssql-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L276-L280) | Просмотр схем и образцов строк, ограниченные запросы только на чтение и планы выполнения через ODBC. Изменения защищены двумя уровнями и по умолчанию используют пробный запуск. | `community` · `admission: не задан` |

### Пакеты и системное программное обеспечение

| Инструмент | Заявленное назначение | Статус каталога |
| --- | --- | --- |
| [`npm-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L34-L38) | Поиск и просмотр пакетов, версий, зависимостей, фрагментов README и загрузок в реестре npm. | `community` · `admission: не задан` |
| [`homebrew-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L231-L235) | Просмотр формул, приложений и установленных пакетов Homebrew, их версий, зависимостей, устаревания и статистики установок. Только чтение. | `community` · `admission: не задан` |
| [`pypi-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L236-L240) | Просмотр пакетов, версий, зависимостей и статистики загрузок PyPI. Только чтение, авторизация не требуется. | `community` · `admission: не задан` |

### Совместная работа, планирование и знания

| Инструмент | Заявленное назначение | Статус каталога |
| --- | --- | --- |
| [`slack-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L44-L48) | Чтение, поиск, последовательный просмотр и безопасная подготовка черновиков сообщений Slack. | `community` · `admission: не задан` |
| [`gws-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L49-L53) | Gmail, Calendar, Docs, Drive и Slides одной командой, защита изменений при нескольких учётных записях. Почта сохраняется в черновики и не отправляется. | `community` · `admission: не задан` |
| [`harvest-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L54-L58) | Просмотр, добавление и изменение записей времени Harvest по периодам для себя, команды, проекта или клиента. | `community` · `admission: не задан` |
| [`otter-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L74-L78) | Поиск и получение расшифровок встреч Otter.ai из оболочки через обёртку над размещённым MCP-сервером Otter.ai. | `community` · `admission: не задан` |
| [`notion-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L79-L83) | Поиск, чтение, создание и обновление страниц и баз данных Notion из оболочки, авторизация PAT или интеграции. | `community` · `admission: не задан` |
| [`clickup-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L84-L88) | Список открытых задач пользователя, просмотр задачи с новыми комментариями и изменение статуса задачи. | `community` · `admission: не задан` |
| [`obsidian-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L164-L168) | Чтение, поиск, создание, обновление, организация и связывание заметок Obsidian через файловую систему, атомарные записи без подключаемого модуля или сервера. | `community` · `admission: не задан` |
| [`calendly-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L187-L191) | Просмотр расписания, одноразовые ссылки бронирования, прямое бронирование, отмена и управление типами событий, доступностью и веб-перехватчиками Calendly. | `community` · `admission: не задан` |
| [`remarkable-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L192-L196) | Управление содержимым планшета reMarkable через облако, просмотр и организация файлов, загрузка PDF и EPUB, отправка веб-статей как EPUB с перекомпоновкой. | `community` · `admission: не задан` |
| [`jira-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L261-L265) | Создание, поиск, перевод между состояниями и комментирование рабочих элементов Jira, досок и спринтов через `acli`. | `community` · `admission: не задан` |
| [`confluence-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L266-L270) | Чтение и запись страниц и пространств Confluence Cloud через REST API, OAuth 3LO или токен API. | `community` · `admission: не задан` |
| [`superbee`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L281-L298) | Преобразование знаний агентов в локальные пакеты OKF с объявленными схемами, точными запросами, конфликтобезопасной записью и переносимыми представлениями (`Views`). | `community` · `admission: admitted` в комментарии, поля нет |

### Браузер, интерфейсы, визуальный разбор и генерация медиа

| Инструмент | Заявленное назначение | Статус каталога |
| --- | --- | --- |
| [`chrome-devtools-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L15-L18) | Навигация, нажатия, заполнение и извлечение с объединёнными операциями и фильтрацией запросов через обёртку над `chrome-devtools-mcp`. | `official` · `admission: не задан` |
| [`lavish-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L19-L22) | Преобразование HTML-артефактов агента в поверхности совместной проверки с аннотациями, комментариями и передачей обратной связи агенту. | `official` · `admission: не задан` |
| [`reactive-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L159-L163) | Выбор элемента в работающем сервере разработки React, Vue или Svelte и сопоставление с исходным файлом и строкой до передачи агенту. | `community` · `admission: не задан` |
| [`comfy-cloud-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L169-L177) | Генерация изображений, видео и звука через 22 партнёрские модели, отправка рабочих процессов и шаблонов ComfyUI, отслеживание заданий, оценка кредитов, поиск узлов и отчёт об использовании. | `community` · `admission: exception` |
| [`mobbin-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L178-L186) | Поиск паттернов UI/UX из производственных приложений через Mobbin и обёртку над его MCP-сервером с OAuth. | `community` · `admission: exception` |

### Агентская и терминальная инфраструктура

| Инструмент | Заявленное назначение | Статус каталога |
| --- | --- | --- |
| [`quota-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L23-L26) | Локальные окна квот и использования Claude, Codex, Cursor, Copilot и Grok для агентов, учитывающих квоты при маршрутизации. Только данные, локальная работа в приоритете. | `official` · `admission: не задан` |
| [`cyber-mux`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L144-L148) | Открытие, отправка, чтение, фокусировка и закрытие терминальных панелей tmux, herdr и WezTerm через единый контракт с обнаружением среды. | `community` · `admission: не задан` |
| [`mastra-axi`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L251-L255) | Обнаружение и запуск агентов, инструментов и рабочих процессов приложения Mastra командами оболочки. | `community` · `admission: не задан` |

## Статусы `admission`, дубликаты и оговорки

### Что именно записано

Из 50 записей только три содержат машинно читаемый объект `admission`: два `exception` и один `admitted`. Ещё один положительный вердикт для `superbee` записан многострочным комментарием. У остальных 46 записей нет ни поля, ни соседнего комментария с вердиктом. Для секции `community` распределение такое: 2 `exception`, 1 `admitted` в поле, 1 `admitted` в комментарии и 42 записи без аннотации `admission`.

Это различие существенно. `VISION.md` требует для положительного admission независимого просмотра исходников на точной ревизии, перечисления просмотренных компонентов и отделения прямых наблюдений от непроверенных утверждений. Если доказательств недостаточно, вердикт должен остаться неопределённым или запросить недостающее ([`VISION.md`, строки 13–25](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/VISION.md#L13-L25)). При этом `official` поддерживает владелец проекта и эта секция закрыта для сторонних добавлений и правок ([`VISION.md`, строка 27](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/VISION.md#L27)). Отсутствие `admission` нельзя превращать в неявное одобрение, отказ или исключение.

### Явные `exception`

`comfy-cloud-axi` проверен на ревизии `0f5b75eb201512604c87f6d75f4234bb685e0879`. Каталог перечисляет такие оговорки ([строки 169–177](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L169-L177)):

- пакет 0.1.6 сообщает версию 0.1.4
- `generate ... --confirm --type` по умолчанию выбирает изображение, а `job chain <id> --dry-run` передаёт `NaN` до вызовов MCP
- ответы `{}` для узлов и сохранённых рабочих процессов могут превращаться в пустые результаты
- платные `workflow run` и `templates run` игнорируют лишние позиционные аргументы
- другие изменяющие команды могут игнорировать завершающие флаги

`mobbin-axi` проверен на ревизии `8eda65af7d760efe45907ad3368d3164abe3062e`. Каталог перечисляет такие оговорки ([строки 178–186](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L178-L186)):

- пакет 0.1.3 сообщает версию 0.1.1
- `search-command --help` отклоняется
- пустое содержимое ответа MCP может стать успешным результатом `0 results`
- `sections` игнорирует `--platform`
- управляющие команды не имеют отдельных наборов флагов
- прежние флаги `--full` и `--json` ничего не делают

Обе записи остаются в `community`. В каталоге нет записей со статусом `rejected` или `excluded`. Следовательно, `exception` здесь — явная оговорка у включённой записи, а не удаление из каталога. Репозиторий не даёт в просмотренных файлах общего формального определения этого значения, поэтому более сильная трактовка была бы домыслом.

### Положительные вердикты

`ado-axi` из `jeffreyhaen/ado-axi` имеет `admission: admitted` на ревизии `5b997626c17a7798f8aea4ff31613e97886a3cc1`. Каталог перечисляет 11 просмотренных компонентов и три наблюдения по исходникам: разбор и проверку параметров прямого API-вызова, управление профилями и построение URL, разрешение учётных данных и преобразование сетевых и HTTP-ошибок ([строки 202–225](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L202-L225)).

`superbee` имеет комментарий с вердиктом `admitted` для релиза v0.1.3 на ревизии `f4e1c37349627030f8201ff52028f71a9c92570a`. В комментарии перечислены контракт AXI, вывод TOON, типизированные ошибки и ограниченная шкала кодов выхода, ограничение списков, сравнение-и-замена (`compare-and-swap`) для изменения и удаления документов, идемпотентное удаление и домашний экран без аргументов ([строки 281–293](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L281-L293)). Поскольку это YAML-комментарий, обычный разбор данных не возвращает данный статус.

### Дубликат

Единственный повтор имени — `ado-axi`: две разные записи с разными URL и владельцами. Запись `dtabolich/ado-axi` заявляет запросы на слияние, ветки, репозитории и конвейеры и не имеет `admission`. Запись `jeffreyhaen/ado-axi` дополнительно заявляет рабочие элементы, ссылки Git, прямой REST API и профили и имеет `admission: admitted` ([обе записи, строки 197–225](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L197-L225)). Дубликатов точных URL нет.

## Две архитектуры обнаружения

Ни `principles.yaml`, ни навык AXI прямо не специфицируют каталог-маршрутизатор. Следующее сравнение — архитектурный вывод из их требований, а не норма, заявленная проектом.

### Вариант A: один статический Agent Skill со всем каталогом

Преимущество этого варианта в том, что навык загружается по запросу и не создаёт затрат в каждой сессии. Спецификация прямо называет Agent Skill вторичным каналом обнаружения с загрузкой по требованию, без постоянной стоимости контекста ([`SKILL.md`, строки 185–190](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L185-L190)). Полный статический каталог также можно генерировать из `catalog.yaml`, сохранив единый источник истины, что соответствует требованию не допускать расхождения навыка и собственного руководства CLI ([`SKILL.md`, строки 196–200](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L196-L200)).

Недостаток проявляется после срабатывания навыка. Агент получает 50 записей независимо от того, сколько из них реально разрешено и сколько относится к текущему намерению. AXI считает каждое поле расходом токенов и требует минимальной схемы, достаточной для выбора следующего действия ([`SKILL.md`, строки 28–36](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L28-L36)). Полная выдача каталога также приближается к чтению руководства заранее, тогда как контекстное раскрытие (`contextual disclosure`) предлагает раскрывать поверхность органически, несколькими релевантными следующими шагами, без навязывания лишней последовательности ([`SKILL.md`, строки 218–230](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L218-L230)).

Итог: вариант прост как справочник и не платит токенами до срабатывания, но после срабатывания его стоимость зависит от всего глобального каталога, а не от текущей задачи и разрешённого набора.

### Вариант B: маленький маршрутизатор по разрешённому локальному набору

Маршрутизатор содержит только краткие сигналы выбора для локально разрешённых инструментов, а подробности раскрывает через конкретный навык, домашний экран или `--help` выбранного AXI. Это ближе сразу к нескольким положениям AXI:

- токеновый бюджет является явным ограничением, TOON заявлен как средство сокращения токенов ([`SKILL.md`, строки 16–20](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L16-L20))
- постоянно загружаемый контекст требуется безжалостно минимизировать, а глубокие данные оставлять явным вызовам ([`SKILL.md`, строки 168–177](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L168-L177))
- описание фронтматтера навыка должно быть кратким триггером, ориентированным на намерение ([`SKILL.md`, строки 196–200](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L196-L200))
- контекстное раскрытие (`contextual disclosure`) показывает несколько логичных следующих действий, а не всю поверхность сразу ([`SKILL.md`, строки 218–231](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L218-L231))

Цена варианта — дополнительный слой данных. Если разрешённый набор редактируется вручную, он может расходиться с фактической доступностью или закреплённым каталогом. Маршрутизатор также не должен скрывать неоднозначность, например две записи `ado-axi`: при совпадении намерения ему нужно показать обе различимые цели или использовать уникальный идентификатор `owner/repo`, а не одно имя.

### Вывод

Для обнаружения доступных агенту инструментов предпочтительнее маленький маршрутизатор по разрешённому локальному набору. Он лучше ограничивает контекст текущим намерением и не загружает сведения о недоступных средствах. Практическая форма:

1. Компактный статический индекс содержит уникальный идентификатор, предметную область, статус `official` или `community` и admission-аннотацию только для разрешённых записей.
2. При неоднозначности маршрутизатор показывает несколько релевантных кандидатов и различает дубликаты по `owner/repo`.
3. Назначение, команды и справка выбранного AXI раскрываются отдельным навыком или вызовом по требованию.
4. Индекс генерируется из закреплённого `catalog.yaml` и отдельного разрешённого набора, а проверка сборки обнаруживает расхождения.

Полный статический навык со всеми 50 записями оправдан только как намеренно вызываемый справочник глобального каталога. Для повседневной маршрутизации он хуже соответствует минимальным схемам, токеновому бюджету и контекстному раскрытию AXI.
