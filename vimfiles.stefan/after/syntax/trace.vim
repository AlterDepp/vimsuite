" Vim syntax file
" Language:	Trace32 script
" Maintainer:	Stefan Liebl <S.Liebl@gmx.de>
" URL:		
" Credits:	Based on the java.vim syntax file by Claudio Fleiner
" Last change:	2004 Mar 03

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" we define it here so that included files can test for it
if !exists("main_syntax")
  let main_syntax='trace'
endif

" ignore case
syn case ignore

" keyword definitions
syn keyword traceConditional      if then
syn keyword traceRepeat           repeat

" trace commands
syn match   traceCommand        '\<\w\+\(\.\w\+\)*\>' transparent contains=traceFlashCommand,traceDataCommand,traceGlobalCommand,traceWinpageCommand,traceAreaCommand,tracePrintCommand,traceEntryCommand,traceWaitCommand,traceChdirCommand,traceEnddoCommand,traceOsCommand,traceDoCommand,traceStringCommand,traceGotoCommand,traceSystemCommand,traceRegisterCommand

" trace commands
syn match   traceFlashCommand   '\<\(flash\|f\)\>\.' contained nextgroup=traceFlashResetCommand,traceFlashCreateCommand,traceFlashTargetCommand,traceFlashEraseCommand,traceFlashProgramCommand
hi link     traceFlashCommand   traceCommand
syn match   traceDataCommand    '\<\(data\|d\)\>\.' contained nextgroup=traceDataLoadCommand,traceDataSetCommand
hi link     traceDataCommand    traceCommand
syn match   traceGlobalCommand  '\<\(global\)\>' contained
hi link     traceGlobalCommand  traceCommand
syn match   traceWinpageCommand '\<\(winpage\)\>\.' contained nextgroup=traceWinpageResetCommand,traceWinpageCreateCommand,traceWinpageSelectCommand
hi link     traceWinpageCommand traceCommand
syn match   traceAreaCommand    '\<\(area\)\>\.' contained nextgroup=traceAreaResetCommand,traceAreaCreateCommand,traceAreaSelectCommand,traceAreaViewCommand
hi link     traceAreaCommand    traceCommand
syn match   tracePrintCommand   '\<\(print\)\>' contained
hi link     tracePrintCommand   traceCommand
syn match   traceEntryCommand   '\<\(entry\)\>' contained
hi link     traceEntryCommand   traceCommand
syn match   traceWaitCommand    '\<\(wait\)\>' contained
hi link     traceWaitCommand    traceCommand
syn match   traceChdirCommand   '\<\(chdir\)\.\?\>' contained nextgroup=traceChdirDoCommand
hi link     traceChdirCommand   traceCommand
syn match   traceEnddoCommand   '\<\(enddo\)\>' contained
hi link     traceEnddoCommand   traceCommand
syn match   traceOsCommand      '\<\(os\)\>\.' contained nextgroup=traceOsPsdCommand,traceOsPtdCommand,traceOsEnvCommand,traceOsFileCommand
hi link     traceOsCommand      traceCommand
syn match   traceDoCommand      '\<\(do\)\>' contained
hi link     traceDoCommand      traceCommand
syn match   traceStringCommand  '\<\(string\)\>\.' contained nextgroup=traceStringCutCommand,traceStringScanCommand
hi link     traceStringCommand  traceCommand
syn match   traceGotoCommand    '\<\(goto\)\>' contained
hi link     traceGotoCommand    traceCommand
syn match   traceSystemCommand  '\<\(system\|sys\)\>\.' contained nextgroup=traceSystemCpuCommand,traceSystemBdmclockCommand,traceSystemUpCommand
hi link     traceSystemCommand  traceCommand
syn match   traceRegisterCommand  '\<\(register\)\>\.' contained nextgroup=traceRegisterSetCommand
hi link     traceRegisterCommand  traceCommand

" second commands
syn match   traceDataLoadCommand        '\(load\.\?\)'  contained nextgroup=traceDataLoadBinaryCommand,traceDataLoadElfCommand
hi link     traceDataLoadCommand        traceCommand
syn match   traceDataSetCommand         '\(set\)'  contained
hi link     traceDataSetCommand         traceCommand
syn match   traceFlashResetCommand      '\(reset\)' contained
hi link     traceFlashResetCommand      traceCommand
syn match   traceFlashEraseCommand      '\(erase\.\?\)' contained nextgroup=traceFlashEraseAllCommand
hi link     traceFlashEraseCommand      traceCommand
syn match   traceFlashProgramCommand    '\(program\.\?\)' contained nextgroup=traceFlashProgramAllCommand,traceFlashProgramOffCommand
hi link     traceFlashProgramCommand    traceCommand
syn match   traceFlashCreateCommand     '\(create\)' contained
hi link     traceFlashCreateCommand     traceCommand
syn match   traceFlashTargetCommand     '\(target\)' contained
hi link     traceFlashTargetCommand     traceCommand
syn match   traceChdirDoCommand         '\(do\)' contained
hi link     traceChdirDoCommand         traceCommand
syn match   traceWinpageResetCommand    '\(reset\)' contained
hi link     traceWinpageResetCommand    traceCommand
syn match   traceWinpageCreateCommand   '\(create\)' contained
hi link     traceWinpageCreateCommand   traceCommand
syn match   traceWinpageSelectCommand   '\(select\)' contained
hi link     traceWinpageSelectCommand   traceCommand
syn match   traceAreaResetCommand       '\(reset\)' contained
hi link     traceAreaResetCommand       traceCommand
syn match   traceAreaCreateCommand      '\(create\)' contained
hi link     traceAreaCreateCommand      traceCommand
syn match   traceAreaSelectCommand      '\(select\)' contained
hi link     traceAreaSelectCommand      traceCommand
syn match   traceAreaViewCommand        '\(view\)' contained
hi link     traceAreaViewCommand        traceCommand
syn match   traceOsPsdCommand           '\(psd()\)' contained
hi link     traceOsPsdCommand           traceCommand
syn match   traceOsPtdCommand           '\(ptd()\)' contained
hi link     traceOsPtdCommand           traceCommand
syn match   traceOsEnvCommand           '\(env\)' contained
hi link     traceOsEnvCommand           traceCommand
syn match   traceOsFileCommand          '\(file\)' contained
hi link     traceOsFileCommand          traceCommand
syn match   traceStringCutCommand       '\(cut\)' contained
hi link     traceStringCutCommand       traceCommand
syn match   traceStringScanCommand      '\(scan\)' contained
hi link     traceStringScanCommand      traceCommand
syn match   traceSystemCpuCommand       '\(cpu\)' contained
hi link     traceSystemCpuCommand       traceCommand
syn match   traceSystemBdmclockCommand  '\(bdmclock\)' contained
hi link     traceSystemBdmclockCommand  traceCommand
syn match   traceSystemUpCommand        '\(up\)' contained
hi link     traceSystemUpCommand        traceCommand
syn match   traceRegisterSetCommand     '\(set\)' contained
hi link     traceRegisterSetCommand     traceCommand

" third commands
syn match   traceDataLoadBinaryCommand  '\(binary\|b\)' contained
hi link     traceDataLoadBinaryCommand  traceCommand
syn match   traceDataLoadElfCommand     '\(elf\)' contained
hi link     traceDataLoadElfCommand     traceCommand
syn match   traceFlashEraseAllCommand   '\(all\)' contained
hi link     traceFlashEraseAllCommand   traceCommand
syn match   traceFlashProgramAllCommand '\(all\)' contained
hi link     traceFlashProgramAllCommand traceCommand
syn match   traceFlashProgramOffCommand '\(off\)' contained
hi link     traceFlashProgramOffCommand traceCommand

syn match   traceFunction         '\<cpufamily\s*(.*)'
"syn keyword traceBranch           goto call

syn match   traceOperator         "\(:=\)\|\(=\)\|\(<-\)\|\(->\)\|\(>>\)\|[+-]"
"syn match   traceEOS              "[.,;:]\(\s\|\n\)"
syn match   traceSeperator        "[.,;:]"

" Comments
syn keyword traceTodo             contained TODO FIXME XXX
" string inside comments
syn region  traceCommentString    contained start=+"+ end=+"+ end=+\*/+me=s-1,he=s-1 contains=traceSpecial,traceCommentStar,traceSpecialChar
syn region  traceComment2String   contained start=+"+  end=+$\|"+  contains=traceSpecial,traceSpecialChar
syn match   traceCommentCharacter contained "'\\[^']\{1,6\}'" contains=traceSpecialChar
syn match   traceCommentCharacter contained "'\\''" contains=traceSpecialChar
syn match   traceCommentCharacter contained "'[^\\]'"
"syn region  traceComment          start="(\*"  end="\*)" contains=traceCommentString,traceCommentCharacter,traceNumber,traceTodo
"syn match   traceCommentStar      contained "^\s*\*[^/]"me=e-1
"syn match   traceCommentStar      contained "^\s*\*$"
syn match   traceLineComment      ";.*" contains=traceComment2String,traceCommentCharacter,traceNumber,traceTodo
hi link traceLineComment traceComment
hi link traceCommentString traceString
hi link traceComment2String traceString
"hi link traceCommentCharacter traceCharacter

" Strings and constants
syn region  traceString           start=+"+ end=+"+  contains=ucSpecialChar,ucSpecialError
"syn match   traceNumber           "#\?\<\(0[0-7]*\|0[xX]\x\+\|\d\+\)[lL]\=\>"
"syn match   traceNumber           "#\?$\?\<\x\+\>"

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_trace_syntax_inits")
  if version < 508
    let did_trace_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink traceConditional                   Conditional
  HiLink traceRepeat                        Repeat
  HiLink traceNumber                        Number
  HiLink traceComment                       Comment
  HiLink traceString                        String
  HiLink traceBranch                        Statement
  HiLink traceOperator                      String
  HiLink traceEOS                           String
  HiLink traceSeperator                     String
  HiLink traceLabel                         Label
  HiLink traceCommand                       Statement
  HiLink traceFunction                      Function

  delcommand HiLink
endif

let b:current_syntax = "trace"

if main_syntax == 'trace'
  unlet main_syntax
endif

" vim: ts=8
