" Vim syntax file
" Language:     ASAP
" Maintainer:   Stefan Liebl
" Last Change:  2008 Aug 27
" License:      This file is placed in the public domain.

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match BlockCommand '/begin\s\+\w\+'
syn match BlockCommand '/end\s\+\w\+'
syn region String      start=+"+ end=+"+
syn keyword attribute ASAP2_VERSION VERSION PROJECT_NO
syn keyword attribute CUSTOMER_NO USER PHONE_NO ECU CPU_TYPE
syn keyword attribute SYSTEM_CONSTANT
syn keyword attribute BYTE_ORDER ALIGNMENT_BYTE ALIGNMENT_WORD ALIGNMENT_LONG ALIGNMENT_FLOAT32_IEEE
syn keyword attribute FORMAT DEPOSIT AXIS_PTS_REF BIT_MASK ECU_ADDRESS ARRAY_SIZE
syn keyword attribute COEFFS FNC_VALUES NO_AXIS_PTS_X NO_AXIS_PTS_Y AXIS_PTS_X AXIS_PTS_Y


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

"  HiLink Record         Normal
  HiLink BlockCommand   Statement
  HiLink attribute      Statement

  delcommand HiLink
endif

let b:current_syntax = "paf"

" vim: ts=8
