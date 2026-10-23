# Архитектура AI-конфигов

`~/dotfiles` — канонический источник AI-конфигурации. Рабочие артефакты раскладываются в домашний каталог.

## Канонический слой

* `ai/instructions/*` — общие Markdown-инструкции
* `ai/skills/*` + `ai/skills/skills.json` — локальные skill-пакеты и внешние зависимости, см. [`skills/README.md`](skills/README.md)
* `ai/plugins/plugins.json` — реестр составных AI-пакетов, см. [`plugins/README.md`](plugins/README.md)
* `ai/mcp.json` — реестр MCP-серверов в формате `server-name → { enabled, transport, command/url, install, clients }` для Codex, Cursor, Claude и OpenCode
* `claude/.settings.template.json`, `codex/.config.template.toml`, `config/opencode/.opencode.template.jsonc` — шаблоны non-MCP настроек клиентов

Удалённый Git-источник фиксируется полным commit SHA прямо в locator:
`owner/repo#<sha>` или `owner/repo#<sha>:path/to/subdirectory`. Часть после
двоеточия использует семантику Git `revision:path`. Плавающие ветки и теги
оркестратор разрешает до записи в реестр.
Локальные источники навыков и плагинов задаются явным путём: `~/...`, `/...`, `./...` или `../...`.

## AI-инструкции

`ai/instructions/*.md` — source of truth для общих AI-инструкций.
Instruction id — это filename без `.md`; projected files используют то же filename под `~/.agents/instructions/`.
Проекции Claude, Codex, Cursor и OpenCode генерируются из одного набора Markdown-файлов в детерминированном порядке имён. Cursor получает локальное глобальное правило `~/.cursor/rules/dotfiles.mdc` с `alwaysApply: true` и полным общим текстом. Ссылка на файл внутри правила не подставляет его содержимое в контекст автоматически, поэтому обязательные инструкции включены в генерируемое тело ([документация Cursor](https://cursor.com/help/customization/rules)).

Если нужен явный текстовый триггер внутри instruction-слоя, выноси его в отдельный файл `ai/instructions/*-activation.md`, а не в доменный документ. Это уменьшает prompt-шум, даёт отдельный instruction id и упрощает независимые правки правил и активации.

Если нужен настоящий Codex slash-command вида `/name`, не клади его в `ai/instructions/`. Делай локальный plugin root с `commands/*.toml` и регистрируй plugin в `ai/plugins/plugins.json`.

После добавления, удаления, переименования или редактирования файлов инструкций запускай `./scripts/install-mcp --instructions-only`, затем `./scripts/install-mcp --check-instructions`. Эти режимы не загружают персональные секреты и не пересобирают настройки моделей, навыков, плагинов и MCP. `--sync-only` и `--check` по-прежнему синхронизируют и проверяют весь набор конфигураций.

## Рабочие каталоги

* `~/.agents/instructions` — projected Markdown-инструкции
* `~/.agents/skills` — единственный source of truth общих навыков
* `~/.agents/plugins/marketplace.json` — локальный каталог плагинов Codex
* `~/.agents/plugins/dotfiles-local/` — общая Claude/Cursor-проекция составных пакетов
* `~/.claude/skills`, `~/.codex/skills`, `~/.cursor/skills` — assistant-specific discovery-слои, symlink-и на `~/.agents/skills`
* `~/.codex/plugins/dotfiles-local/*` — локальные bundle-ы плагинов Codex
* `~/.claude/CLAUDE.md` — тонкая обёртка, импортирующая общий слой
* `~/.cursor/rules/dotfiles.mdc` — генерируемая проекция общего слоя для Cursor
* live MCP-конфиги (`~/.claude/settings.json`, `~/.codex/config.toml`, `~/.cursor/mcp.json`, `~/.config/opencode/opencode.jsonc`) — generated outputs. Персональные значения приходят из env или системного хранилища через `./scripts/personal`; `ELIZA_TOKEN` обновляется из OAuth client credentials в shell-профиле
* `~/.claude.json` — рабочее состояние Claude Code, в репозитории не канонизируется
* `~/.codex/config.toml` частично принадлежит приложению Codex: корневые ключи и таблицы, которых нет в шаблоне, реестре MCP и локальных плагинах (`node_repl`, связки `@openai-*`, доверие проектов, `desktop`), `install-mcp` переносит при синхронизации как есть, а `--check` сравнивает этот файл без учёта порядка и комментариев. Таблицу, убранную из шаблона, нужно удалить из живого файла вручную

## Скрипты

* `./scripts/install-skills` — синхронизирует `~/.agents/skills` и publish-ит его в discovery-слои
* `./scripts/install-plugins` — инвентаризирует полные source tree и строит проекции для Codex, Claude Code и Cursor
* `./scripts/install-mcp` — ставит локальные MCP runtime-ы и материализует live-конфиги
* `./scripts/bootstrap-agent-skills` — projection `~/.agents/skills → ~/.claude/skills, ~/.codex/skills, ~/.cursor/skills`, вызывается из `install-skills`, напрямую обычно не нужен

Все три `install-*` принимают `--update` для перетяжки внешних источников. `--force` оставлен алиасом.

## Общие инструкции

Если инструмент поддерживает проектный формат — предпочтителен `AGENTS.md`. Если ожидает собственный файл (`CLAUDE.md` и т.п.), лучше делать тонкую обёртку над общим слоем, а не дублировать текст.
