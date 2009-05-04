" local syntax file - set colors on a per-machine basis:
" vim: tw=0 ts=4 sw=4
" Vim color file
" Maintainer:	Ron Aaron <ron@ronware.org>
" Last Change:	2003 May 02

set background=light
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "veged"

hi Comment term=bold ctermfg=DarkGreen guifg=#006400
hi Normal guifg=black guibg=white
hi Constant term=underline ctermfg=DarkRed guifg=#993300
hi Special term=bold ctermfg=Magenta guifg=Magenta
hi Identifier term=underline ctermfg=DarkBlue guifg=#000096
hi Statement term=bold ctermfg=LightBlue gui=NONE guifg=#0064c8
hi PreProc term=underline ctermfg=Magenta guifg=#8b26c9
hi Type term=underline ctermfg=Red gui=NONE guifg=#f5844c
hi Visual term=reverse ctermfg=Black ctermbg=LightGray gui=NONE guifg=Black guibg=LightGray
hi Search term=reverse ctermfg=Black ctermbg=Yellow gui=NONE guifg=Black guibg=Yellow
hi Tag term=bold ctermfg=LightBlue guifg=#0064c8
hi Error term=reverse ctermfg=15 ctermbg=9 guibg=Red guifg=White
hi Todo term=standout ctermbg=Yellow ctermfg=Black guifg=White guibg=Red
hi StatusLine term=bold,reverse cterm=NONE ctermfg=White ctermbg=Black gui=NONE guifg=White guibg=Black
hi StatusLineNC term=bold,reverse cterm=NONE ctermfg=White ctermbg=Black gui=NONE guifg=LightGray guibg=DarkGray
hi Ignore term=bold,reverse cterm=NONE ctermfg=LightGray ctermbg=White gui=NONE guifg=DarkGray guibg=White
hi! link MoreMsg Comment
hi! link ErrorMsg Visual
hi! link WarningMsg ErrorMsg
hi! link Question Comment
hi link String	Constant
hi link Character	Constant
hi link Number	Constant
hi link Boolean	Constant
hi link Float		Number
hi link Function	Identifier
hi link Conditional	Statement
hi link Repeat	Statement
hi link Label		Statement
hi link Operator	Statement
hi link Keyword	Statement
hi link Exception	Statement
hi link Include	PreProc
hi link Define	PreProc
hi link Macro		PreProc
hi link PreCondit	PreProc
hi link StorageClass	Type
hi link Structure	Type
hi link Typedef	Type
hi link SpecialChar	Special
hi link Delimiter	Special
hi link SpecialComment Special
hi link Debug		Special
