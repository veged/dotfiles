# Архитектура AI-конфигов

`~/dotfiles` — канонический источник AI-конфигурации. Рабочие артефакты раскладываются в домашний каталог.

## Канонический слой

* `ai/instructions/*` — общие Markdown-инструкции
* `ai/skills/*` + `ai/skills/skills.json` — локальные skill-пакеты и внешние зависимости, см. [`skills/README.md`](skills/README.md)
* `ai/plugins/plugins.json` — реестр локальных плагинов Codex, см. [`plugins/README.md`](plugins/README.md)
* `ai/mcp.json` — реестр MCP-серверов в формате `server-name → { enabled, transport, command/url, install, clients }` для Codex, Cursor, Claude и OpenCode
* `claude/.settings.template.json`, `codex/.config.template.toml`, `config/opencode/.opencode.template.jsonc` — шаблоны non-MCP настроек клиентов

Для GitHub-источников в реестрах допустима короткая форма `owner/repo` или `owner/repo/tree/...`.

## AI-инструкции

`ai/instructions/*.md` — source of truth для общих AI-инструкций.
Instruction id — это filename без `.md`; projected files используют то же filename под `~/.agents/instructions/`.
Claude, Codex и OpenCode instruction lists генерируются из markdown file set в deterministic filename order.

После добавления, удаления, переименования или редактирования instruction files запускай `./scripts/install-mcp --sync-only`.
Для проверки stale generated artifacts запускай `./scripts/install-mcp --check`.

## Рабочие каталоги

* `~/.agents/instructions` — projected Markdown-инструкции
* `~/.agents/skills` — единственный source of truth общих навыков
* `~/.agents/plugins/marketplace.json` — локальный каталог плагинов Codex
* `~/.claude/skills`, `~/.codex/skills` — assistant-specific discovery-слои, symlink-и на `~/.agents/skills`
* `~/.codex/plugins/dotfiles-local/*` — локальные bundle-ы плагинов Codex
* `~/.claude/CLAUDE.md` — тонкая обёртка, импортирующая общий слой
* live MCP-конфиги (`~/.claude/settings.json`, `~/.codex/config.toml`, `~/.cursor/mcp.json`, `~/.config/opencode/opencode.jsonc`) — generated outputs. Персональные значения приходят из env или системного хранилища через `./scripts/personal`; `ELIZA_TOKEN` обновляется из OAuth client credentials в shell-профиле
* `~/.claude.json` — рабочее состояние Claude Code, в репозитории не канонизируется

## Скрипты

* `./scripts/install-skills` — синхронизирует `~/.agents/skills` и publish-ит его в discovery-слои
* `./scripts/install-plugins` — собирает локальные plugin-bundle-ы и marketplace
* `./scripts/install-mcp` — ставит локальные MCP runtime-ы и материализует live-конфиги
* `./scripts/bootstrap-agent-skills` — projection `~/.agents/skills → ~/.claude/skills, ~/.codex/skills`, вызывается из `install-skills`, напрямую обычно не нужен

Все три `install-*` принимают `--update` для перетяжки внешних источников. `--force` оставлен алиасом.

## Общие инструкции

Если инструмент поддерживает проектный формат — предпочтителен `AGENTS.md`. Если ожидает собственный файл (`CLAUDE.md` и т.п.), лучше делать тонкую обёртку над общим слоем, а не дублировать текст.
