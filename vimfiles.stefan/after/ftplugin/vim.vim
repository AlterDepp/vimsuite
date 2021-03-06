" Stefans vim-file plugin

" ----
" TABS
" ----
setlocal expandtab
setlocal shiftwidth=4
setlocal softtabstop=4

setlocal formatoptions=croq

" vimfiles sollen immer im unix-Format gespeichert werden
if &modifiable
    setlocal fileformat=unix
endif

" commenting
let b:commentstring = '"'

" Grep options
let b:GrepFiles = '*.vim'
