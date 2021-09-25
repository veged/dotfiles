set nocompatible

"let g:python2_host_prog = '/usr/bin/python'
let g:python3_host_prog = '/opt/homebrew/bin/python3'

call plug#begin('~/.vim/plugged')

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'troydm/zoomwintab.vim'
Plug 'raimondi/delimitmate'
Plug 'editorconfig/editorconfig-vim'
Plug 'nishigori/increment-activator'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'rickhowe/diffchar.vim'

Plug 'ntpeters/vim-better-whitespace'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'

"Plug 'airblade/vim-gitgutter'
Plug 'nvim-lua/plenary.nvim'
Plug 'lewis6991/gitsigns.nvim'


"if has('nvim')
  "Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"else
  "Plug 'Shougo/deoplete.nvim'
  "Plug 'roxma/nvim-yarp'
  "Plug 'roxma/vim-hug-neovim-rpc'
"endif
"let g:deoplete#enable_at_startup = 1
"Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }

Plug 'neovim/nvim-lspconfig'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'nvim-lua/plenary.nvim'

"Plug 'jose-elias-alvarez/null-ls.nvim'
"lua <<EOF
    "require("null-ls").config {}
    "require("lspconfig")["null-ls"].setup {}
"EOF


Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'ray-x/cmp-treesitter'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'hrsh7th/cmp-buffer'
Plug 'octaltree/cmp-look'
Plug 'hrsh7th/cmp-path'


Plug 'w0rp/ale'
"Plug 'scrooloose/syntastic'
Plug 'marijnh/tern_for_vim'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'moll/vim-node'
Plug 'jose-elias-alvarez/nvim-lsp-ts-utils'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'windwp/nvim-ts-autotag'
Plug 'RRethy/nvim-treesitter-textsubjects'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'jparise/vim-graphql'
Plug 'zirrostig/vim-schlepp'
Plug 'tpope/vim-surround'

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
nmap <leader>nt :NERDTreeFind<CR>
let NERDTreeShowBookmarks=1
let NERDTreeChDirMode=0
let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden=1
let NERDTreeKeepTreeInNewTab=1

command W w
command WQ wq
command Wq wq
command Q q

"let g:syntastic_javascript_checkers = ['jscs']

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

" Deoplete
"let g:deoplete#enable_at_startup = 1
"let g:deoplete#disable_auto_complete = 1
"inoremap <silent><expr> <S-Down>
    "\ pumvisible() ? "\<C-n>" :
    "\ <SID>check_back_space() ? "\<TAB>" :
    "\ deoplete#manual_complete()
"function! s:check_back_space() abort "{{{
  "let col = col('.') - 1
  "return !col || getline('.')[col - 1]  =~ '\s'
"endfunction"}}}
"let g:deoplete#sources#ternjs#include_keywords = 1
"let g:deoplete#sources#jedi#python_path = 'python3'

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
        {name = 'buffer'}, {name = 'nvim_lsp'}, {name = "ultisnips"},
        {name = "nvim_lua"}, {name = "look"}, {name = "path"}
    },
    completion = {completeopt = 'menu,menuone,noinsert'}
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
