# dotfiles

Конфигурационные файлы для macOS-окружения разработчика.

## Быстрый старт

```bash
git clone --recursive https://github.com/veged/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install
```

Скрипт `install` использует [dotbot](https://github.com/anishathalye/dotbot) для:
- Создания симлинков конфигов в `~/.config/` и `~/`
- Установки пакетов через Homebrew (`Brewfile`)

## Что настраивается

| Компонент | Путь | Описание |
|-----------|------|----------|
| **zsh** | `.zshrc`, `.zprofile`, `.zsh_plugins.txt` | Shell с antidote, fzf-tab, fast-syntax-highlighting |
| **neovim** | `nvim/` | Редактор с Lua-конфигом |
| **kitty** | `kitty/` | Терминал с Catppuccin темой |
| **ghostty** | `ghostty/` | Альтернативный терминал |
| **git** | `.gitconfig`, `gitalias.txt` | VCS с алиасами и nvimdiff |
| **claude** | `claude/` | Настройки Claude Code AI |

## CLI-инструменты

Вместо стандартных утилит используются современные альтернативы:

| Классика | Замена | Почему |
|----------|--------|--------|
| `grep` | `ugrep` | Fuzzy-поиск, булевы запросы |
| `find` | `fd` | Параллелизм, простой синтаксис |
| `sed` | `sd` | Preview-режим, литералы |
| `cat` | `bat` | Подсветка синтаксиса |
| `ls` | `eza` | Иконки, tree-вывод, git-статус |
| `cd` | `zoxide` | Умная навигация по истории |

## Особенности zsh

- **Автодополнение** через fzf-tab с превью файлов
- **Переключение светлой/тёмной темы** синхронизируется с macOS
- **VCS-алиасы** (`st`, `di`, `ci`, `co`, `pu`, `up`) автоматически работают и для git, и для arc
- **Клавиши**: `⌥←/→` слово, `⌘←/→` начало/конец строки, `⌘C/X` копирование в системный буфер

## Структура

```
dotfiles/
├── install              # Точка входа
├── install.conf.yaml    # Конфиг dotbot (симлинки, shell-команды)
├── Brewfile             # Homebrew зависимости
├── .zshrc               # Shell-конфиг
├── .gitconfig           # Git-настройки
├── nvim/                # Neovim (init.lua + плагины)
├── kitty/               # Kitty терминал
├── ghostty/             # Ghostty терминал
└── claude/              # Claude Code AI
    ├── CLAUDE.md        # Инструкции для AI
    └── settings.json    # Настройки
```

## Для AI-ассистентов

Этот репозиторий содержит персональные dotfiles. При работе с ним:

1. **Стиль кода**: Конфиги минималистичны, без избыточных комментариев
2. **Язык**: Общение на русском, код и конфиги на английском
3. **CLI**: Предпочтение современным инструментам (fd, eza, bat, sd, jq) — см. таблицу выше
4. **Shell**: zsh с antidote для управления плагинами
5. **Редактор**: neovim с Lua-конфигурацией
6. **Тема**: Catppuccin (Latte/Mocha) с автопереключением по системной теме macOS

Подробные инструкции для AI в `claude/CLAUDE.md`.

## Лицензия

Свободно для использования и адаптации.
