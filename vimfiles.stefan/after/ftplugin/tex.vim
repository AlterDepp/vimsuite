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
    silent! execute '%s/"a/ä'
    silent! execute '%s/"o/ö'
    silent! execute '%s/"u/ü'
    silent! execute '%s/"A/Ä'
    silent! execute '%s/"O/Ö'
    silent! execute '%s/"U/Ü'
    silent! execute '%s/"s/ß'
endfunction

function! Ascii2Tex()
    silent! execute '%s/ä/"a'
    silent! execute '%s/ö/"o'
    silent! execute '%s/ü/"u'
    silent! execute '%s/Ä/"A'
    silent! execute '%s/Ö/"O'
    silent! execute '%s/Ü/"U'
    silent! execute '%s/ß/"s'
endfunction
