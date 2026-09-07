# AXI (`kunchenguid/axi`): исследование официального репозитория

Дата исследования: 31 августа 2026 года.

Зафиксированный снимок: ветка `main`, коммит [`d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb`](https://github.com/kunchenguid/axi/commit/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb) от 28 августа 2026 года. Все ссылки на файлы ниже привязаны к этому коммиту, поэтому выводы воспроизводимы. Использованы только первичные источники внутри официального репозитория: README, спецификация навыка, исходный код, манифесты, рабочие процессы CI, результаты испытаний и релизы. Репозитории отдельных реализаций из каталога не исследовались.

## Краткий вывод

AXI, Agent eXperience Interface, — не протокол, не сервер и не единый исполняемый файл. Это стандарт проектирования CLI для автономных агентов, которые вызывают команды через оболочку. Стандарт ставит расход токенов в один ряд с обычными требованиями к интерфейсу и формулирует десять принципов: компактный TOON-вывод, малые схемы по умолчанию, управляемое усечение, заранее вычисленные итоги, однозначные пустые результаты, структурированные ошибки и коды возврата, контекст в начале сессии, полезные данные при запуске без аргументов, контекстные подсказки и единообразная справка. [README, строки 13–17 и 74–95](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/README.md#L13-L95), [полная спецификация, строки 8–259](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L8-L259)

Практически репозиторий состоит из четырёх частей:

1. Нормативные данные и документация: `principles.yaml`, полная спецификация в `.agents/skills/axi/SKILL.md`, каталог в `catalog.yaml`, README и сайт.
2. Устанавливаемый навык `axi`, который помогает агенту строить и проверять AXI-совместимые CLI.
3. Отдельная библиотека `axi-sdk-js` для Node.js, реализующая общий диспетчер команд, TOON-сериализацию, ошибки, обновление и интеграции начала сессии.
4. Два набора сравнительных испытаний: для GitHub и управления браузером. [Соглашения репозитория, строки 47–64](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/CONTRIBUTING.md#L47-L64)

Корневой `package.json` имеет имя `axi-repo-tools` и `"private": true`, поэтому команды вида `npm install axi` не соответствуют текущей архитектуре. Для готовой функциональности устанавливают конкретный AXI, для авторских правил — навык, для разработки собственного Node.js CLI — `axi-sdk-js`. [Корневой манифест, строки 1–12](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/package.json#L1-L12)

Для dotfiles наиболее предсказуемая модель — отдельно выбрать, что именно требуется: правила AXI как закреплённый навык, конкретные команды вроде `gh-axi` или библиотека для собственных CLI. Автоматическую установку хуков стоит включать только после решения о владельце пользовательских конфигов, потому что SDK изменяет файлы Claude Code, Codex и OpenCode, а даже проектный режим включает пользовательский флаг Codex. [Документация SDK, строки 130–184](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L130-L184)

## Назначение и модель взаимодействия

AXI отвечает на узкую задачу: сделать оболочечные команды удобными именно для модели, а не для человека. Авторы противопоставляют этот подход обычным CLI и структурированным протоколам вроде MCP, у которых, по их тезису, есть дополнительная стоимость схем, поиска инструментов и повторных обращений. AXI остаётся обычной командой в `PATH`, а агент использует её через выполнение команд оболочки. [README, строки 13–17](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/README.md#L13-L17), [описание навыка, строки 3–10](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L3-L10)

Ключевой интерфейс данных — TOON на `stdout`. Внутри программы предлагается сохранять обычные объекты, а преобразование выполнять только на границе вывода. Для списков стандарт рекомендует 3–4 поля, для больших полей — превью с общим размером и явным `--full`, для ошибок — тот же структурированный формат на `stdout`. `stderr` оставлен для журналов, прогресса и диагностики. Успех и идемпотентный пропуск имеют код `0`, обычная ошибка — `1`, ошибка использования — `2`. [Спецификация, строки 16–43, 45–67 и 95–145](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L16-L145)

AXI не определяет общий сетевой транспорт, схему авторизации или универсальный API. Эти свойства остаются у конкретной реализации. Каталог прямо показывает разные варианты: обёртки над существующими CLI, обёртки над MCP, прямые REST-вызовы, локальные файловые инструменты и даже AXI, встроенный в навык. [Каталог, строки 10–33 и последующие записи](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L10-L33)

## Архитектура репозитория

### Спецификация и генерация документации

`principles.yaml` — единый источник номеров, названий и кратких формулировок десяти принципов. Полное нормативное описание находится в `SKILL.md`. Скрипт `scripts/generate-docs.mjs` строит размеченные области README и сайта из `principles.yaml` и `catalog.yaml`, проверяет совпадение заголовков полной спецификации и завершает `--check` с ошибкой при рассинхронизации. [Комментарий в `principles.yaml`, строки 1–8](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/principles.yaml#L1-L8), [генератор, строки 1–25 и 224–293](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/scripts/generate-docs.mjs#L1-L25)

`catalog.yaml` аналогично является единым источником официального и общественного каталогов. Официальные реализации на снимке — `gh-axi`, `chrome-devtools-axi`, `lavish-axi` и `quota-axi`. Добавление в общественный каталог требует записи с именем, URL, автором, предметной областью и описанием, затем `pnpm run docs:gen`. [Каталог, строки 1–28](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/catalog.yaml#L1-L28), [порядок добавления, строки 36–45](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/CONTRIBUTING.md#L36-L45)

Проект декларирует консервативное развитие. Изменения принципов должны проверяться на представительных агентах, моделях и задачах. Для принятия реализации в каталог требуется независимое чтение исходного кода на закреплённой ревизии, но это не заявлено как исчерпывающий аудит посторонних свойств пакета. Официальный раздел каталога изменяет только владелец проекта. [VISION, строки 1–33](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/VISION.md#L1-L33)

### Устанавливаемый навык

`.agents/skills/axi/SKILL.md` — и документация, и устанавливаемый навык с фронтматтером `name: axi`. В репозитории `.claude/skills` является символической ссылкой на `../.agents/skills`, что даёт Claude-совместимое представление того же источника без копирования. [Определение навыка](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L1-L10), [ссылка `.claude/skills`](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.claude/skills)

Навык предназначен для построения, изменения и проверки CLI, с которыми агенты работают через оболочку. Это не навык для вызова единого «сервиса AXI» и не установщик конкретных `gh-axi` или `chrome-devtools-axi`. [Фронтматтер навыка, строки 1–6](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L1-L6)

### `axi-sdk-js`

SDK построен вокруг `runAxiCli(options)`. Объект настройки задаёт описание и верхнеуровневую справку, карту обработчиков `commands`, обработчик домашнего представления `home`, а при необходимости — версию, имя пакета, явный `argv`, инициализацию, ленивое разрешение контекста, собственные форматировщики ошибок и неизвестных команд. Таким образом, главная точка расширения — обычные функции-обработчики, возвращающие строку или объект для TOON-сериализации. [Тип `AxiCliOptions`, строки 25–47](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/cli.ts#L25-L47), [пример настройки, строки 27–53](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L27-L53)

Диспетчер имеет форму `<bin> <command> ...args ...flags`. Флаг перед командой отклоняется с кодом `2`. `--help` на уровне подкоманды обслуживается через `getCommandHelp`, домашний обработчик вызывается при отсутствии команды, а ошибки и сбои разрешения контекста проходят через единый форматирующий рубеж. [Реализация диспетчера, строки 78–178](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/cli.ts#L78-L178)

Объекты кодируются единственной прямой рабочей зависимостью `@toon-format/toon`. Домашнее представление автоматически получает `bin` с сокращённым домашним каталогом и `description`. Для быстрого `-v`, `-V` или `--version` существует отдельный экспорт `axi-sdk-js/fast-path`, не импортирующий граф основной команды. [Вывод, строки 1–68](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/output.ts#L1-L68), [быстрый путь](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/fast-path.ts#L1-L58)

Команда `update` зарезервирована SDK, но конкретный инструмент может переопределить её своим обработчиком. Встроенный вариант определяет имя и версию по ближайшему `package.json`, проверяет `https://registry.npmjs.org/<package>/latest` с тайм-аутом 20 секунд и резервным `npm view`, распознаёт глобальные установки npm и pnpm, Homebrew и временный запуск `npx`, затем либо выполняет соответствующее обновление, либо печатает ручную команду. `update --check` и псевдоним `--dry-run` ничего не устанавливают. [Описание обновления, строки 56–97](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L56-L97), [реализация, строки 11–12, 192–445 и 556–879](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/update.ts#L192-L445)

### Сравнительные испытания

Испытание GitHub содержит 425 запусков: 17 задач, пять вариантов интерфейса и пять повторов. Все задачи выполнялись на `openclaw/openclaw`, агентом и судьёй был Claude Sonnet 4.6, а траектории и вердикты сохранены в репозитории. В этом наборе `gh-axi` получил 100% успешных запусков и среднюю стоимость `$0.050`, но это результат конкретного стенда, а не универсальная гарантия. [Описание и результаты, строки 3–41](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/bench-github/published-results/STUDY.md#L3-L41), [методика, строки 81–97](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/bench-github/published-results/STUDY.md#L81-L97)

Испытание браузера содержит 490 запусков, также с Claude Sonnet 4.6 как агентом и судьёй. Сам отчёт отмечает смещение: варианты MCP создавали Chrome для каждого запуска, что добавляло около 2–5 секунд холодного старта, схемы MCP занимали около 28,5% входных токенов, а запрет инструментов не удалял их из видимого агенту списка. Отдельные задачи также показывают, что AXI не всегда был самым дешёвым или быстрым вариантом. [Сводка и методика, строки 3–27](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/bench-browser/published-results/report.md#L3-L27), [пример `github_issue_investigation`, строки 98–108](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/bench-browser/published-results/report.md#L98-L108)

README отдельно предупреждает, что опубликованы только результаты Claude Sonnet 4.6, хотя стенды принимают другие модели, и результаты других моделей могут отличаться. Следовательно, цифры подтверждают жизнеспособность принципов в двух предметных областях, но не доказывают превосходство AXI для каждого агента, модели или задачи. [README, строки 47–51](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/README.md#L47-L51)

## Установка и эксплуатационные сценарии

### Готовые реализации

README предлагает глобально установить эталонные реализации:

```sh
npm install -g gh-axi
npm install -g chrome-devtools-axi
```

После этого агенту достаточно короткой инструкции в `CLAUDE.md` или `AGENTS.md`, например использовать соответствующую команду для GitHub или браузера. Это независимые пакеты из других репозиториев, а не бинарники данного корневого пакета. [README, строки 53–71](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/README.md#L53-L71)

### Навык с принципами

Официальная команда установки навыка:

```sh
npx skills add kunchenguid/axi
```

Она устанавливает `.agents/skills/axi/SKILL.md`, чтобы агент мог обращаться к правилам при разработке CLI. В документации не закреплены версия пакета `skills`, Git-коммит репозитория или точные целевые каталоги для каждого клиента, поэтому для воспроизводимых dotfiles эту команду нельзя считать сама по себе закреплённой установкой. [README, строки 173–183](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/README.md#L173-L183)

### Библиотека для собственного CLI

SDK устанавливается как обычная зависимость:

```sh
npm install axi-sdk-js
```

На снимке версия манифеста — `0.1.11`, требование — Node.js `>=20`, лицензия — MIT, единственная прямая рабочая зависимость — `@toon-format/toon ^2.1.0`. Последний соответствующий релиз — [`axi-sdk-js-v0.1.11`](https://github.com/kunchenguid/axi/releases/tag/axi-sdk-js-v0.1.11), опубликованный 21 августа 2026 года. [Манифест SDK, строки 1–55](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/package.json#L1-L55)

SDK заявляет macOS, Linux и Windows. Код отдельно учитывает Windows-обёртки npm, а переносимая команда хука используется по короткому имени только после проверки, что найденный через `PATH` файл указывает на тот же исполняемый файл. В противном случае сохраняется абсолютный путь. [Документация SDK, строки 1–8 и 205–212](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L1-L8), [разрешение команды хука, строки 520–614](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/hooks.ts#L520-L614)

### Разработка самого репозитория

Репозиторий — рабочее пространство pnpm. Для локальной разработки авторы требуют Node 24, чтобы совпадать с CI, `pnpm install --frozen-lockfile`, форматирование, линтинг, сборку TypeScript и тесты Vitest. Node 24 — требование к разработке репозитория, тогда как опубликованный SDK допускает Node `>=20`. [CONTRIBUTING, строки 47–64](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/CONTRIBUTING.md#L47-L64), [CI SDK](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.github/workflows/axi-sdk-js-ci.yml#L21-L34)

## Поддерживаемые агенты и редакторы

Явно поддерживаемые цели для контекста начала сессии — Claude Code, Codex и OpenCode. Для Claude Code и Codex SDK создаёт нативные `SessionStart`-хуки. Для OpenCode он создаёт управляемый JavaScript-плагин, который добавляет домашнее представление AXI в системный контекст. [Спецификация, строки 164–183](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L164-L183), [документация SDK, строки 130–167](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L130-L167)

Вторичный путь — стандарт Agent Skills. Спецификация говорит, что навык может работать в любом агенте, поддерживающем этот формат, но официальный репозиторий не приводит исчерпывающего списка клиентов и не описывает отдельные расширения для VS Code, JetBrains IDE, Cursor или других редакторов. Поэтому подтверждённая совместимость ограничивается тремя названными приложениями для хуков и общим форматом навыка для остальных. [Спецификация, строки 185–204](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L185-L204)

Короткая инструкция в `CLAUDE.md` или `AGENTS.md` — ещё один, самый простой слой обнаружения готового AXI. Это рекомендация README, а не программно проверяемая интеграция. [README, строки 67–71](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/README.md#L67-L71)

## Модель конфигурации

У AXI как стандарта нет единого пользовательского файла `axi.yaml`, фоновой службы или центрального реестра. Нормативная конфигурация самого проекта — это `principles.yaml` и `catalog.yaml`. Конфигурация конкретной команды определяется её реализацией, а SDK получает структуру команд как объект JavaScript или TypeScript. [Корневой манифест и скрипты](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/package.json#L1-L22), [тип SDK](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/cli.ts#L25-L47)

Для интеграций начала сессии SDK принимает `scope: "user" | "project"`, `projectDir`, `marker`, `execPath`, `binaryNames`, альтернативные точки входа, тайм-аут, предикат безопасности и обработчик ошибок. По умолчанию область пользовательская, а тайм-аут равен 10 секундам. [Интерфейс настройки, строки 39–77](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/hooks.ts#L39-L77), [установка, строки 692–775](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/hooks.ts#L692-L775)

Целевые пути:

| Приложение | Пользовательская область | Область проекта |
| --- | --- | --- |
| Claude Code | `~/.claude/settings.json` | `<projectDir>/.claude/settings.json` |
| Codex, хуки | `~/.codex/hooks.json` | `<projectDir>/.codex/hooks.json` |
| Codex, флаг | `~/.codex/config.toml` | всё равно `~/.codex/config.toml` |
| OpenCode | `~/.config/opencode/plugins/` | `<projectDir>/.opencode/plugins/` |

Таблица и исключение для флага Codex зафиксированы в документации SDK. Даже установка хуков на уровне проекта включает `[features].hooks = true` в пользовательском `~/.codex/config.toml`. Удаление хуков этот общий флаг не выключает. [Документация SDK, строки 169–184](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L169-L184)

Установка и удаление идентифицируют управляемые записи по вхождению `marker` в команду. Удаление сохраняет посторонние группы и хуки. OpenCode-файл перезаписывается или удаляется только при наличии специальной управляемой метки, иначе SDK сообщает об отказе через `onError`. [Обновление и удаление хуков, строки 108–245 и 874–926](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/hooks.ts#L108-L245), [защита OpenCode-файла, строки 485–515](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/hooks.ts#L485-L515)

## Точки расширения

1. **Новый AXI.** Реализовать обычный неинтерактивный CLI по десяти принципам. JavaScript SDK необязателен, стандарт не привязан к языку. Проект готов принимать SDK для других языков, если они повторяют общую структуру и не раздувают общую поверхность. [VISION, строки 29–38](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/VISION.md#L29-L38)
2. **Обработчики SDK.** Добавлять команды через `commands`, домашнее представление через `home`, ленивый предметный контекст через `resolveContext`, собственную справку и форматирование ошибок через соответствующие функции. [Исходный интерфейс SDK, строки 25–47](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/cli.ts#L25-L47)
3. **Интеграция сессии.** Вызвать `installSessionStartHooks()` только из явной команды настройки, проверить состояние через `sessionStartHookStatus()` и удалить управляемые записи через `uninstallSessionStartHooks()`. [Документация API, строки 111–128 и 130–167](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L111-L167)
4. **Собственное обновление.** Зарегистрировать обработчик `update`, чтобы заменить встроенную политику обновления SDK. [Документация обновления, строки 56–97](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L56-L97)
5. **Каталог.** Добавить проверенную реализацию в `community`, затем сгенерировать README и сайт. Раздел `official` закрыт для сторонних правок. [CONTRIBUTING, строки 36–45](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/CONTRIBUTING.md#L36-L45), [VISION, строка 27](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/VISION.md#L27)
6. **Навык обнаружения.** Поставлять статический `SKILL.md`, сгенерированный из домашнего представления CLI, исключать живое состояние и использовать в примерах неинтерактивные команды, способные работать без глобальной установки. [Спецификация, строки 185–204](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L185-L204)

## Зависимости и цепочка поставки

Опубликованный SDK минимален: Node.js `>=20` и одна прямая рабочая зависимость `@toon-format/toon ^2.1.0`. TypeScript, Vitest, типы Node и `vite-node` — зависимости разработки. Корневые инструменты документации отдельно используют ESLint, Prettier и YAML. [Манифест SDK, строки 44–55](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/package.json#L44-L55), [корневой манифест, строки 14–22](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/package.json#L14-L22)

Рабочее пространство pnpm включает корень, `packages/*` и оба стенда. Оно задаёт `minimumReleaseAge: 10080` со строгой проверкой, исключает из этого правила собственный `axi-sdk-js` и разрешает сценарии сборки только для `esbuild`. [Настройка рабочего пространства](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/pnpm-workspace.yaml#L1-L14)

CI устанавливает зависимости с `--frozen-lockfile`, запускает форматирование, линтинг, сборку и тесты. Публикация SDK идёт через `npm publish --access public --provenance` с разрешением GitHub Actions `id-token: write`. При этом большинство используемых действий закреплены только на старших тегах вроде `actions/checkout@v4` и `googleapis/release-please-action@v4`, а не на неизменяемых SHA. [CI SDK](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.github/workflows/axi-sdk-js-ci.yml#L21-L34), [публикация, строки 12–54](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.github/workflows/axi-sdk-js-release-please.yml#L12-L54)

Человеческие PR в `main` должны проходить через `no-mistakes`. Проверяющее действие `require-no-mistakes` закреплено на конкретном коммите, а сгенерированные release-файлы защищены отдельным рабочим процессом. Это повышает воспроизводимость входящего изменения, но не заменяет аудит публикуемого пакета и зависимостей. [CONTRIBUTING, строки 1–16](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/CONTRIBUTING.md#L1-L16), [закреплённое действие](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.github/workflows/no-mistakes-required.yml#L64-L72)

## Безопасность

### Защитные свойства

- Спецификация требует неинтерактивности, ранней проверки неизвестных флагов, идемпотентных мутаций, структурированных ошибок без необработанных ответов зависимостей и различимых кодов выхода. Это уменьшает риск того, что агент продолжит работу после молча проигнорированного параметра. [Спецификация, строки 95–145](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L95-L145)
- Хуки должны устанавливаться только явной пользовательской командой, а повторная установка должна быть идемпотентной. Обычный `runAxiCli()` сам хуки не ставит. [Спецификация, строки 164–179](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L164-L179), [документация SDK, строки 130–132](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L130-L132)
- Сгенерированный OpenCode-плагин вызывает исполняемый файл через `spawn(..., { shell: false })`, ограничивает выполнение тайм-аутом и не перезаписывает файл без управляемой метки. Переносимое имя команды допускается только после проверки соответствия реальному исполняемому файлу. [Генератор плагина, строки 338–410](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/hooks.ts#L338-L410), [разрешение команды, строки 520–558](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/hooks.ts#L520-L558)
- Удаление хуков сохраняет несвязанные записи и не выключает общий флаг Codex, который может требоваться другим AXI. [Реализация удаления, строки 874–926](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/hooks.ts#L874-L926)

### Риски и границы

- **Контекст как поверхность внедрения инструкций.** OpenCode-плагин без фильтрации добавляет полный `stdout` домашнего представления AXI в системный контекст. Claude Code и Codex получают тот же класс данных через `SessionStart`. Если конкретный AXI включает названия, комментарии или иное недоверенное удалённое содержимое, оно оказывается в высокоприоритетном контексте агента. Это вывод из механизма внедрения, а не заявленная авторами гарантия безопасности. [Код внедрения OpenCode, строки 338–410](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/hooks.ts#L338-L410), [требование компактного контекста, строки 164–183](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L164-L183)
- **Фоновая активность при старте сессии.** После явной установки хук запускает домашнее представление на каждой сессии. Конкретный AXI может при этом читать рабочее состояние, обращаться к сети или использовать учётные данные. Репозиторий требует ограничивать контекст текущим каталогом и токен-бюджетом, но общую модель разрешений не задаёт. [Спецификация, строки 149–179](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L149-L179)
- **Запись в общие конфиги.** Пользовательская установка меняет конфиги трёх приложений. Проектная установка всё равно меняет `~/.codex/config.toml`, а удаление не возвращает этот флаг в прежнее состояние. Это важно, если dotfiles считает эти файлы полностью декларативными. [Документация областей, строки 169–184](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L169-L184)
- **Широкое совпадение маркера.** Управляемый JSON-хук распознаётся через `hook.command.includes(marker)`. Теоретически посторонняя команда, случайно содержащая ту же строку, может быть признана управляемой и изменена или удалена. Это вывод из исходного кода. [Проверка маркера, строки 108–110](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/hooks.ts#L108-L110)
- **Самообновление доверяет `latest`.** Явная команда `<tool> update` для распознанной глобальной установки запускает npm, pnpm или Homebrew и устанавливает текущую последнюю версию. Проверочный режим безопаснее для декларативно управляемой машины. Конкретный CLI может переопределить `update`. [План обновления, строки 402–445](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/update.ts#L402-L445), [выполнение, строки 803–879](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/update.ts#L803-L879)
- **Установка навыка не закреплена.** Документированная команда `npx skills add kunchenguid/axi` не содержит версии установщика или ревизии репозитория. Для dotfiles это риск дрейфа и выполнения изменившегося кода установщика. [README, строки 173–181](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/README.md#L173-L181)
- **Каталог не равен аудиту безопасности.** Правила приёма требуют чтения исходников на закреплённой версии для проверки принципов AXI, но прямо допускают не проводить исчерпывающий аудит несвязанных свойств пакета. Каждую реализацию и её цепочку зависимостей надо оценивать отдельно. [VISION, строки 13–25](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/VISION.md#L13-L25)
- **Лицензия без гарантий.** Код и документация распространяются по MIT с обычным отказом от гарантий и ответственности. При копировании существенных частей в dotfiles требуется сохранить уведомление об авторских правах и текст разрешения. [LICENSE](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/LICENSE)

## Ограничения

1. AXI оптимизирует интерфейс для агента, но не решает авторизацию, разграничение прав, хранение секретов, сетевые повторы или транзакционность. Эти свойства принадлежат конкретной реализации. [Спецификация определяет только интерфейсные принципы](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L8-L259)
2. Обязательность TOON создаёт зависимость от поддержки и корректного понимания этого формата агентом. SDK сохраняет внутри обычные объекты, но внешняя автоматизация, ожидающая JSON, потребует отдельного режима конкретного CLI или преобразователя, которого общий SDK не предоставляет. [Спецификация, строки 14–25](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L14-L25), [реализация вывода](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/output.ts#L1-L68)
3. `runAxiCli()` предполагает команду перед флагами. CLI с привычными глобальными флагами до команды придётся нормализовать на входной границе или не строить на этом диспетчере. [Документация SDK, строки 20–24](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L20-L24)
4. Общий SDK существует только для JavaScript/Node.js. Другие языки разрешены концептуально, но соответствующих пакетов в `packages/` текущего снимка нет. [VISION, строки 29–38](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/VISION.md#L29-L38), [рабочее пространство](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/pnpm-workspace.yaml#L1-L4)
5. Интеграция сессии реализована только для Claude Code, Codex и OpenCode. Для других клиентов остаётся статический Agent Skill или ручная инструкция. [Спецификация, строки 170–204](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L170-L204)
6. Результаты испытаний ограничены одной моделью, одним судьёй той же модели, небольшим числом предметных областей и пятью повторами. В браузерном стенде есть известные различия в стоимости запуска вариантов. [README, строки 47–51](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/README.md#L47-L51), [методика GitHub](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/bench-github/published-results/STUDY.md#L3-L10), [ограничения браузерного стенда](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/bench-browser/published-results/report.md#L15-L27)
7. Репозиторий быстро развивается: исходный коммит датирован мартом 2026 года, а SDK к августу дошёл до `0.1.11`. Номер `0.x` и консервативная декларация развития сами по себе не обещают стабильность API. История релизов показывает регулярные изменения хуков, обновления и быстрого пути версии. [Исходный коммит](https://github.com/kunchenguid/axi/commit/ee125cdf3c35bffcee5a12ae3af2ce7212336876), [релизы SDK](https://github.com/kunchenguid/axi/releases?q=axi-sdk-js&expanded=true), [последний релиз](https://github.com/kunchenguid/axi/releases/tag/axi-sdk-js-v0.1.11)

## Варианты интеграции в dotfiles

Ниже — варианты, основанные на устройстве проекта. Они не применялись и не сверялись с локальными конфигами.

### Вариант A. Только правила проектирования

Закрепить `.agents/skills/axi/SKILL.md` на конкретном коммите в управляемом dotfiles каталоге и подключать его к каталогам навыков нужных агентов. Это даёт воспроизводимость и не ставит исполняемый код. При копировании следует сохранить уведомление MIT. Официальная команда `npx skills add` проще, но не закрепляет ревизию в самой команде. [Навык](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md), [официальная установка](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/README.md#L173-L183), [лицензия](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/LICENSE)

### Вариант B. Конкретные AXI-команды

Установить выбранные пакеты через уже используемый менеджер глобальных CLI и добавить короткое правило выбора инструмента в `AGENTS.md` или `CLAUDE.md`. Версии пакетов лучше закреплять средствами dotfiles, а встроенный `update` использовать только в режиме `--check`, чтобы не создавать второго владельца версий. [Быстрый старт](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/README.md#L53-L71), [политика обновления SDK](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L56-L89)

### Вариант C. Собственные агентские CLI

Добавить `axi-sdk-js` как закреплённую зависимость отдельного Node.js-проекта. Команды и домашнее представление остаются в коде проекта. Интеграцию начала сессии следует выставить как явную подкоманду настройки, а не вызывать при обычном запуске. Для чувствительных источников домашнее представление должно содержать только безопасный компактный итог, потому что оно попадёт в контекст каждого нового сеанса. [Пример SDK](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L27-L53), [настройка хуков](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L130-L167)

### Вариант D. Управляемые хуки

Если конфиги агентов уже считаются декларативной частью dotfiles, безопаснее выбрать одного владельца: либо dotfiles формирует нужные записи, либо явная команда AXI управляет ими. Совместное владение может давать постоянные расхождения форматирования и состава. Проектная область уменьшает охват, но не устраняет запись в пользовательский `~/.codex/config.toml`. Перед автоматизацией полезно использовать read-only `sessionStartHookStatus()` и предусмотреть `uninstallSessionStartHooks()` для управляемых записей. [Области и статус, строки 169–203](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L169-L203), [реализация статуса, строки 839–869](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/hooks.ts#L839-L869)

## Факты, требующие локального решения

Локальные конфиги намеренно не исследовались. Перед внедрением необходимо решить:

1. Нужны ли только принципы AXI, готовые реализации или SDK для собственного кода. Это три независимых артефакта с разными рисками установки. [Корневой README](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/README.md#L53-L71)
2. Какие агенты реально используются: Claude Code, Codex, OpenCode или клиенты только с поддержкой Agent Skills. [Поддерживаемые цели](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L170-L204)
3. Где должен жить навык и каким способом закреплять версию: копия с уведомлением MIT, Git-подмодуль, закреплённая загрузка или незакреплённый `npx skills add`. Официальный репозиторий точной политики dotfiles не задаёт. [Команда установки](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/README.md#L173-L183)
4. Кто владеет `~/.claude/settings.json`, `~/.codex/hooks.json`, `~/.codex/config.toml` и каталогом плагинов OpenCode: dotfiles или SDK. [Таблица путей](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L169-L184)
5. Нужна ли пользовательская область хуков или область отдельных проектов. Для Codex проектная область всё равно требует пользовательского флага. [Документация областей](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L169-L184)
6. Допустимо ли выполнять домашнее представление конкретного AXI на каждой сессии, какие данные оно может читать и какие недоверенные строки может помещать в контекст. [Модель контекста](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/.agents/skills/axi/SKILL.md#L149-L183)
7. Есть ли в среде Node.js `>=20` для SDK и Node 24 для разработки самого репозитория. [Манифест SDK](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/package.json#L44-L55), [CONTRIBUTING](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/CONTRIBUTING.md#L47-L64)
8. Какой менеджер должен устанавливать и обновлять глобальные AXI: npm, pnpm, Homebrew или иной механизм dotfiles. Встроенный `update` распознаёт не все способы и в неизвестном случае только предлагает npm-команду. [План обновления](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/src/update.ts#L192-L445)
9. Нужно ли запрещать исполняющее обновление и оставлять только `update --check`, чтобы версии менялись исключительно через dotfiles. [Документация обновления](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/packages/axi-sdk-js/README.md#L56-L89)
10. Какие конкретные AXI допустимы по модели секретов и полномочий. Наличие в официальном или общественном каталоге не заменяет отдельный аудит их репозиториев и зависимостей. [Правила проверки каталога](https://github.com/kunchenguid/axi/blob/d28c5e79aa7ee7a59a386fc34125f8cd1470fbeb/VISION.md#L13-L27)

## Итоговая рекомендация

Для начала стоит интегрировать только закреплённую версию навыка AXI и короткие правила выбора уже одобренных CLI. Это почти не расширяет исполняемую поверхность и позволяет применять принципы при разработке. `axi-sdk-js` имеет смысл добавлять только в конкретный собственный CLI. Хуки начала сессии следует включать адресно после решения о владельце конфигов и проверки содержимого домашнего представления. Глобальное самообновление лучше оставить в проверочном режиме, если версии пакетов уже управляются dotfiles.
