" Vim compiler file
" Compiler:     python
" Maintainer:   Stefan Liebl
" Last Change:  13.06.2002

if exists('current_compiler')
    finish
endif
let current_compiler = 'python'



let &makeprg = 'python %:p'
"set shellpipe=>
set shellpipe=2>
"let &shellpipe = '|' PathNormpath('e:/tools/gnu/shutils/bin/tee.exe')
"let &shellpipe = '|' PathNormpath('e:/tools/gnu/shutils/bin/tee.exe')
"            \ PathNormpath(make_log) '|' PathNormpath('e:/tools/gnu/shutils/bin/tee.exe')

" set errorformat to default-value
set errorformat&
"set errorformat=

"set errorformat=%ATraceback%.%#
"set errorformat+=%C%\\s%#File\ \"%f\"\\,\ line\ %l\\,\ %m
"set errorformat+=%C%m
"set errorformat+=Z%.%#Error:\ %m

set errorformat+=%E%\\s%#File\ \"%f\"\\,\ line\ %l\\,\ %m
set errorformat+=%C%m
set errorformat+=%Z%.%#Error:\ %m

set errorformat+=%E%\\s%#File\ \"<string>\"\\,\ line\ %l
set errorformat+=%C%m
set errorformat+=%-C\ %p^
set errorformat+=%Z%.%#Error:\ %m

