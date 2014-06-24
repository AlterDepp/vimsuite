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

"setlocal cindent


" Set 'formatoptions' to break comment lines but not other lines,
" and insert the comment leader when hitting <CR> or using "o".
setlocal fo-=t fo+=croql

" Set 'comments' to format dashed lists in comments.
"setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://

setlocal syntax=uc

setlocal tabstop=8

" Grep options
let b:GrepFiles = '*.uc'
