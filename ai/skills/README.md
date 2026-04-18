# Навыки

Общий слой навыков в `ai/skills/`. Рабочие каталоги и общая архитектура — в [`../README.md`](../README.md).

## Структура

В `ai/skills/` смешиваются два источника:

* локальные skill-пакеты — подкаталоги с `SKILL.md` (имя = имя каталога)
* внешние зависимости — реестр в `ai/skills/skills.json`

```text
ai/skills/
├── editorial/
│   └── SKILL.md
├── prompt/
│   └── SKILL.md
├── skills.json
└── README.md
```

## Формат `skills.json`

Словарь `source → spec`.

`source`:

* `owner/repo`
* `owner/repo/tree/...`
* полный `https://github.com/...`

`spec`:

* `"*"` — установить весь источник
* `"skill-name"` — установить один навык
* `["skill-a", "skill-b"]` — установить список

## Правила сборки

* `./scripts/install-skills` собирает локальные пакеты и внешние зависимости в `~/.agents/skills`, затем запускает projection в assistant-specific слои
* конфликт имени между локальным и внешним skill — жёсткая ошибка
* конфликт имён между внешними источниками — жёсткая ошибка
* `./scripts/bootstrap-agent-skills` при необходимости мигрирует `codex-primary-runtime` из `~/.codex/skills` в канонический слой, обычно вызывается из `install-skills`

## Установка

```bash
./scripts/install-skills
./scripts/install-skills --update
```

`--update` переустанавливает внешние зависимости. Локальные пакеты синхронизируются при каждом запуске. `--force` оставлен алиасом.
