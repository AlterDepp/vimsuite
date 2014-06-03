@echo off
setlocal
set vimdir=%~dp0..\..\..
set vimprg=%vimdir%\vim74\gvim.exe
set vimscript=%~dp0gvimmerge.vim
set base=%1
set mine=%2
set theirs=%3
set merged=%4

if not exist %vimprg% (
  echo gvim.exe nicht gefunden
)

set cmd=%vimprg% -f -R %base% %mine% %theirs% %merged% -S %vimscript%
echo %cmd%
%cmd%
