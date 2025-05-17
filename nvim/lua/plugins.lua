o = vim.opt

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
o.rtp:prepend(lazypath)

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
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = {
        -- 'clangd',
        -- 'cpptools',
        -- 'css-lsp',
        -- 'css-variables-language-server',
        -- 'cssmodules-language-server',
        -- 'eslint-lsp',
        -- 'eslint_d',
        -- 'html-lsp',
        -- 'json-lsp',
        -- 'lua-language-server',
        -- 'luacheck',
        -- 'luaformatter',
        -- 'typos-lsp',
        -- 'vtsls'
      },
    },
  },

  {
    'neovim/nvim-lspconfig', -- Quickstart configurations for the Nvim LSP client
    dependencies = {
      -- 'hrsh7th/cmp-nvim-lsp',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim'
    },
    config = function()
      local lspconfig = require('lspconfig')
      local util = require('lspconfig/util')

      lspconfig.typos_lsp.setup { init_options = { diagnosticSeverity = 'Warning' } }
      lspconfig.html.setup {
        filetypes = { 'html' },
        init_options = {
          configurationSection = { 'html', 'javascript' },
          embeddedLanguages = { javascript = true },
        },
        settings = {
          html = {
            suggest = { html5 = true },
            format = {
              templating = true,
              wrapLineLength = 120,
              wrapAttributes = 'auto',
              enable = true
            }
          }
        }
      }
      lspconfig.cssls.setup {}
      lspconfig.css_variables.setup {}
      lspconfig.eslint.setup {
        root_dir = util.root_pattern('package.json'),
        filetypes = { 'javascript', 'typescript', 'html', 'javascriptreact', 'typescriptreact' },
        codeAction = {
          disableRuleComment = { enable = true },
          showDocumentation = { enable = true }
        },
        workingDirectories = { mode = 'auto' },
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = true
        end,
        settings = {
          eslint = {
            format = { enable = true },
            validate = 'on'
          }
        }
      }
      lspconfig.vtsls.setup {}
      lspconfig.jsonls.setup {}
      lspconfig.lua_ls.setup {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            format = {
              enable = true,
              defaultConfig = {
                indent_style = 'space',
                indent_size = 2,
                continuation_indent = 2,
                quote_style='single',
                call_arg_parentheses = 'remove',
                trailing_table_separator = 'never',
                space_around_table_field_list = true,
                space_before_function_call_single_arg = false
              }
            },
            diagnostics = {
              globals = { 'vim' },
              disable = {
                'lowercase-global',
                'undefined-global'
              },
              neededFileStatus = {
                ['codestyle'] = 'Any'
              }
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

      require 'nvim-treesitter.configs'.setup {
        ensure_installed = { 'html', 'css', 'javascript', 'typescript', 'json', 'lua' },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false
        },
        injections = {
          html = {
            javascript = [[
              ((element
                (start_tag
                  (tag_name) @_tag
                  (attribute
                    (attribute_name) @_name
                    (quoted_attribute_value (attribute_value) @_value)?
                )
                (text) @javascript
              ) (#eq? @_tag "script"))
            ]],
          },
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
      { '<M-Left>',    '<Plug>GoNSMLeft' },
      { '<M-Down>',    '<Plug>GoNSMDown' },
      { '<M-Up>',      '<Plug>GoNSMUp' },
      { '<M-Right>',   '<Plug>GoNSMRight' },
      { '<M-Left>',    '<Plug>GoVSMLeft',  mode = 'x' },
      { '<M-Down>',    '<Plug>GoVSMDown',  mode = 'x' },
      { '<M-Up>',      '<Plug>GoVSMUp',    mode = 'x' },
      { '<M-Right>',   '<Plug>GoVSMRight', mode = 'x' },
      { '<M-S-Left>',  '<Plug>GoNSDLeft' },
      { '<M-S-Down>',  '<Plug>GoNSDDown' },
      { '<M-S-Up>',    '<Plug>GoNSDUp' },
      { '<M-S-Right>', '<Plug>GoNSDRight' },
      { '<M-S-Left>',  '<Plug>GoVSDLeft',  mode = 'x' },
      { '<M-S-Down>',  '<Plug>GoVSDDown',  mode = 'x' },
      { '<M-S-Up>',    '<Plug>GoVSDUp',    mode = 'x' },
      { '<M-S-Right>', '<Plug>GoVSDRight', mode = 'x' }
    }
  },

  {
    'nishigori/increment-activator', -- enhance to increment candidates U have defined
    config = function()
      keymapN {
        ['-'] = { '<Plug>(increment-activator-decrement)', 'Decrement' },
        ['+'] = { '<Plug>(increment-activator-increment)', 'Increment' } }
    end
  },

  {
    'kylechui/nvim-surround', -- Add/change/delete surrounding delimiter pairs with ease
    opts = {
      -- delimiters = {
      --   pairs = {
      --     ['c'] = { { '', '```', '' }, { '', '```', '' } },
      --   },
      -- },
      surrounds = {
        ['~'] = {
          add = function()
            return {
              { '```' .. require('nvim-surround.config').get_input('Language: ') or '' .. '\n' },
              { '\n```' },
            }
          end,
          find = { '^```$', '^```$' },
          delete = { '^```$', '^```$' },
          change = {
            target = { '^```$', '^```$' },
            replacement = function()
              return {
                { require('nvim-surround.config').get_input('New language: ') or '' },
                { '' },
              }
            end
          }
        }
      }
    }
  },

  'tpope/vim-repeat',   -- Enable repeating supported plugin maps with .

  {
    'numToStr/Comment.nvim', -- Smart and powerful comment plugin
    event = 'VeryLazy',
    opts = {
      toggler = { line = '<Leader><Leader>', block = '<Leader>*' },
      opleader = { line = '<Leader><Leader>', block = '<Leader>*' }
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
    'saghen/blink.cmp',
    dependencies = {
      'Kaiser-Yang/blink-cmp-dictionary',
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets'
    },

    version = '1.*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = 'enter' },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = {
        documentation = { auto_show = true }
      },

      snippets = { preset = 'luasnip' },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'dictionary', 'lazydev' },
        providers = {
          dictionary = {
            module = 'blink-cmp-dictionary',
            name = 'Dict',
            min_keyword_length = 3,
            opts = {
              dictionary_files = { vim.fn.expand'~/.config/nvim/english-popular-word-list.txt' },
              max_items = 3,
              convert_case = true,
              loud = true,
            }
          },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
        }
      },

      fuzzy = { implementation = 'prefer_rust_with_warning' }
    },
    opts_extend = { 'sources.default' }
  },

  {
    'L3MON4D3/LuaSnip', -- Snippet Engine for Neovim written in Lua
    version = 'v2.*',
    dependencies = { 'rafamadriz/friendly-snippets' },
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
      luasnip.filetype_extend('javascript', { 'typescript' })
      -- luasnip.filetype_extend('javascriptreact', { 'html' })
      -- luasnip.filetype_extend('typescriptreact', { 'html' })

      require('luasnip.loaders.from_vscode').lazy_load()

      keymapI {
        ['<Tab>'] = { function() return luasnip.expand_or_locally_jumpable() and '<Plug>luasnip-expand-or-jump' or
          '<Tab>' end, { expr = true } },
        ['<S-Tab>'] = function() luasnip.jump(-1) end,
        ['<M-Tab>'] = function() if luasnip.choice_active() then require('luasnip.extras.select_choice')() end end
      }
    end
  },

  {
    'troydm/zoomwintab.vim', -- zoom current window
    keys = { '<C-w>o', '<C-w><C-o>' }
  },

  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      toggle = { enabled = true },
      quickfile = { enabled = true },
      bigfile = { enabled = true },
      image = { enabled = true },
      -- dashboard = { enabled = true },
      -- indent = { enabled = true },
      explorer = { enabled = true },
      input = { enabled = true },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            layout = { layout = { position = 'right' } }
          }
        },
      },
      notifier = {
        enabled = true,
        top_down = false
      },
      -- scope = { enabled = true },
      -- scroll = { enabled = true },
      statuscolumn = { enabled = true },
      git = { enabled = true },
      -- words = { enabled = true },
    },
    keys = {
      { '<Leader>e', function() Snacks.explorer() end,               desc = 'File Explorer' },
      { '<Leader>:', function() Snacks.picker.command_history() end, desc = 'Command History' },
      { '<Leader>^', function() Snacks.picker.notifications() end,   desc = 'Notification History' }
    },
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          Snacks.toggle.option('spell', { name = 'Spelling' }):map('<Leader>?')
          Snacks.toggle.new({
            name = 'Mouse',
            get = function() return next(o.mouse:get()) ~= nil end,
            set = function(s) o.mouse = s and 'a' or '' end
          }):map('<Leader>m')
          Snacks.toggle.new({
            name = 'Cursor Crosshair',
            get = function() return o.cursorline:get() or o.cursorcolumn:get() end,
            set = function(s)
              o.cursorline = s
              o.cursorcolumn = s
            end
          }):map('<Leader>c')
        end
      })
    end
  },

  {
    'folke/noice.nvim', -- Completely replaces the UI for messages, cmdline and the popupmenu
    event = 'VeryLazy',
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false
      }
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
    }
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
              'buffers',
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

  {
    'lewis6991/gitsigns.nvim', -- Git integration for buffers
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      word_diff = true
    }
  },

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

  --[[ {
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
        side = 'right',
        centralize_selection = false,
        width = '15%',
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
  }, ]]

  {
    'nvim-telescope/telescope.nvim',        -- Find, Filter, Preview, Pick.
    branch = '0.1.x',
    dependencies = 'nvim-lua/plenary.nvim', -- All the lua functions I don't want to write twice.
    keys = { '<Leader>fc', '<Leader>ff', '<Leader>fg', '<Leader>f/', '<Leader>fb', '<Leader>f:', '<Leader>fh' },
    config = function()
      local telescopeBuiltin = require('telescope.builtin')
      keymapN({
        ['<Leader>f'] = {
          c = { telescopeBuiltin.colorscheme, 'Find color scheme' },
          f = { telescopeBuiltin.find_files, 'Find files' },
          g = { telescopeBuiltin.live_grep, 'Live grep' },
          ['/'] = { telescopeBuiltin.current_buffer_fuzzy_find, 'Current buffer fuzzy find' },
          b = { telescopeBuiltin.buffers, 'Buffers' },
          [':'] = { telescopeBuiltin.command_history, 'Command history' },
          h = { telescopeBuiltin.help_tags, 'Help tags' }
        }
      })

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
        },
        pickers = {
          colorscheme = { enable_preview = true }
        }
      }
    end
  },

  {
    'folke/trouble.nvim', -- A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing
    dependencies = 'nvim-tree/nvim-web-devicons',
    cmd = 'Trouble',
    keys = {
      { '<Leader>!', '<Cmd>Trouble diagnostics toggle filter.buf=0<CR>', desc = 'Buffer Diagnostics (Trouble)' }
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
          ColorColumn = { bg = C.surface0 },                                                -- used for the columns set with 'colorcolumn'
          Conceal = { fg = C.overlay1 },                                                    -- placeholder characters substituted for concealed text (see 'conceallevel')
          Cursor = { fg = C.base, bg = C.text },                                            -- character under the cursor
          lCursor = { fg = C.base, bg = C.text },                                           -- the character under the cursor when |language-mapping| is used (see 'guicursor')
          CursorIM = { fg = C.base, bg = C.text },                                          -- like Cursor, but used when in IME mode |CursorIM|
          CursorColumn = { bg = C.surface0 },                                               -- Screen-column at the cursor, when 'cursorcolumn' is seC.
          CursorLine = { bg = C.surface0 },                                                 -- Screen-line at the cursor, when 'cursorline' is seC.  Low-priority if forecrust (ctermfg OR guifg) is not seC.
          Directory = { fg = C.blue },                                                      -- directory names (and other special names in listings)
          EndOfBuffer = { fg = C.base },                                                    -- filler lines (~) after the end of the buffer.  By default, this is highlighted like |hl-NonText|.
          ErrorMsg = { fg = C.red, style = { 'bold', 'italic' } },                          -- error messages on the command line
          VertSplit = { fg = C.surface0, bg = C.crust },                                    -- the column separating vertically split windows
          Folded = { fg = C.blue, bg = O.transparent_background and C.none or C.surface1 }, -- line used for closed folds
          FoldColumn = { fg = C.overlay0 },                                                 -- 'foldcolumn'
          SignColumn = { fg = C.surface1 },                                                 -- column where |signs| are displayed
          SignColumnSB = { bg = C.crust, fg = C.surface1 },                                 -- column where |signs| are displayed
          Substitute = { bg = C.surface1, fg = U.vary_color({ latte = C.red }, C.pink) },   -- |:substitute| replacement text highlighting
          LineNr = { fg = U.vary_color({ latte = C.base0 }, C.surface1) },                  -- Line number for ':number' and ':#' commands, and when 'number' or 'relativenumber' option is seC.
          CursorLineNr = { fg = C.lavender },                                               -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line. highlights the number in numberline.
          MatchParen = { fg = C.peach, style = { 'bold' } },                                -- The character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
          ModeMsg = { fg = C.text, style = { 'bold' } },                                    -- 'showmode' message (e.g., '-- INSERT -- ')
          MsgArea = { fg = C.text },                                                        -- Area for messages and cmdline
          MsgSeparator = {},                                                                -- Separator for scrolled messages, `msgsep` flag of 'display'
          MoreMsg = { fg = C.teal },                                                        -- |more-prompt|
          NonText = { fg = C.overlay0 },                                                    -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., '>' displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
          Normal = { fg = C.text, bg = O.transparent_background and C.none or C.base },     -- normal text
          NormalNC = {
            fg = C.text,
            bg = (O.transparent_background and O.dim_inactive.enabled and C.dim)
                or (O.dim_inactive.enabled and C.dim)
                or (O.transparent_background and C.none)
                or C.base,
          },                                                                                                           -- normal text in non-current windows
          NormalSB = { fg = C.text, bg = C.crust },                                                                    -- normal text in non-current windows
          NormalFloat = { fg = C.text, bg = O.transparent_background and C.none or C.mantle },                         -- Normal text in floating windows.
          FloatBorder = { fg = C.overlay2 },
          Pmenu = { bg = O.transparent_background and C.none or U.darken(C.surface0, 0.8, C.crust), fg = C.overlay2 }, -- Popup menu: normal item.
          PmenuSel = { fg = C.text, bg = C.surface2, style = { 'bold' } },                                             -- Popup menu: selected item.
          PmenuSbar = { bg = C.surface1 },                                                                             -- Popup menu: scrollbar.
          PmenuThumb = { bg = C.overlay0 },                                                                            -- Popup menu: Thumb of the scrollbar.
          Question = { fg = C.teal },                                                                                  -- |hit-enter| prompt and yes/no questions
          QuickFixLine = { bg = C.surface1, style = { 'bold' } },                                                      -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
          Search = { bg = C.yellow, fg = C.mantle },                                                                   -- Last search pattern highlighting (see 'hlsearch').  Also used for similar items that need to stand ouC.
          IncSearch = { bg = C.peach, fg = C.mantle },                                                                 -- 'incsearch' highlighting; also used for the text replaced with ':s///c'
          CurSearch = { bg = C.pink, fg = C.mantle },                                                                  -- 'cursearch' highlighting: highlights the current search you're on differently
          SpecialKey = { fg = C.text },                                                                                -- Unprintable characters: text displayed differently from what it really is.  But not 'listchars' textspace. |hl-Whitespace|
          SpellBad = { sp = C.red, style = { 'undercurl' } },                                                          -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
          SpellCap = { sp = C.yellow, style = { 'undercurl' } },                                                       -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
          SpellLocal = { sp = C.blue, style = { 'undercurl' } },                                                       -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
          SpellRare = { sp = C.green, style = { 'undercurl' } },                                                       -- Word that is recognized by the spellchecker as one that is hardly ever used.  |spell| Combined with the highlighting used otherwise.
          StatusLine = { fg = C.text, bg = O.transparent_background and C.none or C.mantle },                          -- status line of current window
          StatusLineNC = { fg = C.surface1, bg = O.transparent_background and C.none or C.mantle },                    -- status lines of not-current windows Note: if this is equal to 'StatusLine' Vim will use '^^^' in the status line of the current window.
          TabLine = { bg = C.mantle, fg = C.surface1 },                                                                -- tab pages line, not active tab page label
          TabLineFill = { bg = C.black },                                                                              -- tab pages line, where there are no labels
          TabLineSel = { fg = C.overlay2, bg = C.surface1 },                                                           -- tab pages line, active tab page label
          Title = { fg = C.text, style = { 'bold' } },                                                                 -- titles for output from ':set all', ':autocmd' etC.
          Visual = { bg = C.surface1, style = { 'bold' } },                                                            -- Visual mode selection
          VisualNOS = { bg = C.surface1, style = { 'bold' } },                                                         -- Visual mode selection when vim is 'Not Owning the Selection'.
          WarningMsg = { fg = C.peach },                                                                               -- warning messages
          Whitespace = { fg = C.surface1 },                                                                            -- 'nbsp', 'space', 'tab' and 'trail' in 'listchars'
          ExtraWhitespace = { bg = C.red },
          WildMenu = { bg = C.overlay0 },                                                                              -- current match in 'wildmenu' completion
          WinBar = { fg = C.subtext0, bg = C.surface1 },

          healthError = { fg = C.red },
          healthSuccess = { fg = C.teal },
          healthWarning = { fg = C.yellow },

          CmpCursorLine = { bg = C.surface0, style = { 'underline' } }, -- Highlight group for unmatched characters of each completion field.
          CmpItemAbbr = {},                                             -- Highlight group for unmatched characters of each completion field.
          CmpItemAbbrDeprecated = { strikethrough = true },             -- Highlight group for unmatched characters of each deprecated completion field.
          CmpItemAbbrMatch = { bold = true },                           -- Highlight group for matched characters of each completion field. Matched characters must form a substring of a field which share a starting position.
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
          Comment = { fg = C.overlay0 },                            -- just comments
          SpecialComment = { fg = C.overlay0, style = { 'bold' } }, -- special things inside a comment
          Constant = { fg = C.text },                               -- (preferred) any constant
          ['@constant'] = { fg = C.text },
          String = { fg = C.teal },                                 -- a string constant: 'this is a string'
          ['@punctuation.string'] = { fg = C.sapphire },            -- a string constant: 'this is a string'
          ['@punctuation.string.bracket'] = { style = { 'bold' } }, -- a string constant: 'this is a string'
          ['@string.escape'] = { fg = C.teal, style = { 'bold' } },
          ['@string.regex'] = { fg = C.green },
          ['@punctuation.regex.bracket'] = { fg = C.green },
          Character = { fg = C.teal, style = { 'bold' } }, --  a character constant: 'c', '\n'
          Number = { fg = C.peach },                       --   a number constant: 234, 0xff
          Float = { fg = C.peach },                        --    a floating point constant: 2.3e10
          Boolean = { fg = C.sapphire },                   --  a boolean constant: TRUE, false
          ['@punctuation.array'] = { fg = C.peach },
          ['@punctuation.object'] = { fg = C.sapphire },
          ['@punctuation.table'] = { fg = C.sapphire },
          ['@operator.table'] = { fg = C.sapphire },
          Identifier = { fg = C.text }, -- (preferred) any variable name
          ['@variable.builtin'] = { fg = C.text, bold = true },
          ['@type.builtin'] = { link = '@variable.builtin' },
          ['@function.builtin'] = { link = '@variable.builtin' },
          ['@method.builtin'] = { link = '@variable.builtin' },
          ['@constant.builtin'] = { fg = C.text, style = { 'bold' } },
          ['@parameter'] = { link = 'Identifier' }, -- For parameters of a function.
          Function = { fg = C.text },               -- function name (also: methods for classes)
          ['@constructor'] = { fg = C.text },
          ['@property'] = { fg = C.text },
          ['@field'] = { fg = C.text },
          ['@method'] = { fg = C.text },
          Keyword = { fg = C.blue, style = { 'bold', 'italic' } },                   --  any other keyword
          ['@keyword'] = { fg = C.blue, style = { 'bold', 'italic' } },              -- any other keyword
          ['@keyword.declaration'] = { fg = C.green, style = { 'bold', 'italic' } }, -- Keywords used to define a variable/constant: `var`, `let` and `const` in JavaScript
          ['@operator.declaration'] = { fg = C.green, style = { 'italic' } },
          ['@keyword.function'] = { fg = C.green, style = { 'bold', 'italic' } },    -- Keywords used to define a function: `function` in Lua, `def` and `lambda` in Python.
          ['@punctuation.function'] = { fg = C.green },                              -- Punctuation in function declarations.
          ['@punctuation.function.special'] = { fg = C.green, style = { 'bold', 'italic' } },
          ['@keyword.class'] = { fg = C.green, style = { 'bold', 'italic' } },
          ['@punctuation.class'] = { fg = C.green },
          Statement = { fg = C.blue, style = { 'bold', 'italic' } },       -- (preferred) any statement
          Conditional = { fg = C.sapphire, style = { 'bold', 'italic' } }, -- if, then, else, endif, switch, etC.
          ['@punctuation.conditional'] = { fg = C.sapphire },
          Repeat = { fg = C.peach },                                       -- for, do, while, etC.
          ['@punctuation.repeat'] = { fg = C.peach },
          Label = { fg = C.sapphire, style = { 'bold', 'italic' } },       --    case, default, etC.
          Operator = { fg = C.overlay1 },                                  -- 'sizeof', '+', '*', etC.
          ["@punctuation.keyword"] = { style = { 'italic' } },
          ['@keyword.operator'] = { fg = C.overlay1, style = { 'bold', 'italic' } },
          ['@keyword.with'] = { fg = C.green, style = { 'bold', 'italic' } },
          ['@punctuation.with'] = { fg = C.green },
          ['@keyword.coroutine'] = { fg = C.mauve, style = { 'bold', 'italic' } },
          ['@keyword.return'] = { fg = C.mauve, style = { 'bold', 'italic' } },
          ['@keyword.break'] = { link = '@keyword.return' },
          ['@keyword.continue'] = { link = '@keyword.return' },
          Exception = { fg = C.red },                                            --  try, catch, throw
          ['@exception'] = { fg = C.red },                                       --  try, catch, throw
          ['@keyword.exception'] = { fg = C.red, style = { 'bold', 'italic' } }, --  try, catch, throw
          ['@punctuation.exception'] = { link = '@exception' },                  --  try, catch, throw
          ['@keyword.debugger'] = { fg = C.red, style = { 'bold', 'italic' } },

          PreProc = { fg = C.overlay1 },                         -- (preferred) generic Preprocessor
          Include = { fg = C.green },                            --  preprocessor #include
          Define = { fg = C.green },                             -- preprocessor #define
          Macro = { fg = C.green },                              -- same as Define
          PreCondit = { fg = C.sapphire },                       -- preprocessor #if, #else, #endif, etc.

          Type = { fg = C.text },                                -- (preferred) int, long, char, etC.
          StorageClass = { fg = C.sapphire },                    -- static, register, volatile, etC.
          Structure = { fg = C.teal },                           --  struct, union, enum, etC.
          Typedef = { link = 'Type' },                           --  A typedef

          Special = { fg = C.sapphire },                         -- (preferred) any special symbol
          SpecialChar = { fg = C.sapphire, style = { 'bold' } }, -- special character in a constant
          Tag = { link = 'Special' },                            -- you can use CTRL-] on this
          Delimiter = { fg = C.overlay2 },                       -- character that needs attention
          -- Specialoverlay0= { }, -- special things inside a overlay0
          Debug = { fg = C.red, style = { 'italic' } },          -- debugging statements

          Underlined = { style = { 'underline' } },              -- (preferred) text that stands out, HTML links
          Bold = { style = { 'bold' } },
          Italic = { style = { 'italic' } },
          -- ('Ignore', below, may be invisible...)
          -- Ignore = { }, -- (preferred) left blank, hidden  |hl-Ignore|

          Error = { fg = C.red },                                    -- (preferred) any erroneous construct
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
          debugBreakpoint = { bg = C.base, fg = C.overlay0 },                -- used for breakpoint colors in terminal-debug
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
          DiffAdd = { bg = U.darken(C.green, 0.4, C.base) },    -- diff mode: Added line |diff.txt|
          DiffChange = { bg = U.darken(C.peach, 0.4, C.base) }, -- diff mode: Changed line |diff.txt|
          DiffDelete = { bg = U.darken(C.red, 0.4, C.base) },   -- diff mode: Deleted line |diff.txt|
          DiffText = { bg = U.darken(C.peach, 0.4, C.base) },   -- diff mode: Changed text within a changed line |diff.txt|
          GitSignsChangeInline = { style = { 'underline' }, sp = U.darken(C.yellow, 0.4, C.base) },
          GitSignsAddInline = { bg = C.base, style = { 'underline' }, sp = U.darken(C.green, 0.4, C.base) },
          GitSignsDeleteInline = { bg = C.base, style = { 'underline' }, sp = U.darken(C.red, 0.4, C.base) },
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
    'yioneko/nvim-vtsls', -- Plugin to help utilize capabilities of vtsls
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
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
    'folke/lazydev.nvim', -- Faster LuaLS setup for Neovim
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'olimorris/codecompanion.nvim',
    config = {
      strategies = {
        cmd = { adapter = 'custom_anthropic', language = 'ru' },
        chat = { adapter = 'custom_anthropic', language = 'ru' },
        inline = { adapter = 'custom_anthropic', language = 'ru' },
      },
      adapters = {
        opts = {
          allow_insecure = true,
          language = 'ru'
        },
        custom_anthropic = function()
          return require('codecompanion.adapters').extend('anthropic', {
            name = 'custom',
            url = 'http://api.eliza.yandex.net/anthropic/v1/messages',
            -- env = { api_key = 'SOY_TOKEN' },
            schema = {
              model = { default = 'claude-3-7-sonnet-20250219' }
            }
          })
        end,
        custom_deepseek = function()
          return require('codecompanion.adapters').extend('openai_compatible', {
            url = 'http://api.eliza.yandex.net/together/v1/chat/completions',
            -- env = { api_key = 'SOY_TOKEN' },
            schema = {
              model = { default = 'deepseek-ai/deepseek-r1' },
            },
          })
        end
      }
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },

  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    version = '*',
    opts = {
      provider = 'claude',
      auto_suggestions_provider = 'claude',
      cursor_applying_provider = nil,
      cache_control = {
        enabled = true,
        ttl = 36000,
        persist = true,
      },
      claude = {
        endpoint = 'https://api.eliza.yandex.net/raw/anthropic',
        model = 'claude-3-7-sonnet-20250219',
        disable_tools = true,
        -- prompt = 'Разговаривай на русском.',
        temperature = 0,
        max_tokens = 18192,
        timeout = 240000
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
        minimize_diff = true,                -- Whether to remove unchanged lines when applying a code block
        enable_token_counting = true,        -- Whether to enable token counting. Default to true.
        enable_cursor_planning_mode = false, -- Whether to enable Cursor Planning Mode. Default to false.
      },
      mappings = {
        --- @class AvanteConflictMappings
        diff = {
          ours = 'co',
          theirs = 'ct',
          all_theirs = 'ca',
          both = 'cb',
          cursor = 'cc',
          next = ']x',
          prev = '[x',
        },
        suggestion = {
          accept = '<M-l>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
        jump = {
          next = ']]',
          prev = '[[',
        },
        submit = {
          normal = '<CR>',
          insert = '<C-s>',
        },
        sidebar = {
          apply_all = 'A',
          apply_cursor = 'a',
          switch_windows = '<Tab>',
          reverse_switch_windows = '<S-Tab>',
        },
      },
      hints = { enabled = false },
      windows = {
        position = 'right', -- the position of the sidebar
        wrap = true,        -- similar to vim.o.wrap
        width = 40,         -- default % based on available width
        sidebar_header = {
          enabled = true,   -- true, false to enable/disable the header
          align = 'center', -- left, center, right for title
          rounded = true,
        },
        input = {
          prefix = '> ',
          height = 8, -- Height of the input window in vertical layout
        },
        edit = {
          border = 'rounded',
          start_insert = true, -- Start insert mode when opening the edit window
        },
        ask = {
          floating = false,    -- Open the 'AvanteAsk' prompt in a floating window
          start_insert = true, -- Start insert mode when opening the ask window
          border = 'rounded',
          ---@type 'ours' | 'theirs'
          focus_on_apply = 'ours', -- which diff to focus after applying
        },
      },
      highlights = {
        diff = {
          current = 'DiffText',
          incoming = 'DiffAdd',
        },
      },
      diff = {
        autojump = true,
        list_opener = 'copen',
        --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
        --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
        --- Disable by setting to -1.
        override_timeoutlen = 500,
      },
      suggestion = {
        debounce = 600,
        throttle = 600,
      }
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = 'make',
    -- build = 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false' -- for windows
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'echasnovski/mini.pick',         -- for file_selector provider mini.pick
      'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
      'hrsh7th/nvim-cmp',              -- autocompletion for avante commands and mentions
      'ibhagwan/fzf-lua',              -- for file_selector provider fzf
      'nvim-tree/nvim-web-devicons',   -- or echasnovski/mini.icons
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  }

})
