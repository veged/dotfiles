# Составные AI-пакеты

Канонический реестр находится в `ai/plugins/plugins.json`. Общая архитектура —
в [`../README.md`](../README.md).

Сюда попадают источники, которые нельзя безопасно разрезать на отдельные
`SKILL.md`: готовые plugins, commands, agents, scripts, project kits и деревья
с общими ресурсами. Источник всегда получается целиком.

Локальные source tree этого репозитория храни в `ai/plugins/<name>/`.
Настоящие команды клиента лежат в `commands/*.toml` или `commands/*.md`, а не
в `ai/instructions/`.

## Формат `plugins.json`

Реестр — словарь `package-name → spec`:

* `"owner/repo#<sha>"` — автоматически инвентаризировать весь источник
* `{ "source": "owner/repo#<sha>" }` — та же запись в явной форме
* `{ "source": "owner/repo#<sha>", "skills": "skill-name" }` — намеренно собрать оболочку одного навыка
* `{ "source": "owner/repo#<sha>", "skills": ["skill-a", "skill-b"] }` — выбрать несколько навыков
* `{ "source": "owner/repo#<sha>", "skills": ["!skill-a", "!skill-b"] }` — взять все обнаруженные навыки, кроме перечисленных
* `"./ai/plugins/name"` — локальный source tree

В `skills` нельзя смешивать включения и исключения.

Пользователь не указывает тип пакета и список клиентов. Установщик определяет
артефакты по manifests и структуре, сохраняет полное дерево и строит все
поддерживаемые проекции. Поле `kind` читается только для совместимости со
старыми записями и не записывается оркестратором.

Приоритет инвентаризации:

1. `.codex-plugin`, `.claude-plugin` и `.cursor-plugin` manifests.
2. `commands/`, `.claude/commands/`, skills и agents.
3. Общие `context/`, `knowledge-notes/`, `tokens/`, `components/`, `workflows/` и `scripts/`.
4. Если составных признаков нет — namespaced wrapper из найденных skills.

Недостающие manifests создаются в runtime-копии. Команды Claude, использующие
`${CLAUDE_PLUGIN_ROOT}`, адаптируются к фактическому корню пакета. TOML-команды
дополнительно проецируются в `skills/<command>/SKILL.md`, потому что Codex
индексирует навыки, но не `commands/*.toml`. Если пакет уже содержит одноимённый
навык, он имеет приоритет. Upstream в репозитории при этом не изменяется.

Локальная подмена remote-пакета: замени
`~/.codex/plugins/dotfiles-local/<name>` симлинком на рабочую копию. Установщик
не перетирает override; клиент без подходящего manifest явно отмечается как
неполная проекция.

Рабочая копия и установленный кэш Codex обновляются отдельно. После изменения
локального переопределения повтори `codex plugin add <name>@dotfiles-local`,
чтобы пересоздать установленную копию, затем открой новую задачу Codex.
`install-plugins` публикует источник в каталоге, но не переустанавливает его
в клиенте. Не заменяй содержимое `~/.codex/plugins/cache/` ссылками на внешние
исходники: такая старая установка может пропасть из списка навыков с ошибкой
`missing or invalid plugin.json`, даже если плагин включён и исходники доступны.

## Maintenance-команды

* `/dotfiles:install <что установить>` — найти компонент, получить полный SHA, инвентаризировать и записать минимальную декларацию.
* `/dotfiles:uninstall <что удалить>` — удалить каноническую декларацию и синхронизировать runtime без удаления секретов, данных и внешних binaries.

Новые maintenance-команды добавляй в `ai/plugins/dotfiles/commands/`.

## Установка

```bash
./scripts/install-plugins
./scripts/install-plugins --update
```

`--update` пересобирает remote-пакеты; `--force` оставлен алиасом. Скрипт
публикует Codex personal marketplace, Claude marketplace и Cursor local
projection, а затем печатает все обнаруженные namespaced commands.

Первичное включение пакета выполняется штатным CLI клиента:

```bash
codex plugin add <name>@dotfiles-local
claude plugin marketplace add ~/.agents/plugins/dotfiles-local --scope user
claude plugin install <name>@dotfiles-local --scope user
```

После установки нужен новый thread. Команды вызываются в namespaced форме,
например `/mblode:planning`.

## Повторы команд в Codex

Codex может создавать синтетические `source-command-*` из Markdown-команд. Четыре повтора `create-theme`, `audience`, `slide` и `structure` отключены по полным именам в `codex/.config.template.toml`, их функции доступны через основные навыки. Исходные команды сохранены. Очистка только кэша не решает проблему: клиент создаёт эти файлы повторно.
