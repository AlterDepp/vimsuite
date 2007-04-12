
if exists("current_compiler")
  finish
endif
let current_compiler = "java"


"let &makeprg = "/usr/java/current/bin/javac %:p"
"setlocal shellpipe=2>

"set errorformat+=%E%\\s%#File\ \"%f\"\\,\ line\ %l\\,\ %m
"set errorformat+=%C%m
"set errorformat+=%Z%.%#Error:\ %m

command! Make cd %:p:h | make
command! Clean cd %:p:h | make clean
command! Build cd %:p:h | make build
command! Run cd %:p:h | make run
command! Compile !/usr/java/current/bin/javac %:p
command! RunObject !%:p:r

