" Vim compiler file
" Compiler:     python
" Maintainer:   Stefan Liebl
" Last Change:  13.06.2002

if exists("current_compiler")
    finish
endif
let current_compiler = "python"


"let &makeprg = g:python . ' -c "import py_compile,sys; sys.stderr=sys.stdout; py_compile.compile(%:p)\"'
"let &makeprg = g:python . ' -c "import py_compile; py_compile.compile(r\'%\')"'
set makeprg=python\ -c\ \"import\ py_compile;\ py_compile.compile('%')\"
"let &makeprg = g:python . ' -c "print \"hallo welt\"; print \"ende\""'

setlocal shellpipe=2>

set errorformat+=%E%\\s%#File\ \"%f\"\\,\ line\ %l\\,\ %m
set errorformat+=%C%m
set errorformat+=%Z%.%#Error:\ %m

set errorformat+=%E%\\s%#File\ \"<string>\"\\,\ line\ %l
set errorformat+=%C%m
set errorformat+=%-C\ %p^
set errorformat+=%Z%.%#Error:\ %m

