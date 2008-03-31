" ===========================================================================
"        File: svn.vim
"      Author: Stefan Liebl (S.Liebl@gmx.de)
" Description: handles version controlling with subversion
" ===========================================================================

if !exists('g:svn')
    let g:svn       = 'svn '
endif

let g:SVNlogfile = fnamemodify(tempname(),':h') . '/SVNmessage.log'

"  --------
"  commands
"  --------
command -nargs=? SVNdiff   silent call s:SVNdiff('<args>')
command -nargs=? SVNcommit call s:SVNcommit('<args>')
command -nargs=0 SVNstatus call s:SVNstatus()
command -nargs=0 SVNupdate call s:SVNupdate()
command -nargs=0 SVNlog    call s:SVNlog()
command -nargs=? SVNadd    call s:SVNadd('<args>')
command -nargs=0 SVNstudio call s:SVNstudio()

" ----
" Menu
" ----
let s:SVNMenuLocation = 100
let s:SVNmenuname = '&SVN.'

"-------------------------
function s:SVNRedrawMenu()
"-------------------------
    exec 'anoremenu '.s:SVNMenuLocation.'.5 '.s:SVNmenuname.
                \'&SVNstudio<tab>:SVNstudio'.
                \'   :SVNstudio<CR>'
    exec 'anoremenu '.s:SVNMenuLocation.'.10 '.s:SVNmenuname.
                \'&status<tab>:SVNstatus'.
                \'   :SVNstatus<CR>'
    exec 'anoremenu '.s:SVNMenuLocation.'.15 '.s:SVNmenuname.
                \'&update<tab>:SVNupdate'.
                \'   :SVNupdate<CR>'
    exec 'anoremenu '.s:SVNMenuLocation.'.20 '.s:SVNmenuname.
                \'&diff<tab>:SVNdiff'.
                \'   :SVNdiff<CR>'
    exec 'anoremenu '.s:SVNMenuLocation.'.30 '.s:SVNmenuname.
                \'&commit<tab>:SVNcommit'.
                \'   :SVNcommit<CR>'
    exec 'anoremenu '.s:SVNMenuLocation.'.40 '.s:SVNmenuname.
                \'&log<tab>:SVNlog'.
                \'   :SVNlog<CR>'
    exec 'anoremenu '.s:SVNMenuLocation.'.50 '.s:SVNmenuname.
                \'&add<tab>:SVNadd'.
                \'   :SVNadd<CR>'
endfunction

if !exists('nosvnmenu')
    call s:SVNRedrawMenu()
endif

"----------------------------
function s:SVNcommit(logfile)
"----------------------------
        if filereadable(a:logfile)
            let options = '--file ' . a:logfile
        elseif a:logfile == ''
            let options = ''
        else
            echoerr 'Messagefile for SVNcommit not found: ' . a:logfile
            return
        endif

        " save all files
        wa

        let expression = g:svn . ' commit ' . options
        echo expression
        let output = system(expression)
        echo output
        let expression = g:svn . ' update'
        let output = system(expression)
        echo output

        if filereadable(a:logfile)
            call delete(a:logfile)
        endif
endfunction

"---------------------
function s:SVNupdate()
"---------------------
        let expression = g:svn . ' update'
        let output = system(expression)
        echo output
endfunction

"---------------------
function s:SVNstatus()
"---------------------
        let expression = g:svn . ' status'
        let output = system(expression)
        echo output
endfunction

"---------------------
function s:SVNlog()
"---------------------
        let expression = g:svn . ' log'
        let output = system(expression)
        echo output
endfunction

"------------------------
function s:SVNdiff(input)
"------------------------
    " default
    let revision = ''
    if a:input == ''
        " ohne Argument einfach aktuelles File mit Headrevision vergleichen
        let filename = expand('%:p')
    else
        if filereadable(a:input)
            " mit Filenamen einfach File mit Headrevision vergleichen
            let filename = a:input
        elseif str2nr(a:input) == a:input
            " Argument ist die Revision, mit der verglichen werden soll
            let revision = '-r '.a:input.' '
            let filename = expand('%:p')
        else
            echo 'Falsches Argument: '.a:input
            exit
        endif
    endif

    if filereadable(filename)
        " open file in new tab
        execute 'tabnew ' . filename
        " store filetype
        let filetype = &filetype
        " open headrevision
        let headrevision = tempname()
        let command = '!' . g:svn . 'cat ' . revision . filename . ' > ' . headrevision
        silent execute command
        if winnr()==1
            execute 'vsplit ' . headrevision
        else
            wincmd h
            execute 'view ' . headrevision
        endif
        " set filetype
        let &filetype=filetype
        diffthis
        wincmd l
        diffthis
    elseif isdirectory(filename)
        echo filename . ' is a directory'
    else
        echoerr 'file ' . filename . ' not found'
    endif
endfunction

"--------------------------
function s:SVNadd(filename)
"--------------------------
    if a:filename == ''
        let filename = expand('%:p')
    else
        let filename = a:filename
    endif

    let expression = g:svn . ' add ' . filename
    echo expression
    let output = system(expression)
    echo output
endfunction
"

"---------------------
function s:SVNstudio()
"---------------------
    " Log-Message unten öffnen
    setlocal splitbelow
    silent execute '20split' g:SVNlogfile
    w

    " Status-Meldung in Temp-File umleiten
    let tempfile = tempname()
    " File anzeigen
    silent execute 'vsplit'  tempfile
    call SVNwriteWindow(tempfile)

    " Show differences
    nmap <buffer> <CR>  :execute 'SVNdiff' SVNstudioGetFilename(getline("."))<CR>
    nmap <buffer> <C-l> :silent execute '!' . g:svn . 'status > ' . g:SVNlogfile<CR>
    nmap <buffer> <C-c> :execute 'SVNcommit' g:SVNlogfile<CR>
    nmap <buffer> <C-a> :execute 'SVNadd' g:SVNlogfile<CR>
    nmap <buffer> <C-s> :call SVNwriteWindow(expand('%:p'))<CR>
endfunction

"----------------------------
function SVNwriteWindow(file)
"----------------------------
    normal ggdG
    normal oSVN studio
    normal ostatus message is displayed in this window
    normal oenter log message in right hand window
    normal o
    normal o<CR>    show differences of file under cursor
    normal o<C-l>   copy status-info to log-window
    normal o<C-c>   commit changes with logmessage in right window
    normal o<C-a>   add file under cursor to repository
    normal o<C-s>   update status window
    normal o
    normal o-------------------
    normal o
    w

    let command = '!' . g:svn . 'status >> ' . a:file
    "echo command
    silent execute command
    e
endfunction

"---------------------------------
function SVNstudioGetFilename(line)
"---------------------------------
    let filename = substitute(a:line, '.\s\+\(.\+\)', '\1', '')
    return filename
endfunction


EchoDebug 'loaded svn.vim'

