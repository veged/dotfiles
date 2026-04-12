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

* `~/.codex/plugins/dotfiles-local/<plugin-name>` — собранный локальный плагин для Codex
* `~/.agents/plugins/marketplace.json` — локальный каталог плагинов
* `~/.codex/config.toml` — хранит состояние уже установленных плагинов, но не заменяет установку

## Установка

```bash
./scripts/install-plugins
./scripts/install-plugins --force
```

`--force` пересобирает локальные плагины из `plugins.json`, а не только добирает недостающие.

После bootstrap plugin ещё нужно установить в Codex:

1. открыть `Plugins` или вызвать `/plugins`
2. выбрать marketplace `Dotfiles Local`
3. установить нужный plugin
4. начать новый thread и вызывать plugin через `@`, например `@impeccable`

`/impeccable` не обязана появляться, потому что plugin не равен slash-команде.
