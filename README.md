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
* прогоняет скрипты из `scripts/` — синхронизацию AI-слоёв (`install-skills`, `install-plugins`, `install-mcp`) и `install-remark`

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
│   ├── mcp.json
│   ├── skills/
│   └── plugins/
├── codex/
│   ├── AGENTS.md
│   └── .config.template.toml
└── claude/              # → ~/.claude/*
    ├── CLAUDE.md
    └── .settings.template.json
```

Чтобы добавить новый конфигурационный файл, обычно достаточно положить его в нужную папку.

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
