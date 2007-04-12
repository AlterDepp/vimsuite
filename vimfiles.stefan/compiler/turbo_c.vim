" Vim compiler file
" Compiler:	borland turbo C compiler
" Maintainer:	Stefan Liebl
" Last Change:	08.07.2003 

"if exists('current_compiler')
"  finish
"endif
"let current_compiler = 'tc'


let &l:makeprg = 'u:\daten\priv\c_files\tcc.bat $*'
setlocal shellpipe=>
"let &makeef = bmskdir . '\lint_bmsk.txt'

setlocal errorformat=
setlocal errorformat+=%trror\ %f\ %l:\ %m
setlocal errorformat+=%tarning\ %f\ %l:\ %m

" user functions 
"command! -nargs=0 Compile execute ':wa | make! %:p'
command! -nargs=0 Make execute 'wa | make %:p'
command! -nargs=0 Run  execute '!c:\temp\turbo-c\' . expand('%:t:r') . '.exe'

