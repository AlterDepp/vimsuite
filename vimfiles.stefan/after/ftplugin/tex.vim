" Stefans vim-file plugin

" Add Menu-Bar
setlocal guioptions+=m

" benutze Makefile
let g:Tex_UseMakefile = 1
let g:Tex_CompileRule_dvi = 'make $*'

" ----
" TABS
" ----
setlocal noexpandtab
setlocal shiftwidth=4
setlocal expandtab
setlocal tabstop=4

" formatting
setlocal formatoptions=tcroq

" folding
setlocal nofoldenable

" spell check
setlocal spell

" commenting
let b:commentstring = '%'

" Grep options
let b:GrepFiles = '*.tex'

" Umlaute
command! Tex2Ascii call Tex2Ascii()
command! Ascii2Tex call Ascii2Tex()

function! Tex2Ascii()
    silent! execute '%s/"a/�'
    silent! execute '%s/"o/�'
    silent! execute '%s/"u/�'
    silent! execute '%s/"A/�'
    silent! execute '%s/"O/�'
    silent! execute '%s/"U/�'
    silent! execute '%s/"s/�'
endfunction

function! Ascii2Tex()
    silent! execute '%s/�/"a'
    silent! execute '%s/�/"o'
    silent! execute '%s/�/"u'
    silent! execute '%s/�/"A'
    silent! execute '%s/�/"O'
    silent! execute '%s/�/"U'
    silent! execute '%s/�/"s'
endfunction
