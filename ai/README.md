# Архитектура AI-конфигов

`~/dotfiles` — канонический источник AI-конфигурации. Рабочие артефакты раскладываются в домашний каталог.

## Канонический слой

* `ai/instructions/*` — общие Markdown-инструкции
* `ai/skills/*` + `ai/skills/skills.json` — локальные skill-пакеты и внешние зависимости, см. [`skills/README.md`](skills/README.md)
* `ai/plugins/plugins.json` — реестр локальных плагинов Codex, см. [`plugins/README.md`](plugins/README.md)
* `ai/mcp.json` — реестр MCP-серверов в формате `server-name → { enabled, transport, command/url, install, clients }` для Codex, Cursor, Claude и OpenCode
* `claude/.settings.template.json`, `codex/.config.template.toml`, `config/opencode/.opencode.template.jsonc` — шаблоны non-MCP настроек клиентов

Для GitHub-источников в реестрах допустима короткая форма `owner/repo` или `owner/repo/tree/...`.

## Рабочие каталоги

* `~/.agents/instructions` — projected Markdown-инструкции
* `~/.agents/skills` — единственный source of truth общих навыков
* `~/.agents/plugins/marketplace.json` — локальный каталог плагинов Codex
* `~/.claude/skills`, `~/.codex/skills` — assistant-specific discovery-слои, symlink-и на `~/.agents/skills`
* `~/.codex/plugins/dotfiles-local/*` — локальные bundle-ы плагинов Codex
* `~/.claude/CLAUDE.md` — тонкая обёртка, импортирующая общий слой
* live MCP-конфиги (`~/.claude/settings.json`, `~/.codex/config.toml`, `~/.cursor/mcp.json`, `~/.config/opencode/opencode.jsonc`) — generated outputs. Секреты приходят из env вроде `SOURCECRAFT_PAT`, `SOURCECRAFT_ENTERPRISE_PAT`, `ELIZA_API_HOST`, `ELIZA_TOKEN` (их отсутствие не ломает bootstrap)
* `~/.claude.json` — рабочее состояние Claude Code, в репозитории не канонизируется

## Скрипты

* `./scripts/install-skills` — синхронизирует `~/.agents/skills` и publish-ит его в discovery-слои
* `./scripts/install-plugins` — собирает локальные plugin-bundle-ы и marketplace
* `./scripts/install-mcp` — ставит локальные MCP runtime-ы и материализует live-конфиги
* `./scripts/bootstrap-agent-skills` — projection `~/.agents/skills → ~/.claude/skills, ~/.codex/skills`, вызывается из `install-skills`, напрямую обычно не нужен

Все три `install-*` принимают `--update` для перетяжки внешних источников. `--force` оставлен алиасом.

## Общие инструкции

Если инструмент поддерживает проектный формат — предпочтителен `AGENTS.md`. Если ожидает собственный файл (`CLAUDE.md` и т.п.), лучше делать тонкую обёртку над общим слоем, а не дублировать текст.
