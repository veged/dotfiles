require('utils')
require('plugins')

g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

g.mapleader = ' '
g.maplocalleader = ' '
o.langmap = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'
autocmd('InsertLeave', 'silent !macism org.sil.ukelele.keyboardlayout.vgd.vgd') -- require https://github.com/laishulu/macism

g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0

o.scrolljump = 5
o.scrolloff = 3

-- Remember last location in file
autocmd('BufRead', [[call setpos(".", getpos("'\""))]])

o.wrap = true
o.autoindent = true
o.smartindent = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2

o.list = true
vim.opt.listchars = { tab = '⋗⋅', trail = '·', nbsp = '∷', extends = '※' }
autocmd('BufEnter', 'EnableStripWhitespaceOnSave')

-- Spell checking
o.spell = false
o.spelllang = 'ru_yo,en_us'
o.spelloptions = 'camel,noplainbuffer'
keymapN(
  '<Leader>?',
  function()
    o.spell = not o.spell
    print('󰓆  Spell checking ' .. (o.spell and 'enabled' or 'disabled'))
  end,
  'Toggle spell checking'
)

-- Search and replace
o.ignorecase = true
o.smartcase = true
o.gdefault = true
autocmd('BufReadPost', 'nnoremap <buffer> <CR> <CR>', 'quickfix')
keymapN{
  ['<CR>'] = { Cmd'nohlsearch', 'Clear the search highlight' },
  n = { '<Plug>(highlight-current-n-n)', 'Next search highlight' },
  N = { '<Plug>(highlight-current-n-N)', 'Previous search highlight' }
}

-- Natural arrows in command mode
for k, pum in pairs({ Left = 'Up', Right = 'Down', Up = 'Left', Down = 'Right' }) do
  k = '<' .. k .. '>'
  vim.keymap.set(
    'c',
    k,
    function() return vim.fn.pumvisible() == 1 and '<' .. pum .. '>' or k end,
    { expr = true }
  )
end

-- Visual mode
keymapN{
  [S'Left'] = { 'vh', '⇧←' },
  [S'Right'] = { 'vl', '⇧→' },
  [S'Up'] = { 'Vk', '⇧↑' },
  [S'Down'] = { 'Vj', '⇧↓' } }
keymapV{
  [S'Left'] = { 'h', '⇧←' },
  [S'Right'] = { 'l', '⇧→' },
  [S'Up'] = { 'k', '⇧↑' },
  [S'Down'] = { 'j', '⇧↓' },
  ['<'] = { '<gv', 'Move left and keep selection' },
  ['>'] = { '>gv', 'Move right and keep selection' } }

-- System clipboard
keymapN{
  [C'c'] = { '"+yy', 'Copy to system clipboard' },
  [C'x'] = { '"+dd', 'Cut to system clipboard' } }
keymapV{
  [C'c'] = { '"+y', 'Copy to system clipboard' },
  [C'x'] = { '"+d', 'Cut to system clipboard' } }

-- Toggle mouse
o.mouse = ''
keymapN(
  '<Leader>m',
  function()
    if o.mouse == 'a' then
      o.mouse = ''
      print('󰍾  Mouse usage disabled')
    else
      o.mouse = 'a'
      print('󰍽  Mouse usage enabled')
    end
  end,
  'Toggle mouse')

-- Toggle cursor crosshair
keymapN('<Leader>c', Cmd'set cursorline! cursorcolumn!', 'Toggle cursor crosshair')

-- Toggle line numbers
keymapN(
  '<Leader>n',
  function()
    if not o.number then
      o.number = true
      o.relativenumber = true
    elseif o.relativenumber then
      o.number = true
      o.relativenumber = false
    else
      o.number = false
    end
  end,
  'Toggle line numbers')

keymapN{
  [C'End'] = { Cmd'bn', 'Next buffer' },
  [C'Home'] = { Cmd'bp', 'Previous buffer' } }

keymapN('U', C'r', 'Redo')

-- Write and quit
keymapN{
  ['<Leader>'] = {
    w = { Cmd'w', 'Write' },
    W = { Cmd'w!', 'Force write' },
    a = { Cmd'w', 'Write all' },
    A = { Cmd'wa!', 'Force write all' },
    q = { Cmd'q', 'Quit' },
    Q = { Cmd'q!', 'Force quit' },
    x = { Cmd'qa', 'Quit all' },
    X = { Cmd'qa!', 'Force quit all' },
    s = { Cmd'wqa', 'Write and quit all' },
    S = { Cmd'wqa!', 'Force write and quit all' },
  },
  { mode = { 'n', 'v' } } }

o.signcolumn = 'yes'

o.foldenable = false
o.foldmethod = 'expr'
o.foldexpr = 'nvim_treesitter#foldexpr()'

keymapN{
  ['-'] = { C'x', 'Decrement' },
  ['+'] = { C'a', 'Increment' } }

g.skip_ts_context_commentstring_module = true
g.python3_host_prog = '/Users/veged/.local/share/virtualenvs/veged-vne2RedP/bin/python'
