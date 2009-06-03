" ===========================================================================
"        File: ccm.vim
"      Author: Stefan Liebl (S.Liebl@gmx.de)
" Description: handles version controlling with Continuus
" ===========================================================================

if exists('g:noccm')
    finish
endif

"  --------------------------
"  config datei für Continuus
"  --------------------------
if !exists('g:ccm')
    let g:ccm       = 'ccm '
endif


"  --------
"  commands
"  --------
command -nargs=0 CCMconnect    call s:CCMconnect()
command -nargs=? CCMcheckout   call s:CCMcheckout(expand('%:p'), '<args>')
command -nargs=? CCMcheckpoint call s:CCMcheckpoint(expand('%:p'), '<args>')
command -nargs=0 CCMchangeable call s:CCMchangeable('qx13468')
command -nargs=0 CCMdiff       call s:CCMdiff(expand('%:p'))
command -nargs=0 CCMobject     call s:CCM_get_object(expand('%:p'))
command -nargs=0 CCMhistory    call s:CCMhistory(expand('%:p'))

" ----
" Menu
" ----
let s:CCMMenuLocation = 100
let s:CCMmenuname = '&VCS.&CCM.'

"-------------------------
function s:CCMRedrawMenu()
"-------------------------
    exec 'anoremenu '.s:CCMMenuLocation.'.40 '.s:CCMmenuname.
                \'check\ &out<tab>:CCMcheckout'.
                \'   :CCMcheckout<CR>'
    exec 'anoremenu '.s:CCMMenuLocation.'.40 '.s:CCMmenuname.
                \'check&point<tab>:CCMcheckpoint'.
                \'   :CCMcheckpoint ""<CR>'
    exec 'anoremenu '.s:CCMMenuLocation.'.40 '.s:CCMmenuname.
                \'&diff<tab>:CCMdiff'.
                \'   :CCMdiff<CR>'
    exec 'anoremenu '.s:CCMMenuLocation.'.40 '.s:CCMmenuname.
                \'show\ &history<tab>:CCMhistory'.
                \'   :CCMhistory<CR>'
endfunction

if !exists('noccmmenu')
    call s:CCMRedrawMenu()
endif

"  -------------------
"  Regular Expressions
"  -------------------
let s:any = '.*'
let s:word = '\(\w\+\)'
let s:noPathSeparator = '\([^/\\]\+\)'

"-----------------------------
function s:CCM_run_silent(cmd)
"-----------------------------
    let expression = g:ccm .' '. a:cmd
    echo expression
    let output = system(expression)
    return split(output, "\n")
endfunction

"----------------------
function s:CCM_run(cmd)
"----------------------
    call s:CCMconnect()
    let output = s:CCM_run_silent(a:cmd)
    for line in output
        echo line
    endfor
    echo '---'
    return output
endfunction

let s:connected = 0
"-------------------------
function s:CCMconnected()
"-------------------------
    let output = s:CCM_run_silent('status')
    if (match(output, "Current project:") >= 0)
        let s:connected  = 1
    endif
    return s:connected
endfunction

"-----------------------
function s:CCMconnect()
"-----------------------
    if !s:connected
        if !s:CCMconnected()
            let output = s:CCM_run_silent('start')
            let s:connected  = 1
        endif
    endif
endfunction

"---------------------------
function s:Set_compare_cmd()
"---------------------------
    let vimdiff = g:gvim
    let commands = ' -c ' . '\"winsize 201 60\" -c \"set winwidth=100\"'
    let options = ' -d' . ' %file1 %file2' . ' --servername DIFF'
    let compare_cmd = Double_quote(vimdiff . commands . options)
    let output = s:CCM_run('set cli_compare_cmd ' . compare_cmd)
    "let output = s:CCM_run('set compare_cmd')
endfunction

"---------------------------
function s:CCM_query(string)
"---------------------------
    let query_string = 'query ' . a:string
    let query_format = ' /nf /no_sort /u /f ' . '"%objectname"'
    let output = s:CCM_run(query_string . query_format)
    return output
endfunction

"-------------------------------
function s:CCM_get_owner(object)
"-------------------------------
    let query_string = 'properties ' . a:object['objectname']
    let query_format = ' /f ' . '"%owner"'
    let output = s:CCM_run(query_string . query_format)
    return output
endfunction

"--------------------------------
function s:CCM_long_query(string)
"--------------------------------
    let query_string = 'query ' . a:string
    let query_format = ' /u /f ' . '"%objectname %status %owner %task"'
    let output = s:CCM_run(query_string . query_format)
    return output
endfunction

"------------------------------------
function s:CCM_get_project(filename)
"------------------------------------
    " in Verzeichnis des Files wechseln
    let dirname = fnamemodify(a:filename, ':p:h')
    let cwd_old = getcwd()
    execute 'cd ' . dirname
    " project ermitteln
    let query_string = 'work_area -show '
    let output = s:CCM_run(query_string)
    for line in output
        let projectname = substitute(line, '\(\S\+\).*', '\1', '')
    endfor
    if projectname == ''
        echo 'No project found for ' . a:filename
        echo '=============================='
        echo ' '
    endif
    " Verzeichnis zurücksetzen
    execute 'cd ' . cwd_old

    let project = s:CCM_split_object(projectname)
    return project
endfunction

"-----------------------------------
function s:CCM_get_object(filename)
"-----------------------------------
    let basename = fnamemodify(a:filename, ':t')
    let dirname = fnamemodify(a:filename, ':p:h')

    let object = {}
    let project  = s:CCM_get_project(a:filename)
    if project != {}
        let query_string = '"'
                    \ . 'name=' . Single_quote(basename)
                    \ . ' and is_member_of(' . Single_quote(project['displayname']) . ')"'
        let objectnames = s:CCM_query(query_string)
        let object = s:CCM_choose_object(a:filename, objectnames, project)
        if object == {}
            echo 'no object found for ' . a:filename
        else
            echo object['objectname']
        endif
    else
        echo 'No Project'
    endif
    return object
endfunction

"------------------------------------------------------------
function s:CCM_choose_object(filename, objectnames, project)
"------------------------------------------------------------
    let result = {}
    for line in a:objectnames
        let object = s:CCM_split_object(line)
        let objectpath = s:CCM_get_path(object, a:project)
        let object['path'] = objectpath
        if object['path'] == a:filename
            let result = object
        endif
    endfor
    return result
endfunction

"---------------------------------------
function s:CCM_split_object(objectname)
"---------------------------------------
    let object = {}
    let reName = '\([^-]\+\)'
    let reVersion = '\([^:]\+\)'
    let reType = '\([^:]\+\)'
    let reInstance = '\(\d\+\)'
    let regexp =                  reName.'-'.reVersion
    let regexp = regexp.'\%('.':'.reType.':'.reInstance
    let regexp = regexp.'\)\?'
    let object['name'] = substitute(a:objectname, regexp, '\1', '')
    let object['version'] = substitute(a:objectname, regexp, '\2', '')
    let object['type'] = substitute(a:objectname, regexp, '\3', '')
    let object['instance'] = substitute(a:objectname, regexp, '\4', '')
    let object['displayname'] = object['name'].'-'.object['version']
    let object['objectname'] = object['displayname'].':'.object['type'].':'.object['instance']
    return object
endfunction

"----------------------------------------
function s:CCM_get_path(object, project)
"----------------------------------------
    let query_string = 'finduse'
                \ .' /n "'.a:object['name'].'"'
                \ .' /v "'.a:object['version'].'"'
                \ .' /t "'.a:object['type'].'"'
                \ .' /i "'.a:object['instance'].'"'
                \ .' /working_proj'
    let lines = s:CCM_run(query_string)
    for line in lines
        let regexp = '.*\s\(\S*' . a:object['name'] . '\)-'.a:object['version'].'@' . a:project['displayname']
        let relpath = substitute(line, regexp, '\1', '')
        let foundpath = findfile(relpath)
        if foundpath == ''
            let relpath = substitute(relpath, '[^/\\]\+[/\\]\(.*\)', '\1', '')
            let foundpath = findfile(relpath)
        endif
        if foundpath != ''
            let path = fnamemodify(foundpath, ':p')
            return path
        endif
    endfor
    return ''
endfunction

"-----------------------------------
function s:CCM_get_successor(object)
"-----------------------------------
    let query_string = 'is_successor_of(' . Single_quote(a:object['objectname']) . ')'
    let predecessor = s:CCM_query(query_string)
    if predecessor == ''
        echo 'no successor found for ' . a:object['objectname']
    else
        " delete <CR>
        let predecessor = matchstr(predecessor, '\p\+')
    endif
    return predecessor
endfunction

"-------------------------------------
function s:CCM_get_predecessor(object)
"-------------------------------------
    let query_string = 'is_predecessor_of(' . Single_quote(a:object['objectname']) . ')'
    let query_answer = s:CCM_query(query_string)
    let predecessor = {}
    if query_answer[0] == ''
        echo 'no predecessor found for ' . a:object['objectname']
    else
        let predecessorname = matchstr(query_answer, '\p\+')
        let predecessor = s:CCM_split_object(predecessorname)
    endif
    return predecessor
endfunction

"-----------------------------------
function s:CCM_get_hist_root(object)
"-----------------------------------
    let query_string = '"'
                \ . 'name=' . Single_quote(a:object['name'])
                \ . ' and instance=' . Single_quote(a:object['instance'])
                \ . ' and is_hist_root()"'
    let hist_root = s:CCM_query(query_string)
    if hist_root == ''
        echo 'no hist_root found for ' . a:object['objectname']
    else
        let hist_root = matchstr(hist_root, '\p\+')
    endif
    return hist_root
endfunction

"--------------------------------
function s:CCM_get_default_task()
"--------------------------------
    let output = s:CCM_run('task /default')
    if match(output[0], '\d\+') >= 0
        let task = matchstr(output[0], '\d\+')
    else
        let task = 'none'
    endif
    return task
endfunction

"--------------------------------------------------
function s:CCM_check_out(object, project, comment)
"--------------------------------------------------
    let default_task = s:CCM_get_default_task()
    if default_task == 'none'
        echo 'no default task!'
    else
        let comment = '/comment "' . a:comment . '"'
        let task = '/task ' . default_task
        let project = '/project ' . a:project['displayname']
        let object = a:object['objectname']
        let expression = 'checkout ' . comment .' '. task . ' '. object
        " cd to directory
        let objectpath = s:CCM_get_path(a:object, a:project)
        let old_cwd = getcwd()
        execute 'cd ' . fnamemodify(objectpath, ':p:h')
        let output = s:CCM_run(expression)
        " go back
        execute 'cd ' . old_cwd
    endif
endfunction

"----------------------------------------------
function s:CCM_check_in(object, state, comment)
"----------------------------------------------
    let comment = '/comment "' . a:comment . '" '
    let state   = '/state '   . a:state . ' '
    let expression = 'checkin ' . comment . state . a:object['objectname']
    echo 'comment:' . comment
    echo 'state:' . state
    echo 'expression:' . expression
    echo 'execute'
    let output = s:CCM_run(expression)
endfunction

"----------------------------------------
function s:CCMcheckout(filename, comment)
"----------------------------------------
    let object = s:CCM_get_object(a:filename)
    let project = s:CCM_get_project(a:filename)
    if object != {}
        let output = s:CCM_check_out(object, project, a:comment)
    endif
endfunction

"------------------------------------------
function s:CCMcheckpoint(filename, comment)
"------------------------------------------
    let object = s:CCM_get_object(a:filename)
    if object != {}
        if (a:comment == '')
            if has('gui')
                let l:comment = inputdialog('comment:')
            else
                echo 'enter a comment'
                return
            endif
        else
            let l:comment = a:comment
        endif
        let state = 'checkpoint'
        let output = s:CCM_check_in(object, state, l:comment)
    endif
endfunction

"------------------------------
function s:CCMchangeable(owner)
"------------------------------
    let object = ''
    if project == '?'
        let owner        = 'owner=' . Single_quote(a:owner)
        let project      = ' and project=' . Single_quote('bmsk')
        let released     = ' and status!=' . Single_quote('released')
        let integrate    = ' and status!=' . Single_quote('integrate')
        let rejected     = ' and status!=' . Single_quote('rejected')
        let status       = released . integrate . rejected
        let query_string = '"' . owner . project . status . '"'
        let object = s:CCM_long_query(query_string)
    endif
    if object == ''
        echo 'no working objects found for ' . a:owner
    endif
    return object
endfunction

"---------------------------
function s:CCMdiff(filename)
"---------------------------
    let object = s:CCM_get_object(a:filename)
    if object != {}
        let predecessor = s:CCM_get_predecessor(object)
        if predecessor != {}
            let output = s:CCM_run_silent('diff /g ' . predecessor['objectname'] . ' ' . a:filename)
        endif
    endif
endfunction

"---------------------------------
function s:CCM_view_object(object)
"---------------------------------
    let file_content = s:CCM_run_silent('type ' . a:object['objectname'])
    return file_content
endfunction

"------------------------------
function s:CCMhistory(filename)
"------------------------------
    let object = s:CCM_get_object(a:filename)
    if object != {}
        let expression = 'history /g ' . object['objectname']
        let output = s:CCM_run(expression)
    endif
endfunction

"-----------------------
function s:Wait(seconds)
"-----------------------
    let starttime = localtime()
    while ((localtime() - starttime) < a:seconds)
    endwhile
endfunction

"------------------------------
" Funktionen für Change Synergy
"------------------------------

"command ChangeSynergyBeautify call s:ChangeSynergyBeautify()
command ChangeSynergyCreateCRTaskList call s:ChangeSynergyCreateCRTaskList()
command ChangeSynergyCreateCRList call s:ChangeSynergyCreateCRList()
command ChangeSynergyCreateTaskList call s:ChangeSynergyCreateTaskList()

let s:CR_text = 'CR '
let s:Task_text = 'Task '

" Umformatieren der CR-Liste aus dem ChangeSynergy Bericht
function s:ChangeSynergyBeautify()
    DelAllMultipleEmptyLines
    call s:ChangeSynergyDeleteRejected()
    call s:ChangeSynergyFormatTasks()
    call s:ChangeSynergyFormatCRs()
endfunction

" Liste mit allen CRs incl. Tasks aus Bericht
function s:ChangeSynergyCreateCRTaskList()
    call s:ChangeSynergyBeautify()
    let RE = '^\(' . s:CR_text . '.*\)'
    execute ':%s/' . RE . '/\r\1/e'
    normal ggdddw
endfunction

" Liste mit allen CRs aus Bericht
function s:ChangeSynergyCreateCRList()
    call s:ChangeSynergyBeautify()
    let RE = '^' . s:Task_text . '.*\n'
    execute ':%s/' . RE . '//e'
    execute ':3,$sort'
endfunction

" Liste mit allen Tasks aus Bericht
function s:ChangeSynergyCreateTaskList()
    call s:ChangeSynergyBeautify()
    let RE = '^' . s:CR_text . '.*\n'
    execute ':%s/' . RE . '//e'
    execute ':3,$sort'
endfunction

" Löschen der CRs mit Status 'rejected'
function s:ChangeSynergyDeleteRejected()
    let RE = s:ComposeCrTaskRE('rejected')
    execute ':%s/' . RE . '//e'
endfunction

" Task umfomatieren
function s:ChangeSynergyFormatTasks()
    let RE = '\%('
                \ . 'Task Number:\s\+\(\d\+\)'
                \ . '\s\+'
                \ . 'Resolver:\s\+\(.\+\)'
                \ . '\s\+'
                \ . 'Status:\s\+\(\w\+\)'
                \ . '\n'
                \ . 'Synopsis:\s\+\(.*\)'
                \ . '\n'
                \ . '\)'
"    execute '%:s/' . RE . '/' . s:Task_text . '\1\t\2:\t\4/e'
    execute '%:s/' . RE . '/\=printf("%s%4s %-32s: %s", s:Task_text, submatch(1), submatch(2), submatch(4))/e'
endfunction

" CR umfomatieren
function s:ChangeSynergyFormatCRs()
    let RE = '\%('
                \ . 'CR ID:\s\+\(\d\+\)'
                \ . '\s\+'
                \ . 'Resolver:\s\+\(.\+\)'
                \ . '\s\+'
                \ . 'Status:\s\+\(\w\+\)'
                \ . '\n'
                \ . 'Synopsis:\s\+\(.*\)'
                \ . '\n'
                \ . '\)'
"    execute '%:s/' . RE . '/' . s:CR_text . '\1\t\2:\t\4/e'
    execute '%:s/' . RE . '/\=printf("%s  %4s %-32s: %s", s:CR_text, submatch(1), submatch(2), submatch(4))/e'
endfunction

" Zusammensetzen der Regular Expression für ChangeRequests aus dem Bericht
" Open PST + CR + Task
function s:ComposeCrTaskRE(CRstatus)
    if a:CRstatus == ''
        let CRstatus = '\w\+'
    else
        let CRstatus = a:CRstatus
    endif
    let taskRE = '\(Task Number:.*\nSynopsis:.*\n\n\)'
    let crRE = 'CR ID:.*Status:\s\+\(' . CRstatus . '\)\nSynopsis:.*\n\%(\s*\n\)*' . taskRE . '*'
    return crRE
endfunction

EchoDebug 'loaded ccm.vim'

