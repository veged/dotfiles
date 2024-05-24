local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

autocmd('VimEnter', function(data)
  if vim.fn.isdirectory(data.file) == 1 then
    vim.cmd.cd(data.file)
    require('nvim-tree.api').tree.open()
  end
end)

return require('lazy').setup({
  {
    'williamboman/mason.nvim',
    opts = { PATH = 'prepend' }
  },

  {
    'neovim/nvim-lspconfig', -- Quickstart configurations for the Nvim LSP client
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim'
    },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      local lspconfig = require('lspconfig')
      lspconfig.html.setup({
        capabilities = capabilities,
        init_options = {
          configurationSection = { 'html', 'css', 'javascript' },
          embeddedLanguages = {
            css = true,
            javascript = true
          }
        }
      })
      lspconfig.cssls.setup{ capabilities = capabilities }
      lspconfig.css_variables.setup{}
      lspconfig.eslint.setup{ capabilities = capabilities }
      lspconfig.tsserver.setup{ capabilities = capabilities }
      lspconfig.jsonls.setup{ capabilities = capabilities }
      lspconfig.lua_ls.setup{
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = {
              globals = { 'vim' },
              disable = {
                'lowercase-global',
                'undefined-global'
              },
            },
            workspace = {
              library = {
                vim.env.VIMRUNTIME,
                '${3rd}/luv/library'
              },
              checkThirdParty = false
            },
            telemetry = { enable = false }
          }
        }
      }
    end
  },

  {
    'nvim-treesitter/nvim-treesitter', -- Nvim Treesitter configurations and abstraction layer
    build = ':TSUpdate',
    config = function()
      -- g.skip_ts_default_groups = true
      -- require('nvim-treesitter.highlight').set_custom_captures(treesitter_custom_captures)

      require'nvim-treesitter.configs'.setup{
        ensure_installed = { 'html', 'css', 'javascript', 'typescript', 'json', 'lua' },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false
        },
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
            swap_next = { ['<Leader>p'] = '@parameter.inner' },
            swap_previous = { ['<Leader>P'] = '@parameter.inner' }
          }
        },
        playground = { enable = true }
      }

      vim.treesitter.language.register('bash', 'zsh')
    end
  },

  -- 'nvim-treesitter/nvim-treesitter-textobjects', -- Syntax aware text-objects, select, move, swap, and peek support

  {
    'nvim-treesitter/playground', -- Treesitter playground integrated into Neovim
    cmd = 'TSPlaygroundToggle'
  },

  {
    'booperlv/nvim-gomove', -- A complete plugin for moving and duplicating blocks and lines, with complete fold handling, reindenting, and undoing in one go
    opts = { map_defaults = false, reindent = true },
    keys = {
      { '<M-Left>', '<Plug>GoNSMLeft' },
      { '<M-Down>', '<Plug>GoNSMDown' },
      { '<M-Up>', '<Plug>GoNSMUp' },
      { '<M-Right>', '<Plug>GoNSMRight' },
      { '<M-Left>', '<Plug>GoVSMLeft', mode = 'x' },
      { '<M-Down>', '<Plug>GoVSMDown', mode = 'x' },
      { '<M-Up>', '<Plug>GoVSMUp', mode = 'x' },
      { '<M-Right>', '<Plug>GoVSMRight', mode = 'x' },
      { '<M-S-Left>', '<Plug>GoNSDLeft' },
      { '<M-S-Down>', '<Plug>GoNSDDown' },
      { '<M-S-Up>', '<Plug>GoNSDUp' },
      { '<M-S-Right>', '<Plug>GoNSDRight' },
      { '<M-S-Left>', '<Plug>GoVSDLeft', mode = 'x' },
      { '<M-S-Down>', '<Plug>GoVSDDown', mode = 'x' },
      { '<M-S-Up>', '<Plug>GoVSDUp', mode = 'x' },
      { '<M-S-Right>', '<Plug>GoVSDRight', mode = 'x' }
    }
  },

  'nishigori/increment-activator', -- enhance to increment candidates U have defined

  'tpope/vim-surround', -- Delete/change/add parentheses/quotes/XML-tags/much more with ease

  'tpope/vim-repeat', -- Enable repeating supported plugin maps with .

  {
    'numToStr/Comment.nvim', -- Smart and powerful comment plugin
    event = 'VeryLazy',
    opts = {
      toggler = { line = '<Leader>/', block = '<Leader>*' },
      opleader = { line = '<Leader>/', block = '<Leader>*' }
    },
    lazy = true
  },
  'JoosepAlviste/nvim-ts-context-commentstring', -- Neovim treesitter plugin for setting the commentstring based on the cursor location in a file

  {
    'windwp/nvim-autopairs', -- A super powerful autopair plugin for Neovim that supports multiple characters
    event = 'InsertEnter',
    config = true
  },

  {
    'windwp/nvim-ts-autotag', -- Use treesitter to auto close and auto rename html tag
    event = { 'BufReadPre', 'BufNewFile' },
    config = true
  },

  {
    'rktjmp/highlight-current-n.nvim', -- highlights the current /, ? or * match under your cursor when pressing n or N
    keys = { '/', '?', '*' }
  },

  {
    'hrsh7th/nvim-cmp', -- A completion plugin for neovim coded in Lua
    dependencies = {
      'onsails/lspkind.nvim', -- vscode-like pictograms for neovim lsp completion items
      'octaltree/cmp-look', -- source for Linux look
      'hrsh7th/cmp-nvim-lua', -- source for lua
      'ray-x/cmp-treesitter', -- source for treesitter
      'hrsh7th/cmp-nvim-lsp', -- source for neovim builtin LSP client  use 'hrsh7th/cmp-nvim-lsp'
      'hrsh7th/cmp-buffer', -- source for buffer words
      'hrsh7th/cmp-path' -- source for filesystem paths
    },
    event = 'InsertEnter',
    config = function()
      local cmp = require('cmp')
      -- local types = require('cmp.types')
      -- local str = require('cmp.utils.str')
      local lspkind = require('lspkind')
      local luasnip = require('luasnip')

      vim.opt.completeopt = { 'menu', 'noselect' }

      cmp.setup({
        mapping = {
          ['<Up>'] = cmp.mapping.select_prev_item(),
          ['<Down>'] = cmp.mapping.select_next_item(),
          ['<S-Up>'] = cmp.mapping.scroll_docs(-4),
          ['<S-Down>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
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
                buffer = '󰙏',
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
              dict = '/Users/veged/.config/nvim/english-popular-word-list.txt'
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
    end
  },

  {
    'L3MON4D3/LuaSnip', -- Snippet Engine for Neovim written in Lua
    dependencies = { "rafamadriz/friendly-snippets" },
    build = 'make install_jsregexp',
    event = 'InsertEnter',
    config = function()
      local luasnip = require('luasnip')
      local types = require('luasnip.util.types')
      luasnip.setup({
        history = false,
        update_events = 'InsertLeave,TextChanged,TextChangedI',
        delete_check_events = 'InsertLeave,TextChanged,TextChangedI',
        ext_opts = {
          [types.choiceNode] = {
            active = {
              virt_text = { { ' « ', 'NonTest' } }
            }
          }
        }
      })

      luasnip.filetype_extend('html', { 'javascript' })
      luasnip.filetype_extend('javascript', { 'html' })
      luasnip.filetype_extend('javascriptreact', { 'html' })
      luasnip.filetype_extend('typescriptreact', { 'html' })

      require('luasnip.loaders.from_vscode').lazy_load()

      keymapI{
        ['<Tab>'] = { function() return luasnip.expand_or_locally_jumpable() and '<Plug>luasnip-expand-or-jump' or '<Tab>' end, { expr = true } },
        ['<S-Tab>'] = function() luasnip.jump(-1) end,
        ['<M-Tab>'] = function() if luasnip.choice_active() then require('luasnip.extras.select_choice')() end end
      }
    end
  },
  {
    'saadparwaiz1/cmp_luasnip', -- A collection of luasnip snippets
    dependencies = {'hrsh7th/nvim-cmp', 'L3MON4D3/LuaSnip'},
    event = 'InsertEnter'
  },

  {
    'troydm/zoomwintab.vim', -- zoom current window
    keys = { '<C-w>o', '<C-w><C-o>' }
  },

  {
    'nvim-lualine/lualine.nvim', -- A blazing fast and easy to configure neovim statusline plugin
    config = function()
      local lualine_filename = { {
        'filename',
        file_status = true,
        newfile_status = true,
        path = 1,
        symbols = {
          modified = ' 󰙏',
          readonly = ' ',
          unnamed = '··· no name ···',
          newfile = '  '
        }
      } }

      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = 'catppuccin',
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
          lualine_c = lualine_filename,
          lualine_x = {
            {
              'diagnostics',
              sources = {
                'nvim_lsp',
                'nvim_diagnostic',
                'nvim_workspace_diagnostic'
              },
              symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
              -- on_click = function() vim.cmd('TroubleToggle') end
            }
          },
          lualine_y = { 'filetype' },
          lualine_z = { 'progress', 'location' }
        },
        inactive_sections = {
          lualine_a = { function() return ' ' end },
          lualine_b = { 'branch', 'diff' },
          lualine_c = lualine_filename,
          lualine_x = {},
          lualine_y = { 'filetype' },
          lualine_z = { 'progress', 'location' }
        },
        tabline = {
          lualine_a = {
            {
              'buffers' ,
              use_mode_colors = true,
              symbols = { modified = ' 󰙏 ', alternate_file = '' }
            }
          },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {
            {
              'tabs',
              use_mode_colors = true,
            }
            -- {
            --   function()
            --     local h = io.popen('defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources')
            --     local r = h:read('*a'):match('"KeyboardLayout Name" = (.+);'):gsub('%W', ''):sub(1, 2):lower()
            --     h:close()
            --     return ({ us = 'ENG', ru = 'РУС' })[r]
            --   end,
            --   icon = ''
            -- }
          }
        },
        winbar = {},
        inactive_winbar = {},
        extensions = { 'quickfix', 'nvim-tree' }
      })
    end
  },

  'lewis6991/gitsigns.nvim', -- Git integration for buffers

  {
    "folke/which-key.nvim", -- displays a popup with possible keybindings of the command you started typing
    init = function()
      o.timeout = true
      o.timeoutlen = 400
    end,
    opts = {
      -- operators = {
      --   ['<Leader>/'] = 'Comment line',
      --   ['<Leader>*'] = 'Comment block'
      -- }
    }
  },

  {
    'nvim-tree/nvim-tree.lua', -- A file explorer tree for neovim written in lua
    dependencies = 'nvim-tree/nvim-web-devicons', -- Adds file type icons to Vim plugins
    cmd = 'NvimTreeToggle',
    event = 'BufReadPre',
    keys = {
      { '<Leader>t', '<Cmd>NvimTreeToggle<CR>', desc = 'NvimTree' }
    },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      hijack_cursor = true,
      sync_root_with_cwd = true,
      reload_on_bufenter = true,
      view = {
        centralize_selection = false,
        width = '20%',
        signcolumn = 'yes'
      },
      renderer = {
        add_trailing = true,
        group_empty = true,
        highlight_git = true,
        highlight_opened_files = 'all',
        special_files = {},
        symlink_destination = true,
        icons = {
          git_placement = 'signcolumn',
          show = {
            file = true,
            folder = false,
            folder_arrow = false,
            git = true,
          },
        }
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
    }
  },

  {
    'nvim-telescope/telescope.nvim', -- Find, Filter, Preview, Pick.
    branch = '0.1.x',
    dependencies = 'nvim-lua/plenary.nvim', -- All the lua functions I don't want to write twice.
    keys = { '<Leader>ff', '<Leader>fg', '<Leader>fb', '<Leader>fh' },
    config = function()
      local telescopeBuiltin = require('telescope.builtin')
      keymapN({
        ['<Leader>f'] = {
          f = { telescopeBuiltin.find_files, 'Find files' },
          g = { telescopeBuiltin.live_grep, 'Live grep' },
          b = { telescopeBuiltin.buffers, 'Buffers' },
          h = { telescopeBuiltin.help_tags, 'Help tags' } } })

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
    end
  },

  {
    'folke/trouble.nvim', -- A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing
    dependencies = 'nvim-tree/nvim-web-devicons',
    cmd = 'TroubleToggle',
    keys = {
      { '<Leader>!', '<Cmd>TroubleToggle<CR>', desc = 'Trouble' }
    },
    opts = { use_diagnostic_signs = true }
  },

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    opts = {
      background = {
        light = 'latte',
        dark = 'mocha',
      },
      custom_highlights = function(C)
        local O = require('catppuccin').options
        local U = require('catppuccin.utils.colors')
        return {
          -- Editor
          ColorColumn = { bg = C.surface0 }, -- used for the columns set with 'colorcolumn'
          Conceal = { fg = C.overlay1 }, -- placeholder characters substituted for concealed text (see 'conceallevel')
          Cursor = { fg = C.base, bg = C.text }, -- character under the cursor
          lCursor = { fg = C.base, bg = C.text }, -- the character under the cursor when |language-mapping| is used (see 'guicursor')
          CursorIM = { fg = C.base, bg = C.text }, -- like Cursor, but used when in IME mode |CursorIM|
          CursorColumn = { bg = C.surface0 }, -- Screen-column at the cursor, when 'cursorcolumn' is seC.
          CursorLine = { bg = C.surface0 }, -- Screen-line at the cursor, when 'cursorline' is seC.  Low-priority if forecrust (ctermfg OR guifg) is not seC.
          Directory = { fg = C.blue }, -- directory names (and other special names in listings)
          EndOfBuffer = { fg = C.base }, -- filler lines (~) after the end of the buffer.  By default, this is highlighted like |hl-NonText|.
          ErrorMsg = { fg = C.red, style = { 'bold', 'italic' } }, -- error messages on the command line
          VertSplit = { fg = C.surface0, bg = C.crust }, -- the column separating vertically split windows
          Folded = { fg = C.blue, bg = O.transparent_background and C.none or C.surface1 }, -- line used for closed folds
          FoldColumn = { fg = C.overlay0 }, -- 'foldcolumn'
          SignColumn = { fg = C.surface1 }, -- column where |signs| are displayed
          SignColumnSB = { bg = C.crust, fg = C.surface1 }, -- column where |signs| are displayed
          Substitute = { bg = C.surface1, fg = U.vary_color({ latte = C.red }, C.pink) }, -- |:substitute| replacement text highlighting
          LineNr = { fg = U.vary_color({ latte = C.base0 }, C.surface1) }, -- Line number for ':number' and ':#' commands, and when 'number' or 'relativenumber' option is seC.
          CursorLineNr = { fg = C.lavender }, -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line. highlights the number in numberline.
          MatchParen = { fg = C.peach, style = { 'bold' } }, -- The character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
          ModeMsg = { fg = C.text, style = { 'bold' } }, -- 'showmode' message (e.g., '-- INSERT -- ')
          MsgArea = { fg = C.text }, -- Area for messages and cmdline
          MsgSeparator = {}, -- Separator for scrolled messages, `msgsep` flag of 'display'
          MoreMsg = { fg = C.teal }, -- |more-prompt|
          NonText = { fg = C.overlay0 }, -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., '>' displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
          Normal = { fg = C.text, bg = O.transparent_background and C.none or C.base }, -- normal text
          NormalNC = {
            fg = C.text,
            bg = (O.transparent_background and O.dim_inactive.enabled and C.dim)
            or (O.dim_inactive.enabled and C.dim)
            or (O.transparent_background and C.none)
            or C.base,
          }, -- normal text in non-current windows
          NormalSB = { fg = C.text, bg = C.crust }, -- normal text in non-current windows
          NormalFloat = { fg = C.text, bg = O.transparent_background and C.none or C.mantle }, -- Normal text in floating windows.
          FloatBorder = { fg = C.overlay2 },
          Pmenu = { bg = O.transparent_background and C.none or U.darken(C.surface0, 0.8, C.crust), fg = C.overlay2 }, -- Popup menu: normal item.
          PmenuSel = { fg = C.text, bg = C.surface2, style = { 'bold' } }, -- Popup menu: selected item.
          PmenuSbar = { bg = C.surface1 }, -- Popup menu: scrollbar.
          PmenuThumb = { bg = C.overlay0 }, -- Popup menu: Thumb of the scrollbar.
          Question = { fg = C.teal }, -- |hit-enter| prompt and yes/no questions
          QuickFixLine = { bg = C.surface1, style = { 'bold' } }, -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
          Search = { bg = C.yellow, fg = C.mantle }, -- Last search pattern highlighting (see 'hlsearch').  Also used for similar items that need to stand ouC.
          IncSearch = { bg = C.peach, fg = C.mantle }, -- 'incsearch' highlighting; also used for the text replaced with ':s///c'
          CurSearch = { bg = C.pink, fg = C.mantle }, -- 'cursearch' highlighting: highlights the current search you're on differently
          SpecialKey = { fg = C.text }, -- Unprintable characters: text displayed differently from what it really is.  But not 'listchars' textspace. |hl-Whitespace|
          SpellBad = { sp = C.red, style = { 'undercurl' } }, -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
          SpellCap = { sp = C.yellow, style = { 'undercurl' } }, -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
          SpellLocal = { sp = C.blue, style = { 'undercurl' } }, -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
          SpellRare = { sp = C.green, style = { 'undercurl' } }, -- Word that is recognized by the spellchecker as one that is hardly ever used.  |spell| Combined with the highlighting used otherwise.
          StatusLine = { fg = C.text, bg = O.transparent_background and C.none or C.mantle }, -- status line of current window
          StatusLineNC = { fg = C.surface1, bg = O.transparent_background and C.none or C.mantle }, -- status lines of not-current windows Note: if this is equal to 'StatusLine' Vim will use '^^^' in the status line of the current window.
          TabLine = { bg = C.mantle, fg = C.surface1 }, -- tab pages line, not active tab page label
          TabLineFill = { bg = C.black }, -- tab pages line, where there are no labels
          TabLineSel = { fg = C.overlay2, bg = C.surface1 }, -- tab pages line, active tab page label
          Title = { fg = C.text, style = { 'bold' } }, -- titles for output from ':set all', ':autocmd' etC.
          Visual = { bg = C.surface1, style = { 'bold' } }, -- Visual mode selection
          VisualNOS = { bg = C.surface1, style = { 'bold' } }, -- Visual mode selection when vim is 'Not Owning the Selection'.
          WarningMsg = { fg = C.peach }, -- warning messages
          Whitespace = { fg = C.surface1 }, -- 'nbsp', 'space', 'tab' and 'trail' in 'listchars'
          ExtraWhitespace = { bg = C.red },
          WildMenu = { bg = C.overlay0 }, -- current match in 'wildmenu' completion
          WinBar = { fg = C.subtext0, bg = C.surface1 },

          healthError = { fg = C.red },
          healthSuccess = { fg = C.teal },
          healthWarning = { fg = C.yellow },

          CmpCursorLine = { bg = C.surface0, style = { 'underline' } }, -- Highlight group for unmatched characters of each completion field.
          CmpItemAbbr = {} , -- Highlight group for unmatched characters of each completion field.
          CmpItemAbbrDeprecated = { strikethrough = true } , -- Highlight group for unmatched characters of each deprecated completion field.
          CmpItemAbbrMatch = { bold = true } , -- Highlight group for matched characters of each completion field. Matched characters must form a substring of a field which share a starting position.
          -- CmpItemAbbrMatchFuzzy = { CmpItemAbbrMatch } , -- Highlight group for fuzzy-matched characters of each completion field.
          -- CmpItemKind = { NormalFloat, italic = true } , -- Highlight group for the kind of the field. NOTE: `kind` is a symbol after each completion option.
          -- CmpItemKindConstant = { TSConstant, italic = true } ,
          -- CmpItemKindConstructor { TSConstructor, italic = true },
          -- CmpItemKindFunction = { fg = TSKeywordFunction.fg, italic = true },
          -- CmpItemKindClass = { fg = TSType.fg, italic = true },
          -- CmpItemKindKeyword = { fg = TSKeyword.fg, italic = true },
          -- CmpItemKindField = { italic = true },
          -- CmpItemKindProperty = { TSProperty, italic = true },
          -- CmpItemKindMethod = { TSMethod, italic = true },
          -- CmpItemKindOperator = { TSOperator, italic = true },
          -- CmpItemKindText = { CmpItemKind, italic = true },
          -- CmpItemKindVariable = { fg = TSKeywordVarLetConst.fg, italic = true },
          -- CmpItemKindEnum = { CmpItemKindVariable, italic = true },
          -- CmpItemKindEnumMember = { CmpItemKindVariable, italic = true },
          -- CmpItemKindSnippet = { fg = TSKeywordReturn.fg, italic = true },
          -- CmpItemMenu = { NormalFloat } , -- The menu field's highlight group.

          -- Syntax
          Comment = { fg = C.overlay0 }, -- just comments
          SpecialComment = { fg = C.overlay0, style = { 'bold' } }, -- special things inside a comment
          Constant = { fg = C.text }, -- (preferred) any constant
          ['@constant'] = { fg = C.text },
          String = { fg = C.teal }, -- a string constant: 'this is a string'
          ['@punctuation.string'] = { fg = C.sapphire }, -- a string constant: 'this is a string'
          ['@punctuation.string.bracket'] = { style = { 'bold' } }, -- a string constant: 'this is a string'
          ['@string.escape'] = { fg = C.teal, style = { 'bold' } },
          ['@string.regex'] = { fg = C.green },
          ['@punctuation.regex.bracket'] = { fg = C.green },
          Character = { fg = C.teal, style = { 'bold' } }, --  a character constant: 'c', '\n'
          Number = { fg = C.peach }, --   a number constant: 234, 0xff
          Float = { fg = C.peach }, --    a floating point constant: 2.3e10
          Boolean = { fg = C.sapphire }, --  a boolean constant: TRUE, false
          ['@punctuation.array'] = { fg = C.peach },
          ['@punctuation.object'] = { fg = C.sapphire },
          Identifier = { fg = C.text }, -- (preferred) any variable name
          ['@variable.builtin'] = { fg = C.text, bold = true },
          ['@type.builtin'] = { link = '@variable.builtin' },
          ['@function.builtin'] = { link = '@variable.builtin' },
          ['@method.builtin'] = { link = '@variable.builtin' },
          ['@constant.builtin'] = { fg = C.text, style = { 'bold' } },
          ['@parameter'] = { link = 'Identifier' }, -- For parameters of a function.
          Function = { fg = C.text }, -- function name (also: methods for classes)
            ['@constructor'] = { fg = C.text },
            ['@property'] = { fg = C.text },
            ['@field'] = { fg = C.text },
            ['@method'] = { fg = C.text },
            Keyword = { fg = C.blue, style = { 'bold', 'italic' } }, --  any other keyword
            ['@keyword.declaration'] = { fg = C.green, style = { 'bold', 'italic' } }, -- Keywords used to define a variable/constant: `var`, `let` and `const` in JavaScript
            ['@keyword.function'] = { fg = C.green, style = { 'bold', 'italic' } }, -- Keywords used to define a function: `function` in Lua, `def` and `lambda` in Python.
            ['@punctuation.function'] = { fg = C.green }, -- Punctuation in function declarations.
            ['@punctuation.function.special'] = { fg = C.green, style = { 'bold', 'italic' } },
            ['@keyword.class'] = { fg = C.green, style = { 'bold', 'italic' } },
            ['@punctuation.class'] = { fg = C.green },
            Statement = { fg = C.blue, style = { 'bold', 'italic' } }, -- (preferred) any statement
            Conditional = { fg = C.sapphire, style = { 'bold', 'italic' } }, -- if, then, else, endif, switch, etC.
            ['@punctuation.conditional'] = { fg = C.sapphire },
            Repeat = { fg = C.peach }, -- for, do, while, etC.
            ['@punctuation.repeat'] = { fg = C.peach },
            Label = { fg = C.sapphire, style = { 'bold', 'italic' } }, --    case, default, etC.
            Operator = { fg = C.overlay1 }, -- 'sizeof', '+', '*', etC.
            ["@punctuation.keyword"] = { style = { 'italic' } },
            ['@keyword.operator'] = { fg = C.overlay1, style = { 'bold', 'italic' } },
            ['@keyword.with'] = { fg = C.green, style = { 'bold', 'italic' } },
            ['@punctuation.with'] = { fg = C.green },
            ['@keyword.coroutine'] = { fg = C.mauve, style = { 'bold', 'italic' } },
            ['@keyword.return'] = { fg = C.mauve, style = { 'bold', 'italic' } },
            ['@keyword.break'] = { link = '@keyword.return' },
            ['@keyword.continue'] = { link = '@keyword.return' },
            Exception = { fg = C.red }, --  try, catch, throw
            ['@exception'] = { fg = C.red }, --  try, catch, throw
            ['@keyword.exception'] = { fg = C.red, style = { 'bold', 'italic' } }, --  try, catch, throw
            ['@punctuation.exception'] = { link = '@exception' }, --  try, catch, throw
            ['@keyword.debugger'] = { fg = C.red, style = { 'bold', 'italic' } },

            PreProc = { fg = C.overlay1 }, -- (preferred) generic Preprocessor
            Include = { fg = C.green }, --  preprocessor #include
            Define = { fg = C.green }, -- preprocessor #define
            Macro = { fg = C.green }, -- same as Define
            PreCondit = { fg = C.sapphire }, -- preprocessor #if, #else, #endif, etc.

            Type = { fg = C.text }, -- (preferred) int, long, char, etC.
            StorageClass = { fg = C.sapphire }, -- static, register, volatile, etC.
            Structure = { fg = C.teal }, --  struct, union, enum, etC.
            Typedef = { link = 'Type' }, --  A typedef

            Special = { fg = C.sapphire }, -- (preferred) any special symbol
            SpecialChar = { fg = C.sapphire, style = { 'bold' } }, -- special character in a constant
            Tag = { link = 'Special' }, -- you can use CTRL-] on this
            Delimiter = { fg = C.overlay2 }, -- character that needs attention
            -- Specialoverlay0= { }, -- special things inside a overlay0
            Debug = { fg = C.red, style = { 'italic' } }, -- debugging statements

            Underlined = { style = { 'underline' } }, -- (preferred) text that stands out, HTML links
            Bold = { style = { 'bold' } },
            Italic = { style = { 'italic' } },
            -- ('Ignore', below, may be invisible...)
            -- Ignore = { }, -- (preferred) left blank, hidden  |hl-Ignore|

            Error = { fg = C.red }, -- (preferred) any erroneous construct
            Todo = { bg = C.yellow, fg = C.base, style = { 'bold' } }, -- (preferred) anything that needs extra attention; mostly the keywords TODO FIXME and XXX
            qfLineNr = { fg = C.yellow },
            qfFileName = { fg = C.blue },
            -- htmlH1 = { fg = C.pink, style = { 'bold' } },
            -- htmlH2 = { fg = C.blue, style = { 'bold' } },
            -- mkdHeading = { fg = C.peach, style = { 'bold' } },
            -- mkdCode = { bg = C.terminal_black, fg = C.text },
            -- mkdCodeDelimiter = { bg = C.base, fg = C.text },
            -- mkdCodeStart = { fg = C.flamingo, style = { 'bold' } },
            -- mkdCodeEnd = { fg = C.flamingo, style = { 'bold' } },
            -- mkdLink = { fg = C.blue, style = { 'underline' } },

            -- debugging
            debugPC = { bg = O.transparent_background and C.none or C.crust }, -- used for highlighting the current line in terminal-debug
            debugBreakpoint = { bg = C.base, fg = C.overlay0 }, -- used for breakpoint colors in terminal-debug
            -- illuminate
            illuminatedWord = { bg = C.surface1 },
            illuminatedCurWord = { bg = C.surface1 },
            -- diff
            diffAdded = { fg = C.green },
            diffRemoved = { fg = C.red },
            diffChanged = { fg = C.blue },
            diffOldFile = { fg = C.yellow },
            diffNewFile = { fg = C.peach },
            diffFile = { fg = C.blue },
            diffLine = { fg = C.overlay0 },
            diffIndexLine = { fg = C.teal },
            DiffAdd = { bg = U.darken(C.green, 0.4, C.base) }, -- diff mode: Added line |diff.txt|
            DiffChange = { bg = U.darken(C.peach, 0.4, C.base) }, -- diff mode: Changed line |diff.txt|
            DiffDelete = { bg = U.darken(C.red, 0.4, C.base) }, -- diff mode: Deleted line |diff.txt|
            DiffText = { bg = U.darken(C.peach, 0.4, C.base) }, -- diff mode: Changed text within a changed line |diff.txt|
            -- misc

            -- glyphs
            GlyphPalette1 = { fg = C.red },
            GlyphPalette2 = { fg = C.teal },
            GlyphPalette3 = { fg = C.yellow },
            GlyphPalette4 = { fg = C.blue },
            GlyphPalette6 = { fg = C.teal },
            GlyphPalette7 = { fg = C.text },
            GlyphPalette9 = { fg = C.red },
          }
      end
    },
    init = function()
      o.termguicolors = true
      vim.cmd.colorscheme('catppuccin')
    end
  },

  {
    'ntpeters/vim-better-whitespace', -- Better whitespace highlighting
    init = function()
      g.better_whitespace_operator = '_'
      autocmd('BufEnter', 'EnableStripWhitespaceOnSave')
    end,
  },

  {
    'rickhowe/diffchar.vim', -- Highlight the exact differences, based on characters and words
    ft = 'diff'
  },

  'norcalli/nvim-colorizer.lua', -- A high-performance color highlighter

  {
    'moll/vim-node', -- Tools and environment to make Vim superb for developing with Node.js
    ft = { 'javascript', 'typescript', 'typescriptreact' }
  },

  {
    'jose-elias-alvarez/typescript.nvim', -- A Lua plugin, written in TypeScript, to write TypeScript
    ft = { 'javascript', 'typescript', 'typescriptreact' },
    opts = {
      disable_commands = false, -- prevent the plugin from creating Vim commands
      debug = false, -- enable debug logging for commands
      go_to_source_definition = {
        fallback = true, -- fall back to standard LSP definition on failure
      },
    }
  },

  {
    'maxmellon/vim-jsx-pretty', -- JSX and TSX syntax pretty highlighting
    ft = { 'javascriptreact', 'typescriptreact' }
  },

  {
    'amadeus/vim-mjml', -- Lua vim formatter supported by LuaFormatter
    ft = 'mjml'
  },

  {
    'euclidianAce/BetterLua.vim', -- Better Lua syntax highlighting
    ft = 'lua'
  },

  {
    'andrejlevkovitch/vim-lua-format', -- Lua vim formatter supported by LuaFormatter
    ft = 'lua'
  },

  {
    'folke/neodev.nvim',
    ft = 'lua',
    opts = {
      library = {
        enabled = true,
        runtime = true,
        types = true,
        plugins = true
      },
    }
  },

  'LunarVim/bigfile.nvim' -- Make editing big files faster
})
