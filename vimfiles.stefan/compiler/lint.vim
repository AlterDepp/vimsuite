" Vim compiler file
" Compiler:		lint
" Maintainer:	Stefan Liebl
" Last Change:	13.06.2002 

"if exists('current_compiler')
"  finish
"endif
"let current_compiler = 'bcc'


let &makeprg = PathJoin(GetBmskDir() . ', lint_bmsk.bat') . ' ' . GetDfilesDir() . ' $*'
"set shellpipe=>
"let &shellpipe = '| e:\\tools\\gnu\\shutils\\bin\\tee.exe'
"let &shellpipe = '| e:\\tools\\gnu\\shutils\\bin\\tee.exe ' . make_log . ' | e:\\tools\\gnu\\shutils\\bin\\tee.exe'
set shellpipe=
let &makeef = PathJoin(GetBmskDir() . ', lint_bmsk.txt')

set errorformat=
set errorformat+=%f\ %l:\ %trror\ %n\ %m
set errorformat+=%f\ %l:\ %tarning\ %n\ %m
set errorformat+=%f\ %l:\ %tnfo\ %n\ %m
set errorformat+=%f\ %l:\ %tote\ %n\ %m

let biosdirs  = ''
let biosdirs = biosdirs . ' ' . PathJoin(bmsk_bios . ', adc')
let biosdirs = biosdirs . ' ' . PathJoin(bmsk_bios . ', dio')
"let biosdirs = biosdirs . ' ' . PathJoin(bmsk_bios . ', edc16lib')
let biosdirs = biosdirs . ' ' . PathJoin(bmsk_bios . ', pm')
"let biosdirs = biosdirs . ' ' . PathJoin(bmsk_bios . ', stflprg')
let biosdirs = biosdirs . ' ' . PathJoin(bmsk_bios . ', target')
let biosdirs = biosdirs . ' ' . PathJoin(bmsk_bios . ', tio')
"let biosdirs = biosdirs . ' ' . PathJoin(bmsk_bios . ', tpu_bms')
let biosdirs = biosdirs . ' ' . PathJoin(bmsk_bios . ', tpu_lib_export')
let biosdirs = biosdirs . ' ' . PathJoin(bmsk_bios . ', uhwe')
" user functions 
"command! -nargs=* Compile execute ':wa | cd ' . GetBmskDir() . ' | make! %:p'
command! -nargs=* Compile  wa | execute('cd ' . GetBmskDir()) | make! <args> %:p
command! -nargs=* Make     wa | execute('cd ' . GetBmskDir()) | make! <args> %:p:h
command! -nargs=* MakeBios execute ':wa | cd ' . GetBmskDir() . ' | make! <args> ' . biosdirs

