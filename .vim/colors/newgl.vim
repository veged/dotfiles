" Vim color file
" vim: set foldmethod=marker:

set background=light

" Clear {{{
hi clear
hi clear SpecialKey
hi clear NonText
hi clear Directory
hi clear ErrorMsg
hi clear IncSearch
hi clear Search
hi clear MoreMsg
hi clear ModeMsg
hi clear LineNr
hi clear CursorLineNr
hi clear Question
hi clear StatusLine
hi clear StatusLineNC
hi clear VertSplit
hi clear Title
hi clear Visual
hi clear VisualNOS
hi clear WarningMsg
hi clear WildMenu
hi clear Folded
hi clear FoldColumn
hi clear DiffAdd
hi clear DiffChange
hi clear DiffDelete
hi clear DiffText
hi clear SignColumn
hi clear Conceal
hi clear SpellBad
hi clear SpellCap
hi clear SpellRare
hi clear SpellLocal
hi clear Pmenu
hi clear PmenuSel
hi clear PmenuSbar
hi clear PmenuThumb
hi clear TabLine
hi clear TabLineSel
hi clear TabLineFill
hi clear CursorColumn
hi clear CursorLine
hi clear ColorColumn
hi clear MatchParen
hi clear Comment
hi clear Constant
hi clear Special
hi clear Identifier
hi clear Statement
hi clear PreProc
hi clear Type
hi clear Underlined
hi clear Ignore
hi clear Error
hi clear Todo
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "newgl"
"}}}

hi! Normal ctermfg=0 ctermbg=15 cterm=NONE
hi! Cursor ctermfg=NONE ctermbg=NONE cterm=reverse

hi! SpecialKey ctermfg=14 ctermbg=NONE cterm=NONE
hi! NonText ctermfg=15 ctermbg=NONE cterm=NONE
hi! Directory ctermfg=6 ctermbg=NONE cterm=NONE
hi! ErrorMsg ctermfg=1 ctermbg=15 cterm=NONE
hi! IncSearch ctermfg=8 ctermbg=3 cterm=NONE
hi! Search ctermfg=0 ctermbg=11 cterm=NONE
hi! MoreMsg ctermfg=NONE ctermbg=NONE cterm=NONE
hi! ModeMsg ctermfg=1 ctermbg=NONE cterm=NONE
hi! LineNr ctermfg=8 ctermbg=NONE cterm=NONE
hi! CursorLineNr ctermfg=8 ctermbg=15 cterm=NONE
hi! Question ctermfg=2 ctermbg=NONE cterm=NONE
hi! StatusLine ctermfg=15 ctermbg=8 cterm=NONE
hi! StatusLineNC ctermfg=15 ctermbg=7 cterm=NONE
hi! VertSplit ctermfg=15 ctermbg=8 cterm=NONE
hi! Title ctermfg=2 ctermbg=NONE cterm=NONE
hi! Visual ctermfg=NONE ctermbg=NONE cterm=reverse
hi! VisualNOS ctermfg=NONE ctermbg=NONE cterm=reverse
hi! WarningMsg ctermfg=3 ctermbg=NONE cterm=NONE
hi! WildMenu ctermfg=NONE ctermbg=NONE cterm=NONE
hi! Folded ctermfg=8 ctermbg=15 cterm=NONE
hi! FoldColumn ctermfg=8 ctermbg=15 cterm=NONE
" Diff {{{
hi! DiffAdd ctermfg=NONE ctermbg=10 cterm=NONE
hi link diffAdded DiffAdd
hi! DiffChange ctermfg=NONE ctermbg=12 cterm=NONE
hi link diffChanged DiffChange
hi! DiffDelete ctermfg=NONE ctermbg=9 cterm=NONE
hi link diffRemoved DiffDelete
hi link diffOnly DiffChange
hi link diffIdentical Question
hi link diffDiffer WarningMsg
hi link diffBDiffer diffDiffer
hi link diffIsA WarningMsg
hi link diffNoEOL ErrorMsg
hi link diffCommon Comment
hi link diffFile Folded
hi link diffNewFile Question
hi! DiffText ctermfg=NONE ctermbg=NONE cterm=NONE
" }}}
" JavaScript {{{
hi link javaScriptIdentifier Keyword
hi link javaScriptFuncArg javaScriptFuncKeyword
hi! javaScriptBraces ctermfg=12 ctermbg=NONE cterm=NONE
hi link javaScriptLogicSymbols Operator
hi link javaScriptBracket Comment
hi link javaScriptGlobalObjects Type
hi link javaScriptExceptions Error
" }}}
hi! SignColumn ctermfg=NONE ctermbg=NONE cterm=NONE
hi! Conceal ctermfg=NONE ctermbg=NONE cterm=NONE
hi! SpellBad ctermfg=NONE ctermbg=NONE cterm=NONE
hi! SpellCap ctermfg=NONE ctermbg=NONE cterm=NONE
hi! SpellRare ctermfg=NONE ctermbg=NONE cterm=NONE
hi! SpellLocal ctermfg=NONE ctermbg=NONE cterm=NONE
hi! Pmenu ctermfg=0 ctermbg=7 cterm=NONE
hi! PmenuSel ctermfg=15 ctermbg=8 cterm=NONE
hi! PmenuSbar ctermfg=NONE ctermbg=NONE cterm=NONE
hi! PmenuThumb ctermfg=NONE ctermbg=NONE cterm=NONE
hi! TabLine ctermfg=NONE ctermbg=NONE cterm=NONE
hi! TabLineSel ctermfg=NONE ctermbg=NONE cterm=NONE
hi! TabLineFill ctermfg=NONE ctermbg=NONE cterm=NONE
hi! CursorColumn ctermfg=NONE ctermbg=7 cterm=NONE
hi! CursorLine ctermfg=NONE ctermbg=7 cterm=NONE
hi! ColorColumn ctermfg=NONE ctermbg=NONE cterm=NONE
hi! MatchParen ctermfg=NONE ctermbg=14 cterm=NONE
hi! Comment ctermfg=8 ctermbg=NONE cterm=NONE
hi! SpecialComment ctermfg=8 ctermbg=15 cterm=NONE
hi! Operator ctermfg=8 ctermbg=NONE cterm=NONE
hi! Constant ctermfg=6 ctermbg=NONE cterm=NONE
hi! String ctermfg=2 ctermbg=NONE cterm=NONE
hi! Number ctermfg=9 ctermbg=NONE cterm=NONE
hi! Boolean ctermfg=1 ctermbg=NONE cterm=NONE
hi link Tag Identifier
hi! Special ctermfg=13 ctermbg=NONE cterm=NONE
hi! Identifier ctermfg=4 ctermbg=NONE cterm=NONE
hi! Statement ctermfg=5 ctermbg=NONE cterm=NONE
hi! PreProc ctermfg=3 ctermbg=NONE cterm=NONE
hi! Type ctermfg=13 ctermbg=NONE cterm=NONE
hi link Keyword Type
hi! Underlined ctermfg=NONE ctermbg=15 cterm=underline
hi! Ignore ctermfg=NONE ctermbg=NONE cterm=NONE
hi! Error ctermfg=1 ctermbg=15 cterm=NONE
hi! Todo ctermfg=NONE ctermbg=NONE cterm=NONE
