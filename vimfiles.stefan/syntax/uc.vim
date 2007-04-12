" Vim syntax file
" Language:	Motorola TPU Microcode
" Maintainer:	Stefan Liebl <S.Liebl@gmx.de>
" URL:		ftp://ftp.
" Credits:	Based on the java.vim syntax file by Claudio Fleiner
" Last change:	2003 Apr 8

" Please check :help uc.vim for comments on some of the options available.

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" we define it here so that included files can test for it
if !exists("main_syntax")
  let main_syntax='tpu'
endif

" keyword definitions
syn keyword tpuConditional      if then
syn keyword tpuRepeat           repeat
"syn keyword tpuMacro            macro
syn keyword tpuEntryDef         start_address name cond end disable_match return
syn keyword tpuHsr              hsr0 hsr1
syn keyword tpuRegs             tsr lsr tbs p pac pin ccl C Z P A N SR ERT DIOB P_High P_Low P_high P_low TCR1
syn keyword tpuFlags            flag1 flag2 Flag0 Flag1 Flag2
syn keyword tpuBranch           goto call
syn keyword tpuChan             chan
syn keyword tpuSetValue         set clear high low Low High max nil no_change
syn keyword tpuSet              write_mer enable_mtsr neg_mrl neg_lsl neg_tdl out_m1_c1 match_gte
syn keyword tpuSetExpr          ram au shift no_flush flush
syn keyword tpuIsr              cir

syn match   tpuOperator         "\(:=\)\|\(=\)\|\(<-\)\|\(->\)\|\(>>\)\|[+-]"
syn match   tpuEOS              "[.,;:]\(\s\|\n\)"
syn match   tpuSeperator        "[.,;:]"

syn cluster tpuRegister contains=tpuFlags,tpuRegs
hi link     tpuRegs             tpuRegister
hi link     tpuFlags            tpuRegister
hi link     tpuSetValue         tpuSet
hi link     tpuSetExpr          tpuSet

" %entry ...
syn region tpuEntry             start="^\s*%entry" end="\." contains=tpuEntryDef,tpuOperator,tpuSeparator,tpuNumber
syn match  tpuLabel             "^\w\+:"

" marco definitions
syn region tpuMacroDef		start="^\s*%\s*macro\>" skip="\\$" end="\." contains=ALLBUT,tpuMarcoDef
syn region tpuMacroUse		start="@\w*" end="\>"

" Comments
syn keyword tpuTodo             contained TODO FIXME XXX
" string inside comments
syn region  tpuCommentString    contained start=+"+ end=+"+ end=+\*/+me=s-1,he=s-1 contains=tpuSpecial,tpuCommentStar,tpuSpecialChar
syn region  tpuComment2String   contained start=+"+  end=+$\|"+  contains=tpuSpecial,tpuSpecialChar
syn match   tpuCommentCharacter contained "'\\[^']\{1,6\}'" contains=tpuSpecialChar
syn match   tpuCommentCharacter contained "'\\''" contains=tpuSpecialChar
syn match   tpuCommentCharacter contained "'[^\\]'"
syn region  tpuComment          start="(\*"  end="\*)" contains=tpuCommentString,tpuCommentCharacter,tpuNumber,tpuTodo
syn match   tpuCommentStar      contained "^\s*\*[^/]"me=e-1
syn match   tpuCommentStar      contained "^\s*\*$"
"syn match   tpuLineComment      "//.*" contains=tpuComment2String,tpuCommentCharacter,tpuNumber,tpuTodo
hi link tpuCommentString tpuString
hi link tpuComment2String tpuString
"hi link tpuCommentCharacter tpuCharacter

" match the special comment (**)
"syn match   tpuComment          "(\*\*)"

" Strings and constants
syn region  tpuString           start=+'+ end=+'+  contains=ucSpecialChar,ucSpecialError
syn match   tpuNumber           "#\?\<\(0[0-7]*\|0[xX]\x\+\|\d\+\)[lL]\=\>"
syn match   tpuNumber           "#\?$\?\<\x\+\>"

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_tpu_syntax_inits")
  if version < 508
    let did_tpu_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink tpuConditional                   Conditional
  HiLink tpuRepeat                        Repeat
  HiLink tpuNumber                        Number
  HiLink tpuComment                       Comment
  HiLink tpuMacroDef                      PreProc
  HiLink tpuMacroUse                      PreProc
  HiLink tpuEntry                         Function
  HiLink tpuEntryDef                      Statement
  HiLink tpuString                        String
  HiLink tpuRegister                      Identifier
  HiLink tpuBranch                        Statement
  HiLink tpuChan                          Statement
  HiLink tpuSet                           Statement
  HiLink tpuIsr                           Special
  HiLink tpuHsr                           Special
  HiLink tpuOperator                      String
  HiLink tpuEOS                           String
  HiLink tpuSeperator                     String
  HiLink tpuLabel                         Label

  delcommand HiLink
endif

let b:current_syntax = "tpu"

if main_syntax == 'tpu'
  unlet main_syntax
endif

" vim: ts=8
