%echo off
set vim=%~dp0..\..\..\vim74\gvim.exe
set base=%1
set mine=%2
set theirs=%3
set merged=%4

if not exist %vim% (
  echo gvim.exe nicht gefunden
)
echo %vim% %base% %mine% %theirs% %merged%
