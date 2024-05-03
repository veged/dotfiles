vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.langmap = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'
vim.api.nvim_create_autocmd( 'InsertLeave', { pattern = '*', command = 'silent !macism org.sil.ukelele.keyboardlayout.vgd.vgd' }) -- require https://github.com/laishulu/macism

require('plugins')

vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

vim.o.scrolljump = 5
vim.o.scrolloff = 3

-- Remember last location in file
vim.api.nvim_create_autocmd('BufRead', { pattern = '*', command = [[call setpos(".", getpos("'\""))]] })

vim.o.wrap = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2

vim.o.list = true
vim.opt.listchars = { tab = '⋗⋅', trail = '·', nbsp = '∷', extends = '※' }
vim.api.nvim_create_autocmd('BufEnter', { pattern = '*', command = 'EnableStripWhitespaceOnSave' })

local wk = require('which-key')

-- Spell checking
vim.o.spell = false
vim.o.spelllang = 'ru_yo,en_us'
vim.o.spelloptions = 'camel,noplainbuffer'
wk.register({
  ['<Leader>?'] = {
    function()
      vim.o.spell = not vim.o.spell
      print('󰓆  Spell checking ' .. (vim.o.spell and 'enabled' or 'disabled'))
    end,
    'Toggle spell checking'
  }
})

-- Search and replace
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.gdefault = true
vim.api.nvim_create_autocmd('BufReadPost', { pattern = 'quickfix', command = 'nnoremap <buffer> <CR> <CR>' })
wk.register({
  ['<CR>'] = { '<Cmd>nohlsearch<CR>', 'Clear the search highlight' },
  n = { '<Plug>(highlight-current-n-n)', 'Next search highlight' },
  N = { '<Plug>(highlight-current-n-N)', 'Previous search highlight' }
})

-- Natural arrows in command mode
for key, pum in pairs({ Left = 'Up', Right = 'Down', Up = 'Left', Down = 'Right' }) do
  key = '<' .. key .. '>'
  vim.keymap.set('c', key, function() return vim.fn.pumvisible() == 1 and '<' .. pum .. '>' or key end, { expr = true })
end

-- Visual mode
wk.register({
  ['<S-Left>'] = { 'vh', '⇧←' },
  ['<S-Right>'] = { 'vl', '⇧→' },
  ['<S-Up>'] = { 'Vk', '⇧↑' },
  ['<S-Down>'] = { 'Vj', '⇧↓' }
})
wk.register({
  ['<S-Left>'] = { 'h', '⇧←' },
  ['<S-Right>'] = { 'l', '⇧→' },
  ['<S-Up>'] = { 'k', '⇧↑' },
  ['<S-Down>'] = { 'j', '⇧↓' },
  ['<'] = { '<gv', 'Move left and keep selection' },
  ['>'] = { '>gv', 'Move right and keep selection' }
}, { mode = 'v' })

-- System clipboard
wk.register({
  ['<C-c>'] = { '"+yy', 'Copy to system clipboard' },
  ['<C-x>'] = { '"+dd', 'Cut to system clipboard' }
})
wk.register({
  ['<C-c>'] = { '"+y', 'Copy to system clipboard' },
  ['<C-x>'] = { '"+d', 'Cut to system clipboard' }
}, { mode = 'v' })

-- Toggle mouse
vim.o.mouse = ''
wk.register({
  ['<Leader>m'] = {
    function()
      if vim.o.mouse == 'a' then
        vim.o.mouse = ''
        print('󰍾  Mouse usage disabled')
      else
        vim.o.mouse = 'a'
        print('󰍽  Mouse usage enabled')
      end
    end,
    'Toggle mouse'
  }
})

-- Toggle cursor crosshair
wk.register({ ['<Leader>c'] = { '<Cmd>set cursorline! cursorcolumn!<CR>', 'Toggle cursor crosshair' } })

-- Toggle line numbers
wk.register({
  ['<Leader>n'] = {
    function()
      if not vim.o.number then
        vim.o.number = true
        vim.o.relativenumber = true
      elseif vim.o.relativenumber then
        vim.o.number = true
        vim.o.relativenumber = false
      else
        vim.o.number = false
      end
    end,
    'Toggle line numbers'
  }
})

wk.register({
  ['<C-End>'] = { '<Cmd>bn<CR>', 'Next buffer' },
  ['<C-Home>'] = { '<Cmd>bp<CR>', 'Previous buffer' }
})

wk.register({ U = { '<C-r>', 'Redo' } })

-- Write and quit
wk.register({
  ['<Leader>'] = {
    w = { '<Cmd>w<CR>', 'Write' },
    W = { '<Cmd>w<CR>', 'Write all' },
    q = { '<Cmd>q<CR>', 'Quit' },
    Q = { '<Cmd>qa<CR>', 'Quit all' },
    x = { '<Cmd>qa<CR>', 'Quit all' },
    s = { '<Cmd>wqa<CR>', 'Write and quit all' },
    ['!'] = {
      w = { '<Cmd>w!<CR>', 'Force write' },
      W = { '<Cmd>wa!<CR>', 'Force write all' },
      q = { '<Cmd>q!<CR>', 'Force quit' },
      Q = { '<Cmd>qa!<CR>', 'Force quit all' },
      x = { '<Cmd>qa!<CR>', 'Force quit all' },
      s = { '<Cmd>wqa!<CR>', 'Force write and quit all' },
      name = 'Force'
    }
  },
  { mode = { 'n', 'v' } }
})

-- vim.api.nvim_create_user_command('W', 'w', { desc = 'Write' })
-- vim.api.nvim_create_user_command('Wa', 'w', { desc = 'Write all' })
-- vim.api.nvim_create_user_command('Wq', 'wq', { desc = 'Write and quit' })
-- vim.api.nvim_create_user_command('Wqa', 'wqa', { desc = 'Write and quit all' })
-- vim.api.nvim_create_user_command('Q', 'q', { desc = 'Quit' })
-- vim.api.nvim_create_user_command('Qa', 'qa', { desc = 'Quit all' })

vim.o.signcolumn = 'yes'

vim.o.foldenable = false
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

wk.register({
  ['-'] = { '<C-x>', 'Decrement' },
  ['+'] = { '<C-a>', 'Increment' }
})

vim.g.skip_ts_context_commentstring_module = true
