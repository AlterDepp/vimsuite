" ===========================================================================
"        File: tools.vim
"      Author: Stefan Liebl (S.Liebl@gmx.de)
" Description: some usefull tools
" Revision:    $LastChangedRevision: 60 $
" ===========================================================================

" ----------------
" Project settings
" ----------------
if !exists("basedir")
    let g:basedir = getcwd()
endif

let s:makefileNames = [
            \ 'makefile',
            \  'Makefile',
            \  'makefile.mak',
            \  'Makefile.mak',
            \  'make.bat',
            \  'make_fsw.bat']
let g:projectFile = fnamemodify($VIMRUNTIME . '/../projects.txt', ':p')

" ----------
" SetProject
" ----------
if (v:version > 602)
    command -complete=customlist,GetAllMakefiles -nargs=? SetProject call s:SetProject('<args>')
else
    command -nargs=1 SetProject call SetProject('<args>')
endif
"function GetAllMakefiles(ArgLead, CmdLine, CursorPos)
function GetAllMakefiles(...)
    let makefilePaths = []

    " Get Makefiles from g:WA or ArgLead
    let path = g:WA
    if a:0 == 3
        let ArgLead = a:1
        let CmdLine = a:2
        let CursorPos = a:3
        if ArgLead != ''
            let path = expand(ArgLead)
        endif
    endif
    let makefilePaths += s:GetAllMakefilesInPath(path)

    if makefilePaths == []
        " Get Projects from project.txt
        let projectPaths = s:GetProjectPaths(g:projectFile)
        for projectPath in projectPaths
            let makefilePaths += s:GetAllMakefilesInPath(projectPath)
        endfor
    endif

    return makefilePaths
endfunction

" Get all Makefiles defined in s:makefileNames contained in path
function s:GetAllMakefilesInPath(path)
    let files = []
    if isdirectory(a:path)
        let path = a:path
    else
        let path = a:path . '*'
    endif
    for makefileName in s:makefileNames
        let pathlist = path . ',' . path . '/*,' . path . '/*/*'
        let newfiles = split(globpath(pathlist, makefileName))
        let files += newfiles
"        echo files
    endfor
    return files
endfunction

" Get Project-Paths from project.txt
function s:GetProjectPaths(projectFile)
    let paths = []
    if filereadable(a:projectFile)
        let paths = split(system('more ' . a:projectFile))
    endif
    return paths
endfunction

" Find makefile and set some options
" ----------------------------------
function s:SetProject(makefile)
    if ((a:makefile == '') && has('browse'))
        " Browse for makefile
        if exists('g:WA')
            let l:WA = g:WA
        else
            let l:WA = ''
        endif

        let makefilePath = fnamemodify(browse(0, 'Select makefile', l:WA, ''), ':p')
    else
        " set Workarea and basedir
        if filereadable(a:makefile)
            let makefilePath = fnamemodify(a:makefile, ':p')
        else
            echoerr 'No makefile' a:makefile
            return
        endif
    endif

    " split file name and path
    let g:basedir = fnamemodify(makefilePath, ':p:h')
    let g:makefileName = fnamemodify(makefilePath, ':t')

    " test if makefile is a batch-script
    let ext = fnamemodify(g:makefileName, ':e')
    if ext == 'bat'
        let &makeprg = makefilePath . ' $*'
    endif

    " set directories
    execute 'cd ' . g:basedir
    " cd path
    let &cdpath = g:basedir
    " browse-dir
    set browsedir=buffer

    " search path
    set path&

    call s:SetProjectVariables()

endfunction

" Set Project Specific Variables
function s:SetProjectVariables()
    let varnames = [
                \ 'VIM_COMPILER',
                \ 'VIM_PATH',
                \ 'VIM_TAGS',
                \ 'VIM_CSCOPEPRG',
                \ 'VIM_CSCOPEFILE',
                \ 'GOALS',
                \]
    let s:Variables = s:GetMakeVars(varnames)

    echo 'Reading variables from makefile'
    echo '-------------------------------'
    for varname in keys(s:Variables)
        echo printf('%-15s = %s', varname, s:Variables[varname])
    endfor
    echo '-------------------------------'
    echo ''

    try
        " evaluate path variable
        if s:Variables['VIM_PATH'] != ''
            try
                execute 'set path=' . s:Variables['VIM_PATH']
            catch
                echoerr 'cant set path to ' . s:Variables['VIM_PATH']
                echoerr 'check the make variable VIM_PATH'
            endtry
        else
            echomsg 'set the make-variable VIM_PATH to what you want to be set to path'
        endif

        " evaluate tags
        if s:Variables['VIM_TAGS'] != ''
            try
                execute 'set tags=' . s:Variables['VIM_TAGS']
            catch
                echoerr 'cant set tags to ' . s:Variables['VIM_TAGS']
                echoerr 'check the make variable VIM_TAGS'
            endtry
        else
            echomsg 'set the make-variable VIM_TAGS to what you want to be set to tags'
        endif

        " evaluate cscope
        if s:Variables['VIM_CSCOPEPRG'] != ''
            try
                execute 'set cscopeprg=' . s:Variables['VIM_CSCOPEPRG']
            catch
                echoerr 'cant set cscopeprg to ' . s:Variables['VIM_CSCOPEPRG']
                echoerr 'check the make variable VIM_CSCOPEPRG'
            endtry
        else
            echomsg 'set the make-variable VIM_CSCOPEPRG to what you want to be set to cscopeprg'
        endif
        if s:Variables['VIM_CSCOPEFILE'] != ''
            try
                cscope kill -1
                execute 'cscope add ' . s:Variables['VIM_CSCOPEFILE']
            catch
                echomsg 'cant add cscope-file ' . s:Variables['VIM_CSCOPEFILE']
                echomsg 'check the make variable VIM_CSCOPEFILE and if file exists'
            endtry
        else
            echomsg 'set the make-variable VIM_CSCOPEFILE if you want to add a cscope-database'
        endif

        " evaluate compiler
        if s:Variables['VIM_COMPILER'] != ''
            try
                execute 'compiler ' . s:Variables['VIM_COMPILER']
            catch
                echoerr 'cant set compiler to ' . s:Variables['VIM_COMPILER']
                echoerr 'check the make variable VIM_COMPILER'
            endtry
        else
            echomsg 'set the make-variable VIM_COMPILER to the compiler plugin you want to use'
        endif

    catch
        echoerr 'Could not read variables from makefile (vim-script-error)'
    endtry

endfunction

" Get values for a list of variables as dictionary
function! s:GetMakeVars(varNameList)
    let varlist = {}
    try
        let vars = join(a:varNameList, ' ')
        let command = g:makefileName . ' getvar name="' . vars . '"'
        let output = system(command)
        let lines = split(output, "\n")
        let RE = '^\(\w\+\)=\(.*\)\s*'
        let SU = "let varlist['\\1']='\\2'"
        "echo 'getvars:'
        for line in lines
        "    echo line
            if match(line, RE) >= 0
                execute substitute(line, RE, SU, '')
            endif
        endfor
        "echo ''
    catch
        echoerr 'Could not read make variables'
    endtry

    if varlist == {}
        echoerr 'Could not read any variables from makefile'
        echo 'Command:' command
        echo 'Make output is:'
        for line in lines
            echo line
        endfor
        echo '---'
    endif
    return varlist
endfunction

" ------------------------------------------
" special make-command for target-completion
" ------------------------------------------
command -complete=customlist,GetAllMakeGoals -nargs=* Make call s:Make('<args>')
function GetAllMakeGoals(...)
    " evaluate make-goals
    if s:Variables['GOALS'] != ''
        try
            let goals = split(s:Variables['GOALS'])
            return goals
        catch
            echoerr 'cant set goals to ' . s:Variables['GOALS']
            echoerr 'check the make variable GOALS'
        endtry
    else
        echomsg 'set the make-variable VIM_COMPILER to the compiler plugin you want to use'
    endif
endfunction
function s:Make(args)
    cscope kill -1
    execute ':make ' . a:args
    try
        execute 'cscope add ' . s:Variables['VIM_CSCOPEFILE']
    endtry
endfunction


" ------------------
" Draw Vimsuite-Menu
" ------------------
let s:VimSuiteMenuLocation = 70
let s:VimSuiteMenuName = '&VimSuite.'

function s:AddMakefileToProjectMenu(makefilePath)
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.10 '.s:VimSuiteMenuName.'&Project.'
                \ . escape(a:makefilePath, '.\') . '<tab>'.
                \'    :SetProject ' . a:makefilePath . '<CR>'
endfunction
"
function s:AddAllKnownProjectsToMenu()
    " Projects in project.txt
    exec 'anoremenu '. s:VimSuiteMenuName.
                \'&Project.-sep2-  :'
    let projectPaths = s:GetProjectPaths(g:projectFile)
    let makefilePaths = []
    for projectPath in projectPaths
        let makefilePaths += s:GetAllMakefilesInPath(projectPath)
    endfor
    for makefilePath in makefilePaths
        call s:AddMakefileToProjectMenu(makefilePath)
    endfor

    " Projects in g:WA
    exec 'anoremenu '. s:VimSuiteMenuName.
                \'&Project.-sep3-  :'
    for makefilePath in s:GetAllMakefilesInPath(g:WA)
        call s:AddMakefileToProjectMenu(makefilePath)
    endfor
endfunction
"
function s:InitProjectMenu()
    exec 'silent! aunmenu '.s:VimSuiteMenuName.'&Project'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.10 '.s:VimSuiteMenuName.
                \'&Project.&Browse\ for\ makefile<tab>:SetProject'.
                \'   :SetProject<CR>'
    exec 'anoremenu ..25 '. s:VimSuiteMenuName.
                \'&Project.-sep1-  :'
endfunction
"
function s:RedrawProjectMenu()
    call s:InitProjectMenu()
    call s:AddAllKnownProjectsToMenu()
endfunction

" -------
" Session
" -------
if (v:version > 602)
    command -complete=custom,GetAllSessions -nargs=? SessionLoad call s:SessionLoad('<args>')
else
    command -nargs=? SessionLoad call s:SessionLoad('<args>')
endif
function s:SessionLoad(SessionFile)
    if ((a:SessionFile == '') && has('browse'))
        " Browse for session-file
        if exists('b:browsefilter')
            let l:browsefilter = b:browsefilter
        endif
        let b:browsefilter = "Vim Sessions (*.vim)\t*.vim\nAll Files (*.*)\t*.*"
        let SessionFile = browse(0, 'Select Session', $VIMRUNTIME . '/..', '')
        if exists('l:browsefilter')
            let b:browsefilter = l:browsefilter
        endif
    else
        let SessionFile = a:SessionFile
    endif
    if filereadable(SessionFile)
        execute('source ' . SessionFile)
    else
        echo 'No such File:' SessionFile
    endif
endfunction

command -nargs=? SessionSave call s:SessionSave('<args>')
command -nargs=? Exit SessionSave <args>|exit
function s:SessionSave(SessionName)
    if (a:SessionName == '')
        if ((v:this_session == '') && has('browse'))
            " Browse for session-file
            if exists('b:browsefilter')
                let l:browsefilter = b:browsefilter
            endif
            let b:browsefilter = "Vim Sessions (*.vim)\t*.vim\nAll Files (*.*)\t*.*"
            let SessionName = browse(1, 'Select Session File', $VIMRUNTIME . '/..', 'Session.vim')
            if exists('l:browsefilter')
                let b:browsefilter = l:browsefilter
            endif
        else
            let SessionName = v:this_session
        endif
    else
        let SessionName = a:SessionName
    endif
    execute('mksession! ' . SessionName)
endfunction

function GetAllSessions(ArgLead, CmdLine, CursorPos)
    let sessions_txt = $VIMRUNTIME . '/../sessions.txt'
    let sessions = ''
    let sessions = sessions . GlobLong($VIMRUNTIME . '/../*.vim')
    if filereadable(sessions_txt)
        let sessions = sessions . system("cat " . sessions_txt)
    endif
    return sessions
endfunction


function s:DelSessions()
    exec 'silent! aunmenu '.s:VimSuiteMenuName.'&Session'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.10 '.s:VimSuiteMenuName.
                \'&Session.&Browse\ for\ Sessionfile<tab>:SessionLoad'.
                \'   :SessionLoad<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.20 '.s:VimSuiteMenuName.
                \'&Session.&Save<tab>:SessionSave'.
                \'   :SessionSave<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.20 '.s:VimSuiteMenuName.
                \'&Session.Save\ &As<tab>:SessionSave'.
                \'   :let v:this_session = ""<CR>:SessionSave<CR>'
endfunction

function s:RedrawSessionMenu()
    call s:DelSessions()
"    call s:AddAllKnownSessionsToMenu()
endfunction

function s:RedrawMenu()
    " Project
    call s:RedrawProjectMenu()
    " Session
    call s:RedrawSessionMenu()
    " Compile
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.30 '.s:VimSuiteMenuName.
                \'&Compile.&Build<tab>:make'.
                \'   :make<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.30 '.s:VimSuiteMenuName.
                \'&Compile.&Lint<tab>:make\ lint'.
                \'   :make lint<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.30 '.s:VimSuiteMenuName.
                \'&Compile.&Clean<tab>:make\ clean'.
                \'   :make clean<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.30 '.s:VimSuiteMenuName.
                \'&Compile.&Run<tab>:make\ run'.
                \'   :make run<CR>'
"        exec 'anoremenu '.s:VimSuiteMenuLocation.'.30 '. s:VimSuiteMenuName.
"                    \'&Compile.-sep-  :'
    " Search
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.40 '.s:VimSuiteMenuName.
                \'&Search.&Grep<tab>:Grep'.
                \'   :Grep<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.40 '.s:VimSuiteMenuName.
                \'&Search.&File<tab>:find\ <name>'.
                \'   :call FindFile()<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.40 '. s:VimSuiteMenuName.
                \'&Search.-sep-  :'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.40 '.s:VimSuiteMenuName.
                \'&Search.Goto\ &Cscope-Tag<tab>:cscope'.
                \'   :cscope find i <C-R><C-W><CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.40 '.s:VimSuiteMenuName.
                \'&Search.Goto\ &CTag<tab>:tag'.
                \'   :tag <C-R><C-W><CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.40 '.s:VimSuiteMenuName.
                \'&Search.List\ &CTags<tab>:tselect'.
                \'   :tselect /<C-R><C-W><CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.40 '.s:VimSuiteMenuName.
                \'&Search.Update\ c&tags<tab>:make\ tags'.
                \'   :make tags<CR>'
    " Edit
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.50 '.s:VimSuiteMenuName.
                \'&Edit.&Comment\ out/in<tab>^k'.
                \'   :CommentInOut<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.50 '.s:VimSuiteMenuName.
                \'&Edit.Mark\ &long\ lines<tab>:MarkLongLines'.
                \'   :MarkLongLines<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.50 '.s:VimSuiteMenuName.
                \'&Edit.&Reformat\ File<tab>:Reformat'.
                \'   :Reformat<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.50 '.s:VimSuiteMenuName.
                \'&Edit.Reformat\ &Tabs<tab>:ReformatTabs'.
                \'   :ReformatTabs<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.50 '.s:VimSuiteMenuName.
                \'&Edit.Reformat\ &Indent<tab>:ReformatIndent'.
                \'   :ReformatIndent<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.50 '.s:VimSuiteMenuName.
                \'&Edit.Delete\ trailing\ spaces<tab>:DelAllTrailWhitespace'.
                \'   :DelAllTrailWhitespace<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.50 '.s:VimSuiteMenuName.
                \'&Edit.Delete\ multiple\ &empty\ lines<tab>:DelAllMultipleEmptyLines'.
                \'   :DelAllMultipleEmptyLines<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.50 '.s:VimSuiteMenuName.
                \'&Edit.Delete\ multiple\ &same\ lines<tab>:DelAllMultipleSameLines'.
                \'   :DelAllMultipleSameLines<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.50 '. s:VimSuiteMenuName.
                \'&Edit.-sep-  :'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.50 '.s:VimSuiteMenuName.
                \'&Edit.Insert\ &Function\ Header<tab>:InsertFHeader'.
                \'   :InsertFHeader<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.50 '.s:VimSuiteMenuName.
                \'&Edit.Insert\ &C-File\ Header<tab>:InsertCHeader'.
                \'   :InsertCHeader<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.50 '.s:VimSuiteMenuName.
                \'&Edit.Insert\ &H-File\ Header<tab>:InsertHHeader'.
                \'   :InsertHHeader<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.50 '.s:VimSuiteMenuName.
                \'&Edit.Insert\ H&TML-File\ Header<tab>:InsertHTMLHeader'.
                \'   :InsertHTMLHeader<CR>'
    " Diff
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.60 '.s:VimSuiteMenuName.
                \'&Diff.&show\ diffs<tab>:diffthis'.
                \'   :diffthis<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.60 '.s:VimSuiteMenuName.
                \'&Diff.&end\ diffs<tab>:DiffOff'.
                \'   :DiffOff<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.60 '.s:VimSuiteMenuName.
                \'&Diff.&close\ diff<tab>:DiffClose'.
                \'   :DiffClose<CR>'
endfunction
call s:RedrawMenu()

" search functions
" ----------------

" Search for file
function FindFile()
    let basename = inputdialog('Filename:')
    echo 'basename:' basename
    " do it
    execute ':find ' basename
endfunction

" don't use :grep
let &grepprg='echo extern grep is not supported. Use vimgrep'

" defaults
let g:GrepDir = getcwd()
let g:GrepFiles = '*.*'

command -nargs=* Grep call Grep('<args>')
function Grep(input)
    if (a:input == '')
        let pattern = inputdialog('Pattern:')
    else
        let pattern = a:input
    endif

    " Use Buffer-Variables, if exists
    if exists('b:GrepDir')
        let GrepDir = b:GrepDir
    else
        let GrepDir = g:GrepDir
    endif
    if exists('b:GrepFiles')
        let GrepFiles = b:GrepFiles
    else
        let GrepFiles = g:GrepFiles
    endif

    call GrepFull(GrepDir, GrepFiles, pattern)
endfunction

function GrepFull(GrepDir, GrepFiles, Pattern)
    " Normpath
    let GrepDir = substitute(a:GrepDir, '\\', '/', 'g')
    " add GrepDir to each GrepFiles
    let Files = substitute(a:GrepFiles, '\(\S\+\)', GrepDir.'/**/\0', 'g')
    " get pattern if empty
    if (a:Pattern == '')
        let Pattern = inputdialog('Pattern:')
    else
        let Pattern = a:Pattern
    endif


    " do it
    let command = 'vimgrep /'.Pattern.'/gj '.Files
    echo command
    silent execute command
    " list results
    execute 'cl'
endfunction

" Formatting Functions
" --------------------

" delete all multiple empty lines
command -range=% DelAllMultipleEmptyLines call DelAllMultipleEmptyLines(<line1>,<line2>)
function DelAllMultipleEmptyLines(fromline, toline)
    let cursorLine = line(".")
    let cursorCol = col(".")
    execute a:fromline . ',' . a:toline . 's/\s\+$//e'
    execute a:fromline . ',' . a:toline . 's/^\s*\(\n\s*$\)\+//e'
    call cursor(cursorLine, cursorCol)
endfunction

" delete all trailling whitespace
command -range=% DelAllTrailWhitespace call DelAllTrailWhitespace(<line1>,<line2>)
function DelAllTrailWhitespace(fromline, toline)
    let cursorLine = line(".")
    let cursorCol = col(".")
    execute a:fromline . ',' . a:toline . 's/\s\+$//e'
    call cursor(cursorLine, cursorCol)
endfunction

" delete all multiple same lines
command -range=% DelAllMultipleSameLines call DelAllMultipleSameLines(<line1>,<line2>)
function DelAllMultipleSameLines(fromline, toline)
    let cursorLine = line(".")
    let cursorCol = col(".")
    execute a:fromline . ',' . a:toline . 's/^\(.*\)\(\n^\1$\)\+/\1/e'
    call cursor(cursorLine, cursorCol)
endfunction

" reformat
command -range=% Reformat call ReformatFile(<line1>,<line2>)
function ReformatFile (fromline,toline)
    call ReformatText(a:fromline,a:toline)
    if (&filetype == 'kgs')
        call ReformatKGS()
    endif
endfunction

"command -range=% Reformat call ReformatText(<line1>,<line2>)
function ReformatText (fromline,toline)
"    execute a:fromline . ',' . a:toline . 'DelAllTrailWhitespace'
    call DelAllTrailWhitespace(a:fromline,a:toline)
    call ReformatTabs(a:fromline,a:toline)
    call ReformatIndent(a:fromline,a:toline)
endfunction

command -range=% ReformatIndent call ReformatIndent(<line1>,<line2>)
function ReformatIndent (fromline,toline)
    " mark actual position
    let cursorLine = line(".")
    let cursorCol = col(".")
    " mark all commented lines
    let line_nr = a:fromline
    while (line_nr <= a:toline)
        let line = getline(line_nr)
        if (match(line,'^' . b:commentstring)>=0)
            let line = '@' . line
"            echo line
            call setline(line_nr, line)
        endif
        let line_nr = line_nr + 1
    endwhile
    " indent all lines
    execute 'normal ' . a:fromline . 'G=' . a:toline . 'G'
    " reindent commented lines
    let substCmd = 's?^\s*@' . b:commentstring . '?' . b:commentstring . '?'
    silent! execute a:fromline . ','  . a:toline . substCmd
    " go back to mark
    call cursor(cursorLine, cursorCol)
endfunction

command -range=% ReformatTabs call ReformatTabs(<line1>,<line2>)
function ReformatTabs (fromline,toline)
    let cursorLine = line(".")
    let cursorCol = col(".")
    if (a:fromline > 1)
        call cursor(a:fromline-1, 255)
    else
        call cursor(a:fromline, 1)
    endif
    let found = search('\t', 'W')
    while ((found > 0) && (found <= a:toline))
        execute "normal r\t"
        let found = search('\t', 'W')
    endwhile
    call cursor(cursorLine, cursorCol)
endfunction

" convert UTF-8 to LATIN1
command ConvertUTF8 call ConvertUTF8()
function ConvertUTF8()
    silent! %s/&#195;&#164;/\&#228;/ " ä
    silent! %s/&#195;&#182;/\&#246;/ " ö
    silent! %s/&#195;&#188;/\&#252;/ " ü
    silent! %s/&#195;&#132;/\&#196;/ " Ä
"    silent! %s/&#195;&#xxx;/\&#214;/ " Ö
    silent! %s/&#195;&#156;/\&#220;/ " Ü
    silent! %s/&#195;&#159;/\&#223;/ " ß
    silent! %s/&#226;&#130;&#172;/€/ " €
endfunction

" insert history comment
command HistoryComment call HistComment()
function HistComment()
    let l:date = GetDate()
    execute 'normal O' . l:date . ' IST_LIEBL'
    execute 'normal o'
    execute 'normal k$'
endfunction

" find all non-extern functions in h-files
function FindDeclaration()
    let bmsk_sw = g:bmsk_sw
    let bmsk_header = g:bmsk_header
    let bios_header = g:bios_header
    let id         = '(\\ *[a-zA-Z0-9_]+\\ *)'
    let not_extern = '([^x]*\\ +)'
    let start      = not_extern . '*'
    let type       = '(' . id . '\\ +)'
    let declarator = '(' . id . ')'
    let parameter  = '(' . id . ')(\\ +' . id .',?\\ *)?'
    let parlist    = '(' . parameter . '+)'
    let bracket    = '(\\(' . parlist . '\\))'
    let definition  = '(\\ *({.*)?)'
    let declaration = '(\\ *;.*)'
    let end         = definition
    "let end         = definition . declaration . '?'
    execute ':Hgrep -x '' . start . type . declarator . bracket . end . '''
endfunction

" indent a wordNum to position
function IndentWordNum(wordNum, pos)
    " store cursor postion
    let cursorLine = line(".")
    let cursorCol = col(".")
"    echo 'IndentWordNum' cursorLine cursorCol a:wordNum a:pos getline(line("."))
    " go to word at pos
    execute 'normal 0' . a:wordNum . 'w'
    if (line(".") == cursorLine)
        if (virtcol('.') > a:pos)
            " word has to be undented
            " go to end of previous word
            execute 'normal ge'
            if (virtcol('.') < a:pos-1)
                " ok, only whitespace to delete
                "            echo 'undent' col(".")
                execute 'normal ' . a:pos . '|dw'
            else
                " delete as much as possible
                "            echo 'remove' col(".")
                execute 'normal ldwi '
            endif
        else
            " word has to be indented
            "        echo 'indent' col(".")
            execute 'normal h'
            while (virtcol('.') < a:pos-1)
                " indent word
                execute "normal a\<TAB>\<ESC>"
            endwhile
        endif
    else
"        echo 'kein' a:wordNum '. Wort in Zeile' cursorLine
    endif
    " restore cursor position
    call cursor(cursorLine, cursorCol)
endfunction

" ----------------
" Comment In / Out
" ----------------
nnoremap <C-K> :call CommentInOut(b:commentstring)<CR>j
command CommentInOut call CommentInOut(b:commentstring)
function CommentInOut(commentstring)
	let leadingWhitespace = '^\s\*'
	let noLeadingWhitespace = '^'
    let ignoreCase = '\c'
	let CommentedString = ignoreCase . noLeadingWhitespace . a:commentstring
	let line = GetLine()
	let line_nr = line('.')
	let found = match(line, CommentedString)
	"echo l:found
	if (found == -1)
		"echo 'nicht gefunden'
		let line = substitute(line, '^', a:commentstring, '')
	else
		"echo 'gefunden'
		let line = substitute(line, a:commentstring, '', '')
	endif
	call setline(line_nr, line)
endfunction

" mark lines longer as textwidth
command MarkLongLines call MarkLongLines('on')
command MarkLongLinesOff call MarkLongLines('off')
function MarkLongLines(onoff)
"    echo a:onoff
    if (a:onoff=='on')
        let markline = &textwidth + 1
        let longline='"\%' . markline . 'v.*"'
"        execute('let @/ = ' . longline)
        execute 'syntax match toLong ' . longline . ' containedin=ALL'
        highlight  toLong guibg=red
    else
"        execute 'normal :nohlsearch<CR>'
        syntax clear toLong
        highlight clear toLong
    endif
endfunction

command SynaxShowGroup execute('echo synIDattr(synID(line("."), col("."), 1), "name")')

" diff options
set diffexpr=FileDiff()
set diffopt=filler,iwhite
function FileDiff(...)
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  if a:0 == 3
      let arg1 = a:1
      let arg2 = a:2
      let arg3 = a:3
  else
      let arg1 = v:fname_in
      let arg2 = v:fname_new
      let arg3 = v:fname_out
  endif

  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  if !executable(cmd)
      let cmd = 'diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction


" turn diff off
command DiffClose call DiffClose()
function DiffClose()
    :quit
    call DiffOff()
endfunction

command DiffOff call DiffOff()
function DiffOff()
    set nodiff
    set noscrollbind
    set foldcolumn=0
    set foldmethod=syntax
endfunction

" options for DirDiff
let g:DirDiffCommand = expand($VIMRUNTIME . '/diff')
let g:DirDiffExcludes = '*.log,*.pyc,.svn,_ccmwaid.inf,.static_wa,out,tags,cscope.out'
"let g:DirDiffDynamicDiffText = 1

" options for Vimball
let g:vimball_home = expand(g:vimsuite . '/vimfiles')

" merge
command -nargs=+ Merge call Merge(<args>)
function Merge(...)
    let args = a:0
    if a:0 != 4
        echo 'usage: Merge first,second,root,out'
    else
        let first  = fnamemodify(bufname(a:1), ':p:8')
        let second = fnamemodify(bufname(a:2), ':p:8')
        let root   = fnamemodify(bufname(a:3), ':p:8')
        let out    = fnamemodify(bufname(a:4), ':p:8')
        echo 'root-buffer  :' root
        echo 'first-buffer :' first
        echo 'second-buffer:' second
        echo 'output-buffer:' out

        execute '!'. g:diff . ' ' . root . ' '. first . ' | ' . g:patch . ' --force ' . second . ' --output="' . out
        execute bufwinnr(4) . 'wincmd w'
        execute 'edit'
        execute 'wincmd ='
    endif
endfunction

" -------------
" abbreviations
" -------------
"iabbreviate li !IST_LIEBL: */<Left><Left><Left>


" ------
" python
" ------
command Batch echo system(expand('%:p:r.bat'))
command -nargs=* Python execute(':wa | cd ' . GetBmskDir()) | echo system(g:python . ' ' . expand('%:p') . ' <args>')

" ---------
" templates
" ---------
command InsertCHeader call Insert_Header('file_c.tpl')
command InsertHHeader call Insert_Header('file_h.tpl')
command InsertFHeader call Insert_Header('funct.tpl')
command InsertHTMLHeader call Insert_Header('html.tpl')
function Insert_Header(file)
    let file = g:vimfiles . '/templates/' . a:file
    execute ':read ' . file
    let l:filename = expand('%:t')
    execute ':%s/%filename/' . l:filename . '/e'
    let l:basename = substitute(expand('%:t:r'), '.*', '\U\0', '')
    execute ':%s/%basename/' . l:basename . '/e'
    let l:author = 'IST_LIEBL'
    execute ':%s/%author/' . l:author . '/e'
    while search('%date', '') > 0
        "execute 'normal /%date'
        execute ':d'
        execute ':HistoryComment'
        execute 'normal jdd'
    endwhile
endfunction

EchoDebug 'loaded tools.vim'
