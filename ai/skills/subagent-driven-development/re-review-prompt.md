# Message для scoped re-review Work Unit

Основной путь — `followup_task` тому же reviewer, который вынес исходные
замечания. Это не новый dispatch и не новая позиция fresh-agent budget.

```yaml
target: "[REVIEWER_ID]"
message: |
  Повторно проверь исправления Work Unit N.

  ## Исходные требования

  [BRIEF_FILES]

  ## Открытые замечания

  [FINDINGS]

  ## Исправление

  Report implementer: [REPORT_FILE]
  Fix base: [FIX_BASE_SHA]
  Head: [HEAD_SHA]
  Scoped review package: [DIFF_FILE]

  Прочитай последние fix-записи report и package. Для каждого замечания
  вынеси ADDRESSED или NOT ADDRESSED с `file:line`.

  Проверяй только список замечаний и новый fix diff. Новую
  Critical/Important-регрессию внутри fix diff добавь к открытым
  замечаниям. Наблюдение вне fix diff пометь как Out-of-Scope и не расширяй
  им цикл.

  Не повторяй тесты из актуального report. Узкий тест допустим только при
  конкретном новом сомнении.

  Review только для чтения. Не меняй worktree, index, HEAD или branch.

  ## Формат ответа

  ### Вердикты замечаний
  - [замечание] — ADDRESSED | NOT ADDRESSED; file:line

  ### Новые регрессии в fix diff
  - Critical/Important/Minor или «нет»

  ### Наблюдения вне scope
  - [...] или «нет»

  ### Итог
  Fix round: all addressed | findings remain

  Начни сразу с первого вердикта, без рассказа о процессе.
```

## Fallback при недоступном reviewer

Только если исходный reviewer завершён и его нельзя продолжить:

1. пересчитай `fresh-agent budget`;
2. запиши причину новой позиции в ledger;
3. создай одного replacement reviewer с явными
   `fork_turns: "none"` и `model`;
4. передай ему этот message, исходный review report и все перечисленные
   ниже файлы.

Не используй fallback только потому, что новый dispatch привычнее.

## Плейсхолдеры

- `[REVIEWER_ID]` — идентификатор исходного reviewer для `followup_task`.
- `[BRIEF_FILES]` — те же brief-файлы `Work Unit`.
- `[FINDINGS]` — Critical/Important и реальные spec gaps без пересказа.
- `[REPORT_FILE]` — тот же report с дописанной fix-секцией.
- `[FIX_BASE_SHA]`, `[HEAD_SHA]` — только диапазон исправления.
- `[DIFF_FILE]` — scoped package, созданный `scripts/review-package`.
