" Stefans c-file plugin for bmsk

" abbreviations
"iabbrev if if ()<left>

" ----
" TABS
" ----
" tab width
let s:tabwidth = 4
let &l:tabstop = s:tabwidth
" spaces for tabs
"let &softtabstop = s:tabwidth
" smart indent tabs (use spaces for indent else tabs)
"set smarttab
" use spaces for tabs
setlocal expandtab

" autoindent
" indent mode - one of autoindent, smartindent or cindent
" set autoindent
" set smartindent
setlocal cindent
setlocal cinoptions=*200,)100,(s,w1,W4
let &l:shiftwidth = s:tabwidth
"setlocal formatoptions=croqwl

if (g:os == 'linux')
    setlocal tags+=/usr/include/tags
    setlocal tags+=/usr/X11/include/tags
    setlocal tags+=/usr/src/include/linux/tags

    " filesearching
    setlocal path=.,/usr/include/**
endif
setlocal suffixesadd=.h

" commenting
" ----------
let b:commentstring = "\/\/"

" Set 'comments' to format dashed lists in comments.
"setlocal comments=sO:*\ -,mO:\ \ \ ,exO:*/,s1:/*,mb:\ ,ex:*/
setlocal cpoptions-=C

" spell check
setlocal spell

" Grep options
let b:GrepFiles = '*.c *.h'

" matchit.vim
let b:match_words = '\<lint\s\+-save\>:\<lint\s\+-restore\>'

" Adding spaces where needed
" --------------------------
let s:nonOperator = '[^=!+-\*/<>]'
let s:nonOperatorNonSpace = '[^ =!+-\*/<>]'
let s:noSpaceNoEol = '.'
let s:noWord = '.'
function! AddSpaceBeforeOperator(pattern)
    execute '%substitute@' .
                \ '\(' . s:nonOperatorNonSpace . '\)' .
                \ '\(' . a:pattern . '\)' .
                \ '\(' . s:nonOperator . '\)' .
                \ '@\1 \2\3@ec'
endfunction
function! AddSpaceAfterOperator(pattern)
    execute '%substitute@' .
                \ '\(' . s:nonOperator . '\)' .
                \ '\(' . a:pattern . '\)' .
                \ '\(' . s:nonOperatorNonSpace . '\)'
                \ '@\1\2 \3@c'
endfunction
function! AddSpaceAroundOperator(pattern)
    call AddSpaceBeforeOperator(a:pattern)
    call AddSpaceAfterOperator(a:pattern)
endfunction

function! AddSpaceAfter(pattern)
    execute '%substitute@' .
                \ '\(' . s:noWord . '\)'
                \ '\(' . a:pattern . '\)' .
                \ '\(' . s:noSpaceNoEol . '\)'
                \ '@\1\2 \3@c'
endfunction

command! ReformatCSpaces call ReformatCSpaces()
function! ReformatCSpaces()
"    call AddSpaceAroundOperator('=')
"    call AddSpaceAroundOperator('+')
"    call AddSpaceAroundOperator('-')
"    call AddSpaceAroundOperator('\*')
"    call AddSpaceAroundOperator('/')
"    call AddSpaceAroundOperator('==')
"    call AddSpaceAroundOperator('!=')
"    call AddSpaceAroundOperator('+=')
"    call AddSpaceAroundOperator('-=')
"    call AddSpaceAroundOperator('\*=')
"    call AddSpaceAroundOperator('/=')
"    call AddSpaceAroundOperator('<=')
"    call AddSpaceAroundOperator('>=')
    call AddSpaceAfter('if')
endfunction
