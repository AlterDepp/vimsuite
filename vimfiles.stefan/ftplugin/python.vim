" Stefans python-file plugin

" don't use spaces for tabs
setlocal noexpandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal formatoptions=croq

setlocal tags+=/usr/lib/python/tags
" commenting
let b:commentstring = '#'

" Grep options
let b:GrepFiles = '*.py'
