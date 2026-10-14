# Форматы ссылок SourceCraft

Базовый адрес веб-ссылок: `https://sourcecraft.dev/<org_slug>/<repo_slug>`. Не используй адрес клонирования `git.sourcecraft.dev` или REST API `api.sourcecraft.tech`.

| Сущность | Путь после базового адреса |
| --- | --- |
| Репозиторий | — |
| Ветка | `?rev=<branch>` |
| Задача | `/issues/<номер>` |
| Предложение изменений (PR) | `/pr/<номер>` |
| Коммит | `/commit/<полный_sha>` |
| Запуск CI/CD | `/cicd/runs/<идентификатор_запуска>` |
| Раздел расписаний CI/CD | `/cicd/schedules` |

Списки: `/issues`, `/pr`, `/commits/?rev=<branch>`, `/branches`, `/tags`, `/releases`, `/cicd/runs`. Кодируй значения `rev` для URL, например `codex/topic` → `codex%2Ftopic`.

Настройки расписаний находятся в `.sourcecraft/ci.yaml`. Для отдельного расписания и других сущностей без указанного пути бери ссылку из интерфейса SourceCraft или ответа MCP, не угадывай маршрут.

Для файлов и диапазонов строк в экспертном ревью см. навык `assist-expert-review`.

Страница PR использует `/pr/<номер>`, не `/pulls/<номер>`. Только для поля `url` инструмента Codex `attach_artifact` замени этот путь на `/pull/<номер>` и проверь результат через `list_artifacts`. В ответе пользователю оставляй ссылку `/pr/<номер>`.
