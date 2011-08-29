" defaults for gcc
unlet current_compiler
execute('source ' . $VIMRUNTIME . '/compiler/gcc.vim')

" add german text
"set errorformat+=%D%*\\a[%*\\d]:\ Wechsel\ in\ das\ Verzeichnis\ »%f«
"set errorformat+=%X%*\\a[%*\\d]:\ Verlassen\ des\ Verzeichnisses\ »%f«

" defaults for python
"let s:shellpipe_save = &shellpipe
"let s:makeprg_save = &makeprg
"unlet current_compiler
"execute('source ' . g:vimsuite . '/vimfiles.stefan/compiler/python.vim')
"let &shellpipe = s:shellpipe_save
"let &makeprg = s:makeprg_save
"unlet s:shellpipe_save
"unlet s:makeprg_save

" -------
" PC-Lint
" -------
"set errorformat+=\"%f\"\\,\ line\ %l:\ %t%.%#\ \(pclint:%n\):%m
"set errorformat+=%t%.%#\ \(pclint:%n\):%m
" -------
" SP-Lint
" -------
set errorformat+=%A%f\(%l\):\ %m
set errorformat+=%A%f\(%l\):
set errorformat+=%A%f\(%l\\,%c\):\ %m
set errorformat+=%A%f\(%l\\,%c\):
set errorformat+=%C\ \ \ \ %m

" -----
" Tools
" -----
set errorformat+=%+G%.%#.exe:\ %m
set errorformat+=%+G%.%#.exe[%*\\d]:\ ***\ %m

" Error format from other programs: ...: ...
"set errorformat+=%+G%f:\ %m

let current_compiler = 'gcc-special'
