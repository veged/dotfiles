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

-- Spell
vim.o.spell = false
vim.o.spelllang = 'ru_yo,en_us'
vim.o.spelloptions = 'camel,noplainbuffer'
vim.keymap.set('n', '<Leader>?', function() vim.o.spell = not vim.o.spell end)

-- Search and replace
vim.o.ignorecase = true
vim.o.smartcase = true
vim.api.nvim_create_autocmd('BufReadPost', { pattern = 'quickfix', command = 'nnoremap <buffer> <CR> <CR>' })
vim.keymap.set('n', '<CR>', '<Cmd>nohlsearch<CR>', { desc = 'Clear the search highlight by Enter' })

vim.keymap.set('n', 'n', '<Plug>(highlight-current-n-n)')
vim.keymap.set('n', 'N', '<Plug>(highlight-current-n-N)')
vim.o.gdefault = true

-- Natural arrows in command mode
vim.keymap.set('c', '<Left>', function() return vim.fn.pumvisible() == 1 and '<Up>' or '<Left>' end, { expr = true })
vim.keymap.set('c', '<Right>', function() return vim.fn.pumvisible() == 1 and '<Down>' or '<Right>' end, { expr = true })
vim.keymap.set('c', '<Up>', function() return vim.fn.pumvisible() == 1 and '<Left>' or '<Up>' end, { expr = true })
vim.keymap.set('c', '<Down>', function() return vim.fn.pumvisible() == 1 and '<Right>' or '<Down>' end, { expr = true })

-- Visual mode
vim.keymap.set('n', '<S-Left>', 'vh')
vim.keymap.set('n', '<S-Right>', 'vl')
vim.keymap.set('n', '<S-Up>', 'Vk')
vim.keymap.set('n', '<S-Down>', 'Vj')
vim.keymap.set('v', '<S-Left>', 'h')
vim.keymap.set('v', '<S-Right>', 'l')
vim.keymap.set('v', '<S-Up>', 'k')
vim.keymap.set('v', '<S-Down>', 'j')
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- System clipboard
vim.keymap.set('v', '<C-c>', '"+y')
vim.keymap.set('n', '<C-c>', '"+yy')
vim.keymap.set('v', '<C-x>', '"+d')
-- vim.keymap.set('n', '<C-x>', '"+dd')

-- Toggle mouse
vim.opt.mouse = ''
vim.keymap.set('n', '<Leader>m', function()
  if vim.o.mouse == 'a' then
    vim.o.mouse = ''
    print('  Mouse usage disabled')
  else
    vim.o.mouse = 'a'
    print('  Mouse usage enabled')
  end
end)

-- Toggle cursor crosshair
vim.keymap.set('n', '<Leader>c', '<Cmd>set cursorline! cursorcolumn!<CR>')

-- Toggle line numbers
vim.keymap.set('n', '<Leader>n', function()
  if vim.o.number then
    vim.o.number = false
    vim.o.relativenumber = true
  elseif vim.o.relativenumber then
    vim.o.number = false
    vim.o.relativenumber = false
  else
    vim.o.number = true
  end
end)

vim.keymap.set('n', '<C-End>', '<Cmd>bn<CR>')
vim.keymap.set('n', '<C-Home>', '<Cmd>bp<CR>')

vim.keymap.set('n', 'U', '<C-r>')

-- Write and quit
vim.keymap.set({'n', 'v'}, '<Leader>w', '<Cmd>w<CR>')
vim.keymap.set({'n', 'v'}, '<Leader>W', '<Cmd>wa<CR>')
vim.keymap.set({'n', 'v'}, '<Leader>q', '<Cmd>q<CR>')
vim.keymap.set({'n', 'v'}, '<Leader>Q', '<Cmd>qa<CR>')
vim.keymap.set({'n', 'v'}, '<Leader>!w', '<Cmd>w!<CR>')
vim.keymap.set({'n', 'v'}, '<Leader>!W', '<Cmd>wa!<CR>')
vim.keymap.set({'n', 'v'}, '<Leader>!q', '<Cmd>q!<CR>')
vim.keymap.set({'n', 'v'}, '<Leader>!Q', '<Cmd>qa!<CR>')
vim.keymap.set({'n', 'v'}, '<Leader>x', '<Cmd>qa<CR>')
vim.keymap.set({'n', 'v'}, '<Leader>!x', '<Cmd>qa!<CR>')
vim.keymap.set({'n', 'v'}, '<Leader>s', '<Cmd>wqa<CR>')
vim.keymap.set({'n', 'v'}, '<Leader>!s', '<Cmd>wqa!<CR>')
vim.api.nvim_create_user_command('W', 'w', { desc = 'Write' })
vim.api.nvim_create_user_command('WQ', 'wq', { desc = 'Write and quit' })
vim.api.nvim_create_user_command('Wqa', 'wqa', { desc = 'Write and quit all' })
vim.api.nvim_create_user_command('Q', 'q', { desc = 'Quit' })
vim.api.nvim_create_user_command('Qa', 'qa', { desc = 'Quit all' })

vim.o.signcolumn = 'yes'

vim.o.foldenable = false
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

vim.g.skip_ts_context_commentstring_module = true
