
" Default Variables.  You can override these in your global variables
" settings.
"
" For VCSManagerExcludes and VCSManagerIgnore, separate different patterns with a
" ',' (comma and no space!).
"
" eg. in your .vimrc file: let g:VCSManagerExcludes = "CVS,*.class,*.o"
"                          let g:VCSManagerIgnore = "Id:"
"                          " ignore white space in diff
"                          let g:VCSManagerAddArgs = "-w" 
"
" You can set the pattern that diff excludes.  Defaults to the CVS directory
if !exists("g:VCSManagerExcludes")
    let g:VCSManagerExcludes = ""
endif
" This is the -I argument of the diff, ignore the lines of differences that
" matches the pattern
if !exists("g:VCSManagerIgnore")
    let g:VCSManagerIgnore = ""
endif
if !exists("g:VCSManagerSort")
    let g:VCSManagerSort = 1
endif
if !exists("g:VCSManagerWindowSize")
    let g:VCSManagerWindowSize = 14
endif
if !exists("g:VCSManagerInteractive")
    let g:VCSManagerInteractive = 0
endif
if !exists("g:VCSManagerIgnoreCase")
    let g:VCSManagerIgnoreCase = 0
endif
" Additional arguments
if !exists("g:VCSManagerAddArgs")
    let g:VCSManagerAddArgs = ""
endif

" Regular Expression for changed files
if !exists("g:VCSManagerReChanged")
"    let g:VCSManagerReChangedFile =   '[ADMRC?!]'.  '[ MC]'.'[ L]'.'[ +]'.'[ S]'.'[ KOTB]'.'[ *]'
    let g:VCSManagerReChangedFile =   '[ADMRC]'.    '[ MC]'.'[ L]'.'[ +]'.'[ S]'.'[ KOTB]'.'[ *]'
    let g:VCSManagerReChangedProps = '[ ADMRCX?!~]'. '[MC]'.'[ L]'.'[ +]'.'[ S]'.'[ KOTB]'.'[ *]'
    let g:VCSManagerReChangedAdd =   '[ ADMRCX?!~]'.'[ MC]'.'[ L]'. '[+]'.'[ S]'.'[ KOTB]'.'[ *]'
    let g:VCSManagerReStatus =       '[ ADMRCX?!~]'.'[ MC]'.'[ L]'.'[ +]'.'[ S]'.'[ KOTB]'.'[ *]'
    let g:VCSManagerReChanged = g:VCSManagerReChangedFile
endif

" String used for the English equivalent "Only in ")
if !exists("g:VCSManagerTextOnlyIn")
    let g:VCSManagerTextOnlyIn = "Only in "
endif

" String used for the English equivalent ": ")
if !exists("g:VCSManagerTextOnlyInCenter")
    let g:VCSManagerTextOnlyInCenter = ": "
endif

" Set some script specific variables:
"
let s:VCSManagerFirstDiffLine = 6

exe 'amenu <silent> '.g:VCSCommandMenuRoot.'.'.'Manage'.' '.':VCSManager<CR>'

command VCSManager call s:VCSManager()
function s:VCSManager()

    " open cwd in buffer
    exe 'edit '.getcwd()
"return
    " open status window in cwd
    exe "VCSStatus '.'"
    " close old buffer
    wincmd k
    bd!

    " Mark the current location of the line
    let b:currentDiff = line(".")

    " set comment string
    let b:commentstring = '# '

    " Check for an internationalized version of diff ?
    call <SID>GetDiffStrings()

    " add some help
    call append(0, "")
"    call append(0, "Diff Args:" . cmdarg)
"    call append(0, "Options: 'u'=update,'x'=set excludes,'i'=set ignore,'a'=set args" )
    call append(0, "Usage:   <Enter>/'o'=open,'c'=commit,'\\dj'=next,'\\dk'=prev, 'q'=quit")
    " go to the beginning of the file
    0
    setlocal nomodified
    setlocal nomodifiable
    setlocal buftype=nowrite
    setlocal bufhidden=delete
    setlocal nowrap

    " Set up local key bindings
"    nnoremap <buffer> s :. call <SID>VCSManagerSync()<CR>
"    vnoremap <buffer> s :call <SID>VCSManagerSync()<CR>
    nnoremap <buffer> u :call <SID>VCSManagerUpdate()<CR>
    nnoremap <buffer> c :call <SID>VCSManagerCommit()<CR>
    nnoremap <buffer> d :call <SID>VCSManagerDelete()<CR>
"    nnoremap <buffer> a :call <SID>ChangeArguments()<CR>
    nnoremap <buffer> i :call <SID>VCSManagerChangeIgnore()<CR>
"    nnoremap <buffer> q :call <SID>VCSManagerQuit()<CR>

"    nnoremap <buffer> o    :call <SID>VCSManagerOpen()<CR>
    nnoremap <buffer> <CR>  :call <SID>VCSManagerOpen()<CR>
    nnoremap <buffer> <2-Leftmouse> :call <SID>VCSManagerOpen()<CR>
    call <SID>SetupSyntax()

    " Open the first diff
"    call <SID>VCSManagerNext()
endfunction

function <SID>GetDiffStrings()
    let s:VCSManagerDiffOnlyLineCenter = g:VCSManagerTextOnlyInCenter
    let s:VCSManagerDiffOnlyLine = g:VCSManagerTextOnlyIn
    let s:VCSManagerDifferLine = g:VCSManagerReChanged
    let s:VCSManagerStatus = g:VCSManagerReStatus
    return
endfunction

" Set up syntax highlighing for the diff window
function <SID>SetupSyntax()
  if has("syntax") && exists("g:syntax_on") 
"    syn match VCSManagerSrcA               "\[A\]"
"    syn match VCSManagerSrcB               "\[B\]"
    syn match VCSManagerUsage              "^Usage.*"
    syn match VCSManagerOptions            "^Options.*"
    exec 'syn match VCSManagerFiles              "' . s:VCSManagerDifferLine .'"'
    exec 'syn match VCSManagerOnly               "' . s:VCSManagerDiffOnlyLine . '"'
"    syn match VCSManagerSelected           "^==>.*"
"    contains=VCSManagerSrcA,VCSManagerSrcB

"    hi def link VCSManagerSrcA               Directory
"    hi def link VCSManagerSrcB               Type
    hi def link VCSManagerUsage              Special
    hi def link VCSManagerOptions            Special
    hi def link VCSManagerFiles              PreProc
    hi def link VCSManagerOnly               PreProc
"    hi def link VCSManagerSelected           DiffChange
  endif
endfunction

command VCSManagerOpen call <SID>VCSManagerOpen()
function <SID>VCSManagerOpen()
    " First dehighlight the last marked
    call <SID>DeHighlightLine()

    " Mark the current location of the line
    let b:currentDiff = line(".")

    " Save the number of this window, to which we wish to return
    " This is required in case there are other windows open
    let thisWindow = winnr()

    call <SID>CloseDiffWindows()

    " Ensure we're in the right window
    exec thisWindow.'wincmd w'

    let line = getline(".")
    " Parse the line and see whether it's a "Only in" or "Files Differ"
    call <SID>HighlightLine()
    let fileA = <SID>GetFileNameFromLine(line)
    if <SID>IsOnly(line)
        " We open the file
"        let fileSrc = <SID>ParseOnlySrc(line)
"        if (fileSrc == "A")
"            let fileToOpen = fileA
"        elseif (fileSrc == "B")
"            let fileToOpen = fileB
"        endif
"        split
"        wincmd k
"        silent exec "edit ". <SID>EscapeFileName(fileToOpen)
"        " Fool the window saying that this is diff
"        diffthis
"        wincmd j
"        " Resize the window
"        exe("resize " . g:VCSManagerWindowSize)
"        exe (b:currentDiff)
    elseif <SID>IsDiffer(line)
        "Open the diff windows
        split
        wincmd k
        silent exec "edit ".<SID>EscapeFileName(fileA)
        silent exec "VCSVimDiff"
        " go to left window
        wincmd h

        " Go back to the diff window
        wincmd j
        " Resize the window
"        exe("resize " . g:VCSManagerWindowSize)
"        exe (b:currentDiff)
        " Center the line
"        exe ("normal z.")
    else
        echo "There is no diff at the current line!"
    endif
endfunction

" commit selected files
function <SID>VCSManagerCommit()
    let fileList = <SID>GetFileList()
    let files = join(fileList, ' ')
    echo 'Commit ' . files
    VCSCommit '.files
endfunction

" get list of files to commit
function <SID>GetFileList()
    let filelist = []
    let reLine = '^'.s:VCSManagerDifferLine.'\s\+\S\+$'
    let filename = "<SID>GetFileNameFromLine(getline(line('.')))"
    let addFileToList = 'call add(filelist, '.filename.')'
    let command = 'g/'.reLine.'/'.addFileToList
"    echo command
    exe command
    return filelist
endfunction

" Close the opened diff comparison windows if they exist
function <SID>CloseDiffWindows()
    if (<SID>AreDiffWinsOpened())
        wincmd k
        " Ask the user to save if buffer is modified
        call <SID>AskIfModified()
        bd!
        " User may just have one window opened, we may not need to close
        " the second diff window
        if (&diff)
            call <SID>AskIfModified()
            bd!
        endif
    endif
endfunction

function <SID>HighlightLine()
    let savedLine = line(".")
    exe (b:currentDiff)
    setlocal modifiable
    let line = getline(".")
    if (match(line, "^    ") == 0)
        s/^    /==> /
    endif
    setlocal nomodifiable
    setlocal nomodified
    exe (savedLine)
    redraw
endfunction

function <SID>DeHighlightLine()
    let savedLine = line(".")
    exe (b:currentDiff)
    let line = getline(".")
    setlocal modifiable
    if (match(line, "^==> ") == 0)
        s/^==> /    /
    endif
    setlocal nomodifiable
    setlocal nomodified
    exe (savedLine)
    redraw
endfunction

" Return filename
function <SID>GetFileNameFromLine(line)
    let reFile = '^'.s:VCSManagerStatus.'\s\+.\{-}\(\S\+\)$'
    let fileToProcess = substitute(a:line, reFile, '\1', '')
"    echom "line : " . a:line. "reFile:".reFile.": File to Process:" . fileToProcess . ":"
    return fileToProcess
endfunction

" The given line begins with the "Files"
function <SID>IsDiffer(line)
"    return (match(a:line, "^ *" . s:VCSManagerDifferLine . "\\|^==> " . s:VCSManagerDifferLine  ) == 0)
    return 1
endfunction

" The given line begins with the "Only in"
function <SID>IsOnly(line)	
"    return (match(a:line, "^ *" . s:VCSManagerDiffOnlyLine . "\\|^==> " . s:VCSManagerDiffOnlyLine ) == 0)
    return 0
endfunction

function <SID>ParseOnlyFile(line)
    let regex = '^.*' . s:VCSManagerDiffOnlyLine . '\[.\]\(.*\)' . s:VCSManagerDiffOnlyLineCenter . '\(.*\)'
    let root = substitute(a:line, regex , '\1', '')
    let file = root . s:sep . substitute(a:line, regex , '\2', '')
    return file
endfunction

function <SID>AreDiffWinsOpened()
    let currBuff = expand("%:p")
    let currLine = line(".")
    wincmd k
    let abovedBuff = expand("%:p")
    if (&diff)
        let abovedIsDiff = 1
    else
        let abovedIsDiff = 0
    endif
    " Go Back if the aboved buffer is not the same
    if (currBuff != abovedBuff)
        wincmd j
        " Go back to the same line
        exe (currLine)
        if (abovedIsDiff == 1)
            return 1
        else
            " Aboved is just a bogus buffer, not a diff buffer
            return 0
        endif
    else
        exe (currLine)
        return 0
    endif
endfunction

function <SID>EscapeFileName(path)
    if (v:version >= 702)
        return fnameescape(a:path)
    else
        " This is not a complete list of escaped character, so it's
        " not as sophisicated as the fnameescape, but this should
        " cover most of the cases and should work for Vim version <
        " 7.2
        return escape(a:path, " \t\n*?[{`$\\%#'\"|!<")
    endif
endfunction

function <SID>VCSManagerNext()
    " If the current window is a diff, go down one
    if (&diff == 1)
        wincmd j
    endif
    " if the current line is <= 6, (within the header range), we go to the
    " first diff line open it
    if (line(".") < s:VCSManagerFirstDiffLine)
        exe (s:VCSManagerFirstDiffLine)
        let b:currentDiff = line(".")
    endif
    silent exe (b:currentDiff + 1)
    call <SID>VCSManagerOpen()
endfunction

" Ask the user to save if the buffer is modified
"
function <SID>AskIfModified()
    if (&modified)
        let input = confirm("File " . expand("%:p") . " has been modified.", "&Save\nCa&ncel", 1)
        if (input == 1)
            w!
        endif
    endif
endfunction

" Update status
function <SID>VCSManagerUpdate()
    call s:VCSManager()
endfunction

" Delete File
function <SID>VCSManagerDelete()
    let filename = <SID>GetFileNameFromLine(getline(line('.')))
    echo filename
    " switch to file (VSCDelete needs this)
    let oldCwd = getcwd()
    exe 'edit '.filename
    let command = 'VCSDelete'
    if !filereadable(filename)
        write
        let command = command.' --force'
    endif
    silent exe command
    wincmd k
    bd!
    call VCSCommandChdir(oldCwd)
    call <SID>VCSManagerUpdate()
endfunction

" Ignore current line
function <SID>VCSManagerChangeIgnore()
    setlocal modifiable
    exe "normal 0I#\<ESC>"
    setlocal nomodified
    setlocal nomodifiable
endfunction
