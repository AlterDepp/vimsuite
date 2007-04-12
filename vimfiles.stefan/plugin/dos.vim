" ===========================================================================
"        File: dos.vim
"      Author: Stefan Liebl (S.Liebl@gmx.de)
" Description: sources mswin.vim if the os is mswin
" ===========================================================================

if (g:os == 'dos')
    runtime mswin.vim
    behave mswin
endif

