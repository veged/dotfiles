# dotfiles

Персональные `dotfiles` для macOS.

## Быстрый старт

```bash
git clone --recursive https://github.com/veged/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/personal setup
./install
```

`install` запускает [Dotbot](https://github.com/anishathalye/dotbot), который:

* создаёт симлинки конфигов в `~/.config/` и `~/`
* ставит пакеты через Homebrew из `Brewfile`
* прогоняет скрипты из `scripts/` — синхронизацию AI-слоёв (`install-skills`, `install-plugins`, `install-mcp`) и локальные инструменты (`install-remark`, `install-openspec`)

## Персонализация

Персонализация — это не выбранный набор инструментов и не стиль конфигов, а значения, которые у другого пользователя обязаны быть своими.

| Значение | Где искать | Что сделать |
| --- | --- | --- |
| Обязательные персональные переменные | `personal.required` | Заполнить через `./scripts/personal setup`; значения сохраняются в системное хранилище секретов. |
| Сервисные токены | `personal.required.yandex-tokens` | Получить автоматически через `./scripts/yandex-tokens sync`; для `DATALENS_TOKEN` отдельно выполнить `./scripts/yandex-tokens manual`. |
| URL форка | `README.md` | Если публикуешь свой форк, заменить команду `git clone`. |

Всё остальное — состав конфига. `Brewfile`, темы, shell-настройки, AI-инструкции, skills, plugins и MCP-серверы можно оставлять как есть или менять по вкусу.

`personal.required` хранит только имена переменных. Значения не коммитятся: `scripts/personal` читает уже заданные env vars или достаёт значения из macOS Keychain / `secret-tool` по имени переменной.

Полезные команды:

```bash
./scripts/personal setup
./scripts/personal check
./scripts/personal set GIT_EMAIL
./scripts/personal unset SOURCECRAFT_PAT
./scripts/personal set YANDEX_TOKENS_MULTITOOL_CLIENT_SECRET
./scripts/personal set YANDEX_TOKENS_MCP_STORE_CLIENT_SECRET
./scripts/yandex-tokens sync
./scripts/yandex-tokens manual
./scripts/yandex-tokens check
```

Перед первым `sync` сохрани OAuth client secrets двумя командами `personal set` выше: они не должны попадать в Git. `./scripts/yandex-tokens sync` повторяет CLI-потоки получения токенов для значений, которые умеют получаться автоматически, и складывает результат в то же хранилище (`macOS Keychain` / `secret-tool`). Для `DATALENS_TOKEN` остаётся отдельный ручной шаг: `./scripts/yandex-tokens manual`. Одноразовая миграция уже экспортированных значений: `./scripts/yandex-tokens import-current`.

Для проверки оставшихся жёстко прошитых личных маркеров:

```bash
ug -n -I --hidden 'OLD_NAME|OLD_EMAIL|OLD_TOKEN_FRAGMENT' README.md home ai codex config scripts
```

Сгенерированные файлы вроде `~/.claude/settings.json`, `~/.codex/config.toml`, `~/.cursor/mcp.json`, `~/.config/opencode/opencode.jsonc` и `~/.claude.json` править вручную не нужно: их пересобирает `./scripts/install-mcp`.

## Состав

| Путь | Куда попадает | Что настраивает |
| --- | --- | --- |
| `install` | — | Точка входа для Dotbot. |
| `install.conf.yaml` | — | Симлинки, Homebrew bundle и post-install скрипты. |
| `Brewfile` | Homebrew | CLI, desktop apps, fonts, taps и VS Code extensions. |
| `home/*` | `~/.*` | `zsh`, Git, ripgrep и shell-профиль. |
| `config/*` | `~/.config/*` | `nvim`, `kitty`, `ghostty`, OpenCode и связанные конфиги. |
| `ai/*` | `~/.agents/*` и generated configs | Общие инструкции, skills, plugins и MCP-реестр. |
| `claude/*` | `~/.claude/*` | Тонкая Claude-обёртка и template настроек. |
| `codex/*` | `~/.codex/*` | Codex-инструкции и template настроек. |
| `personal.required` | system secret storage | Имена обязательных персональных переменных. |
| `personal.required.yandex-tokens` | system secret storage | Имена сервисных токенов, загружаемых через `scripts/yandex-tokens`. |
| `scripts/*` | — | Синхронизация AI-слоёв, MCP и remark toolchain. |

Чтобы добавить новый конфигурационный файл, обычно достаточно положить его в нужную папку.

## CLI-инструменты

Часть стандартных утилит здесь заменена на более удобные аналоги:

| Классика       | Замена   | Зачем                                |
| -------------- | -------- | ------------------------------------ |
| `grep`         | `ugrep`  | Нечёткий поиск и булевы запросы      |
| `find`         | `fd`     | Параллелизм и простой синтаксис      |
| `sed`          | `sd`     | Предпросмотр и литеральные замены    |
| `cat`          | `bat`    | Подсветка синтаксиса                 |
| `ls`           | `eza`    | Деревья каталогов и статус Git       |
| `cd`           | `zoxide` | Быстрая навигация по истории         |
| `awk` для JSON | `jq`     | Работа с JSON без лишних пайпов      |
| —              | `yq`     | Работа с YAML, JSON, XML, CSV и TOML |

## Особенности `zsh`

* автодополнение через `fzf-tab` с предпросмотром файлов
* синхронизация светлой и тёмной темы с macOS
* VCS-алиасы `st`, `di`, `ci`, `co`, `pu`, `up` для Git и Arc
* удобные клавиши для навигации по строке и работы с буфером обмена

## AI-конфиги

Канонический слой лежит в `ai/`, рабочие артефакты раскладываются в `~/.agents/`, `~/.claude/` и `~/.codex/`. `install` собирает всё это сам. Подробности — в [`ai/README.md`](ai/README.md), детали пайплайнов — в [`ai/skills/README.md`](ai/skills/README.md) и [`ai/plugins/README.md`](ai/plugins/README.md).

## Для AI-ассистентов

При работе с этим репозиторием важно помнить несколько вещей:

* общение ведётся на русском языке
* код и конфиги пишутся на английском
* предпочтительны современные CLI-инструменты: `fd`, `eza`, `bat`, `sd`, `jq`, `yq`
* основная оболочка — `zsh` с `antidote`
* основной редактор — `neovim` с конфигурацией на Lua
* основная тема — Catppuccin с автопереключением по системной теме macOS

Подробные инструкции для AI лежат в `claude/CLAUDE.md` и `codex/AGENTS.md`.

## Лицензия

Свободно для использования и адаптации.
