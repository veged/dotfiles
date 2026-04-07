# Плагины

`~/dotfiles` хранит канонический реестр локальных плагинов Codex в `ai/plugins/plugins.json`.

Это отдельный слой поверх общих навыков. Он нужен там, где одного плоского пространства имён недостаточно, например при конфликте имён.

## Формат

`plugins.json` — это словарь `plugin-name -> spec`.

`spec` поддерживает четыре формы:

* `"owner/repo"` — завернуть весь источник в плагин с этим именем
* `{ "source": "owner/repo", "skills": "*" }` — то же самое, но в явной форме
* `{ "source": "owner/repo", "skills": "skill-name" }` — завернуть один навык
* `{ "source": "owner/repo", "skills": ["skill-a", "skill-b"] }` — завернуть список навыков

Для `source` поддержан и полный `https://github.com/...`, но короткая форма предпочтительнее.

## Рабочие каталоги

* `~/plugins/<plugin-name>` — собранный локальный плагин для Codex
* `~/.agents/plugins/marketplace.json` — локальный каталог плагинов
* `~/.codex/config.toml` — включает нужные идентификаторы плагинов вида `plugin-name@dotfiles-local`

## Установка

```bash
./scripts/install-plugins
./scripts/install-plugins --force
```

`--force` пересобирает локальные плагины из `plugins.json`, а не только добирает недостающие.
