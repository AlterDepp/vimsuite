" Vim Global Plugin for Editing .srec Files
" Maintainer: Alexander Fleck
"            <alexander.fleck@gmx.net>
" License:    This File is placed in the Public Domain.
" Revision | Date [DD.MM.YY] | Changes
" 00.01.00 |       05.07.09  | 01. Revision
" 00.01.10 |                 | -
" 00.02.00 |       29.03.10  | Fun added, MakeSrecS5()
" 00.02.10 |                 | -
" 00.02.20 |       15.11.12  | Fun added, MakeSrecSet()

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

" M0
" M1
" M2
" M3
" M4
" M5 = MakeS5
if !hasmapto('<Plug>MakeSrecLineS5')
  map <unique> <Leader>m5 <Plug>MakeSrecLineS5
endif
noremap <unique> <script> <Plug>MakeSrecLineS5 <SID>MakeSrecS5
noremap <SID>MakeSrecS5 <Esc>:call <SID>MakeSrecS5()<CR>
" M6
" M7
" M8
" M9

" MS = MakeSet
if !hasmapto('<Plug>MakeSet')
  map <unique> <Leader>ms <Plug>MakeSet
endif
noremap <unique> <script> <Plug>MakeSet <SID>MakeSrecSet
noremap <SID>MakeSrecSet <Esc>:call <SID>MakeSrecSet()<CR>

" Functions
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

" make S5 record
fun s:MakeSrecS5()
  let s:ln = getline(".")
  
  let s:ln = s:ln . libsrec#MkS5(s:ln)
  
  call setline(".", s:ln)
  
  unlet s:ln
endfun

" make srec set
fun s:MakeSrecSet()
  " Dict for Type of Record
  let s:dict = { 2: "S1",
               \ 3: "S2",
               \ 4: "S3" }
  
  let s:ln = getline(".")
  
  call inputsave()
  let s:nodl = input('Num of Data-Lines: ')
  call inputrestore()
  call inputsave()
  let s:nodb = input('Num of Data-Bytes: ')
  call inputrestore()
  
  call inputsave()
  let s:noab = input('Num of Addr-Bytes: ')
  call inputrestore()
  
  call inputsave()
  let s:atad = input('at Addr: ')
  call inputrestore()
  
  " check for valid Range, Type of Record
  if ((s:noab > 1) && (s:noab < 5))
    let s:tosr = s:dict[s:noab]
  else
    let s:tosr = ""
    " bypass the Loop below
    let s:nodl = 0
  endif
  
  " Cntr of Data Lines
  let s:dlct = s:nodl
  while s:dlct > 0
    " get Cursor Line
    let s:cl = line(".")
    " append Line with Type
    call append(".", s:tosr)
    call cursor(s:cl + 1, 1)
    
    let s:ln = getline(".")
    
    " create ByteCount
    "-----------------------------------
    " calc Input for ByteCount
    let s:hxin = s:nodb + s:noab + 1
    " convert to Hex Value,
    "            Hex String without "0x"
    let s:hxva = "0123456789ABCDEF"
    let s:srbc = ""
    while s:hxin
      let s:srbc = s:hxva[s:hxin % 16] . s:srbc
      let s:hxin = s:hxin        / 16
    endwhile
    
    " add missing Zeros
    while strlen(s:srbc) < 2
      let s:srbc = "0" . s:srbc
    endwhile
    " Exception Handling
    if strlen(s:srbc) > 2
      " check Number of ByteCount Bytes
      let s:srbc = "__cNBB__"
    endif
    
    let s:ln = s:ln . s:srbc
    "-----------------------------------
    
    " create Addr, but with running Vals
    "-----------------------------------
    " calc Input for Addr
    let s:hxin = s:atad + ((s:nodl - s:dlct) * s:nodb)
    " convert to Hex Value,
    "            Hex String without "0x"
    let s:hxva = "0123456789ABCDEF"
    let s:srad = ""
    while s:hxin
      let s:srad = s:hxva[s:hxin % 16] . s:srad
      let s:hxin = s:hxin        / 16
    endwhile
    
    " add missing Zeros
    while strlen(s:srad) < (2 * s:noab)
      let s:srad = "0" . s:srad
    endwhile
    " Exception Handling
    if strlen(s:srad) > (2 * s:noab)
      " check Number of Address Bytes
      let s:srad = "__cNAB__"
    endif
    
    let s:ln = s:ln . s:srad
    "-----------------------------------
    let s:ln = s:ln . libsrec#CrDA(s:ln)
    let s:ln = s:ln . libsrec#CrCS(s:ln)
    
    call setline(".", s:ln)
    let s:dlct = s:dlct - 1
    
    unlet s:srad
    unlet s:srbc
    unlet s:hxva
    unlet s:hxin
    unlet s:cl
  endwhile
  
  unlet s:dlct
  unlet s:tosr
  unlet s:atad
  unlet s:noab
  unlet s:nodb
  unlet s:nodl
  unlet s:ln
  unlet s:dict
endfun

let &cpo = s:save_cpo

