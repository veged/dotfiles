# Fabric → Codex CLI

Fabric ходит в модель не через OpenAI API, а через локальный мост, который вызывает
`codex exec`. Ответы идут на **ChatGPT-подписке** (auth берётся из залогиненного
Codex CLI), отдельный API-ключ и биллинг не нужны.

## Как это устроено

```
fabric ──HTTP /v1/chat/completions──▶ codex-bridge.mjs ──spawn──▶ codex exec ──▶ ChatGPT
```

- **`codex-bridge.mjs`** — локальный OpenAI-совместимый сервер (`127.0.0.1:8123`, без
  зависимостей). На каждый запрос запускает `codex exec --ephemeral --ignore-user-config
  -s read-only` и отдаёт финальное сообщение модели.
- **`.env`** (в `~/.config/fabric/`, вне git) — Fabric настроен на встроенный вендор
  `OpenAI` с base URL, указывающим на мост. Создаётся `scripts/install-fabric`.
- **`~/.local/bin/fabric`** — обёртка над `fabric-ai`, всегда добавляет
  `--disable-responses-api` (уводит вендор на Chat Completions, который реализует мост).
- **launchd** `com.fabric.codex-bridge` — держит мост запущенным и поднимает его при входе
  в систему. Plist генерируется `scripts/install-fabric` под конкретную машину (путь к
  node, `$HOME`), поэтому в git не хранится.

## Установка

Часть dotbot-конфига: `./install` линкует `codex-bridge.mjs`/`README.md` в
`~/.config/fabric/`, обёртку — в `~/.local/bin/fabric`, ставит `fabric-ai` из Brewfile и
прогоняет `scripts/install-fabric` (генерит `.env` и launchd-агент, тянет паттерны).

Требуется установленный и залогиненный **Codex CLI** (`codex login`) — это внешний
prerequisite, не покрывается Brewfile.

Повторно настроить мост вручную: `./scripts/install-fabric`.

## Использование

```sh
pbpaste | fabric -p summarize
fabric -p extract_ideas -y "https://youtu.be/..." -g ru
echo "текст" | fabric -p analyze_claims
```

Команда `fabric` (обёртка) эквивалентна `fabric-ai`, но с правильным транспортом.
Список паттернов: `fabric -l`. Обновить паттерны: `fabric -U`.

> Всегда вызывай с `-p <pattern>`: без паттерна Fabric трактует имя бинаря как имя
> паттерна (поведение самого Fabric).

## Модель и ризонинг

Заданы в сгенерированном LaunchAgent (env), дефолты дублируются в `codex-bridge.mjs`:

| Переменная | Значение | Назначение |
|---|---|---|
| `CODEX_MODEL` | `gpt-5.5` | модель по умолчанию |
| `CODEX_REASONING_EFFORT` | `high` | `minimal\|low\|medium\|high\|xhigh` |
| `FABRIC_CODEX_BRIDGE_PORT` | `8123` | порт моста |

`DEFAULT_MODEL` в `.env` Fabric шлёт в запросе, мост пробрасывает в `codex -m`. Сменить
модель: поправь `scripts/install-fabric` (env плиста) + `.env` и перезапусти `install-fabric`.
Разово: `fabric -m gpt-5.4 ...`.

## Управление мостом

```sh
./scripts/install-fabric                 # перегенерировать plist + перезагрузить агент

# ручное управление
launchctl kickstart -k gui/$(id -u)/com.fabric.codex-bridge   # рестарт
launchctl bootout     gui/$(id -u)/com.fabric.codex-bridge    # выгрузить

curl -s 127.0.0.1:8123/health
tail -f ~/.config/fabric/codex-bridge.log
```

## Ограничения

- **Codex заточен под кодинг.** Его системный промпт агентский; для большинства
  текстовых паттернов это не мешает, но иногда формулировки могут «уходить в кодинг».
- **Накладные расходы.** Каждый вызов = отдельный процесс `codex` + ~10–15k токенов на его
  системный промпт. Медленнее и «дороже» по лимитам подписки, чем прямой API.
- **Сессии Fabric** (`--session`) деградируют: multi-turn склеивается в один промпт.
- **Лимиты ChatGPT-плана** общие с интерактивным Codex.
