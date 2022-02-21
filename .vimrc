set nocompatible

let g:python3_host_prog = '/opt/homebrew/bin/python3'

call plug#begin('~/.vim/plugged')

Plug 'nvim-lua/plenary.nvim' " All the lua functions I don't want to write twice.
Plug 'nvim-telescope/telescope.nvim' " Find, Filter, Preview, Pick.

Plug 'vim-airline/vim-airline' " lean & mean status/tabline
Plug 'vim-airline/vim-airline-themes'
Plug 'troydm/zoomwintab.vim' " zoom current window
Plug 'raimondi/delimitmate' " provides insert mode auto-completion for quotes, parens, brackets, etc
Plug 'editorconfig/editorconfig-vim' " EditorConfig plugin
Plug 'nishigori/increment-activator' " enhance to increment candidates U have defined
Plug 'scrooloose/nerdcommenter' " intensely nerdy commenting powers
Plug 'kyazdani42/nvim-web-devicons' " Adds file type icons to Vim plugins
Plug 'kyazdani42/nvim-tree.lua' " A file explorer tree for neovim written in lua
Plug 'rickhowe/diffchar.vim' " Highlight the exact differences, based on characters and words

Plug 'ntpeters/vim-better-whitespace' " Better whitespace highlighting
Plug 'MarcWeber/vim-addon-mw-utils' " various utils such as caching interpreted contents of files or advanced glob like things
Plug 'SirVer/ultisnips' " The ultimate snippet solution
Plug 'honza/vim-snippets' " default snippets
Plug 'quangnguyen30192/cmp-nvim-ultisnips' " nvim-cmp source for ultisnips

Plug 'lewis6991/gitsigns.nvim' " Git integration for buffers

Plug 'neovim/nvim-lspconfig' " Quickstart configurations for the Nvim LSP client

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Nvim Treesitter configurations and abstraction layer

Plug 'hrsh7th/nvim-cmp' " A completion plugin for neovim coded in Lua
Plug 'hrsh7th/cmp-nvim-lsp' " source for neovim builtin LSP client
Plug 'ray-x/cmp-treesitter' " source for treesitter
Plug 'hrsh7th/cmp-nvim-lua' " source for lua
Plug 'hrsh7th/cmp-buffer' " source for buffer words
Plug 'octaltree/cmp-look' " source for Linux look
Plug 'hrsh7th/cmp-path' " source for filesystem paths

Plug 'w0rp/ale' " Check syntax in Vim asynchronously and fix files
Plug 'marijnh/tern_for_vim' " Tern plugin
Plug 'pangloss/vim-javascript' " Vastly improved Javascript indentation and syntax support
Plug 'leafgarland/typescript-vim' " Typescript syntax files
Plug 'moll/vim-node' " Tools and environment to make Vim superb for developing with Node.js
Plug 'jose-elias-alvarez/nvim-lsp-ts-utils' " Utilities to improve the TypeScript development experience
Plug 'JoosepAlviste/nvim-ts-context-commentstring' " setting the commentstring based on the cursor location in a file
Plug 'windwp/nvim-ts-autotag' " Use treesitter to auto close and auto rename html tag
Plug 'RRethy/nvim-treesitter-textsubjects' " Location and syntax aware text objects
Plug 'maxmellon/vim-jsx-pretty' " JSX and TSX syntax pretty highlighting
Plug 'jparise/vim-graphql' " GraphQL file detection, syntax highlighting, and indentation
Plug 'zirrostig/vim-schlepp' " easily moving text selections around
Plug 'tpope/vim-surround' " Delete/change/add parentheses/quotes/XML-tags/much more with ease

call plug#end()

set mouse=
function! ToggleMouse()
  if &mouse == 'a'
    set mouse=
    echo "Mouse usage disabled"
  else
    set mouse=a
    echo "Mouse usage enabled"
  endif
endfunction
nnoremap <leader>m :call ToggleMouse()<CR>


" Remember last location in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif


set backspace=indent,eol,start

set enc=utf-8
lang ru_RU.UTF-8

set nobackup

set wildmenu

set title
set ruler
set showcmd
set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)

set vb

set scrolljump=5
set scrolloff=3

set incsearch
set showmatch
set hlsearch
set ignorecase
set smartcase
"Clear the search highlight by pressing ENTER when in Normal mode (Typing commands)
:nnoremap <CR> :nohlsearch<CR>/<BS><CR>

set gdefault

set list listchars=tab:>·,trail:·
autocmd BufEnter * EnableStripWhitespaceOnSave

set nowrap
set autoindent
set smartindent
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4

vnoremap < <gv
vnoremap > >gv

if exists(':tnoremap')
    tnoremap <Esc> <C-\><C-n>
endif

set pastetoggle=<leader>v

nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>

syntax enable

colorscheme newgl

" Airline
set laststatus=2
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_theme='sol'
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.paste = 'ρ'

" UltiSnips
let g:UltiSnipsExpandTrigger="<C-s>"
let g:UltiSnipsJumpForwardTrigger="<Tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-Tab>"
let g:ultisnips_javascript = {
      \ 'keyword-spacing': 'never',
      \ 'semi': 'never',
      \ 'space-before-function-paren': 'never',
      \ }

" NERDTree
"nmap <leader>nt :NERDTreeFind<CR>
"let NERDTreeShowBookmarks=1
"let NERDTreeChDirMode=0
"let NERDTreeQuitOnOpen=1
"let NERDTreeShowHidden=1
"let NERDTreeKeepTreeInNewTab=1

" nvim-tree
lua <<EOF
require'nvim-tree'.setup {
  disable_netrw       = true,
  hijack_netrw        = true,
  open_on_setup       = false,
  ignore_ft_on_setup  = {},
  auto_close          = false,
  open_on_tab         = false,
  hijack_cursor       = false,
  update_cwd          = false,
  update_to_buf_dir   = {
    enable = true,
    auto_open = true,
  },
  diagnostics = {
    enable = false,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
  update_focused_file = {
    enable      = false,
    update_cwd  = false,
    ignore_list = {}
  },
  system_open = {
    cmd  = nil,
    args = {}
  },
  filters = {
    dotfiles = false,
    custom = {}
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 500,
  },
  view = {
    width = 30,
    height = 30,
    hide_root_folder = false,
    side = 'left',
    auto_resize = false,
    mappings = {
      custom_only = false,
      list = {}
    },
    number = false,
    relativenumber = false,
    signcolumn = "yes"
  },
  trash = {
    cmd = "trash",
    require_confirm = true
  }
}
EOF


command W w
command WQ wq
command Q q

" Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

lua <<EOF
    local telescope = require('telescope')
    telescope.setup{
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
            file_ignore_patterns = { 'node_modules' },
        }
    }
EOF

" ALE
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚠︎'
let g:ale_lint_on_text_changed = 'never'
let g:ale_statusline_format = ['✗ %d', '⚠ %d', '⬥ ok']
let g:ale_echo_msg_error_str = '✗'
let g:ale_echo_msg_warning_str = '⚠'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

lua <<EOF
require('gitsigns').setup()
EOF

" Tern
let g:tern#command = ["tern"]
let g:tern#arguments = ["--persistent"]

lua <<EOF
local cmp = require'cmp'

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end

cmp.setup({
    mapping = {
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true
        }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if vim.fn.pumvisible() == 1 then
                if vim.fn['UltiSnips#CanExpandSnippet']() == 1 or
                    vim.fn['UltiSnips#CanJumpForwards']() == 1 then
                    return vim.fn.feedkeys(t(
                    '<C-R>=UltiSnips#ExpandSnippetOrJump()<CR>'))
                end

                vim.fn.feedkeys(t('<C-n>'), 'n')
            elseif check_back_space() then
                vim.fn.feedkeys(t('<tab>'), 'n')
            else
                fallback()
            end
        end, {'i', 's'}),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if vim.fn.pumvisible() == 1 then
                vim.fn.feedkeys(t('<C-p>'), 'n')
            else
                fallback()
            end
        end, {'i', 's'})
    },
    snippet = {expand = function(args) vim.fn["UltiSnips#Anon"](args.body) end},
    sources = {
        {name = 'buffer', max_item_count = 5},
        {name = 'nvim_lsp', max_item_count = 5},
        {name = "nvim_lua", max_item_count = 5},
        {name = "look", max_item_count = 5},
        {name = "path", max_item_count = 5}
    },
    completion = {completeopt = 'menu,menuone,noinsert'},
    confirmation = {
        get_commit_characters = function(commit_characters)
            return vim.tbl_filter(function(char)
                return char ~= ',' and char ~= '.'
            end, commit_characters)
        end
    }

})
EOF

lua <<EOF
    require('lspconfig').tsserver.setup {
        on_attach = function(client, bufnr)
            -- disable tsserver formatting if you plan on formatting via null-ls
            -- client.resolved_capabilities.document_formatting = false
            -- client.resolved_capabilities.document_range_formatting = false

            local ts_utils = require('nvim-lsp-ts-utils')

            -- defaults
            ts_utils.setup {
                debug = false,
                disable_commands = false,
                enable_import_on_completion = false,

                -- import all
                import_all_timeout = 5000, -- ms
                import_all_priorities = {
                    buffers = 4, -- loaded buffer names
                    buffer_content = 3, -- loaded buffer content
                    local_files = 2, -- git files or files with relative path markers
                    same_file = 1, -- add to existing import statement
                },
                import_all_scan_buffers = 100,
                import_all_select_source = false,

                -- eslint
                eslint_enable_code_actions = true,
                eslint_enable_disable_comments = true,
                eslint_bin = 'eslint',
                eslint_enable_diagnostics = false,
                eslint_opts = {},

                -- formatting
                enable_formatting = false,
                formatter = 'prettier',
                formatter_opts = {},

                -- update imports on file move
                update_imports_on_move = false,
                require_confirmation_on_move = false,
                watch_dir = nil,

                -- filter diagnostics
                filter_out_diagnostics_by_severity = {},
                filter_out_diagnostics_by_code = {},
            }

            -- required to fix code action ranges and filter diagnostics
            ts_utils.setup_client(client)

            -- no default maps, so you may want to define some here
            local opts = { silent = true }
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gs', ':TSLspOrganize<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', ':TSLspRenameFile<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', ':TSLspImportAll<CR>', opts)
        end
    }
EOF

" Schlepp
vmap <unique> <S-up> <Plug>SchleppUp
vmap <unique> <S-down> <Plug>SchleppDown
vmap <unique> <S-left> <Plug>SchleppLeft
vmap <unique> <S-right> <Plug>SchleppRight
vmap <unique> i <Plug>SchleppToggleReindent
nmap <unique> <leader>d V<Plug>SchleppDupDown<Esc>
vmap <unique> <leader>d <Plug>SchleppDupDown<Esc>
"vmap <unique> Dh <Plug>SchleppDupLeft
"vmap <unique> Dl <Plug>SchleppDupRight
