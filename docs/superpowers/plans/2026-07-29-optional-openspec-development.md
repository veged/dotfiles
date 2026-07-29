# План реализации опциональной разработки по OpenSpec

> Для агентов: выполняйте план через `subagent-driven-development` или
> `executing-plans`. Отмечайте шаги флажками `- [ ]`.

**Цель:** добавить опциональный макропроцесс OpenSpec, который использует
адаптивный SDD для исполнения и не меняет обычный процесс разработки.

**Архитектура:** новый навык `openspec-development` управляет артефактами,
состоянием и маршрутизацией через исполняемый интерфейс
`openspec-orchestrate`. Один связный рабочий блок получает постоянного
исполнителя, несколько независимых блоков — адаптивный SDD. Навык
`openspec-archive` отдельно архивирует изменение после слияния.

**Стек:** Markdown, Bash, тесты Zsh, `jq`, Git, CLI OpenSpec.

## Общие ограничения

* OpenSpec включается только по явному запросу или для указанного активного
  изменения
* Наличие каталога `openspec/` не включает новый процесс
* Навык не устанавливает OpenSpec и не разрешает `npx` скачивать пакет
* OpenSpec и Git остаются источниками истины, журнал служит только кешем
* Имена моделей не закрепляются
* Повторные вызовы продолжают прежнего агента и передают только новый вход
* В режиме SDD его итоговый reviewer выполняет OpenSpec-проверку; второе полное
  ревью запрещено
* После чистого ревью оркестратор запускает свежие проверки текущего `HEAD`
* Архивация запускается отдельно после слияния и не создаёт коммит
* Не менять `ai/skills/skills.json`: локальные навыки устанавливаются
  автоматически
* Не включать несвязанные изменения из текущей рабочей копии

---

### Задача 1: Обобщить SDD для внешних планов

**Файлы:**

* Изменить:
  `ai/skills/subagent-driven-development/scripts/sdd-workspace`
* Изменить: `ai/skills/subagent-driven-development/SKILL.md`
* Создать:
  `ai/skills/subagent-driven-development/final-reviewer-prompt.md`
* Изменить: `scripts/tests/test-adaptive-sdd-skill.zsh`
* Создать: `scripts/tests/test-sdd-workspace.zsh`

**Интерфейсы:**

* Вход: `sdd-workspace PLAN_FILE`
* Выход: абсолютный путь
  `.superpowers/sdd/{basename}-{path-hash}/`
* Стабильность: один путь плана всегда возвращает одну рабочую область
* Изоляция: разные относительные пути с именем `tasks.md` возвращают разные
  области
* Внешний вызывающий навык может передать готовые `[BRIEF_FILES]`
* Итоговый reviewer принимает `[REQUIREMENT_FILES]`, `[REPORT_FILES]`,
  `[DIFF_FILE]`, `BASE` и `HEAD`

- [ ] **Шаг 1: написать тест устойчивой рабочей области**

Создать `scripts/tests/test-sdd-workspace.zsh`. Тест должен создать временный
Git-репозиторий и два одноимённых плана:

```zsh
repo="$tmp_root/repo"
mkdir -p "$repo/docs/a" "$repo/docs/b"
git -C "$repo" init -q
print '# План A' > "$repo/docs/a/tasks.md"
print '# План B' > "$repo/docs/b/tasks.md"

first=$(cd "$repo" && "$workspace" docs/a/tasks.md)
first_again=$(cd "$repo" && "$workspace" docs/a/tasks.md)
second=$(cd "$repo" && "$workspace" docs/b/tasks.md)

[[ "$first" == "$first_again" ]] || fail 'путь рабочей области нестабилен'
[[ "$first" != "$second" ]] || fail 'одноимённые планы столкнулись'
[[ -f "$repo/.superpowers/sdd/.gitignore" ]] || fail 'нет .gitignore'
```

Добавить сценарий с пробелом в имени каталога. Проверить, что путь содержит
`tasks-` и восьмисимвольный хеш.

* [ ] **Шаг 2: запустить тест и подтвердить исходную ошибку**

```bash
zsh scripts/tests/test-sdd-workspace.zsh
```

Ожидаемый результат: тест завершается ошибкой
`одноимённые планы столкнулись`.

* [ ] **Шаг 3: сделать идентификатор рабочей области устойчивым**

В `sdd-workspace`:

1. получить корень через
   `git -C "$(dirname "$plan")" rev-parse --show-toplevel`
2. получить канонический путь плана
3. убедиться, что план находится внутри корня
4. вычислить относительный путь
5. получить восьмисимвольный хеш относительного пути через
   `git hash-object --stdin`
6. использовать каталог `${slug}-${hash}`

Скрипт должен сохранить проверку существования плана, русские сообщения и
`.superpowers/sdd/.gitignore` со строкой `*`.

* [ ] **Шаг 4: проверить исправление рабочей области**

```bash
zsh scripts/tests/test-sdd-workspace.zsh
zsh scripts/tests/test-sdd-task-brief.zsh
```

Ожидаемый результат: оба теста печатают `ok`.

* [ ] **Шаг 5: зафиксировать контракт внешних кратких заданий тестом**

Расширить `required` в `test-adaptive-sdd-skill.zsh`:

```zsh
'готовые файлы кратких заданий'
'[REQUIREMENT_FILES]'
'final-reviewer-prompt.md'
'второе полное ревью'
```

Добавить проверки, что `final-reviewer-prompt.md` содержит:

```text
[REQUIREMENT_FILES]
[REPORT_FILES]
[DIFF_FILE]
BASE
HEAD
artifact {id}
implementation
external
```

* [ ] **Шаг 6: запустить тест и подтвердить отсутствие контракта**

```bash
zsh scripts/tests/test-adaptive-sdd-skill.zsh
```

Ожидаемый результат: ошибка о первом отсутствующем правиле.

* [ ] **Шаг 7: дополнить SDD и шаблон итогового reviewer**

В `SKILL.md`:

* разрешить вызывающему навыку передавать готовые краткие задания
* не запускать `task-brief`, если `[BRIEF_FILES]` уже заданы
* передавать итоговому reviewer дополнительные `[REQUIREMENT_FILES]`
* указать, что итоговый reviewer может вернуть категории
  `artifact {id}`, `implementation` и `external`
* запретить вызывающему навыку второе полное ревью

Создать `final-reviewer-prompt.md`. Он должен:

* читать ограниченный пакет один раз
* сверять все файлы требований и отчёты
* не повторять подтверждённые проверки того же `HEAD`
* ничего не менять
* писать полные замечания в `[REVIEW_REPORT]`
* возвращать компактный статус, категории, `HEAD` и путь к отчёту

- [ ] **Шаг 8: проверить SDD**

```bash
zsh scripts/tests/test-adaptive-sdd-skill.zsh
zsh scripts/tests/test-sdd-review-package.zsh
zsh scripts/tests/test-sdd-task-brief.zsh
zsh scripts/tests/test-sdd-workspace.zsh
bash -n ai/skills/subagent-driven-development/scripts/sdd-workspace
```

Ожидаемый результат: все команды завершаются с кодом 0.

* [ ] **Шаг 9: зафиксировать блок**

```bash
git add \
  ai/skills/subagent-driven-development/SKILL.md \
  ai/skills/subagent-driven-development/final-reviewer-prompt.md \
  ai/skills/subagent-driven-development/scripts/sdd-workspace \
  scripts/tests/test-adaptive-sdd-skill.zsh \
  scripts/tests/test-sdd-workspace.zsh
git commit -m "feat: обобщить SDD для внешних планов"
```

### Задача 2: Добавить макропроцесс `openspec-development`

**Файлы:**

* Создать: `ai/skills/openspec-development/SKILL.md`
* Создать: `ai/skills/openspec-development/planner-prompt.md`
* Создать: `ai/skills/openspec-development/implementer-prompt.md`
* Создать: `ai/skills/openspec-development/reviewer-prompt.md`
* Создать: `ai/skills/openspec-development/re-review-prompt.md`
* Создать:
  `ai/skills/openspec-development/scripts/openspec-workspace`
* Создать:
  `ai/skills/openspec-development/scripts/openspec-task-brief`
* Создать: `scripts/tests/test-openspec-development-skill.zsh`
* Создать: `scripts/tests/test-openspec-workspace.zsh`
* Создать: `scripts/tests/test-openspec-task-brief.zsh`

**Интерфейсы:**

* `openspec-workspace CHANGE_NAME` создаёт
  `.superpowers/openspec/{change-name}/` и один раз инициализирует `state.md`
* `openspec-task-brief APPLY_JSON TASK_ID [OUTFILE]` извлекает
  `.tasks[] | {id, description, done}` и все `.contextFiles`
* `openspec-development` активируется только явно или для указанного изменения
* Состояния: `discover`, `planning`, `human-approval`, `execution`, `review`,
  `fresh-verification`, `ready-for-merge`

- [ ] **Шаг 1: написать тест рабочей области OpenSpec**

В `test-openspec-workspace.zsh` проверить:

```zsh
dir=$(cd "$repo" && "$workspace" 'add-dark-mode')
[[ "$dir" == "$repo/.superpowers/openspec/add-dark-mode" ]]
ugrep -Fq 'stage: discover' "$dir/state.md"
ugrep -Fq 'implementation: unset' "$dir/state.md"
ugrep -Fq 'verified-head: none' "$dir/state.md"
```

Повторный вызов не должен перезаписывать добавленную строку журнала. Имена
`../escape`, `with/slash` и пустая строка должны завершаться кодом 2.

* [ ] **Шаг 2: написать тест краткого задания OpenSpec**

Создать тестовые данные:

```json
{
  "changeName": "add-dark-mode",
  "state": "ready",
  "contextFiles": {
    "proposal": ["openspec/changes/add-dark-mode/proposal.md"],
    "specs": ["openspec/changes/add-dark-mode/specs/theme/spec.md"],
    "design": ["openspec/changes/add-dark-mode/design.md"],
    "tasks": ["openspec/changes/add-dark-mode/tasks.md"]
  },
  "tasks": [
    {"id": "1", "description": "Добавить хранилище темы", "done": false},
    {"id": "2", "description": "Добавить переключатель", "done": true}
  ]
}
```

Проверить, что задание `1` содержит имя изменения, описание, `done: false` и
все четыре пути контекста. Готовая задача `2`, неизвестный ID и невалидный JSON
должны завершаться кодом 3.

* [ ] **Шаг 3: запустить тесты и подтвердить отсутствие скриптов**

```bash
zsh scripts/tests/test-openspec-workspace.zsh
zsh scripts/tests/test-openspec-task-brief.zsh
```

Ожидаемый результат: команды не находят исполняемые файлы.

* [ ] **Шаг 4: реализовать `openspec-workspace`**

Скрипт должен:

* принимать ровно одно имя в `kebab-case`
* использовать корень Git
* создавать `.superpowers/openspec/.gitignore` со строкой `*`
* не перезаписывать существующий `state.md`
* инициализировать поля:

```markdown
# Состояние OpenSpec — изменение: add-dark-mode

stage: discover
planner: unavailable
executor: unavailable
reviewer: unavailable
implementation: unset
sdd-workspace: none
verified-head: none

## Отчёты

## Открытые замечания
```

* [ ] **Шаг 5: реализовать `openspec-task-brief`**

Скрипт должен валидировать JSON через `jq -e`, отклонять выполненную задачу и
атомарно записывать:

```markdown
# Рабочий пункт 1

Изменение: `add-dark-mode`
Состояние: `done: false`

## Требование

Добавить хранилище темы

## Контекст

* `openspec/changes/add-dark-mode/proposal.md`
* `openspec/changes/add-dark-mode/specs/theme/spec.md`
* `openspec/changes/add-dark-mode/design.md`
* `openspec/changes/add-dark-mode/tasks.md`
```

Путь по умолчанию:
`.superpowers/openspec/{change-name}/task-{id}-brief.md`.

* [ ] **Шаг 6: проверить скрипты**

```bash
zsh scripts/tests/test-openspec-workspace.zsh
zsh scripts/tests/test-openspec-task-brief.zsh
bash -n ai/skills/openspec-development/scripts/openspec-workspace
bash -n ai/skills/openspec-development/scripts/openspec-task-brief
```

Ожидаемый результат: все команды завершаются с кодом 0.

* [ ] **Шаг 7: написать статический тест макропроцесса**

`test-openspec-development-skill.zsh` должен проверять:

```zsh
required=(
  'явно просит применить OpenSpec'
  'не включается только из-за наличия каталога'
  'fork_turns: "none"'
  'state.md'
  'готовые файлы кратких заданий'
  'ровно одно итоговое ревью'
  'не запускай второе полное ревью'
  'artifact {id}'
  'implementation'
  'external'
  'OBSOLETE'
  'fresh-verification'
  'текущего HEAD'
)
```

Дополнительно проверить наличие ссылок на все четыре файла шаблонов и оба
скрипта. Запретить фиксированные `model:` и автоматические `npm install`,
`npx --yes`.

* [ ] **Шаг 8: запустить тест и подтвердить отсутствие навыка**

```bash
zsh scripts/tests/test-openspec-development-skill.zsh
```

Ожидаемый результат: ошибка об отсутствующем `SKILL.md`.

* [ ] **Шаг 9: написать `SKILL.md`**

Перенести из design-документа:

* точные условия активации
* иерархию источников истины
* восстановление по OpenSpec, Git и `state.md`
* компактный контракт ответов
* стадии и переходы
* ручное утверждение
* выбор `single` или `sdd`
* маршрутизацию категорий
* пакетную обработку смешанных замечаний
* одну итоговую проверку
* свежую верификацию текущего `HEAD`

Для поиска CLI сначала использовать уже доступный `openspec` из `PATH`, затем
локальный бинарный файл проекта. Не запускать команду, которая может скачать
пакет.

* [ ] **Шаг 10: написать файлы шаблонов**

`planner-prompt.md`:

* получает имя изменения, пути состояния и отчёта
* читает полные JSON-ответы CLI
* обновляет только активные артефакты
* валидирует изменение
* возвращает `READY`, `BLOCKED` или `UPDATED`

`implementer-prompt.md`:

* работает по одному рабочему блоку
* не меняет артефакты
* отмечает только завершённые пункты
* записывает проверки и `HEAD`
* возвращает `DONE`, `BLOCKED` или `NEEDS_ARTIFACT`

`reviewer-prompt.md`:

* ничего не меняет
* проверяет пакет против всех `contextFiles`
* пишет замечания в файл
* использует категории `artifact {id}`, `implementation`, `external`

`re-review-prompt.md`:

* передаётся прежнему reviewer через продолжение
* проверяет только открытые замечания и пакет исправлений
* принимает вердикты `ADDRESSED`, `OBSOLETE`, `NOT ADDRESSED`

- [ ] **Шаг 11: отформатировать и проверить навык**

```bash
remark ai/skills/openspec-development --frail
zsh scripts/tests/test-openspec-development-skill.zsh
zsh scripts/tests/test-openspec-workspace.zsh
zsh scripts/tests/test-openspec-task-brief.zsh
```

Ожидаемый результат: Markdown и тесты проходят.

* [ ] **Шаг 12: зафиксировать блок**

```bash
git add \
  ai/skills/openspec-development \
  scripts/tests/test-openspec-development-skill.zsh \
  scripts/tests/test-openspec-workspace.zsh \
  scripts/tests/test-openspec-task-brief.zsh
git commit -m "feat: добавить опциональную разработку по OpenSpec"
```

### Задача 3: Добавить архивацию и сквозную проверку

**Файлы:**

* Создать: `ai/skills/openspec-archive/SKILL.md`
* Создать: `scripts/tests/test-openspec-archive-skill.zsh`
* Изменить: `scripts/tests/test-openspec-development-skill.zsh`
* Добавить в рабочую ветку:
  `docs/superpowers/specs/2026-07-29-optional-openspec-development-design.md`
* Добавить в рабочую ветку:
  `docs/superpowers/plans/2026-07-29-optional-openspec-development.md`

**Интерфейсы:**

* `openspec-archive` запускается только явно после слияния
* Основная ветка определяется из Git, а не фиксируется как `main`
* Грязная рабочая копия, другая ветка и незавершённые задачи блокируют архив
* Архив не коммитит, не сливает и не переключает ветки

- [ ] **Шаг 1: написать тест контракта архивации**

`test-openspec-archive-skill.zsh` должен проверять:

```zsh
required=(
  'только по явному запросу'
  'после слияния'
  'основную ветку'
  'чистую рабочую копию'
  'openspec status'
  'openspec instructions apply'
  'openspec archive'
  'не переключай ветки'
  'не сливай'
  'не создавай коммит'
  'влияние на реализацию'
)
```

Запретить безусловное требование ветки `main`, флаги `--skip-specs` и
`--no-validate`.

* [ ] **Шаг 2: запустить тест и подтвердить отсутствие навыка**

```bash
zsh scripts/tests/test-openspec-archive-skill.zsh
```

Ожидаемый результат: ошибка об отсутствующем `SKILL.md`.

* [ ] **Шаг 3: написать `openspec-archive/SKILL.md`**

Навык должен:

1. определить основную ветку по настроенной вышестоящей ветке или `HEAD`
   удалённого репозитория
2. потребовать текущую основную ветку и чистую рабочую копию
3. выбрать активное изменение
4. получить `status --json` и `instructions apply --json`
5. показать незавершённые пункты и запросить подтверждение
6. выполнить штатный `archive --yes --json`
7. при ошибке формы продолжить `planner`
8. повторить архив только при отсутствии влияния на реализацию
9. при влиянии остановиться и вернуть изменение в разработку

Навык не выполняет Git-операции и не создаёт коммит после успешного архива.

* [ ] **Шаг 4: усилить тест отсутствия двойного ревью**

В `test-openspec-development-skill.zsh` проверить одновременно:

```zsh
ugrep -Fq 'итоговый reviewer SDD одновременно' "$skill"
ugrep -Fq 'не запускай второе полное ревью' "$skill"
```

В `test-adaptive-sdd-skill.zsh` проверить обратный контракт: вызывающий навык
получает итоговый отчёт и не добавляет reviewer.

* [ ] **Шаг 5: перенести документы в рабочую ветку**

Из корневой рабочей копии скопировать без изменений:

```bash
mkdir -p docs/superpowers/specs docs/superpowers/plans
cp \
  /Users/veged/dotfiles/docs/superpowers/specs/2026-07-29-optional-openspec-development-design.md \
  docs/superpowers/specs/
cp \
  /Users/veged/dotfiles/docs/superpowers/plans/2026-07-29-optional-openspec-development.md \
  docs/superpowers/plans/
```

* [ ] **Шаг 6: отформатировать все новые Markdown-файлы**

```bash
remark \
  ai/skills/openspec-development \
  ai/skills/openspec-archive \
  ai/skills/subagent-driven-development \
  docs/superpowers/specs/2026-07-29-optional-openspec-development-design.md \
  docs/superpowers/plans/2026-07-29-optional-openspec-development.md \
  --quiet --output
```

* [ ] **Шаг 7: выполнить профильные тесты**

```bash
zsh scripts/tests/test-openspec-development-skill.zsh
zsh scripts/tests/test-openspec-workspace.zsh
zsh scripts/tests/test-openspec-task-brief.zsh
zsh scripts/tests/test-openspec-archive-skill.zsh
zsh scripts/tests/test-adaptive-sdd-skill.zsh
zsh scripts/tests/test-sdd-workspace.zsh
zsh scripts/tests/test-sdd-review-package.zsh
zsh scripts/tests/test-sdd-task-brief.zsh
```

Ожидаемый результат: восемь тестов печатают `ok`.

* [ ] **Шаг 8: выполнить регрессионные тесты слоя навыков**

```bash
zsh scripts/tests/test-skill-acquisition.zsh
zsh scripts/tests/test-agent-skills-layer.zsh
zsh scripts/tests/test-skill-layering.zsh
zsh scripts/tests/test-plugin-layering.zsh
```

Ожидаемый результат: четыре теста печатают `ok`.

* [ ] **Шаг 9: проверить синтаксис и состояние**

```bash
bash -n ai/skills/subagent-driven-development/scripts/sdd-workspace
bash -n ai/skills/openspec-development/scripts/openspec-workspace
bash -n ai/skills/openspec-development/scripts/openspec-task-brief
git diff --check
```

Ожидаемый результат: команды завершаются без вывода ошибок.

* [ ] **Шаг 10: установить локальные навыки**

```bash
./scripts/install-skills
```

Проверить, что существуют:

```text
~/.agents/skills/openspec-development/SKILL.md
~/.agents/skills/openspec-archive/SKILL.md
~/.agents/skills/subagent-driven-development/final-reviewer-prompt.md
```

* [ ] **Шаг 11: зафиксировать блок**

```bash
git add \
  ai/skills/openspec-archive \
  ai/skills/openspec-development/SKILL.md \
  ai/skills/subagent-driven-development/SKILL.md \
  scripts/tests/test-openspec-archive-skill.zsh \
  scripts/tests/test-openspec-development-skill.zsh \
  scripts/tests/test-adaptive-sdd-skill.zsh \
  docs/superpowers/specs/2026-07-29-optional-openspec-development-design.md \
  docs/superpowers/plans/2026-07-29-optional-openspec-development.md
git commit -m "feat: завершить интеграцию OpenSpec и SDD"
```

### Задача 4: Сделать переходы макропроцесса исполняемыми

**Файлы:**

* Создать:
  `ai/skills/openspec-development/scripts/openspec-orchestrate`
* Изменить: `ai/skills/openspec-development/SKILL.md`
* Изменить: `ai/skills/openspec-archive/SKILL.md`
* Изменить: `scripts/tests/test-openspec-scenarios.zsh`
* Создать: `scripts/tests/fixtures/openspec-orchestration/`

**Интерфейс:**

```text
openspec-orchestrate SNAPSHOT_JSON STATE_FILE [OPENSPEC_CLI]
```

Скрипт принимает локальный снимок события, безопасно обновляет известные поля
`state.md` и печатает одно JSON-решение. Он вызывает только явно переданный CLI
OpenSpec и Git, но не подменяет среду выполнения агентов.

* [ ] **Шаг 1: заменить статический сценарный тест исполняемым**

Проверить 14 сценариев через подменённый CLI, локальные данные JSON и реальные
`openspec-workspace`, `openspec-task-brief` и `sdd-workspace`. Зафиксировать
RED до появления `openspec-orchestrate`.

* [ ] **Шаг 2: реализовать минимальный драйвер событий**

Поддержать события `discover`, `recover`, `route`, `review`,
`review-complete`, `findings`, `verify`, `archive-guard` и `archive-impact`.
Решения должны наблюдаемо задавать команды, число ролей, режим, повторно
открытые пункты, свежий `HEAD` и архивные ограничения.

* [ ] **Шаг 3: сделать драйвер обязательной частью навыков**

`openspec-development` вызывает драйвер для всех детерминированных переходов.
`openspec-archive` передаёт ему проверки `archive-guard` и результат
`archive-impact`.

* [ ] **Шаг 4: выполнить полный профиль**

Запустить сценарный и профильные тесты, регрессии слоёв, `bash -n`, `zsh -n`,
`remark`, `quick_validate.py` и `git diff --check`.

## Итоговая самопроверка

* Задача 1 покрывает общие расширения SDD и предотвращает столкновение планов
* Задача 2 покрывает активацию, состояние, планирование, исполнение, ревью,
  восстановление и смешанные замечания
* Задача 3 покрывает архивирование, запрет двойного ревью, установку и
  регрессии
* Задача 4 делает 14 сценариев наблюдаемыми через исполняемый интерфейс
* Все требования design-документа сопоставлены с проверяемым шагом
* В плане нет незаполненных секций и ссылок на неопределённые интерфейсы
