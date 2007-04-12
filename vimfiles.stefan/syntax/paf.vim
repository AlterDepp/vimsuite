" Vim syntax file
" Language:     Motorola S record
" Maintainer:   slimzhao <vim2004@21cn.com>
" Last Change:  2004 May 31
" License:      This file is placed in the public domain.

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case ignore

" storage types

syn match srecChecksum  /\x\{2}\r\?$/ contained
syn match LineType  /^:\x\{2}/ contained
syn match Addr  /\%4c\x\{4}/ contained
syn match AddrOffset  /\%10c\x\{4}/ contained
syn match RecordType  /\%8c\x\{2}/ contained
syn match NormalRecord  /^:10\x\{40}/ contained contains=LineType,Addr,RecordType,srecChecksum
syn match ExtendedRecord  /^:02\x\{12}/ contained contains=LineType,RecordType,AddrOffset,srecChecksum
syn match OtherRecord  /^:\x\{15,39}$/ contained contains=LineType,Addr,RecordType,srecChecksum
syn match Record  /^:\x\+/ contains=NormalRecord,ExtendedRecord,OtherRecord

syn case match

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_srec_syntax_inits")
  if version < 508
    let did_srec_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink Record         Normal
  HiLink NormalRecord   Normal
  HiLink ExtendedRecord Normal
  HiLink RecordType     Special
  HiLink Addr           Constant
  HiLink AddrOffset     Constant
  "Checksum
  HiLink srecChecksum   Search
  "Record type
  HiLink LineType       Comment

  delcommand HiLink
endif

let b:current_syntax = "paf"

" vim: ts=8
