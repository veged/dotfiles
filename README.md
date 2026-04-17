# dotfiles

Персональные `dotfiles` для macOS.

## Быстрый старт

```bash
git clone --recursive https://github.com/veged/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install
```

`install` запускает [Dotbot](https://github.com/anishathalye/dotbot), который:

* создаёт симлинки конфигов в `~/.config/` и `~/`
* ставит пакеты через Homebrew из `Brewfile`

## Что настраивается

| Компонент  | Путь                             | Описание                                                            |
| ---------- | -------------------------------- | ------------------------------------------------------------------- |
| `zsh`      | `home/zshrc`, `home/zprofile`    | Оболочка `zsh` с `antidote`, `fzf-tab` и `fast-syntax-highlighting` |
| `neovim`   | `config/nvim/`                   | Редактор с конфигурацией на Lua                                     |
| `kitty`    | `config/kitty/`                  | Терминал с темой Catppuccin                                         |
| `ghostty`  | `config/ghostty/`                | Альтернативный терминал                                             |
| `git`      | `home/gitconfig`, `gitalias.txt` | Конфигурация Git с алиасами и `nvimdiff`                            |
| `claude`   | `claude/`                        | Настройки Claude Code                                               |
| `codex`    | `codex/`                         | Настройки OpenAI Codex                                              |
| `ai`       | `ai/`                            | Общие инструкции, команды, навыки и плагины для AI-инструментов     |
| `opencode` | `config/opencode/`               | Настройки OpenCode                                                  |

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

## Структура

```text
dotfiles/
├── install              # Точка входа
├── install.conf.yaml    # Конфигурация Dotbot
├── Brewfile             # Зависимости Homebrew
├── home/                # → ~/.*  (с добавлением точки)
│   ├── zshrc
│   ├── zprofile
│   ├── gitconfig
│   └── ...
├── config/              # → ~/.config/*
│   ├── kitty/
│   ├── ghostty/
│   ├── nvim/
│   └── opencode/
├── ai/
│   ├── instructions/
│   ├── skills/
│   └── plugins/
├── codex/
│   ├── AGENTS.md
│   └── config.toml
└── claude/              # → ~/.claude/*
    ├── CLAUDE.md
    └── settings.json
```

Чтобы добавить новый конфигурационный файл, обычно достаточно положить его в нужную папку.

## AI-конфиги

Для AI-инструментов репозиторий разделяет канонический слой в `dotfiles` и рабочие слои в домашнем каталоге:

* `dotfiles/ai/` — канонический источник общих инструкций, навыков и плагинов
* `dotfiles/ai/skills/*` — локальные skill-пакеты в формате Agent Skills
* `dotfiles/ai/skills/skills.json` — внешние зависимости общих навыков
* `dotfiles/ai/plugins/plugins.json` — канонический реестр локальных плагинов Codex
* `~/.agents/instructions` — рабочий слой общих Markdown-инструкций
* `~/.agents/skills` — единственный source of truth для общих навыков; его собирает `./scripts/install-skills`
* `~/.claude/skills` и `~/.codex/skills` — assistant-specific discovery-слои, которые `./scripts/install-skills` обновляет через внутренний bootstrap из `~/.agents/skills`
* `~/.codex/plugins/dotfiles-local` — локальные bundle-ы плагинов Codex, которые собирает `./scripts/install-plugins`
* `~/.agents/plugins/marketplace.json` — локальный каталог плагинов Codex
* `~/.claude/CLAUDE.md` — тонкая обёртка, которая импортирует общие инструкции
* `~/.codex/AGENTS.md` и `~/.codex/config.toml` — слой адаптации Codex из `dotfiles/codex/`
* `~/.config/opencode/opencode.jsonc` — адаптер OpenCode на те же общие инструкции

Реестры описаны в минимальной форме:

* `ai/skills/skills.json` — словарь `source -> "*" | "skill" | ["skills"]` для внешних skill-зависимостей
* `ai/plugins/plugins.json` — словарь `plugin-name -> "source" | { source, skills }`
* для GitHub-источников можно использовать короткую форму `owner/repo` вместо полного `https://github.com/owner/repo`

`./scripts/install-plugins` только публикует personal marketplace и локальные bundle-ы. Сам plugin затем ставится через `Plugins` или `/plugins` и вызывается через `@plugin-name`, а не через slash-команду вида `/impeccable`.

`./scripts/bootstrap-agent-skills` не создаёт второй источник правды: он только публикует содержимое `~/.agents/skills` в assistant-specific discovery-слои и мигрирует известные общие bundle-ы вроде `codex-primary-runtime` из `~/.codex/skills`, не трогая `.system`. Обычно его напрямую вызывать не нужно: `./scripts/install-skills` делает это сам.

Если инструмент поддерживает общий формат проектных инструкций, предпочтителен `AGENTS.md`. Если инструмент ожидает собственный файл вроде `CLAUDE.md`, лучше делать тонкую обёртку над общим слоем, а не дублировать содержимое.

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
