# Навыки

`~/dotfiles` хранит общий слой навыков в `ai/skills/`.

## Структура

В `ai/skills/` смешиваются два источника:

* локальные skill-пакеты — подкаталоги верхнего уровня, где лежит `SKILL.md`
* внешние зависимости — реестр в `ai/skills/skills.json`

Пример:

```text
ai/skills/
├── editorial/
│   ├── SKILL.md
│   └── references/
├── prompt/
├── skills.json
└── README.md
```

## Локальные навыки

Каждый каталог `ai/skills/<name>/`, в котором есть `SKILL.md`, считается локальным skill-пакетом и синхронизируется как есть.

Имена локальных навыков определяются именем каталога.

## Внешние зависимости

`skills.json` — это словарь `source -> spec`.

`source` можно записывать в трёх видах:

* `owner/repo`
* `owner/repo/tree/...`
* полный `https://github.com/...`

`spec` поддерживает три формы:

* `"*"` — установить весь источник
* `"skill-name"` — установить один навык
* `["skill-a", "skill-b"]` — установить список навыков

## Правила сборки

* `./scripts/install-skills` собирает итоговый набор из локальных skill-пакетов и внешних зависимостей только в `~/.agents/skills`, а затем запускает projection в assistant-specific discovery-слои
* конфликт имени между локальным и внешним skill — жёсткая ошибка
* конфликт имени между внешними skill-источниками — жёсткая ошибка
* `./scripts/bootstrap-agent-skills` публикует канонический слой в assistant-specific discovery-каталоги и при необходимости мигрирует `codex-primary-runtime` из `~/.codex/skills` в `~/.agents/skills`; обычно он вызывается из `./scripts/install-skills`

## Рабочие каталоги

* `~/.agents/skills` — канонический общий слой навыков для всех инструментов
* `~/.claude/skills` — projected discovery-слой Claude, собранный из `~/.agents/skills`
* `~/.codex/skills` — projected discovery-слой Codex, собранный из `~/.agents/skills`; `.system` остаётся вне этого source of truth

## Установка

```bash
./scripts/install-skills
./scripts/install-skills --update
```

`--update` переустанавливает внешние зависимости из `skills.json`, но локальные skill-пакеты синхронизируются при каждом запуске.

`--force` оставлен как алиас для обратной совместимости.
