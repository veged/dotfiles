# Навыки

`~/dotfiles` хранит канонический реестр общих навыков в `ai/skills/skills.json`.

## Формат

`skills.json` — это словарь `source -> spec`.

`source` можно записывать в трёх видах:

* `owner/repo`
* `owner/repo/tree/...`
* полный `https://github.com/...`

`spec` поддерживает три формы:

* `"*"` — установить весь источник
* `"skill-name"` — установить один навык
* `["skill-a", "skill-b"]` — установить список навыков

## Рабочие каталоги

* `~/.agents/skills` — канонический общий слой навыков для Codex, OpenCode и совместимых инструментов
* `~/.claude/skills` — зеркало общего слоя симлинками

## Установка

```bash
./scripts/install-skills
./scripts/install-skills --force
```

`--force` переустанавливает навыки из `skills.json`, а не только добирает недостающие.
