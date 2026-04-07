# Архитектура AI-конфигов

`~/dotfiles` — канонический источник.

Рабочие слои:

- `~/.agents/instructions` — общие файлы инструкций для инструментов, которые умеют читать обычный Markdown.
- `~/.claude/CLAUDE.md` — тонкая обертка Claude, импортирующая общие инструкции.
- `~/.claude/settings.json` — канонический статический конфиг Claude Code.
- `~/.claude.json` — runtime state Claude Code; не канонизируем в `dotfiles`.
- `~/.config/opencode/opencode.jsonc` — адаптер OpenCode, указывающий на общие инструкции.
- `~/.cursor/mcp.json` — канонический MCP-конфиг Cursor; секреты приходят из env (`SOURCECRAFT_PAT`, `SOURCECRAFT_ENTERPRISE_PAT`).
- `~/.cursor/commands` / `~/.claude/commands` — общие команды из `ai/commands`.

Для общих проектных инструкций предпочтителен `AGENTS.md`.
Если инструмент это поддерживает, специализированные обертки могут импортировать `AGENTS.md` или ссылаться на него.
