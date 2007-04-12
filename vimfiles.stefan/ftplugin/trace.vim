" Vim filetype plugin file
" Language:	TPU-Micro-Code for Motorola-Processor
" Maintainer:	Stefan Liebl <S.Liebl@gmx.de>
" Last Change:	22003 Apr 8

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

" ----
" TABS
" ----
setlocal expandtab
setlocal shiftwidth=4

setlocal formatoptions=croq

" commenting
let b:commentstring = ';'

setlocal syntax=trace
