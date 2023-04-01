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

vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = function(data)
  if vim.fn.isdirectory(data.file) == 1 then
    vim.cmd.cd(data.file)
    require('nvim-tree.api').tree.open()
  end
end})

return require('lazy').setup({
  {
    'nvim-telescope/telescope.nvim', -- Find, Filter, Preview, Pick.
    branch = '0.1.x',
    dependencies = 'nvim-lua/plenary.nvim', -- All the lua functions I don't want to write twice.
    keys = { '<Leader>ff', '<Leader>fg', '<Leader>fb', '<Leader>fh' },
    config = function()
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
    end
  },

  'editorconfig/editorconfig-vim', -- EditorConfig plugin

  {
    'rktjmp/highlight-current-n.nvim', -- highlights the current /, ? or * match under your cursor when pressing n or N
    keys = { '/', '?', '*' }
  },

  {
    'booperlv/nvim-gomove', -- A complete plugin for moving and duplicating blocks and lines, with complete fold handling, reindenting, and undoing in one go
    opts = { map_defaults = false, reindent = true },
    keys = {
      { '<C-h>', '<Plug>GoNSMLeft' },
      { '<C-j>', '<Plug>GoNSMDown' },
      { '<C-k>', '<Plug>GoNSMUp' },
      { '<C-l>', '<Plug>GoNSMRight' },
      { '<C-h>', '<Plug>GoVSMLeft', mode = 'x' },
      { '<C-j>', '<Plug>GoVSMDown', mode = 'x' },
      { '<C-k>', '<Plug>GoVSMUp', mode = 'x' },
      { '<C-l>', '<Plug>GoVSMRight', mode = 'x' },
      { '<M-Left>', '<Plug>GoNSMLeft' },
      { '<M-Down>', '<Plug>GoNSMDown' },
      { '<M-Up>', '<Plug>GoNSMUp' },
      { '<M-Right>', '<Plug>GoNSMRight' },
      { '<M-Left>', '<Plug>GoVSMLeft', mode = 'x' },
      { '<M-Down>', '<Plug>GoVSMDown', mode = 'x' },
      { '<M-Up>', '<Plug>GoVSMUp', mode = 'x' },
      { '<M-Right>', '<Plug>GoVSMRight', mode = 'x' },
      { '<C-S-h>', '<Plug>GoNSDLeft' },
      { '<C-S-j>', '<Plug>GoNSDDown' },
      { '<C-S-k>', '<Plug>GoNSDUp' },
      { '<C-S-l>', '<Plug>GoNSDRight' },
      { '<C-S-h>', '<Plug>GoVSDLeft', mode = 'x' },
      { '<C-S-j>', '<Plug>GoVSDDown', mode = 'x' },
      { '<C-S-k>', '<Plug>GoVSDUp', mode = 'x' },
      { '<C-S-l>', '<Plug>GoVSDRight', mode = 'x' },
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

  'tpope/vim-surround', -- Delete/change/add parentheses/quotes/XML-tags/much more with ease

  {
    'numToStr/Comment.nvim', -- Smart and powerful comment plugin
    opts = {
      toggler = { line = '<Leader>/', block = '<Leader>*' },
      opleader = { line = '<Leader>/', block = '<Leader>*' }
    },
    keys = {
      '<Leader>/',
      '<Leader>*',
      { '<Leader>/', mode = 'v' },
      { '<Leader>*', mode = 'v' }
    }
  },

  {
    'windwp/nvim-autopairs', -- A super powerful autopair plugin for Neovim that supports multiple characters
    event = 'InsertEnter'
  },

  'ntpeters/vim-better-whitespace', -- Better whitespace highlighting
  'tpope/vim-repeat', -- Enable repeating supported plugin maps with .
  'nishigori/increment-activator', -- enhance to increment candidates U have defined

  {
    'troydm/zoomwintab.vim', -- zoom current window
    keys = { '<C-w>o', '<C-w><C-o>' }
  },

  'LunarVim/bigfile.nvim', -- Make editing big files faster

  'folke/which-key.nvim', -- displays a popup with possible keybindings of the command you started typing

  'lewis6991/gitsigns.nvim', -- Git integration for buffers

  {
    'nvim-lualine/lualine.nvim', -- A blazing fast and easy to configure neovim statusline plugin
    config = function()
      local lualine_filename = { {
        'filename',
        file_status = true,
        newfile_status = true,
        path = 1,
        symbols = {
          modified = ' פֿ',
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
          lualine_a = { 'buffers' },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = { 'tabs' },
          lualine_z = {
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
    'nvim-tree/nvim-tree.lua', -- A file explorer tree for neovim written in lua
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- Adds file type icons to Vim plugins
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
    'folke/trouble.nvim', -- A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing
    dependencies = 'nvim-tree/nvim-web-devicons',
    cmd = 'TroubleToggle',
    keys = {
      { '<Leader>!', '<Cmd>TroubleToggle<CR>', desc = 'Trouble' }
    },
    opts = { use_diagnostic_signs = true }
  },

  {
    'L3MON4D3/LuaSnip', -- Snippet Engine for Neovim written in Lua
    version = '<CurrentMajor>.*',
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

      vim.keymap.set('i', '<Tab>', function() return luasnip.expand_or_locally_jumpable() and '<Plug>luasnip-expand-or-jump' or '<Tab>' end, { expr = true })
      vim.keymap.set('i', '<S-Tab>', function() luasnip.jump(-1) end)
      vim.keymap.set('i', '<M-Tab>', function() if luasnip.choice_active() then require('luasnip.extras.select_choice')() end end)
    end
  },

  {
    'utilyre/spoon.nvim', -- A collection of luasnip snippets
    dependencies = 'L3MON4D3/LuaSnip',
    event = 'InsertEnter',
    config = function()
      require('spoon').setup({
        preferSingleQuotes = true,
        langs = { lua = true, javascript = true, javascriptreact = true }
      })
      local luasnip = require('luasnip')
      local snippets = require('spoon.snippets')
      luasnip.add_snippets('typescript', snippets.javascript)
      luasnip.add_snippets('typescriptreact', snippets.javascriptreact)
    end
  },

  {
    'saadparwaiz1/cmp_luasnip', -- A collection of luasnip snippets
    dependencies = {'hrsh7th/nvim-cmp', 'L3MON4D3/LuaSnip'},
    event = 'InsertEnter'
  },

  {
    'neovim/nvim-lspconfig', -- Quickstart configurations for the Nvim LSP client
    dependencies = 'hrsh7th/cmp-nvim-lsp',
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      local lspconfig = require('lspconfig')
      lspconfig.eslint.setup({ capabilities = capabilities })
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
    end
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
          -- ['<Esc>'] = function(fallback)
            --   if cmp.visible() then
            --     cmp.abort()
            --   else
            --     fallback()
            --   end
            -- end,
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
      'veged/nvim-treesitter', -- Nvim Treesitter configurations and abstraction layer
      build = ':TSUpdate',
      config = function()
        -- vim.g.skip_ts_default_groups = true
        -- require('nvim-treesitter.highlight').set_custom_captures(treesitter_custom_captures)

        require'nvim-treesitter.configs'.setup {
          ensure_installed = { 'html', 'css', 'javascript', 'typescript', 'json', 'lua' },
          auto_install = true,
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false
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
      end
    },

    {
      'nvim-treesitter/playground', -- Treesitter playground integrated into Neovim
      cmd = 'TSPlaygroundToggle'
    },

    {
      'f-person/auto-dark-mode.nvim',
      name = 'auto-dark-mode',
      opts = {
        update_interval = 60000,
        set_dark_mode = function()
          vim.o.background = 'dark'
          io.popen('kitty +kitten themes --reload-in=all Catppuccin-Latte')
        end,
        set_light_mode = function()
          vim.o.background = 'light'
          io.popen('kitty +kitten themes --reload-in=all Catppuccin-Mocha')
        end
      }
    },

    -- {
    --   'veged/yacolors.nvim',
    --   lazy = false,
    --   priority = 1000,
    --   dependencies = 'rktjmp/lush.nvim', -- Create Neovim themes with real-time feedback, export anywhere
    --   config = function()
    --     vim.o.termguicolors = true
    --     vim.o.background = 'light'
    --     vim.cmd('colorscheme yacolors')
    --   end
    -- },
    {
      'catppuccin/nvim',
      name = 'catppuccin',
      dependencies = 'auto-dark-mode',
      opts = {
        background = {
          light = 'latte',
          dark = 'mocha',
        },
        styles = {
          comments = {},
          conditionals = { 'italic', 'bold' },
          loops = { 'italic', 'bold' },
          functions = {},
          keywords = { 'italic', 'bold' },
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        custom_highlights = function(colors)
          return {
            -- Comment = { fg = colors.flamingo },
            -- ["@constant.builtin"] = { fg = colors.peach, style = {} },
            -- ["@comment"] = { fg = colors.surface2, style = { "italic" } },
          }
        end
      },
      init = function()
        vim.o.termguicolors = true
        vim.cmd.colorscheme 'catppuccin'
      end
    },

    {
      'rickhowe/diffchar.vim', -- Highlight the exact differences, based on characters and words
      ft = 'diff'
    },

    'norcalli/nvim-colorizer.lua', -- A high-performance color highlighter

    {
      'moll/vim-node', -- Tools and environment to make Vim superb for developing with Node.js
      ft = { 'javascript', 'typescript' }
    },

    {
      'jose-elias-alvarez/typescript.nvim', -- A Lua plugin, written in TypeScript, to write TypeScript
      ft = { 'typescript', 'typescriptreact' },
      config = function()
        require('typescript').setup({ server = {
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
          on_attach = function(client, bufnr)
            print('tsserver attached')
            local bufopts = { noremap=true, silent=true, buffer=bufnr }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

            vim.keymap.set('n', '<Leader>h', vim.lsp.buf.hover, bufopts)
            vim.keymap.set('n', '<Leader>H', vim.lsp.buf.signature_help, bufopts)

            vim.keymap.set('n', '<Leader>=', vim.lsp.buf.format, bufopts)
            vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, bufopts)
            vim.keymap.set('n', '<Leader>@', vim.lsp.buf.code_action, bufopts)

            vim.keymap.set('n', '<Leader>~a', vim.lsp.buf.add_workspace_folder, bufopts)
            vim.keymap.set('n', '<Leader>~r', vim.lsp.buf.remove_workspace_folder, bufopts)
            vim.keymap.set('n', '<Leader>~l', function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, bufopts)
          end
        } })
      end
    },

    'JoosepAlviste/nvim-ts-context-commentstring', -- Neovim treesitter plugin for setting the commentstring based on the cursor location in a file

    {
      'windwp/nvim-ts-autotag', -- Use treesitter to auto close and auto rename html tag
      ft = { 'html', 'javascriptreact', 'typescriptreact' }
    },

    'nvim-treesitter/nvim-treesitter-textobjects', -- Syntax aware text-objects, select, move, swap, and peek support

    {
      'maxmellon/vim-jsx-pretty', -- JSX and TSX syntax pretty highlighting
      ft = { 'javascriptreact', 'typescriptreact' }
    },

    {
      'euclidianAce/BetterLua.vim', -- Better Lua syntax highlighting
      ft = 'lua'
    },

    {
      'andrejlevkovitch/vim-lua-format', -- Lua vim formatter supported by LuaFormatter
      ft = 'lua'
    }
})
