# Плагины

Канонический реестр локальных плагинов Codex в `ai/plugins/plugins.json`. Рабочие каталоги и общая архитектура — в [`../README.md`](../README.md).

Плагины — отдельный слой поверх общих навыков. Они нужны там, где плоского пространства имён не хватает, например при конфликте имён.

## Формат `plugins.json`

Словарь `plugin-name → spec`. `spec`:

* `"owner/repo"` — завернуть весь источник
* `{ "source": "owner/repo", "skills": "*" }` — то же явно
* `{ "source": "owner/repo", "skills": "skill-name" }` — один навык
* `{ "source": "owner/repo", "skills": ["skill-a", "skill-b"] }` — список

Для `source` допустим и полный `https://github.com/...`, но короткая форма предпочтительнее.

## Установка

```bash
./scripts/install-plugins
./scripts/install-plugins --update
```

`--update` пересобирает локальные плагины из `plugins.json`. `--force` оставлен алиасом.

Скрипт только публикует personal marketplace и локальные bundle-ы. Сам plugin затем ставится в Codex:

1. открыть `Plugins` или вызвать `/plugins`
2. выбрать marketplace `Dotfiles Local`
3. установить нужный plugin
4. начать новый thread и вызывать plugin через `@`, например `@impeccable`

Slash-команда вида `/impeccable` появляться не обязана — plugin не равен slash-команде.
