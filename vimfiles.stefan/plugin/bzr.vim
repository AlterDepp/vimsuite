" ===========================================================================
"        File: bzr.vim
"      Author: Stefan Liebl (S.Liebl@gmx.de)
" Description: handles version controlling with subversion
" ===========================================================================

if !exists('g:bzr')
    let g:bzr      = 'bzr '
endif

let g:BZRlogfile = fnamemodify(tempname(),':h') . '/BZRmessage.log'

"  --------
"  commands
"  --------
command -nargs=? BZRdiff   silent call s:BZRdiff('<args>')
command -nargs=? BZRcommit call s:BZRcommit('<args>')
command -nargs=0 BZRstatus call s:BZRstatus()
command -nargs=0 BZRupdate call s:BZRupdate()
command -nargs=0 BZRlog    call s:BZRlog()
command -nargs=? BZRadd    call s:BZRadd('<args>')
command -nargs=0 BZRstudio call s:BZRstudio()

" ----
" Menu
" ----
let s:BZRMenuLocation = 100
let s:BZRmenuname = '&BZR.'

"-------------------------
function s:BZRRedrawMenu()
"-------------------------
    exec 'anoremenu '.s:BZRMenuLocation.'.5 '.s:BZRmenuname.
                \'&BZRstudio<tab>:BZRstudio'.
                \'   :BZRstudio<CR>'
    exec 'anoremenu '.s:BZRMenuLocation.'.10 '.s:BZRmenuname.
                \'&status<tab>:BZRstatus'.
                \'   :BZRstatus<CR>'
    exec 'anoremenu '.s:BZRMenuLocation.'.15 '.s:BZRmenuname.
                \'&update<tab>:BZRupdate'.
                \'   :BZRupdate<CR>'
    exec 'anoremenu '.s:BZRMenuLocation.'.20 '.s:BZRmenuname.
                \'&diff<tab>:BZRdiff'.
                \'   :BZRdiff<CR>'
    exec 'anoremenu '.s:BZRMenuLocation.'.30 '.s:BZRmenuname.
                \'&commit<tab>:BZRcommit'.
                \'   :BZRcommit<CR>'
    exec 'anoremenu '.s:BZRMenuLocation.'.40 '.s:BZRmenuname.
                \'&log<tab>:BZRlog'.
                \'   :BZRlog<CR>'
    exec 'anoremenu '.s:BZRMenuLocation.'.50 '.s:BZRmenuname.
                \'&add<tab>:BZRadd'.
                \'   :BZRadd<CR>'
endfunction

if !exists('nobzrmenu')
    call s:BZRRedrawMenu()
endif

"----------------------------
function s:BZRcommit(logfile)
"----------------------------
        if filereadable(a:logfile)
            let options = '--file ' . a:logfile
        elseif a:logfile == ''
            let options = ''
        else
            echoerr 'Messagefile for BZRcommit not found: ' . a:logfile
            return
        endif

        " save all files
        wa

        let expression = g:bzr . ' commit ' . options
        echo expression
        let output = system(expression)
        echo output
        let expression = g:bzr . ' update'
        let output = system(expression)
        echo output

        if filereadable(a:logfile)
            call delete(a:logfile)
        endif
endfunction

"---------------------
function s:BZRupdate()
"---------------------
        let expression = g:bzr . ' update'
        let output = system(expression)
        echo output
endfunction

"---------------------
function s:BZRstatus()
"---------------------
        let expression = g:bzr . ' status'
        let output = system(expression)
        echo output
endfunction

"---------------------
function s:BZRlog()
"---------------------
        let expression = g:bzr . ' log'
        let output = system(expression)
        echo output
endfunction

"------------------------
function s:BZRdiff(input)
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
        let command = '!' . g:bzr . 'cat ' . revision . filename . ' > ' . headrevision
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
function s:BZRadd(filename)
"--------------------------
    if a:filename == ''
        let filename = expand('%:p')
    else
        let filename = a:filename
    endif

    let expression = g:bzr . ' add ' . filename
    echo expression
    let output = system(expression)
    echo output
endfunction
"

"---------------------
function s:BZRstudio()
"---------------------
    " Log-Message unten öffnen
    setlocal splitbelow
    silent execute '20split' g:BZRlogfile
    w

    " Status-Meldung in Temp-File umleiten
    let tempfile = tempname()
    " File anzeigen
    silent execute 'vsplit'  tempfile
    call BZRwriteWindow(tempfile)

    " Show differences
    nmap <buffer> <CR>  :execute 'BZRdiff' BZRstudioGetFilename(getline("."))<CR>
    nmap <buffer> <C-l> :silent execute '!' . g:BZR . 'status > ' . g:BZRlogfile<CR>
    nmap <buffer> <C-c> :execute 'BZRcommit' g:BZRlogfile<CR>
    nmap <buffer> <C-a> :execute 'BZRadd' g:BZRlogfile<CR>
    nmap <buffer> <C-s> :call BZRwriteWindow(expand('%:p'))<CR>
endfunction

"----------------------------
function BZRwriteWindow(file)
"----------------------------
    normal ggdG
    normal oBZR studio
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

    let command = '!' . g:bzr . 'status >> ' . a:file
    "echo command
    silent execute command
    e
endfunction

"---------------------------------
function BZRstudioGetFilename(line)
"---------------------------------
    let filename = substitute(a:line, '.\s\+\(.\+\)', '\1', '')
    return filename
endfunction


EchoDebug 'loaded bzr.vim'

