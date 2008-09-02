" Stefans a2l-file plugin

" don't use spaces for tabs
setlocal expandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal formatoptions=croq
setlocal syntax=a2l

" commenting
let b:commentstring = '//'

" Grep options
"let b:GrepFiles = '*.py'

" matchit.vim
let b:match_words = '/begin\>:/end\>'

