# Плагины

Канонический реестр локальных плагинов Codex в `ai/plugins/plugins.json`. Рабочие каталоги и общая архитектура — в [`../README.md`](../README.md).

Плагины — отдельный слой поверх общих навыков. Они нужны там, где плоского пространства имён не хватает, например при конфликте имён.

## Формат `plugins.json`

Словарь `plugin-name → spec`. `spec`:

* `"owner/repo"` — завернуть весь источник
* `{ "source": "owner/repo", "skills": "*" }` — то же явно
* `{ "source": "owner/repo", "skills": "skill-name" }` — один навык
* `{ "source": "owner/repo", "skills": ["skill-a", "skill-b"] }` — список
* `{ "source": "owner/repo", "kind": "plugin" }` — подключить готовый Codex-plugin целиком (с `commands`/`agents`/`context`), а не набор skills

Для `source` допустим и полный `https://github.com/...` или `ssh://...`, но короткая форма предпочтительнее.

`kind: "plugin"` берёт source двумя способами:

* **remote URL** (канонический, «для всех») → `install-plugins` клонирует репозиторий в `~/.codex/plugins/dotfiles-local/<name>` реальной папкой, как `kind: skills`;
* **локальный путь** (`./...`, `~/...`) → симлинк на рабочую копию, правки видны сразу — для разработки своих плагинов (live: прокидывается в marketplace и installed cache Codex).

Локальная подмена remote-плагина: замени чекаут `~/.codex/plugins/dotfiles-local/<name>` симлинком на свою рабочую копию — `install-plugins` уважает такой симлинк (`local override`) и не перетирает его при реинсталле.

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
