require('plugins')

local g = vim.g
local o = vim.o
local autocmd = function(e, p, c) vim.api.nvim_create_autocmd(e, { pattern = p, command = c }) end
local keys = require('which-key').register
local keysV = function(k) keys(k, { mode = 'v' }) end
local key = function(k, c, d) keys({ [k] = { c, d } }) end
local Cmd = function (s) return '<Cmd>' .. s .. '<CR>' end
local S= function (s) return '<S-' .. s .. '>' end
local C= function (s) return '<C-' .. s .. '>' end

g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

g.mapleader = ' '
g.maplocalleader = ' '
o.langmap = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'
autocmd('InsertLeave', '*', 'silent !macism org.sil.ukelele.keyboardlayout.vgd.vgd') -- require https://github.com/laishulu/macism

g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0

o.scrolljump = 5
o.scrolloff = 3

-- Remember last location in file
autocmd('BufRead', '*', [[call setpos(".", getpos("'\""))]])

o.wrap = true
o.autoindent = true
o.smartindent = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2

o.list = true
vim.opt.listchars = { tab = '⋗⋅', trail = '·', nbsp = '∷', extends = '※' }
autocmd('BufEnter', '*', 'EnableStripWhitespaceOnSave')

-- Spell checking
o.spell = false
o.spelllang = 'ru_yo,en_us'
o.spelloptions = 'camel,noplainbuffer'
key(
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
autocmd('BufReadPost', 'quickfix', 'nnoremap <buffer> <CR> <CR>')
keys{
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
keys{
  [S'Left'] = { 'vh', '⇧←' },
  [S'Right'] = { 'vl', '⇧→' },
  [S'Up'] = { 'Vk', '⇧↑' },
  [S'Down'] = { 'Vj', '⇧↓' } }
keysV{
  [S'Left'] = { 'h', '⇧←' },
  [S'Right'] = { 'l', '⇧→' },
  [S'Up'] = { 'k', '⇧↑' },
  [S'Down'] = { 'j', '⇧↓' },
  ['<'] = { '<gv', 'Move left and keep selection' },
  ['>'] = { '>gv', 'Move right and keep selection' } }

-- System clipboard
keys{
  [C'c'] = { '"+yy', 'Copy to system clipboard' },
  [C'x'] = { '"+dd', 'Cut to system clipboard' } }
keysV{
  [C'c'] = { '"+y', 'Copy to system clipboard' },
  [C'x'] = { '"+d', 'Cut to system clipboard' } }

-- Toggle mouse
o.mouse = ''
key(
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
key('<Leader>c', Cmd'set cursorline! cursorcolumn!', 'Toggle cursor crosshair')

-- Toggle line numbers
key(
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

keys{
  [C'End'] = { Cmd'bn', 'Next buffer' },
  [C'Home'] = { Cmd'bp', 'Previous buffer' } }

key('U', C'r', 'Redo')

-- Write and quit
keys{
  ['<Leader>'] = {
    w = { Cmd'w', 'Write' },
    W = { Cmd'w', 'Write all' },
    q = { Cmd'q', 'Quit' },
    Q = { Cmd'qa', 'Quit all' },
    x = { Cmd'qa', 'Quit all' },
    s = { Cmd'wqa', 'Write and quit all' },
    ['!'] = {
      w = { Cmd'w!', 'Force write' },
      W = { Cmd'wa!', 'Force write all' },
      q = { Cmd'q!', 'Force quit' },
      Q = { Cmd'qa!', 'Force quit all' },
      x = { Cmd'qa!', 'Force quit all' },
      s = { Cmd'wqa!', 'Force write and quit all' },
      name = 'Force'
    }
  },
  { mode = { 'n', 'v' } } }

-- vim.api.nvim_create_user_command('W', 'w', { desc = 'Write' })
-- vim.api.nvim_create_user_command('Wa', 'w', { desc = 'Write all' })
-- vim.api.nvim_create_user_command('Wq', 'wq', { desc = 'Write and quit' })
-- vim.api.nvim_create_user_command('Wqa', 'wqa', { desc = 'Write and quit all' })
-- vim.api.nvim_create_user_command('Q', 'q', { desc = 'Quit' })
-- vim.api.nvim_create_user_command('Qa', 'qa', { desc = 'Quit all' })

o.signcolumn = 'yes'

o.foldenable = false
o.foldmethod = 'expr'
o.foldexpr = 'nvim_treesitter#foldexpr()'

keys{
  ['-'] = { C'x', 'Decrement' },
  ['+'] = { C'a', 'Increment' } }

g.skip_ts_context_commentstring_module = true
