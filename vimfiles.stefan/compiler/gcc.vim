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
"setlocal errorformat+=\"%f\"\\,\ line\ %l:\ %t%.%#\ \(pclint:%n\):%m
"setlocal errorformat+=%t%.%#\ \(pclint:%n\):%m
" -------
" SP-Lint
" -------
setlocal errorformat+=%A%f\(%l\):\ %m
setlocal errorformat+=%A%f\(%l\):
setlocal errorformat+=%A%f\(%l\\,%c\):\ %m
setlocal errorformat+=%A%f\(%l\\,%c\):
setlocal errorformat+=%C\ \ \ \ %m

" -----
" Tools
" -----
setlocal errorformat+=%+G%.%#.exe:\ %m

" Error format from other programs: ...: ...
"setlocal errorformat+=%+G%f:\ %m

let current_compiler = 'gcc-special'
