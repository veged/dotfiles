# Архитектура AI-конфигов

`~/dotfiles` — канонический источник AI-конфигурации. Рабочие артефакты раскладываются в домашний каталог.

## Слои

* `~/.agents/instructions` — общие файлы инструкций для инструментов, которые умеют читать обычный Markdown
* `ai/skills/*` — локальные skill-пакеты в формате Agent Skills
* `ai/skills/skills.json` — внешние зависимости общих навыков
* `ai/plugins/plugins.json` — канонический реестр локальных плагинов Codex
* `~/.agents/skills` — общий слой навыков, который синхронизирует `./scripts/install-skills`
* `~/.codex/plugins/dotfiles-local` — локальные bundle-ы плагинов Codex, которые собирает `./scripts/install-plugins`
* `~/.agents/plugins/marketplace.json` — локальный каталог плагинов Codex
* `~/.claude/CLAUDE.md` — тонкая обёртка Claude, которая импортирует общие инструкции
* `~/.claude/skills` — зеркало общего слоя навыков симлинками
* `~/.claude/settings.json` — канонический статический конфиг Claude Code
* `~/.claude.json` — рабочее состояние Claude Code; в `dotfiles` не канонизируется
* `~/.config/opencode/opencode.jsonc` — адаптер OpenCode на общие инструкции
* `~/.cursor/mcp.json` — канонический MCP-конфиг Cursor; секреты приходят из переменных окружения `SOURCECRAFT_PAT` и `SOURCECRAFT_ENTERPRISE_PAT`

## Форматы реестров

* `ai/skills/skills.json` — словарь `source -> "*" | "skill" | ["skills"]` для внешних skill-зависимостей
* `ai/plugins/plugins.json` — словарь `plugin-name -> "source" | { source, skills }`
* GitHub-источники можно задавать в короткой форме `owner/repo` или `owner/repo/tree/...`

## Установка плагинов Codex

`./scripts/install-plugins` только собирает локальные bundle-ы и personal marketplace.

Чтобы обновить содержимое plugins из upstream-источников, используй `./scripts/install-plugins --update`.

Сама установка делается через `Plugins` или `/plugins`, после чего plugin вызывается через `@plugin-name`. Slash-команда вида `/impeccable` появляться не обязана.

## Общие инструкции

Для проектных инструкций предпочтителен `AGENTS.md`.

Если инструмент поддерживает собственный формат, вроде `CLAUDE.md`, лучше импортировать общий слой или ссылаться на него, а не дублировать текст.
