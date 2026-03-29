# Аудит NeoVim конфига veged/dotfiles — 2026

Полный разбор `init.lua` и `plugins.lua` по четырём категориям: критические баги, устаревшие/заменяемые плагины, пропущенные улучшения и вопросы, требующие решения.

***

## Критические проблемы

### Ghost-вызов nvim-tree

В `plugins.lua` на уровне `VimEnter` (до `lazy.setup`) выполняется:

```lua
require('nvim-tree.api').tree.open()
```

При этом `nvim-tree` **нигде не объявлен** в списке плагинов. `netrw` отключён (`g.loaded_netrw = 1`), а файловый проводник — это `Snacks.explorer`, который уже включён и настроен. При открытии директории из терминала (`nvim .`) это приводит к ошибке `module 'nvim-tree.api' not found`.[^1][^2]

**Исправление:**

```lua
-- было
autocmd('VimEnter', function(data)
  if vim.fn.isdirectory(data.file) == 1 then
    vim.cmd.cd(data.file)
    require('nvim-tree.api').tree.open()
  end
end)

-- стало
autocmd('VimEnter', function(data)
  if vim.fn.isdirectory(data.file) == 1 then
    vim.cmd.cd(data.file)
    Snacks.explorer()
  end
end)
```

### Невалидный spec для CodeCompanion

В `lazy.nvim` ключ `config = <table>` — это не валидная форма spec. Поддерживаются только `config = true`, `config = function() end`, или `opts = {}`. При передаче таблицы плагин загружается без каких-либо настроек — весь блок `strategies`, `adapters` и языковые параметры молча игнорируются. Это означает, что `CodeCompanion` у тебя сейчас работает с дефолтными адаптерами, без кастомного `api.eliza.yandex.net` и без `language = 'ru'`.[^3]

**Исправление:** обернуть в `config = function() require('codecompanion').setup({ ... }) end` или переименовать в `opts = { ... }`:

```lua
{
  'olimorris/codecompanion.nvim',
  cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions' },
  opts = {       -- <-- было: config = {
    strategies = {
      cmd  = { adapter = 'custom_anthropic', language = 'ru' },
      chat = { adapter = 'custom_anthropic', language = 'ru' },
      inline = { adapter = 'custom_anthropic', language = 'ru' },
    },
    adapters = { ... },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
},
```

***

## Avante и completion: отсутствует blink-интеграция

У `avante.nvim` зависимость `hrsh7th/nvim-cmp` помечена как опциональная и нужна для completion slash-команд и mentions. В твоём конфиге `nvim-cmp` не установлен, используется `blink.cmp`. Это означает, что `@file`, `@quickfix` и slash-команды в Avante sidebar сейчас работают без completion.[^4][^5][^6][^1]

Решение — добавить `Kaiser-Yang/blink-cmp-avante` как source для `blink.cmp`:[^7]

```lua
-- в blink.cmp opts:
sources = {
  default = { 'lsp', 'path', 'snippets', 'buffer', 'dictionary', 'lazydev', 'avante' },
  providers = {
    avante = {
      module = 'blink-cmp-avante',
      name = 'Avante',
    },
    -- ... существующие providers
  },
},

-- в avante.nvim dependencies добавить:
{ 'Kaiser-Yang/blink-cmp-avante' },
-- и убрать 'hrsh7th/nvim-cmp' из avante dependencies
```

***

## Устаревшие и заменяемые плагины

### norcalli/nvim-colorizer.lua → catgoose/nvim-colorizer.lua

Оригинальный репозиторий `norcalli` не обновлялся ~5 лет и фактически заброшен. Существует активно поддерживаемый форк [`catgoose/nvim-colorizer.lua`](https://github.com/catgoose/nvim-colorizer.lua), который добавляет поддержку `oklch`, `hwb`, `lab`, `lch`, `color()`, CSS custom properties (`var(--name)`), Tailwind CSS, Sass-переменных, режим virtualtext, приоритеты через `vim.hl.priorities` — и требует Neovim >= 0.10. Замена drop-in:[^8][^9][^10]

```lua
-- было
'norcalli/nvim-colorizer.lua'

-- стало
{ 'catgoose/nvim-colorizer.lua', event = 'BufReadPre', opts = {} }
```

*Заметка на будущее:* Neovim 0.12 (пока в master) добавит `vim.lsp.document_color` — нативную подсветку цветов через LSP. Когда 0.12 выйдет стабильно, colorizer можно будет полностью убрать для CSS/HTML и заменить на `LspAttach`-хук.[^11][^12]

### BetterLua.vim + vim-lua-format — оба избыточны

`euclidianAce/BetterLua.vim` — VimScript syntax file с последним коммитом в 2020 году. В конфиге уже есть `nvim-treesitter` с парсером `lua` и `lazydev.nvim`. Treesitter-подсветка lua полноценная, а BetterLua может конфликтовать с TS highlight groups или перекрывать их.[^13][^14][^1]

`andrejlevkovitch/vim-lua-format` вызывает внешний бинарник `LuaFormatter`. У тебя уже настроен `lua_ls` с `format.enable = true` и полным `defaultConfig` (indent, quotes, trailing separators). Оба плагина — прямая замена собственным конфигом: `lua_ls` делает то же самое, используя тот же внутренний форматтер StyLua-based.[^15][^1]

**Вердикт:** Удалить оба. Если захочешь внешний форматтер Lua — рассмотреть `stevearc/conform.nvim` со `stylua`.[^16]

### moll/vim-node — устарел в 2026

Последний коммит апрель 2018. Предоставляет: `gf` по `require()` путям и `:Nedit` для навигации в `node_modules`. В 2026 с `vtsls` + `nvim-vtsls` (оба присутствуют) LSP `gd`/`gr` покрывают навигацию по модулям семантически точнее, чем regex-эвристика `vim-node`. Единственный уникальный случай — `gf` для перехода в конкретный файл в `node_modules`, но с `Snacks.picker` или `fff.nvim` это решается иначе.[^17][^1]

**Вердикт:** Кандидат на удаление. Проверить, используешь ли `gf` по node_modules вручную.

***

## Пропущенные улучшения

### tsx-парсер не установлен

В `ensure_installed` перечислены `html`, `css`, `javascript`, `typescript`, `json`, `lua` — **`tsx` отсутствует**. При этом `vim-jsx-pretty` загружается для `typescriptreact` и `javascriptreact`, а в LSP-конфиге заданы `typescriptreact` и `javascriptreact` filetypes.[^1]

Без `tsx`-парсера Treesitter не может правильно строить синтаксическое дерево TSX-файлов. Это приводит к смешанной подсветке: частично через `vim-jsx-pretty` (regex), частично через TS (без понимания JSX-структуры).[^18][^19]

**Исправление:** добавить `'tsx'` в `ensure_installed`:

```lua
ensure_installed = { 'html', 'css', 'javascript', 'typescript', 'tsx', 'json', 'lua' },
```

После добавления `tsx`-парсера стоит проверить, нужен ли `vim-jsx-pretty` ещё для indent — в некоторых конфигах Treesitter indent для tsx всё ещё работает нестабильно, так что `vim-jsx-pretty` пока лучше оставить.[^19][^18]

### nvim-treesitter: ветка master заморожена

С мая 2025 ветка `master` заморожена — README официально гласит: «The master branch is frozen and provided for backward compatibility only». Все новые парсеры, исправления и функции теперь только в `main`.[^20][^21]

**Важно:** `main` — это полностью несовместимый рерайт с другим API, который требует миграции конфига практически с нуля. Текущий конфиг с `require('nvim-treesitter.configs').setup({...})` работает только на `master`. Переход на `main` — это отдельный проект, не однострочное изменение.[^22][^20]

**Вердикт пока:** зафиксировать явно `branch = 'master'` чтобы не получить сюрприз, когда master перестанет быть дефолтом. Следить за экосистемой — переход на `main` неизбежен, но не срочен.

```lua
{
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',   -- явно, до готовности к main-миграции
  build = ':TSUpdate',
  ...
}
```

### Дублирующийся биндинг command_history

`<Leader>:` привязан к `Snacks.picker.command_history()`, и одновременно `<Leader>f:` привязан к `telescopeBuiltin.command_history`. Это разные префиксы, но семантически одна функция через два разных инструмента — создаёт путаницу.[^1]

### Telescope: все use-cases покрывает Snacks.picker

`Telescope` используется ровно для пяти вещей: `colorscheme`, `current_buffer_fuzzy_find`, `buffers`, `command_history`, `help_tags`. У `Snacks.picker` есть все эти источники. Если убрать Telescope, высвобождается одна `plenary.nvim`-зависимость и устраняется дублирование picker-слоя. При этом `avante.nvim` имеет Telescope как опциональный `file_selector` — его можно заменить на `snacks` или `fzf`.[^5][^23][^24][^1]

### CodeCompanion: устаревшая модель

В конфиге `claude-3-7-sonnet-20250219`, тогда как Avante уже использует `claude-sonnet-4-5`. Стоит обновить в обоих адаптерах (`custom_anthropic` и `custom_deepseek`).[^1]

### CodeCompanion: нет lazy-loading

CodeCompanion объявлен без `cmd`, `keys` или `event` — он загружается при старте. Логичнее:[^1]

```lua
cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions' },
keys = { { '<Leader>ai', '<Cmd>CodeCompanionActions<CR>' } },
```

***

## Плагины без изменений (исследованы, оставить)

| Плагин | Почему оставить |
|--------|----------------|
| `dmtrKovalenko/fff.nvim` | Уникальный Rust-бэкенд, собственный файловый индекс, frecency-ranking, typo-resistant fuzzy — принципиально другой класс, не дубль picker'ов[^25][^26] |
| `numToStr/Comment.nvim` | Нативный `gc` (Neovim 0.10+) не поддерживает кастомные маппинги `<Leader><Leader>` / `<Leader>*`, а также `gcA`, `gco`, `gcO`[^27][^28][^29] |
| `rickhowe/diffchar.vim` | Единственный инструмент для char-by-char diff highlight; нативного аналога нет ни в 0.11, ни в 0.12[^30][^31][^32] |
| `ntpeters/vim-better-whitespace` | Активно обновляется (2025), `better_whitespace_operator = '_'` — не дефолт, `EnableStripWhitespaceOnSave` удобнее чем autocmd-самописка[^33] |
| `booperlv/nvim-gomove` | Нет активно поддерживаемой замены с функцией **дублирования** блоков; `mini.move` умеет только перемещать[^34][^35] |
| `windwp/nvim-ts-autotag` | Нет нативного аналога для HTML-тегов |
| `windwp/nvim-autopairs` | Нет нативного аналога |
| `kylechui/nvim-surround` | Нет нативного аналога; кастомное `~` для markdown code-блоков — уникальная логика[^1] |
| `maxmellon/vim-jsx-pretty` | До выяснения стабильности Treesitter indent для tsx — оставить (см. раздел про tsx-парсер)[^18][^19] |
| `olimorris/codecompanion.nvim` | Отдельный AI-слой с blink-completion в chat-буфере, slash-commands, action palette — не дублирует Avante (Cursor-style edit workflow)[^3][^36] |

### Что делать с zoomwintab.vim

`troydm/zoomwintab.vim` — старый VimScript плагин. Нативного toggle-zoom/restore в Neovim нет. Но у тебя уже есть `snacks.nvim`, а `Snacks.zen` реализует zoom-подобное поведение через `toggle`-механизм, который ты уже используешь (`Snacks.toggle.new`). Стоит попробовать:[^37][^1]

```lua
-- в Snacks init, рядом с другими toggle:
Snacks.toggle.zen():map('<C-w>o')
```

Это позволит убрать `zoomwintab.vim` без потери функциональности, используя уже загруженный `snacks`.

***

## Сводная таблица вердиктов

| Плагин | Вердикт | Действие |
|--------|---------|----------|
| Ghost `nvim-tree` call | 🔴 Баг | Заменить на `Snacks.explorer()` |
| `CodeCompanion` config = {} | 🔴 Баг | Переписать как `opts = {}` или `config = function()` |
| `avante` + blink без source | 🟡 Нефункционально | Добавить `blink-cmp-avante` |
| `norcalli/nvim-colorizer.lua` | 🟡 Устарел | Заменить на `catgoose/nvim-colorizer.lua` |
| `BetterLua.vim` | 🟡 Избыточен | Удалить (TS lua parser) |
| `vim-lua-format` | 🟡 Избыточен | Удалить (lua_ls format) |
| `moll/vim-node` | 🟡 Устарел | Кандидат на удаление |
| `tsx` в ensure_installed | 🟡 Отсутствует | Добавить |
| `nvim-treesitter` branch | 🟡 Неявно | Зафиксировать `branch = 'master'` |
| Дубль `command_history` | 🟡 Коллизия | Выбрать один источник |
| Telescope vs Snacks.picker | 🔵 Упрощение | Рассмотреть замену |
| `zoomwintab.vim` | 🔵 Упрощение | Рассмотреть `Snacks.toggle.zen` |
| `CodeCompanion` lazy-loading | 🔵 Улучшение | Добавить `cmd =` |
| CodeCompanion model | 🔵 Устарело | Обновить до claude-sonnet-4-5 |

---

## References

1. [plugins.lua.pdf](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/9364607/f54bc1f5-9b11-4665-b4a3-6365a2974992/plugins.lua.pdf?AWSAccessKeyId=ASIA2F3EMEYETTQYAOMB&Signature=jRcVNd2kpE3T1CdMORABwbH6puI%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEEoaCXVzLWVhc3QtMSJHMEUCIQD%2F4VN99vHoAM2rYEWb5Fg2aul6zpUK0NOm1v0nTDcq6gIgK0iBIXmYygzSv%2BSMNnHDxjy189rdhua%2BvLJper24YPUq8wQIExABGgw2OTk3NTMzMDk3MDUiDIlWKqf1klYLs09zbirQBMsAoPpmFJweslVzSeSpcJEVuFEI4%2BFdWEkWN9wOFb6PHhOHCA7j9EGplE%2Fs1LHd9QUjci9s7NkkqxK1o6mKqSMG3Ya0Am18TlLix42zX5WSFTZfLA%2FDv0nqSy1h6D2cicpe3xOFBIJ7KLM87QkRUrG6WzLSZKgU9LGXNut14JucVEjSmg9kDi1IMJ0lsBs5FiWgl6RnXn0IlXx6AjUOxhDfHy7zSQ2rueE0ng4yt6eK8IPpvz%2FqhLz2a79wok9Hm%2BCzcX%2BJ9Kt%2F5LX4YCEF%2Fp5TK88KeDijAwsIGktDVJ68N%2FSa1zPBG94ofE0d7sWBRJ8JpT52mffXH%2FOZHtg%2BIbuVz%2FtDjv%2FEAahlfumq%2BAngAo5hPDslZ9UdoXE01J7a%2BB3tAqv9PxhCL4HtNo7G9hGLqb0L6yMrdPFm2acalbINeKJhYmzXc4dP%2F9gB1Z0PDMuYe1sLTYk9FsdO4w0UHIvKtOPqFHnF4zN40BmNL1HTQOzi6G7VaJ495Dpzmxjz%2FM%2BZN4x%2BR8NuUBcZs6uZcemc0wYKWyYvL8iae3rqDPdKqNaOhS8JmN4ZroeU2wrB8CEUmaZe9WYEn7Nr2g1S45WSXHSt85PEG7O2lD6%2BZlg1gzLOtz55%2BctaWfYIM%2F9%2BqKw5ujSZjfzXtWugg9in8dUBBDWfggvk%2B3YVW%2FOCjS3TllBVOclMTxvxCPLDZT9jJIV8xIF142ggiM3TdsdkSzIbB3e%2FhXsTCc4AUbnZrhSYJlQGjgS59ykMWk%2BtaBKOELQg4A82r%2FzWoSss2q9U9tEwi8ClzgY6mAHpurh2qUvBHdYaSGIprNC0KklWSQ7Iy2slOPuCqsAYSvc94HNUd7OQTXec88EfHuf8ZozcVjDltFivP5Acf0IiLrbPmAQX3d1viGMDjIG2OnW5ZuZZl0b4Qob7k5Ry1%2FkGCOxO6lfqyzcC5qw24M6jqjunPyjTujeihpaWQXluS1hppAsjiQG1A9TD1DeUSKrQ19OlVUz7aQ%3D%3D&Expires=1774808542) - 1/30
plugins.lua
o = vim.opt 
 
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim' 
if not...

2. [init.lua.pdf](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/9364607/264f0e8e-9213-4bd0-a829-df0e7f00cf8a/init.lua.pdf?AWSAccessKeyId=ASIA2F3EMEYETTQYAOMB&Signature=dBJNankyh6%2BfjGHTawGRa6wKP8Q%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEEoaCXVzLWVhc3QtMSJHMEUCIQD%2F4VN99vHoAM2rYEWb5Fg2aul6zpUK0NOm1v0nTDcq6gIgK0iBIXmYygzSv%2BSMNnHDxjy189rdhua%2BvLJper24YPUq8wQIExABGgw2OTk3NTMzMDk3MDUiDIlWKqf1klYLs09zbirQBMsAoPpmFJweslVzSeSpcJEVuFEI4%2BFdWEkWN9wOFb6PHhOHCA7j9EGplE%2Fs1LHd9QUjci9s7NkkqxK1o6mKqSMG3Ya0Am18TlLix42zX5WSFTZfLA%2FDv0nqSy1h6D2cicpe3xOFBIJ7KLM87QkRUrG6WzLSZKgU9LGXNut14JucVEjSmg9kDi1IMJ0lsBs5FiWgl6RnXn0IlXx6AjUOxhDfHy7zSQ2rueE0ng4yt6eK8IPpvz%2FqhLz2a79wok9Hm%2BCzcX%2BJ9Kt%2F5LX4YCEF%2Fp5TK88KeDijAwsIGktDVJ68N%2FSa1zPBG94ofE0d7sWBRJ8JpT52mffXH%2FOZHtg%2BIbuVz%2FtDjv%2FEAahlfumq%2BAngAo5hPDslZ9UdoXE01J7a%2BB3tAqv9PxhCL4HtNo7G9hGLqb0L6yMrdPFm2acalbINeKJhYmzXc4dP%2F9gB1Z0PDMuYe1sLTYk9FsdO4w0UHIvKtOPqFHnF4zN40BmNL1HTQOzi6G7VaJ495Dpzmxjz%2FM%2BZN4x%2BR8NuUBcZs6uZcemc0wYKWyYvL8iae3rqDPdKqNaOhS8JmN4ZroeU2wrB8CEUmaZe9WYEn7Nr2g1S45WSXHSt85PEG7O2lD6%2BZlg1gzLOtz55%2BctaWfYIM%2F9%2BqKw5ujSZjfzXtWugg9in8dUBBDWfggvk%2B3YVW%2FOCjS3TllBVOclMTxvxCPLDZT9jJIV8xIF142ggiM3TdsdkSzIbB3e%2FhXsTCc4AUbnZrhSYJlQGjgS59ykMWk%2BtaBKOELQg4A82r%2FzWoSss2q9U9tEwi8ClzgY6mAHpurh2qUvBHdYaSGIprNC0KklWSQ7Iy2slOPuCqsAYSvc94HNUd7OQTXec88EfHuf8ZozcVjDltFivP5Acf0IiLrbPmAQX3d1viGMDjIG2OnW5ZuZZl0b4Qob7k5Ry1%2FkGCOxO6lfqyzcC5qw24M6jqjunPyjTujeihpaWQXluS1hppAsjiQG1A9TD1DeUSKrQ19OlVUz7aQ%3D%3D&Expires=1774808542) - 1/5
init.lua
require('utils') 
 
g.loaded_netrw = 1 
g.loaded_netrwPlugin = 1 
 
g.mapleader = ' ' 
...

3. [Getting Started](https://codecompanion.olimorris.dev/getting-started) - AI Coding, Vim Style

4. [support blink as cmp provider · Issue #959 · yetone/avante.nvim](https://github.com/yetone/avante.nvim/issues/959) - LazyVim recently switched to blink instead of nvim-cmp , can blink be supported by avante as well? I...

5. [bug: vim.validate is deprecated. Feature will be removed in Nvim 1.0 ...](https://github.com/yetone/avante.nvim/issues/2167) - vim.validate is deprecated. Feature will be removed in Nvim 1.0. ADVICE: - use vim.validate(name, va...

6. [bug: build failed · Issue #1578 · yetone/avante.nvim - GitHub](https://github.com/yetone/avante.nvim/issues/1578) - --- The below dependencies are optional, "echasnovski/mini.pick ... "hrsh7th/nvim-cmp", -- autocompl...

7. [Kaiser-Yang/blink-cmp-avante - GitHub](https://github.com/Kaiser-Yang/blink-cmp-avante) - Avante source for blink.cmp. Use @ to trigger the mention completion. Accept the @file or @quickfix ...

8. [norcalli/nvim-colorizer.lua: The fastest Neovim colorizer.](https://github.com/norcalli/nvim-colorizer.lua) - The fastest Neovim colorizer. Contribute to norcalli/nvim-colorizer.lua development by creating an a...

9. [GitHub - catgoose/nvim-colorizer.lua: The fastest Neovim colorizer](https://github.com/catgoose/nvim-colorizer.lua) - The fastest Neovim colorizer. Contribute to catgoose/nvim-colorizer.lua development by creating an a...

10. [catgoose/nvim-colorizer.lua - neovimcraft](https://neovimcraft.com/plugin/catgoose/nvim-colorizer.lua/) - catgoose/nvim-colorizer.lua: The fastest Neovim colorizer

11. [LSP `document_color` support available on `master` (AKA v0.12)](https://www.reddit.com/r/neovim/comments/1k7arqq/lsp_document_color_support_available_on_master/) - nvim now supports LSP document colors, so if your language server can recognize a colorful thing and...

12. [Lsp - Neovim docs](https://neovim.io/doc/user/lsp/) - Document colors are enabled for highlighting color references in a document. To opt out call vim.lsp...

13. [GitHub - euclidianAce/BetterLua.vim: Better Lua syntax highlighting in Vim/NeoVim](https://github.com/euclidianAce/BetterLua.vim) - Better Lua syntax highlighting in Vim/NeoVim. Contribute to euclidianAce/BetterLua.vim development b...

14. [Basic Highlight Overriding · Issue #3058 · nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter/issues/3058) - Describe the highlighting problem All I want to do is override a highlight group. I have tried many ...

15. [andrejlevkovitch/vim-lua-format - GitHub](https://github.com/andrejlevkovitch/vim-lua-format) - lua-format : Specifies the style config file. Style Options. The .lua-format file must be in the sou...

16. [Part 7: Neovim formatter with conform.nvim | Duy NG](https://tduyng.com/blog/neovim-formatter-conform/) - Setup code formatter with conform.nvim. Format your code automatically on save

17. [Issues · moll/vim-node - GitHub](https://github.com/moll/vim-node/issues) - Tools and environment to make Vim superb for developing with Node.js. Like Rails.vim for Node. - mol...

18. [LSP-Zero default config: TSX and JSX indentation is seriously busted.](https://www.reddit.com/r/neovim/comments/10v2xgy/lspzero_default_config_tsx_and_jsx_indentation_is/)

19. [A problem with jsx/tsx highlighting with Treesitter. : r/neovim - Reddit](https://www.reddit.com/r/neovim/comments/y8wkyg/a_problem_with_jsxtsx_highlighting_with_treesitter/) - Highlighting of JSX and TSX is improper. As you can see, these less/greater signs that open and clos...

20. [master => main switching instructions · nvim-treesitter nvim-treesitter · Discussion #7901](https://github.com/nvim-treesitter/nvim-treesitter/discussions/7901) - Hello! I've been following the master branch via vim-plug like this: Plug 'nvim-treesitter/nvim-tree...

21. [nvim-treesitterのmainブランチ移行 - yasunori0418's blog](https://blog.yasunori0418.dev/p/migrate-treesitter-main/) - Vim駅伝\nこの記事はVim駅伝の2025-08-13向けの記事です。\n前回の記事はmitsu-yukiさんの『Vimへコピぺする時に置き換え元の文字でクリップボードを上書きしないいくつかの方法』...

22. [master => main switching instructions · Issue #7899 · nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter/issues/7899) - Hello! I've been following the master branch via vim-plug like this: Plug 'nvim-treesitter/nvim-tree...

23. [How to transform your Neovim to Cursor in minutes - Composio](https://composio.dev/content/how-to-transform-your-neovim-to-cursor-in-minutes) - Prerequisites · Neovim 0.10.1 (or higher) · A plugin manager. Better if you have lazy.nvim · avante....

24. [Trending Neovim Plugins in 2026 - Dotfyle](https://dotfyle.com/neovim/plugins/trending) - List of trending Neovim plugins ranked by recent installations across 1000+ tracked Neovim configura...

25. [dmtrKovalenko/fff.nvim: Finally a Fast Fuzzy File Finder for ...](https://github.com/dmtrKovalenko/fff.nvim) - Finally a Fast Fuzzy File Finder for neovim . Contribute to dmtrKovalenko/fff.nvim development by cr...

26. [dmtrKovalenko/fff.nvim - Neovim plugin - Dotfyle](https://dotfyle.com/plugins/dmtrKovalenko/fff.nvim) - Fast File Finder for your AI and neovim, with memory built-in

27. [Does the builtin comment feature miss the gco etc function? #28995](https://github.com/neovim/neovim/discussions/28995) - Apparently, we can press o to insert the comment then press gcc. But I think this method breaks the ...

28. [Neovim now has built-in commenting - Reddit](https://www.reddit.com/r/neovim/comments/1bwlvrt/neovim_now_has_builtin_commenting/) - The PR for built-in commenting has been merged into Nightly builds. There is more info in the initia...

29. [How to Vim: Toggle Comments - Bozhidar Batsov](https://batsov.com/articles/2025/05/25/how-to-vim-toggle-comments/) - Neovim 0.10 (released in 2024) introduced built-in commenting gc ... Now you'll have pretty much the...

30. ['rickhowe/diffchar.vim' Highlight the exact differences, based ... - Reddit](https://www.reddit.com/r/neovim/comments/1duw5kq/rickhowediffcharvim_highlight_the_exact/) - It gives me the Delta user experience when using Vim as a diff pager with this plugin. 20 upvotes · ...

31. [How to highlight only the actual differences in Vim diff?](https://stackoverflow.com/questions/45256477/how-to-highlight-only-the-actual-differences-in-vim-diff) - When using vimdiff, it highlights the differing portion of the lines in a "greedy" fashion. That is,...

32. [rickhowe/diffchar.vim: Highlight the exact differences ... - GitHub](https://github.com/rickhowe/diffchar.vim) - Vim highlights all the text in between the first and last different characters on a changed line. Bu...

33. [ntpeters/vim-better-whitespace - GitHub](https://github.com/ntpeters/vim-better-whitespace) - The purpose of this plugin is to provide a better experience for showing and dealing with extra whit...

34. [booperlv/nvim-gomove - GitHub](https://github.com/booperlv/nvim-gomove) - A complete plugin for moving and duplicating blocks and lines, with complete fold handling, reindent...

35. [mini.move vs nvim-gomove - compare differences and ...](https://www.libhunt.com/compare-mini.move-vs-nvim-gomove)

36. [CodeCompanion.nvim与Blink.cmp兼容性问题解析 - GitCode博客](https://blog.gitcode.com/0ca3d49d4b11e288844e59ced83e4c75.html) - 在Neovim生态系统中，代码补全功能是开发者工作流中不可或缺的一部分。CodeCompanion.nvim作为一款新兴的AI辅助编程插件，其与各类补全引擎的兼容性尤为重要。近期发现的一个典型问题涉及...

37. [GitHub - vim-scripts/zoomwintab.vim: zoomwintab.vim is a simple zoom window plugin](https://github.com/vim-scripts/zoomwintab.vim) - zoomwintab.vim is a simple zoom window plugin. Contribute to vim-scripts/zoomwintab.vim development ...

