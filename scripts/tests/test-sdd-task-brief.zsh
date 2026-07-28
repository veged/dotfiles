#!/usr/bin/env zsh

emulate -LR zsh
set -euo pipefail

repo_root=${0:A:h:h:h}
task_brief="$repo_root/ai/skills/subagent-driven-development/scripts/task-brief"
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/sdd-task-brief.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT

fail() {
  print -u2 -- "$1"
  exit 1
}

plan="$tmp_root/plan.md"
cat > "$plan" <<'MARKDOWN'
# План

### Задача 1: Русский заголовок

Требование первой задачи.

```markdown
### Task 99: Это пример, а не задача плана
```

### Task 2: English technical heading

Требование второй задачи.

### Задача 3: Следующая задача

Требование третьей задачи.
MARKDOWN

"$task_brief" "$plan" 1 "$tmp_root/task-1.md"
ugrep -Fq 'Требование первой задачи.' "$tmp_root/task-1.md" \
  || fail 'не извлечена задача с русским заголовком'
if ugrep -Fq 'Требование второй задачи.' "$tmp_root/task-1.md"; then
  fail 'brief первой задачи захватил следующую задачу'
fi

"$task_brief" "$plan" 2 "$tmp_root/task-2.md"
ugrep -Fq 'Требование второй задачи.' "$tmp_root/task-2.md" \
  || fail 'не извлечена задача с английским заголовком'
if ugrep -Fq 'Это пример, а не задача плана' "$tmp_root/task-2.md"; then
  fail 'заголовок внутри code fence принят за задачу'
fi

set +e
"$task_brief" "$plan" '1.*' "$tmp_root/invalid.md" 2>"$tmp_root/invalid.err"
exit_code=$?
set -e

[[ $exit_code -eq 2 ]] \
  || fail "ожидался код 2 для некорректного номера, получен $exit_code"
ugrep -Fq 'положительным целым числом' "$tmp_root/invalid.err" \
  || fail 'нет диагностики некорректного номера'

print 'test-sdd-task-brief: ok'
