
" special keywords
syntax keyword cType     uint8  sint8  uint16  sint16  uint32  sint32  uint64  sint64
syntax keyword cType    tuint8 tsint8 tuint16 tsint16 tuint32 tsint32 tuint64 tsint64
syntax keyword cType    float32
syntax keyword cType    DfpType SfpType SfpErrorType LWrd LInt
syntax keyword cType    TickType
syntax keyword Special  ATOMIC BEGIN_ATOMIC END_ATOMIC

" debug
syntax match   cTodo    "\(debug\)"

" Lint-Komments and #ifdef's
" Flexelint-Comment
syntax match   cLint    "\(\/\/\)\(lint.*\)"
syntax match   cLint    "\(\/\*\)\(lint\_.\{-}\)\(\*\/\)"
" Splint-Comment
syntax match   cLint    "\/\*@\_.\{-}@\*\/"
" #ifdef _lint or #ifndef _lint
syntax match   cLint    "\(#\s*ifn\?def\s\+_lint\)"

hi def link cLint		Todo

syntax keyword cConstant TRUE FALSE

syntax region myFold start="{" end="}" transparent fold
syntax region if0Fold start="^\s*#\s*if\s\+0\+\>" end="^\s*#\s*endif" fold containedin=cPreCondit
let c_no_if0 = 1
syntax sync fromstart
"setlocal foldmethod=syntax
"setlocal nofoldenable

" Folds for #ifdef
command! -nargs=0 FoldDefine call FoldDefine(<args>)
function! FoldDefine ()
    execute 'normal mx'
    let startline = line('.')
"    execute 'normal %k'
    execute 'normal 0%'
    if match(GetLine(), 'endif') < 0
        execute 'normal k'
    endif
    let endline = line('.')
"    echo 'start: ' . startline . ' end: ' . endline
    let foldname = 'FoldDefine' . startline
    let start='"\%' . startline . 'l.*"'
    let end='"\%' . endline . 'l.*"'
    let command = 'syntax region ' . foldname . ' start=' . start . ' end=' . end . ' fold containedin=cPreCondit'
"    echo command
    execute command
    execute 'highlight def link ' . foldname . ' Comment'
    syntax sync fromstart
    setlocal foldmethod=syntax
    execute 'normal `x'
endfunction

command! -nargs=0 UnFoldDefine call UnFoldDefine(<args>)
function! UnFoldDefine ()
    let foldname = 'FoldDefine' . line('.')
    execute "syntax clear " . foldname
endfunction

