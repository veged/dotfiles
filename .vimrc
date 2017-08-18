set nocompatible

let g:python2_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'

call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'regedarek/zoomwin'
Plug 'troydm/zoomwintab.vim'
Plug 'raimondi/delimitmate'
Plug 'editorconfig/editorconfig-vim'
Plug 'nishigori/increment-activator'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'rickhowe/diffchar.vim'

Plug 'ntpeters/vim-better-whitespace'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
"Plug 'garbas/vim-snipmate'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

Plug 'airblade/vim-gitgutter'

if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }
endif


Plug 'w0rp/ale'
"Plug 'scrooloose/syntastic'
Plug 'marijnh/tern_for_vim'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
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

set guifont=PragmataPro


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
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-tab>"
let g:UltiSnips_javascript = {
      \ 'keyword-spacing': 'never',
      \ 'semi': 'always',
      \ 'space-before-function-paren': 'never',
      \ }

"FuzzyFinder
nnoremap <silent> ffb :FufBuffer<CR>
nnoremap <silent> fff :FufFile<CR>
nnoremap <silent> ffd :FufDir<CR>
nnoremap <silent> ffj :FufJumpList<CR>

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

" ALE
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚠︎'
let g:ale_lint_on_text_changed = 'never'
let g:ale_statusline_format = ['✗ %d', '⚠ %d', '⬥ ok']
let g:ale_echo_msg_error_str = '✗'
let g:ale_echo_msg_warning_str = '⚠'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

" Tern
let g:tern#command = ["tern"]
let g:tern#arguments = ["--persistent"]

" Deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#disable_auto_complete = 1
inoremap <silent><expr> <S-Down>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ deoplete#mappings#manual_complete()
function! s:check_back_space() abort "{{{
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}


" GitGutter


" Schlepp
vmap <unique> <S-up> <Plug>SchleppUp
vmap <unique> <S-down> <Plug>SchleppDown
vmap <unique> <S-left> <Plug>SchleppLeft
vmap <unique> <S-right> <Plug>SchleppRight
vmap <unique> i <Plug>SchleppToggleReindent
vmap <unique> <leader>d <Plug>SchleppDupDown<Esc>
"vmap <unique> Dh <Plug>SchleppDupLeft
"vmap <unique> Dl <Plug>SchleppDupRight
