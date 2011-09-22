@echo off
set a=%1
set b=%2

:: remove ""
set a=%a:"=%
set b=%b:"=%
:: escape space
set a=%a: =\ %
set b=%b: =\ %

echo on
"c:\Program Files (x86)\vim\vim73\gvim.exe" -c "DirDiff %a% %b%"
