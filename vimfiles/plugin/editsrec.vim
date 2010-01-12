" Vim Global Plugin for Editing .srec Files
" Maintainer: Alexander Fleck
"            <alexander.fleck@gmx.net>
" License:    This File is placed in the Public Domain.
" Revision | Date [DD.MM.YY] | Changes
" 00.01.00 |       05.07.09  | 01. Revision

if exists("loaded_editsrec")
  finish
endif
let loaded_editsrec = 1

let s:save_cpo = &cpo
set cpo&vim

" BC = ByteCount
if !hasmapto('<Plug>EditSrecLineBC')
  map <unique> <Leader>lb <Plug>EditSrecLineBC
endif
noremap <unique> <script> <Plug>EditSrecLineBC <SID>AutoLineBC
noremap <SID>AutoLineBC <Esc>:call <SID>AutoLineBC()<CR>
if !hasmapto('<Plug>EditSrecPartBC')
  map <unique> <Leader>pb <Plug>EditSrecPartBC
endif
noremap <unique> <script> <Plug>EditSrecPartBC <SID>AutoPartBC
noremap <SID>AutoPartBC <Esc>:call <SID>AutoPartBC()<CR>

" AD = ADdress
if !hasmapto('<Plug>EditSrecLineAD')
  map <unique> <Leader>la <Plug>EditSrecLineAD
endif
noremap <unique> <script> <Plug>EditSrecLineAD <SID>AutoLineAD
noremap <SID>AutoLineAD <Esc>:call <SID>AutoLineAD()<CR>
if !hasmapto('<Plug>EditSrecPartAD')
  map <unique> <Leader>pa <Plug>EditSrecPartAD
endif
noremap <unique> <script> <Plug>EditSrecPartAD <SID>AutoPartAD
noremap <SID>AutoPartAD <Esc>:call <SID>AutoPartAD()<CR>

" DA = DAta
if !hasmapto('<Plug>EditSrecLineDA')
  map <unique> <Leader>ld <Plug>EditSrecLineDA
endif
noremap <unique> <script> <Plug>EditSrecLineDA <SID>AutoLineDA
noremap <SID>AutoLineDA <Esc>:call <SID>AutoLineDA()<CR>
if !hasmapto('<Plug>EditSrecPartDA')
  map <unique> <Leader>pd <Plug>EditSrecPartDA
endif
noremap <unique> <script> <Plug>EditSrecPartDA <SID>AutoPartDA
noremap <SID>AutoPartDA <Esc>:call <SID>AutoPartDA()<CR>

" CS = CheckSum
if !hasmapto('<Plug>EditSrecLineCS')
  map <unique> <Leader>lc <Plug>EditSrecLineCS
endif
noremap <unique> <script> <Plug>EditSrecLineCS <SID>AutoLineCS
noremap <SID>AutoLineCS <Esc>:call <SID>AutoLineCS()<CR>
if !hasmapto('<Plug>EditSrecPartCS')
  map <unique> <Leader>pc <Plug>EditSrecPartCS
endif
noremap <unique> <script> <Plug>EditSrecPartCS <SID>AutoPartCS
noremap <SID>AutoPartCS <Esc>:call <SID>AutoPartCS()<CR>

" obsolete Mappings
"imap <F5>    <Esc>:call <SID>AutoLineBC()<CR>a
"imap <F6>    <Esc>:call <SID>AutoLineAD()<CR>a
"imap <F7>    <Esc>:call <SID>AutoLineDA()<CR>a
"imap <F8>    <Esc>:call <SID>AutoLineCS()<CR>a
"imap <C-F5>  <Esc>:call <SID>AutoPartBC()<CR>a
"imap <C-F6>  <Esc>:call <SID>AutoPartAD()<CR>a
"imap <C-F7>  <Esc>:call <SID>AutoPartDA()<CR>a
"imap <C-F8>  <Esc>:call <SID>AutoPartCS()<CR>a

" create Line from ByteCount
fun s:AutoLineBC()
  let s:ln = getline(".")
  
  let s:ln = s:ln . libsrec#CrBC(s:ln)
  let s:ln = s:ln . libsrec#CrAD(s:ln)
  let s:ln = s:ln . libsrec#CrDA(s:ln)
  let s:ln = s:ln . libsrec#CrCS(s:ln)
  
  call setline(".", s:ln)
  
  unlet s:ln
endfun

" create only ByteCount
fun s:AutoPartBC()
  let s:ln = getline(".")
  
  let s:ln = s:ln . libsrec#CrBC(s:ln)
  
  call setline(".", s:ln)
  
  unlet s:ln
endfun

" create Line from ADdress
fun s:AutoLineAD()
  let s:ln = getline(".")
  
  let s:ln = s:ln . libsrec#CrAD(s:ln)
  let s:ln = s:ln . libsrec#CrDA(s:ln)
  let s:ln = s:ln . libsrec#CrCS(s:ln)
  
  call setline(".", s:ln)
  
  unlet s:ln
endfun

" create only ADdress
fun s:AutoPartAD()
  let s:ln = getline(".")
  
  let s:ln = s:ln . libsrec#CrAD(s:ln)
  
  call setline(".", s:ln)
  
  unlet s:ln
endfun

" create Line from DAta
fun s:AutoLineDA()
  let s:ln = getline(".")
  
  let s:ln = s:ln . libsrec#CrDA(s:ln)
  let s:ln = s:ln . libsrec#CrCS(s:ln)
  
  call setline(".", s:ln)
  
  unlet s:ln
endfun

" create only DAta
fun s:AutoPartDA()
  let s:ln = getline(".")
  
  let s:ln = s:ln . libsrec#CrDA(s:ln)
  
  call setline(".", s:ln)
  
  unlet s:ln
endfun

" create Line from CheckSum
fun s:AutoLineCS()
  let s:ln = getline(".")
  
  let s:ln = s:ln . libsrec#CrCS(s:ln)
  
  call setline(".", s:ln)
  
  unlet s:ln
endfun

" create only CheckSum
fun s:AutoPartCS()
  let s:ln = getline(".")
  
  let s:ln = s:ln . libsrec#CrCS(s:ln)
  
  call setline(".", s:ln)
  
  unlet s:ln
endfun

let &cpo = s:save_cpo

