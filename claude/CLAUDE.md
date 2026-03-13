# Глобальные инструкции

## Язык

Всегда общайся со мной на **русском языке**.

## CLI: обязатоное использование современных инструментов

| Вместо | Используй | Ключевые фичи |
|--------|-----------|---------------|
| grep | ugrep | `--bool 'a AND b'`, `-z3` fuzzy, `-I` skip binary |
| find | fd | `-x cmd {}` parallel exec, `-e ext`, `-S +100k`, `--changed-within 7d` |
| sed | sd | `-p` preview, `-s` literal (без regex), in-place по умолчанию |
| ls | eza | `--tree`, `--git`, `-la` |
| curl | xh | auto exit codes (4=4xx, 5=5xx), нет --retry |
| man | tldr | краткие примеры |
| awk (JSON) | jq | `-s` slurp files, `-r` raw output |
| Fetch, WebFetch (GitHub) | gh | `gh api repos/o/r/readme --jq '.content' \| base64 -d`, `gh pr view`, `gh issue view` |
| — | yq | YAML/JSON/XML/CSV/TOML, `-i` in-place, `-o json` |
| — | fzf | `fd \| fzf --preview 'bat {}'` |

### Принципы

* **Минимизируй пайпы** — jq/ugrep/fd делают всё сами:
  ```bash
  # ❌ fd -e json | xargs cat | jq '.x' | sort | uniq -c
  # ✅ jq -s '[.[].x] | group_by(.) | map({v:.[0], n:length})' *.json
  ```
* **`fd -x` вместо `xargs`** — встроенный параллелизм и обработка пробелов
* **Предпросмотр перед деструктивом** — `sd -p`, `fd ... ` без `-x rm` сначала
* **Пробелы в именах** — `fd -x cmd {}` или `fd -0 | xargs -0`
