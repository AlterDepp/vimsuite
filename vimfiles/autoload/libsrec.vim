" Vim Library for Editing .srec Files
" Maintainer: Alexander Fleck
"            <alexander.fleck@gmx.net>
" License:    This File is placed in the Public Domain.
" Revision | Date [DD.MM.YY] | Changes
" 00.01.00 |       05.07.09  | 01. Revision
" 00.01.10 |       29.03.10  | BugFix, in libsrec#CrCS()
"          |                 | leading Zeros in Result
" 00.02.00 |       29.03.10  | Fun added, MkS5()
" 00.02.10 |       15.06.10  | BugFix, in libsrec#CrCS()
"          |                 | wrong Source for CS

" create ByteCount
fun libsrec#CrBC(line)
  let s:byco = ""
  
  " Dictionary with Assumptions
  let s:dict = { 0: '0F',
               \ 1: '0F',
               \ 2: '0F',
               \ 3: '0F',
               \ 4: ''  ,
               \ 5: '03',
               \ 6: ''  ,
               \ 7: '05',
               \ 8: '04',
               \ 9: '03' }
  
  let s:byco = s:dict[a:line[1]]
  
  unlet s:dict
  "unlet s:byco
  return s:byco
endfun

" create ADdress
fun libsrec#CrAD(line)
  let s:adrs = ""
  " Number of Bytes for Address
  let s:adby = ""
  " Dictionary
  let s:dict = { 0: 2,
               \ 1: 2,
               \ 2: 3,
               \ 3: 4,
               \ 4: 0,
               \ 5: 2,
               \ 6: 0,
               \ 7: 4,
               \ 8: 3,
               \ 9: 2 }
  
  let s:adby = s:dict[a:line[1]]
  
  let s:n = 0
  while 1
    let s:n = s:n + 1
    if s:n > s:adby
      break
    endif
    let s:adrs = s:adrs . "00"
    continue
  endwhile
  unlet s:n
  
  unlet s:dict
  unlet s:adby
  "unlet s:adrs
  return s:adrs
endfun

" create DAta
fun libsrec#CrDA(line)
  let s:data = ""
  " Number of Bytes for Data
  let s:daby = ""
  
  " get ByteCount from Line
  let s:bchx = "0x" . a:line[2] . a:line[3]
  " Dictionary
  let s:dict = { 0: s:bchx - 3,
               \ 1: s:bchx - 3,
               \ 2: s:bchx - 4,
               \ 3: s:bchx - 5,
               \ 4: 0         ,
               \ 5: 0         ,
               \ 6: 0         ,
               \ 7: 0         ,
               \ 8: 0         ,
               \ 9: 0          }
  
  let s:daby = s:dict[a:line[1]]
  
  let s:n = 0
  while 1
    let s:n = s:n + 1
    if s:n > s:daby
      break
    endif
    let s:data = s:data . "FF"
    continue
  endwhile
  unlet s:n
  
  unlet s:dict
  unlet s:bchx
  unlet s:daby
  "unlet s:data
  return s:data
endfun

" create CheckSum
fun libsrec#CrCS(line)
  " CheckSum as a String
  let s:chsu = ""
  
  " get ByteCount from Line
  let s:bchx = "0x" . a:line[2] . a:line[3]
  
  if ((a:line[1] == "4") || (a:line[1] == "6"))
    " there' s no S4 or S6
  else
    " CheckSum as a Value
    let s:csby = 0
    
    " add the Byte Values
    let s:n = 0
    while 1
      let s:n = s:n + 1
      if s:n > s:bchx
        break
      endif
      let s:csby = s:csby + ("0x" . a:line[2*s:n] . a:line[2*s:n+1])
      continue
    endwhile
    unlet s:n
    
    " CheckSum is:
    let s:csby = 255 - (s:csby % 256)
    
    " convert to Hex Value,
    "            Hex String without "0x"
    let s:hxva = "0123456789ABCDEF"
    while s:csby
      let s:chsu = s:hxva[s:csby % 16] . s:chsu
      let s:csby = s:csby        / 16
    endwhile
    
    " add missing Zeros
    while strlen(s:chsu) < 2
      let s:chsu = "0" . s:chsu
    endwhile
    " Exception Handling
    if strlen(s:chsu) > 2
      let s:chsu = "CS"
    endif
    
    unlet s:hxva
    unlet s:csby
  endif
  
  unlet s:bchx
  "unlet s:chsu
  return s:chsu
endfun

" make S5 record
fun libsrec#MkS5(line)
  let s:srec = ""
  let s:line = ""
  let s:srco = 0
  let s:srad = ""
  
  let s:srec = s:srec . "S5" . "03"
  
  let s:n = 1
  while (line2byte(s:n) != line2byte("."))
    let s:line = getline(s:n)
    if ((s:line[0] == "S") && ((s:line[1] == "1") || (s:line[1] == "2") || (s:line[1] == "3")))
      let s:srco = s:srco + 1
    endif
    let s:n = s:n + 1
  endwhile
  unlet s:n
  
  " convert to Hex Value,
  "            Hex String without "0x"
  let s:hxva = "0123456789ABCDEF"
  while s:srco
    let s:srad = s:hxva[s:srco % 16] . s:srad
    let s:srco = s:srco        / 16
  endwhile
  
  " add missing Zeros
  while strlen(s:srad) < 4
    let s:srad = "0" . s:srad
  endwhile
  " Exception Handling
  if strlen(s:srad) > 4
    let s:srad = "AAAA"
  endif
  
  unlet s:hxva
  
  let s:srec = s:srec . s:srad . libsrec#CrCS(s:srec . s:srad)
  
  unlet s:srad
  unlet s:srco
  unlet s:line
  "unlet s:srec
  return s:srec
endfun

