# Архитектура AI-конфигов

`~/dotfiles` — канонический источник AI-конфигурации. Рабочие артефакты раскладываются в домашний каталог.

## Слои

* `~/.agents/instructions` — общие файлы инструкций для инструментов, которые умеют читать обычный Markdown
* `ai/skills/*` — локальные skill-пакеты в формате Agent Skills
* `ai/skills/skills.json` — внешние зависимости общих навыков
* `ai/plugins/plugins.json` — канонический реестр локальных плагинов Codex
* `ai/mcp.json` — канонический MCP-реестр для Codex, Cursor, Claude и OpenCode
* `~/.agents/skills` — единый source of truth для общих навыков; его синхронизирует `./scripts/install-skills`
* `~/.claude/skills` и `~/.codex/skills` — assistant-specific discovery-слои, которые `./scripts/install-skills` обновляет через внутренний bootstrap из `~/.agents/skills`
* `~/.codex/plugins/dotfiles-local` — локальные bundle-ы плагинов Codex, которые собирает `./scripts/install-plugins`
* `~/.agents/plugins/marketplace.json` — локальный каталог плагинов Codex
* `~/.claude/CLAUDE.md` — тонкая обёртка Claude, которая импортирует общие инструкции
* `claude/.settings.template.json`, `codex/.config.template.toml` и `config/opencode/.opencode.template.jsonc` — source templates для клиентских non-MCP настроек
* `./scripts/install-mcp` — ставит локальные MCP runtime-ы и материализует `~/.claude/settings.json`, `~/.codex/config.toml`, `~/.cursor/mcp.json` и `~/.config/opencode/opencode.jsonc`
* `~/.claude.json` — рабочее состояние Claude Code; в `dotfiles` не канонизируется
* live MCP-конфиги в домашнем каталоге — generated outputs; секреты и provider-specific значения приходят из env вроде `SOURCECRAFT_PAT`, `SOURCECRAFT_ENTERPRISE_PAT`, `ELIZA_API_HOST` и `ELIZA_TOKEN`, но их отсутствие не должно ломать сам bootstrap

## Форматы реестров

* `ai/skills/skills.json` — словарь `source -> "*" | "skill" | ["skills"]` для внешних skill-зависимостей
* `ai/plugins/plugins.json` — словарь `plugin-name -> "source" | { source, skills }`
* `ai/mcp.json` — словарь `server-name -> { enabled, transport, command/url, install, clients }`
* GitHub-источники можно задавать в короткой форме `owner/repo` или `owner/repo/tree/...`

## Установка плагинов Codex

`./scripts/install-plugins` только собирает локальные bundle-ы и personal marketplace.

Чтобы обновить содержимое plugins из upstream-источников, используй `./scripts/install-plugins --update`.

Сама установка делается через `Plugins` или `/plugins`, после чего plugin вызывается через `@plugin-name`. Slash-команда вида `/impeccable` появляться не обязана.

`./scripts/bootstrap-agent-skills` не хранит собственных навыков: он только публикует канонический слой в `~/.claude/skills` и `~/.codex/skills`, плюс один раз мигрирует известные общие bundle-ы вроде `codex-primary-runtime` из `~/.codex/skills`, не трогая `.system`. Обычно его напрямую вызывать не нужно: `./scripts/install-skills` делает это сам.

## Общие инструкции

Для проектных инструкций предпочтителен `AGENTS.md`.

Если инструмент поддерживает собственный формат, вроде `CLAUDE.md`, лучше импортировать общий слой или ссылаться на него, а не дублировать текст.
