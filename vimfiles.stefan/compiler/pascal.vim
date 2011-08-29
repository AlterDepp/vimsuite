" Vim compiler file
" Compiler:		gnu pascal compiler gpc
" Maintainer:	Stefan Liebl
" Last Change:	01.09.2002 

if exists("current_compiler")
  finish
endif
let current_compiler = "pascal"


"let &makeprg = "\\tools\\python\\v2.1a2\\python %:p"
"set shellpipe=2>

"set errorformat+=%E%\\s%#File\ \"%f\"\\,\ line\ %l\\,\ %m
"set errorformat+=%C%m
"set errorformat+=%Z%.%#Error:\ %m

command! Make cd %:p:h | make
command! Clean cd %:p:h | make clean
command! Build cd %:p:h | make build
command! Run cd %:p:h | make run
"command! Compile !gpc --borland-pascal -Wall -W %:p -o %:p:r
command! Compile !ppc386 -Sp -vwnh -o%:p:r %:p
command! RunObject !%:p:r

