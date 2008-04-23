let s:project_file = expand('<sfile>')

if exists('s:did_projectplugin')
    finish
endif
let s:did_projectplugin='myProject'
let current_compiler = 'myCompiler'

" ========
" Settings
" ========
function s:ProjectCreateSettings(setting_file)
    echo 'Create' a:setting_file
    if !exists('s:makeCommand')
        let s:makeCommand = expand(s:basedir . '/make.bat')
    endif
    let command = escape(s:makeCommand, ' \') . ' vim-config'
    echo command
    call system(command)
    if !filereadable(a:setting_file)
        throw 'Could not create Settings-file ' . a:setting_file
    endif
endfunction

function s:ProjectLoadSettings()
    let s:basedir = fnamemodify(s:project_file, ':h')
    execute 'cd ' . s:basedir
    let s:setting_file = expand(s:basedir . '/out/settings.vim')

    " Create setting file
    if !filereadable(s:setting_file)
        call s:ProjectCreateSettings()
    endif

    " Load setting file
    try
        echo 'Load ' . s:setting_file
        " don't use 'source', so you can use script-variables
        for command in readfile(s:setting_file)
            execute command
        endfor
    catch
        echoerr 'could not read' s:setting_file
    endtry
endfunction

" =====
" Menue
" =====
let s:ProjectMenuLocation = 90
let s:ProjectMenuName = '&BMSX.'

function s:ProjectRedrawMenu()
    " Settings
    " ...
    " Compile
    exec 'anoremenu .30.10 '.s:ProjectMenuName.
                \'&Compile.&Build<tab>:Make'.
                \'   :Make<CR>'
    exec 'anoremenu ..40 '.s:ProjectMenuName.
                \'&Compile.&Clean<tab>:Make\ clean'.
                \'   :Make clean<CR>'
    exec 'anoremenu ..45 '.s:ProjectMenuName.
                \'&Compile.&Clean\ all<tab>:Make\ distclean'.
                \'   :Make distclean<CR>'
    exec 'anoremenu ..50 '. s:ProjectMenuName.
                \'&Compile.-sep-  :'
    exec 'anoremenu ..60 '.s:ProjectMenuName.
                \'&Compile.&Show\ Errors<tab>:cl'.
                \'   :cl<CR>'
    exec 'anoremenu ..70 '.s:ProjectMenuName.
                \'&Compile.&Open\ Error\ Window<tab>:copen'.
                \'   :copen<CR>'
    exec 'anoremenu ..75 '.s:ProjectMenuName.
                \'&Compile.&Parse\ make\.log<tab>:cfile\ out/make\.log'.
                \'   :cfile out/make.log<CR>'
    exec 'anoremenu ..80 '.s:ProjectMenuName.
                \'&Compile.Goto\ &Error<tab>:cc'.
                \'   :cc<CR>'
    exec 'anoremenu ..90 '.s:ProjectMenuName.
                \'&Compile.Goto\ &next\ Error<tab>:cn'.
                \'   :cn<CR>'
    " Search
    exec 'anoremenu ..20 '.s:ProjectMenuName.
                \'&Search.Goto\ &Cscope-Tag<tab>:cscope'.
                \'   :cscope find i <C-R><C-W><CR>'
    exec 'anoremenu ..30 '.s:ProjectMenuName.
                \'&Search.Goto\ &CTag<tab>:tag'.
                \'   :tag <C-R><C-W><CR>'
    exec 'anoremenu ..40 '.s:ProjectMenuName.
                \'&Search.List\ &CTags<tab>:tselect'.
                \'   :tselect /<C-R><C-W><CR>'
    exec 'anoremenu ..50 '.s:ProjectMenuName.
                \'&Search.Update\ c&tags<tab>:Make\ ctags'.
                \'   :Make ctags<CR>'
    exec 'anoremenu ..60 '.s:ProjectMenuName.
                \'&Search.Update\ C&scope<tab>:Make\ cscope'.
                \'   :Make cscope<CR>'
    exec 'anoremenu ..70 '.s:ProjectMenuName.
                \'&Search.Disconnect\ C&scope<tab>:cscope\ kill\ -1'.
                \'   :cscope kill -1<CR>'
endfunction

" ====
" Make
" ====
function s:GetMakeOptions(args)
    let makeopts =  a:args
    return makeopts
endfunction

function GetAllMakeCompletions(...)
    return join(s:makegoals + s:makeopts, "\n")
endfunction

command -complete=custom,GetAllMakeCompletions -nargs=* Make call s:Make('<args>')
function s:Make(args)
    echo a:args
    CscopeDisconnect
    execute 'make ' . s:GetMakeOptions(a:args)
    CscopeConnect
    try
        clist
    catch /E42/ " list is empty
        echo 'no output'
    endtry
endfunction

" -----------------
" CSCOPE-Connection
" -----------------
command CscopeConnect call s:CscopeConnect(s:cscopefile)
function s:CscopeConnect(cscopefile)
    if filereadable(a:cscopefile)
        execute 'cscope add ' . a:cscopefile
    "else
        "echomsg 'cscope: Could not connect: File ' . a:cscopefile . ' does not exist'
    endif
endfunction

command CscopeDisconnect call s:CscopeDisconnect()
function s:CscopeDisconnect()
    cscope kill -1
endfunction

" ========
" Settings
" ========
" ...

" =====
" Tools
" =====
" ...

" ========
" Compiler
" ========
function s:SetCompiler()
    " clear errorformats
    set errorformat=
    setlocal errorformat=
    " stdout and stderr to stdout and file
    let &shellpipe = '2>&1 | ' . g:tee
    " automatic errorfilename
    set makeef=

    " -------
    " Doxygen
    " -------
    set errorformat+=%t%.%#:\ Doxygen:\ %f:%l:\ %m

    " -----
    " LaTeX
    " -----
    set errorformat+=%t%.%#:\ LaTeX:\ %f:%l:\ %m

    " ----------
    " A2L-Parser
    " ----------
    set errorformat+=%t%.%#:\ Yacc:\ %f:%l:\ %m
    set errorformat+=%t%.%#:\ Yacc:\ %f:\ %m

    " -----
    " BMS-X
    " -----
    set errorformat+=BMS-X:\ %tarning:\ %f:\ %m
    set errorformat+=BMS-X:\ %tarning:\ %m
    set errorformat+=BMS-X:\ %trror:\ %f:\ %m
    set errorformat+=BMS-X:\ %trror:\ %m

    " -----
    " scons
    " -----
    set errorformat+=%+Gscons:\ ***\ %m
    set errorformat+=%+Gscons:\ %m\ is\ up\ to\ date.
    set errorformat+=%+Gscons:\ done\ building\ targets.
    set errorformat+=%Dos.chdir('%f')
    set errorformat+=scons:\ %tarning:\ %m

    " ------
    " python
    " ------
    set errorformat+=%f:%l:\ User%tarning:\ %m

    set errorformat+=%E%\\s%#File\ \"%f\"\\,\ line\ %l\\,\ %m
    set errorformat+=%C%m
    set errorformat+=%Z%.%#Error:\ %m

    set errorformat+=%E%\\s%#File\ \"<string>\"\\,\ line\ %l
    set errorformat+=%C%m
    set errorformat+=%-C\ %p^
    set errorformat+=%Z%.%#Error:\ %m

    " -------
    " PC-Lint
    " -------
    set errorformat+=\"%f\"\\,\ line\ %l:\ %t%.%#\ \(pclint:%n\):%m
    set errorformat+=%t%.%#\ %n:\ %m
    set errorformat+=%t%.%#\ \(pclint:%n\):\ %m
    " -------
    " SP-Lint
    " -------
    set errorformat+=%A%f\(%l\):\ %m
    set errorformat+=%A%f\(%l\):
    set errorformat+=%A%f\(%l\\,%c\):\ %m
    set errorformat+=%A%f\(%l\\,%c\):
    set errorformat+=%C\ \ \ \ %m

    " ---
    " gcc
    " ---
    set errorformat+=%f:%l:%c:\ %t%*\\w:\ \[%n\]\ %m
    set errorformat+=%*[^\"]\"%f\"%*\\D%l:\ %m
    set errorformat+=\"%f\"%*\\D%l:\ %m
    set errorformat+=%-G%f:%l:\ %trror:\ (Each\ undeclared\ identifier\ is\ reported\ only\ once
    set errorformat+=%-G%f:%l:\ %trror:\ for\ each\ function\ it\ appears\ in.)
    set errorformat+=%f:%l:\ %m
    set errorformat+=\"%f\"\\,\ line\ %l%*\\D%c%*[^\ ]\ %m
    set errorformat+=%D%*\\a[%*\\d]:\ Entering\ directory\ `%f'
    set errorformat+=%X%*\\a[%*\\d]:\ Leaving\ directory\ `%f'
    set errorformat+=%D%*\\a:\ Entering\ directory\ `%f'
    set errorformat+=%X%*\\a:\ Leaving\ directory\ `%f'
    set errorformat+=%DMaking\ %*\\a\ in\ %f

    " -----
    " Tools
    " -----
    set errorformat+=%+G/bin/%.%#:\ %m
    set errorformat+=%+G%.%#.exe:\ %m
    set errorformat+=%+G%.%#.exe[%*\\d]:\ ***\ %m

    " Error format from other programs: ...: ...
    "set errorformat+=%+G%f:\ %m
endfunction


" ================
" Start of session
" ================
function s:ProjectOnStart()
    " Load Settings
    call s:ProjectLoadSettings()
    " Menu
    call s:ProjectRedrawMenu()
    exec 'anoremenu .42 Hilfe.-MyProject- :'
    exec 'anoremenu .43 Hilfe.MyProject<tab> :help myProject<CR>'

    " Titel-Leiste
    set titlelen=100
    let &titlestring = '%t - (%-F) - %='

    " Make Settings
    let &cdpath = s:basedir
    let &path = s:path
    set notagrelative
    let &tags = s:tags
    let &cscopeprg = s:cscopeprg
    let &makeprg = s:makeCommand . ' $*'
    call s:SetCompiler()
    CscopeDisconnect
    CscopeConnect
endfunction

command ProjectUpdate call s:ProjectUpdate()
function s:ProjectUpdate()
    " rewrite vim-config
    Make vim-config
    " reload file
    execute 'SetProject ' . s:project_file
    call s:ProjectOnStart()
endfunction

call s:ProjectOnStart()

