# Плагины

Канонический реестр локальных плагинов Codex в `ai/plugins/plugins.json`. Рабочие каталоги и общая архитектура — в [`../README.md`](../README.md).

Плагины — отдельный слой поверх общих навыков. Они нужны там, где плоского пространства имён не хватает, например при конфликте имён.

Реальные Codex slash-команды живут именно здесь: в plugin root под `commands/*.toml` или `commands/*.md`. Файлы в `ai/instructions/*.md` не регистрируют slash-команды клиента; они влияют только на prompt/instruction layer.

По умолчанию держи один source of truth прямо в `commands/*.toml`. Отдельный instruction-источник или генератор добавляй только если один и тот же контент действительно должен обслуживать несколько разных рантаймов.

Локальные plugin root для этого репозитория храни в `ai/plugins/<plugin-name>/`. Тогда `plugins.json` остаётся коротким реестром, а сам plugin лежит рядом.

## Формат `plugins.json`

Словарь `plugin-name → spec`. `spec`:

* `"owner/repo"` — завернуть весь источник
* `{ "source": "owner/repo", "skills": "*" }` — то же явно
* `{ "source": "owner/repo", "skills": "skill-name" }` — один навык
* `{ "source": "owner/repo", "skills": ["skill-a", "skill-b"] }` — список
* `{ "source": "owner/repo", "skills": ["!skill-a", "!skill-b"] }` — весь источник, кроме перечисленных навыков
* `{ "source": "owner/repo", "kind": "plugin" }` — подключить готовый Codex-plugin целиком (с `commands`/`agents`/`context`), а не набор skills
* `{ "source": "./ai/plugins/name", "kind": "plugin" }` — локальный plugin root из этого репозитория; основной вариант для своих slash-команд и локальной разработки plugin

В `skills` нельзя смешивать включения и исключения: `["skill-a", "!skill-b"]` считается ошибкой.

Для `source` допустим и полный `https://github.com/...` или `ssh://...`, но короткая форма предпочтительнее.

`kind: "plugin"` берёт source двумя способами:

* **remote URL** (канонический, «для всех») → `install-plugins` клонирует репозиторий в `~/.codex/plugins/dotfiles-local/<name>` реальной папкой, как `kind: skills`;
* **локальный путь** (`./...`, `~/...`) → симлинк на рабочую копию, правки видны сразу — для разработки своих плагинов (live: прокидывается в marketplace и installed cache Codex).

Локальная подмена remote-плагина: замени чекаут `~/.codex/plugins/dotfiles-local/<name>` симлинком на свою рабочую копию — `install-plugins` уважает такой симлинк (`local override`) и не перетирает его при реинсталле.

## Локальные maintenance-команды

Плагин `dotfiles` — namespace для формальных команд обслуживания AI-конфигурации:

* `/dotfiles:install <что установить>` — найти или исследовать компонент по описанию, слагу, ссылке или пути; классифицировать его как skill, plugin, MCP или другой поддерживаемый тип; записать в подходящий source of truth и установить штатным контуром
* `/dotfiles:uninstall <что удалить>` — найти управляемый компонент по тем же формам ввода, удалить его каноническую декларацию и синхронизировать runtime-проекции без автоматического удаления данных, секретов и внешних binaries

Новые команды обслуживания добавляй в `ai/plugins/dotfiles/commands/`, не создавая отдельные плагины для каждого действия.

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
