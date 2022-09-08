require('impatient')
require('plugins')

-- Remember last location in file
vim.api.nvim_create_autocmd('BufRead', { pattern = '*', command = [[call setpos(".", getpos("'\""))]] })

vim.o.scrolljump = 5
vim.o.scrolloff = 3

vim.g.mapleader = ' '
vim.o.langmap = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'

vim.o.wrap = false
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2

vim.o.list = true
vim.opt.listchars = { tab = '⋗⋅', trail = '·', nbsp = '∷', extends = '※' }
vim.api.nvim_create_autocmd('BufEnter', { pattern = '*', command = 'EnableStripWhitespaceOnSave' })

-- Search and replace
vim.o.ignorecase = true
vim.o.smartcase = true
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

require('gomove').setup({ map_defaults = false, reindent = true })

vim.keymap.set('n', '<C-h>', '<Plug>GoNSMLeft')
vim.keymap.set('n', '<C-j>', '<Plug>GoNSMDown')
vim.keymap.set('n', '<C-k>', '<Plug>GoNSMUp')
vim.keymap.set('n', '<C-l>', '<Plug>GoNSMRight')
vim.keymap.set('x', '<C-h>', '<Plug>GoVSMLeft')
vim.keymap.set('x', '<C-j>', '<Plug>GoVSMDown')
vim.keymap.set('x', '<C-k>', '<Plug>GoVSMUp')
vim.keymap.set('x', '<C-l>', '<Plug>GoVSMRight')
vim.keymap.set('n', '<M-Left>', '<Plug>GoNSMLeft')
vim.keymap.set('n', '<M-Down>', '<Plug>GoNSMDown')
vim.keymap.set('n', '<M-Up>', '<Plug>GoNSMUp')
vim.keymap.set('n', '<M-Right>', '<Plug>GoNSMRight')
vim.keymap.set('x', '<M-Left>', '<Plug>GoVSMLeft')
vim.keymap.set('x', '<M-Down>', '<Plug>GoVSMDown')
vim.keymap.set('x', '<M-Up>', '<Plug>GoVSMUp')
vim.keymap.set('x', '<M-Right>', '<Plug>GoVSMRight')

vim.keymap.set('n', '<C-S-h>', '<Plug>GoNSDLeft')
vim.keymap.set('n', '<C-S-j>', '<Plug>GoNSDDown')
vim.keymap.set('n', '<C-S-k>', '<Plug>GoNSDUp')
vim.keymap.set('n', '<C-S-l>', '<Plug>GoNSDRight')
vim.keymap.set('x', '<C-S-h>', '<Plug>GoVSDLeft')
vim.keymap.set('x', '<C-S-j>', '<Plug>GoVSDDown')
vim.keymap.set('x', '<C-S-k>', '<Plug>GoVSDUp')
vim.keymap.set('x', '<C-S-l>', '<Plug>GoVSDRight')
vim.keymap.set('n', '<M-S-Left>', '<Plug>GoNSDLeft')
vim.keymap.set('n', '<M-S-Down>', '<Plug>GoNSDDown')
vim.keymap.set('n', '<M-S-Up>', '<Plug>GoNSDUp')
vim.keymap.set('n', '<M-S-Right>', '<Plug>GoNSDRight')
vim.keymap.set('x', '<M-S-Left>', '<Plug>GoVSDLeft')
vim.keymap.set('x', '<M-S-Down>', '<Plug>GoVSDDown')
vim.keymap.set('x', '<M-S-Up>', '<Plug>GoVSDUp')
vim.keymap.set('x', '<M-S-Right>', '<Plug>GoVSDRight')

-- Toggle mouse
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

vim.keymap.set('n', 'U', '<C-r>')

-- Write and quit
vim.keymap.set('n', '<Leader>w', '<Cmd>w<CR>')
vim.keymap.set('n', '<Leader>W', '<Cmd>w!<CR>')
vim.keymap.set('n', '<Leader>x', '<Cmd>q<CR>')
vim.keymap.set('n', '<Leader>X', '<Cmd>q!<CR>')
vim.keymap.set('n', '<Leader>aw', '<Cmd>wa<CR>')
vim.keymap.set('n', '<Leader>aW', '<Cmd>wa!<CR>')
vim.keymap.set('n', '<Leader>ax', '<Cmd>qa<CR>')
vim.keymap.set('n', '<Leader>aX', '<Cmd>qa!<CR>')
vim.keymap.set('n', '<Leader>s', '<Cmd>wq<CR>')
vim.keymap.set('n', '<Leader>S', '<Cmd>wq!<CR>')
vim.keymap.set('n', '<Leader>as', '<Cmd>wqa<CR>')
vim.keymap.set('n', '<Leader>aS', '<Cmd>wqa!<CR>')
vim.api.nvim_create_user_command('W', 'w', { desc = 'Write' })
vim.api.nvim_create_user_command('WQ', 'wq', { desc = 'Write and quit' })
vim.api.nvim_create_user_command('Wqa', 'wqa', { desc = 'Write and quit all' })
vim.api.nvim_create_user_command('Q', 'q', { desc = 'Quit' })
vim.api.nvim_create_user_command('Qa', 'qa', { desc = 'Quit all' })

vim.o.termguicolors = true
vim.o.background = 'light'
vim.cmd('colorscheme yacolors')

-- Completion

require('nvim-autopairs').setup()

require('Comment').setup({
  toggler = { line = '<Leader>/', block = '<Leader>*' },
  opleader = { line = '<Leader>/', block = '<Leader>*' }
})

local luasnip = require('luasnip')
local types = require('luasnip.util.types')

luasnip.config.set_config({
  history = true,
  updateevents = 'TextChanged,TextChangedI',
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { ' « ', 'NonTest' } }
      }
    }
  }
})

vim.keymap.set('i', '<Tab>', 'luasnip#expand_or_jumpable() ? "<Plug>luasnip-expand-or-jump" : "<Tab>"', { expr = true })
vim.keymap.set('i', '<S-Tab>', function() luasnip.jump(-1) end)
vim.keymap.set('i', '<M-Tab>', function() if luasnip.choice_active() then require('luasnip.extras.select_choice')() end end)

require('spoon').setup({
  preferSingleQuotes = true,
  langs = { lua = true, javascript = true, javascriptreact = true }
})
snippets = require('spoon.snippets')
luasnip.add_snippets('typescript', snippets.javascript)
luasnip.add_snippets('typescriptreact', snippets.javascriptreact)

local cmp = require('cmp')
local types = require('cmp.types')
local str = require('cmp.utils.str')
local lspkind = require('lspkind')

vim.opt.completeopt = { 'menu', 'noselect' }

cmp.setup({
  mapping = {
    ['<Up>'] = cmp.mapping.select_prev_item(),
    ['<Down>'] = cmp.mapping.select_next_item(),
    ['<S-Up>'] = cmp.mapping.scroll_docs(-4),
    ['<S-Down>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<Esc>'] = function(fallback)
      if cmp.visible() then
        cmp.abort()
      else
        fallback()
      end
    end,
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = false
    })
  },
  window = {
    completion = cmp.config.window.bordered({ winhighlight = 'Normal:NormalFloat,FloatBorder:Normal,CursorLine:CmpCursorLine,Search:Search' }),
    documentation = cmp.config.window.bordered()
  },
  formatting = {
    fields = { 'menu', 'abbr', 'kind' },
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      before = function(entry, item)
        local menu_icon = {
          nvim_lsp = '',
          treesitter = '',
          buffer = 'פֿ',
          ultisnips = '',
          path = '',
          look = ''
        }
        item.menu = menu_icon[entry.source.name]
        return item
      end
    })
  },
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  sources = {
    { name = 'luasnip', max_item_count = 3 },
    { name = 'nvim_lsp', max_item_count = 5 },
    { name = 'treesitter', max_item_count = 5 },
    {
      name = 'buffer',
      max_item_count = 5,
      option = { get_bufnrs = function() return vim.api.nvim_list_bufs() end }
    },
    { name = 'nvim_lua', max_item_count = 5 },
    {
      name = 'look',
      max_item_count = 3,
      option = {
        convert_case = true,
        loud = true,
        dict = '/Users/veged/.vim/english-popular-word-list.txt'
      }
    },
    { name = 'path', max_item_count = 3 }
  },
  completion = { completeopt = 'menu,noselect' },
  confirmation = {
    get_commit_characters = function(commit_characters)
      return vim.tbl_filter(function(char) return char ~= ',' and char ~= '.' end, commit_characters)
    end
  }
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

vim.o.signcolumn = 'yes'

require('lspconfig').eslint.setup({ capabilities = capabilities })
require('lspconfig').html.setup({ capabilities = capabilities })
require('lspconfig').tsserver.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
      local bufopts = { noremap=true, silent=true, buffer=bufnr }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  end
})
require('typescript').setup({})

require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'yacolors',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    always_divide_middle = true,
    globalstatus = false
  },
  sections = {
    lualine_a = {
      {
        'mode',
        icons_enabled = true,
        fmt = function(str) return str:sub(1, 1) end
      }
    },
    lualine_b = { 'branch', 'diff' },
    lualine_c = {
      {
        'filename',
        file_status = true,
        newfile_status = true,
        path = 0,
        symbols = {
          modified = ' פֿ',
          readonly = ' ',
          unnamed = '··· no name ···',
          newfile = '  '
        }
      }
    },
    lualine_x = {
      {
        'diagnostics',
        sources = {
          'nvim_lsp',
          'nvim_diagnostic',
          'nvim_workspace_diagnostic'
        },
        symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' }
      }
    },
    lualine_y = { 'filetype' },
    lualine_z = { 'progress', 'location' }
  },
  inactive_sections = {
    lualine_a = { function() return ' ' end },
    lualine_b = { 'branch', 'diff' },
    lualine_c = { 'filename' },
    lualine_x = {},
    lualine_y = { 'filetype' },
    lualine_z = { 'progress', 'location' }
  },
  tabline = {
    lualine_a = { 'buffers' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'tabs' }
  },
  winbar = {},
  inactive_winbar = {},
  extensions = { 'quickfix', 'nvim-tree' }
})

require('trouble').setup({
    use_diagnostic_signs = true
})
vim.keymap.set('n', '<Leader>!', '<Cmd>TroubleToggle<CR>')

local treesitter_custom_captures = {
  ['keyword.var'] = 'TSKeywordVarLetConst',
  ['keyword.let'] = 'TSKeywordVarLetConst',
  ['keyword.const'] = 'TSKeywordVarLetConst',
  ['keyword.switch'] = 'TSKeywordSwitch',
  ['keyword.break'] = 'TSKeywordBreak',
  ['keyword.continue'] = 'TSKeywordContinue',
  ['punctuation.bracket.array'] = 'TSPunctArray',
  ['punctuation.delimiter.array'] = 'TSPunctArray',
}

require('nvim-treesitter.highlight').set_custom_captures(treesitter_custom_captures)

require'nvim-treesitter.configs'.setup {
  ensure_installed = { 'html', 'css', 'javascript', 'typescript', 'json', 'lua' },
  auto_install = true,
  highlight = {
    enable = true,
    custom_captures = treesitter_custom_captures
  },
  -- indent = { enable = true },
  context_commentstring = { enable = true },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner'
      },
      selection_modes = {
        ['@parameter.outer'] = 'v',
        ['@function.outer'] = 'V',
        ['@class.outer'] = '<c-v>'
      }
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
      goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer'
      },
      goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' }
    },
    swap = {
      enable = true,
      swap_next = { ['<Leader>a'] = '@parameter.inner' },
      swap_previous = { ['<Leader>A'] = '@parameter.inner' }
    }
  },
  playground = { enable = true }
}

vim.o.foldenable = false
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

require('nvim-tree').setup({
  create_in_closed_folder = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  reload_on_bufenter = true,
  view = {
    centralize_selection = false,
    width = '20%',
    height = '100%',
    signcolumn = 'yes'
  },
  renderer = {
    add_trailing = true,
    group_empty = true,
    highlight_git = true,
    highlight_opened_files = 'all',
    special_files = {},
    symlink_destination = true
  },
  update_focused_file = { enable = true },
  git = { ignore = false },
  filesystem_watchers = { enable = false },
  actions = {
    use_system_clipboard = true,
    open_file = {
      quit_on_open = false,
      resize_window = true,
      window_picker = { chars = '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ' }
    }
  }
})
vim.keymap.set('n', '<Leader>t', '<Cmd>NvimTreeToggle<CR>')

-- Telescope
local telescopeBuiltin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>ff', telescopeBuiltin.find_files)
vim.keymap.set('n', '<Leader>fg', telescopeBuiltin.live_grep)
vim.keymap.set('n', '<Leader>fb', telescopeBuiltin.buffers)
vim.keymap.set('n', '<Leader>fh', telescopeBuiltin.help_tags)

require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--ignore-file',
      '.gitignore'
    },
    file_ignore_patterns = { 'node_modules' }
  }
}
