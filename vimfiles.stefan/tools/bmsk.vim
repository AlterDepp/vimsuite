if exists('nobmsk')
    finish
endif

if !exists('g:Austausch')
    let g:Austausch = fnamemodify('//smuc1805/ee-org/Austausch/ea-92', ':p')
endif
if !exists('g:myAustausch')
    let g:myAustausch = fnamemodify(g:Austausch . '/Liebl', ':p')
endif
 
" ---- 
" Menu
" ---- 
let s:BmskMenuLocation = 90
let s:BMSKmenuname = '&BMSK.'

" -----------
" Set Project
" -----------
command -complete=dir -nargs=1 SetBmskWA let g:bmskWA = '<args>'
command! -complete=custom,GetAllBmskProjects -nargs=? SetBmskProject
            \ call s:SetBmskProject('<args>')

function s:SetBmskProject(basedir)
    if ((a:basedir == '') && has('browse'))
        " Browse for makefile
        if exists('g:bmskWA')
            let l:bmskWA = g:bmskWA
        else
            let l:bmskWA = ''
        endif

        if exists('b:browsefilter')
            let l:browsefilter = b:browsefilter
        endif
        let b:browsefilter = 
                    \ 'Makefiles (make_fsw.bat)\tmake_fsw.bat\n' .
                    \ 'Makefiles (makefile*)\tmakefile*\n' .
                    \ 'All Files (*.*)\t*.*'
        let makefile = browse(0, 'Select makefile', l:bmskWA, '')
        if exists('l:browsefilter')
            let b:browsefilter = l:browsefilter
        endif
        let basedir = fnamemodify(makefile, ':p:h')
        let makefile = fnamemodify(makefile, ':t')
        if ((makefile == 'make_fsw.bat') || (makefile == 'makefile.mak') || (makefile == 'makefile'))
            call s:SetBmskDirs(basedir)
        else
            echo 'No makefile:' makefile
        endif
    else
        " set Workarea and basedir
        if (isdirectory(a:basedir))
            let basedir = a:basedir
            let makefile = fnamemodify(a:basedir . '/make_fsw.bat', ':p')
            if !filereadable(makefile)
                let makefile = glob(a:basedir . '/*/make_fsw.bat')
                let basedir = fnamemodify(makefile, ':p:h')
            endif
            if (filereadable(makefile))
                call s:SetBmskDirs(basedir)
            else
                echo 'No makefile' makefile
            endif
        else
            echo 'No directory:' a:basedir
        endif
    endif
endfunction

function GetAllBmskProjects(ArgLead, CmdLine, CursorPos)
    let projects_txt = fnamemodify($VIMRUNTIME . '/../projects.txt', ':p')
    let projects = ''
"    if exists('g:bmskWA')
"        let projects = projects . GlobLong(g:bmskWA . '/bmsk*')
"    endif
    if filereadable(projects_txt)
        let projects = projects . system('more ' . projects_txt)
    endif
"    if (a:CursorPos > strlen('SetBmskProject e:'))
"        let path = substitute(a:CmdLine, '.*SetBmskProject\s\+\(\f*\)', '\1', '')
"        let projects = projects . GlobLong(path)
"    endif
    return projects
endfunction

function s:AddAllKnownProjectsToMenu()
    let projREGEX = '\(\f\+\)' . "\n" . '\(.*\)'
    let projects = GetAllBmskProjects(0, '', 0)
    while strlen(projects) > 0
        let project = substitute(projects, projREGEX, '\1', '')
        call s:AddBmskProjectToMenu(project)
        let projects = substitute(projects, projREGEX, '\2', '')
    endwhile
endfunction

function s:AddBmskProjectToMenu(projectPath)
    if isdirectory(a:projectPath)
        let projectName = fnamemodify(a:projectPath, ':p:h:t')
        exec 'anoremenu ..30 '.s:BMSKmenuname.'&Project.'
                    \ . escape(projectName, '.') . '<tab>'
                    \ . '   :SetBmskProject ' . a:projectPath . '<CR>'
    endif
endfunction

function s:DelBmskProjects()
    exec 'silent! aunmenu '.s:BMSKmenuname.'&Project'
    exec 'anoremenu '.s:BmskMenuLocation.'.10.10 '.s:BMSKmenuname.
                \'&Project.&Browse\ for\ makefile<tab>:SetBmskProject'.
                \'   :SetBmskProject<CR>'
    exec 'anoremenu ..25 '. s:BMSKmenuname.
                \'&Project.-sep1-  :'
endfunction

function s:BmskRedrawProjectMenu()
    call s:DelBmskProjects()
    call s:AddAllKnownProjectsToMenu()
endfunction

function s:BmskRedrawMenu()
"    exec 'anoremenu '.s:BmskMenuLocation.'.25 '. s:BMSKmenuname.'-sepsuite0-  :'
    " Project
    call s:BmskRedrawProjectMenu()
    if exists('g:bmskdir')
        exec 'anoremenu ..20 '.s:BMSKmenuname.
                    \'&Project.&Update\ Buffers<tab>:BuffersUpdate'.
                    \'   :BuffersUpdate<CR>'
        " Settings
        exec 'anoremenu .20.10 '.s:BMSKmenuname.
                    \'&Settings.&Motorvariante<tab>:SetMotorvariante'.
                    \'   :SetMotorvariante<CR>'
        exec 'anoremenu ..20 '.s:BMSKmenuname.
                    \'&Settings.Hardware-&Muster<tab>:SetMuster'.
                    \'   :SetMuster<CR>'
        exec 'anoremenu ..30 '.s:BMSKmenuname.
                    \'&Settings.&Egas<tab>:SetEgas'.
                    \'   :SetEgas<CR>'
        exec 'anoremenu ..40 '.s:BMSKmenuname.
                    \'&Settings.Software-&Stand<tab>:SetSWStand'.
                    \'   :SetSWStand<CR>'
        " Compile
        exec 'anoremenu .30.10 '.s:BMSKmenuname.
                    \'&Compile.&Build<tab>:Make'.
                    \'   :Make<CR>'
        exec 'anoremenu ..20 '.s:BMSKmenuname.
                    \'&Compile.&Alle\ Teststände<tab>:MakeAll\ Test'.
                    \'   :MakeAll Test<CR>'
        exec 'anoremenu ..30 '.s:BMSKmenuname.
                    \'&Compile.&Lint<tab>:Lint'.
                    \'   :Lint<CR>'
        exec 'anoremenu ..35 '.s:BMSKmenuname.
                    \'&Compile.&Doku\ erstellen<tab>:Make\ doku'.
                    \'   :Make doku<CR>'
        exec 'anoremenu ..36 '.s:BMSKmenuname.
                    \'&Compile.&Einzeldoku\ erstellen<tab>:MakeDoku\ doku\ funktionen="\.\.\."'.
                    \'   :MakeDoku<CR>'
        exec 'anoremenu ..40 '.s:BMSKmenuname.
                    \'&Compile.&Clean<tab>:Make\ clean'.
                    \'   :Make clean<CR>'
        exec 'anoremenu ..45 '.s:BMSKmenuname.
                    \'&Compile.&Clean\ all<tab>:Make\ distclean'.
                    \'   :Make distclean<CR>'
        exec 'anoremenu ..50 '. s:BMSKmenuname.
                    \'&Compile.-sep-  :'
        exec 'anoremenu ..60 '.s:BMSKmenuname.
                    \'&Compile.&Show\ Errors<tab>:cl'.
                    \'   :cl<CR>'
        exec 'anoremenu ..70 '.s:BMSKmenuname.
                    \'&Compile.&Open\ Error\ Window<tab>:copen'.
                    \'   :copen<CR>'
        exec 'anoremenu ..75 '.s:BMSKmenuname.
                    \'&Compile.&Parse\ make\.log<tab>:cfile\ out/make\.log'.
                    \'   :cfile out/make.log<CR>'
        exec 'anoremenu ..80 '.s:BMSKmenuname.
                    \'&Compile.Goto\ &Error<tab>:cc'.
                    \'   :cc<CR>'
        exec 'anoremenu ..90 '.s:BMSKmenuname.
                    \'&Compile.Goto\ &next\ Error<tab>:cn'.
                    \'   :cn<CR>'
        exec 'anoremenu ..100 '. s:BMSKmenuname.
                    \'&Compile.-sep1-  :'
        exec 'anoremenu ..110 '.s:BMSKmenuname.
                    \'&Compile.&A2L-Patch<tab>:A2L'.
                    \'   :A2L<CR>'
        exec 'anoremenu ..120 '.s:BMSKmenuname.
                    \'&Compile.Copy\ output\ to\ &Austausch<tab>:COPYoutput'.
                    \'   :COPYoutput<CR>'
        exec 'anoremenu ..130 '.s:BMSKmenuname.
                    \'&Compile.&Rename\ output<tab>:RENAMEoutput'.
                    \'   :RENAMEoutput<CR>'
        " Tools
        exec 'anoremenu .40.10 '.s:BMSKmenuname.
                    \'&Tools.&A2L-Patch<tab>:A2L'.
                    \'   :A2L<CR>'
        exec 'anoremenu ..20 '.s:BMSKmenuname.
                    \'&Tools.Copy\ output\ to\ &Austausch<tab>:COPYoutput'.
                    \'   :COPYoutput<CR>'
        exec 'anoremenu ..30 '.s:BMSKmenuname.
                    \'&Tools.&Rename\ output<tab>:RENAMEoutput'.
                    \'   :RENAMEoutput<CR>'
        exec 'anoremenu ..40 '. s:BMSKmenuname.
                    \'&Tools.-sep1-  :'
        exec 'anoremenu ..50 '.s:BMSKmenuname.
                    \'&Tools.&Check\ A2L\ Types<tab>:BmskCheckA2l'.
                    \'   :BmskCheckA2l<CR>'
        " Search
        exec 'anoremenu .50.10 '.s:BMSKmenuname.
                    \'&Search.&Grep<tab>:GrepBmsk'.
                    \'   :GrepBmsk<CR>'
        exec 'anoremenu ..20 '.s:BMSKmenuname.
                    \'&Search.Goto\ &Cscope-Tag<tab>:cscope'.
                    \'   :cscope find i <C-R><C-W><CR>'
        exec 'anoremenu ..30 '.s:BMSKmenuname.
                    \'&Search.Goto\ &CTag<tab>:tag'.
                    \'   :tag <C-R><C-W><CR>'
        exec 'anoremenu ..40 '.s:BMSKmenuname.
                    \'&Search.List\ &CTags<tab>:tselect'.
                    \'   :tselect /<C-R><C-W><CR>'
        exec 'anoremenu ..50 '.s:BMSKmenuname.
                    \'&Search.Update\ c&tags<tab>:Make\ ctags'.
                    \'   :Make ctags<CR>'
        exec 'anoremenu ..60 '.s:BMSKmenuname.
                    \'&Search.Update\ C&scope<tab>:Make\ cscope'.
                    \'   :Make cscope<CR>'
        exec 'anoremenu ..70 '.s:BMSKmenuname.
                    \'&Search.Disconnect\ C&scope<tab>:cscope\ kill\ -1'.
                    \'   :cscope kill -1<CR>'
        " BuildManager
        exec 'anoremenu .60.10 '.s:BMSKmenuname.
                    \'&BuildManager.&Entwicklerstand<tab>:MakeAll\ Entwickler'.
                    \'   :MakeAll Entwickler<CR>'
        exec 'anoremenu ..20 '.s:BMSKmenuname.
                    \'&BuildManager.&Serienstand<tab>:MakeAll\ Serie'.
                    \'   :MakeAll Serie<CR>'
        exec 'anoremenu ..30 '.s:BMSKmenuname.
                    \'&BuildManager.&Deliver\ Products<tab>:CopyProgrammstand'.
                    \'   :CopyProgrammstand<CR>'
        exec 'anoremenu ..40 '.s:BMSKmenuname.
                    \'&BuildManager.&Task\ Report<tab>:TaskReport'.
                    \'   :TaskReport<CR>'
    endif
endfunction

" -----------------
" Menü BMSK anlegen
" -----------------
if !exists('nobmskmenu')
    call s:BmskRedrawMenu()
    exec 'anoremenu .42 Hilfe.-BMSK- :'
    exec 'anoremenu .43 Hilfe.BMSK<tab> :help bmsk<CR>'
endif

" -----------------------
" Alle Buffer neu anlegen
" -----------------------
command BuffersUpdate call BuffersUpdate()
function BuffersUpdate()
    " alle Buffer löschen
    let last_buffer = bufnr('$')
    execute '1,' . last_buffer . 'bdelete'

    " load all bmsk-files as buffers
    try
python <<EOF
import vim
import os
basedir = vim.eval('GetBmskDir()')
parsedirs = ['sw', 'config', 'make', 'fremd']
bufferExtentions = ['.c', '.h', '.kgs', '.dat', '.osp', '.mak', '.mkink']
specialFiles = ['makefile']
def AddAllFiles(basedir, path, files):
    print path
    #print 'Extentions:', bufferExtentions
    for file in files:
        bufferExtention = os.path.splitext(file)[1]
        #print 'BufExt:', bufferExtention
        if ((bufferExtention in bufferExtentions) or (file in specialFiles)):
            buffername = os.path.join(path, file).replace(basedir + '//','')
            #print buffername
            vim.command('badd ' + buffername)
# start adding buffers
for dir in parsedirs:
    parsedir = os.path.join(basedir, dir)
    os.path.walk(parsedir, AddAllFiles, basedir)
EOF
    catch /^Vim\%((\a\+)\)\=:E370/	" python not available
        echo 'BuffersUpdate needs python'
    endtry
endfunction

" -----------
" bmsk Muster
" -----------
command -nargs=? SetMuster call SetMuster('<args>')
function SetMuster(Muster)
    if (a:Muster == '')
        let l:Muster = confirm('Muster:', "&default\nC&0\nC&1\nC&2\nC&5", 1, 'Question')
        if l:Muster == 1
            let g:Muster = ''
        elseif l:Muster == 2
            let g:Muster = 'C0'
        elseif l:Muster == 3
            let g:Muster = 'C1'
        elseif l:Muster == 4
            let g:Muster = 'C2'
        elseif l:Muster == 5
            let g:Muster = 'C5'
        else
            echo 'Abbruch'
            return
        endif
    else
        let g:Muster = a:Muster
    endif
    call s:SetBmskDirs(g:bmskdir)
endfunction

" -----------
" bmsk Egas
" -----------
command -nargs=? SetEgas call SetEgas('<args>')
function SetEgas(Egas)
    if (a:Egas == '')
        let l:Egas = confirm('Egas:', "&default\n&0\n&1\n&2", 1, 'Question')
        if l:Egas == 1
            let g:Egas = ''
        elseif l:Egas == 2
            let g:Egas = '0'
        elseif l:Egas == 3
            let g:Egas = '1'
        elseif l:Egas == 4
            let g:Egas = '2'
        else
            echo 'Abbruch'
            return
        endif
    else
        let g:Egas = a:Egas
    endif
    call s:SetBmskDirs(g:bmskdir)
endfunction

" -------------
" bmsk Baureihe
" -------------
command -nargs=? SetMotorvariante call s:SetMotorvariante('<args>')
function s:SetMotorvariante(Motor)
    if a:Motor == ''
        let l:Motor = confirm('Motor:', "&default\nK&25\nK&40\nK&46\nK&71", 1, 'Question')
        if l:Motor == 1
            let g:Motor = ''
        elseif l:Motor == 2
            let g:Motor = 'K25'
        elseif l:Motor == 3
            let g:Motor = 'K40'
        elseif l:Motor == 4
            let g:Motor = 'K46'
            let g:Egas = '1'
        elseif l:Motor == 5
            let g:Motor = 'K71'
        else
            echo 'Abbruch'
            return
        endif
    else
        let g:Motor = a:Motor
    endif
    call s:SetBmskDirs(g:bmskdir)
endfunction

" -------------
" bmsk SW_Stand
" -------------
command -nargs=? SetSWStand call SetSWStand('<args>')
function SetSWStand(SW_Stand)
    if (a:SW_Stand == '')
        let l:SW_Stand = confirm('SW_Stand:', "&default\n&Test\n&Entwickler\n&Serie", 1, 'Question')
        if l:SW_Stand == 1
            let g:SW_Stand = ''
        elseif l:SW_Stand == 2
            let g:SW_Stand = 'Test'
        elseif l:SW_Stand == 3
            let g:SW_Stand = 'Entwickler'
        elseif l:SW_Stand == 4
            let g:SW_Stand = 'Serie'
        else
            echo 'Abbruch'
            return
        endif
    else
        let g:SW_Stand = a:SW_Stand
    endif
    call s:SetBmskDirs(g:bmskdir)
endfunction

" ----------
" bmsk Xlint
" ----------
command -nargs=? SetXlint call SetXlint('<args>')
function SetXlint(Xlint)
    if (a:Xlint == '')
        let l:Xlint = inputdialog('Xlint:', g:Xlint, 'cancel')
        if l:Xlint == 'cancel'
            return
        else
            g:Xlint = l:Xlint
        endif
    else
        let g:Xlint = a:Xlint
    endif
    call s:SetBmskDirs(g:bmskdir)
endfunction


" -----------
" Directories
" -----------

function s:SetBmskDirs(bmskdir)
    " Rücksetzen der Make-Variablen
    unlet! g:OutDir
    unlet! g:ProductDir
    unlet! g:DfilesDir
    unlet! g:CscopeFile
    unlet! g:CTagsFile
    unlet! g:PTagsFile
    unlet! g:Goals
    unlet! g:Programname
    unlet! g:OutDirVariante
    unlet! g:bmsk_stand

    " Variablen erzeugen, damit s:GetMakeVar funktioniert
    if !exists('g:Muster')
        let g:Muster = ''
    endif
    if !exists('g:Egas')
        let g:Egas = ''
    endif
    if !exists('g:Motor')
        let g:Motor = ''
    endif
    if !exists('g:SW_Stand')
        let g:SW_Stand = ''
    endif
    if !exists('g:Xlint')
        let g:Xlint = ''
    endif

    " bmsk dirs
    let g:bmskdir   = substitute(fnamemodify(a:bmskdir, ':p'), '\\', '/', 'g')

    " cd to bmskdir
    execute 'cd ' . g:bmskdir

    " Make
    call s:SetBmskCompiler()

    " Default-Werte aus Make übernehmen
    call GetAllMakeVars()

    if g:Muster == ''
        let g:Muster = s:GetMakeVar('Muster')
    endif
    if g:Egas == ''
        let g:Egas = s:GetMakeVar('Egas')
    endif
    if g:Motor == ''
        let g:Motor = s:GetMakeVar('Motor')
    endif
    if g:SW_Stand == ''
        let g:SW_Stand = s:GetMakeVar('Stand')
    endif
    if g:Xlint == ''
        let g:Xlint = s:GetMakeVar('DIAB_LINT_OPTION')
    endif

    " bmsk dirs
    let g:bmskWA         = fnamemodify(g:bmskdir, ':h:h')
    let g:bmskProject    = fnamemodify(g:bmskdir, ':h:h:t')
    let g:bmsk_sw        = fnamemodify(g:bmskdir . '/sw', ':p')
    let g:bmsk_bios      = fnamemodify(g:bmskdir . '/sw/bios', ':p')
    let g:bmsk_d         = GetDfilesDir()
    let g:bmsk_stand     = GetStandDir()
    let g:OutDir         = GetOutDir()
    let g:OutDirVariante = GetOutDirVariante()
    let g:bmsk_ext       = '*.c *.h *.kgs *.d *.dat *.mak *.inv'

    " cd path
    let &cdpath = g:bmskdir
    " browse-dir
    set browsedir=buffer
    " search path
    set path&
    let &path = &path . ',' . g:bmskdir.''
    let &path = &path . ',' . g:bmskdir.'config/**'
    let &path = &path . ',' . g:bmskdir.'diagnose/**'
    let &path = &path . ',' . g:bmskdir.'doku/**'
    let &path = &path . ',' . g:bmskdir.'fremd/**'
    let &path = &path . ',' . g:bmskdir.'make/**'
    let &path = &path . ',' . g:OutDir
    let &path = &path . ',' . g:OutDir.'defndep/**'
    let &path = &path . ',' . g:OutDir.'doku/**'
    let &path = &path . ',' . g:OutDirVariante.'**'
    let &path = &path . ',' . g:bmskdir.'product/**'
    let &path = &path . ',' . g:bmskdir.'sw/**'
    let &path = &path . ',' . g:bmskdir.'tools/**'
    let &path = substitute(&path, '\\', '/', 'g')
    " files for tags (may not start with './', since . is the path of the
    " current file
    let &tags = substitute(GetCTagsFile(), '^\..', '', '') . ',' . substitute(GetPTagsFile() , '^\..', '', '')

    " Grep Dir and Extentions
    let g:GrepDir = g:bmsk_sw
    let g:GrepFiles = '*.c *.h *.kgs'

    " cscope
    let &cscopeprg = GetCscopePrg()
    cscope kill -1
    let reffile = GetCscopeFile()
    if (filereadable(reffile))
        execute 'cscope add' reffile
    endif

    call s:BmskRedrawMenu()
    call GetGoals()

    " Python
    let g:python = fnamemodify(g:bmskdir . '/tools/python/v2.1a2/python.exe', ':p')

    " Titel-Leiste
    set titlelen=100
    let &titlestring = '%t - (%-F) - %=BMSK: %{g:bmskProject}'
                \ . ' Motor: %{g:Motor} Muster: %{g:Muster} Egas: %{g:Egas} SW-Stand: %{g:SW_Stand}'

endfunction

function s:SetBmskCompiler()
    set errorformat=
    " tex-errorformat laden
    let b:forceRedoTexCompiler = 'yes'
    let g:Tex_ShowallLines = 1
    "execute 'source ' . expand(g:vimfiles . '/compiler/tex.vim')

    let g:makeCommand = g:bmskdir . 'make_fsw.bat'
    let &makeprg = g:makeCommand . ' $*'
    let &shellpipe = '| ' . g:tee
    set makeef=

    " -------------------------------------
    " Diab-Data-Compiler, Assembler, Linker
    " -------------------------------------
    " dcc_info, dcc_warning, dcc_error, dcc_fatal
    setlocal errorformat+=\"%f\"\\,\ line\ %l:\ %t%.%#\ \(dcc:%n\):%m
    " dcc_fatal
    setlocal errorformat+=\"%f\"\\,\ line\ %l:\ %tatal\ error\ \(dcc:%n\):%m
    setlocal errorformat+=%tatal\ error\ \(dcc:%n\):%m
    " das_error
    setlocal errorformat+=\"%f\"\\,\ line\ %l:\ %t[a-z]:%m
    " dld_error
    setlocal errorformat+=d%td:%m
    setlocal errorformat+=d%td.EXE:%m
    " -------
    " PC-Lint
    " -------
    setlocal errorformat+=\"%f\"\\,\ line\ %l:\ %t%.%#\ \(pclint:%n\):%m
    setlocal errorformat+=%t%.%#\ \(pclint:%n\):%m
    " -------
    " SP-Lint
    " -------
    "setlocal errorformat+=%f\(%l,%c\):\ %m
    setlocal errorformat+=%A%f\(%l\):\ %m
    setlocal errorformat+=%A%f\(%l\):
    setlocal errorformat+=%A%f\(%l\\,%c\):\ %m
    setlocal errorformat+=%A%f\(%l\\,%c\):
    setlocal errorformat+=%C\ \ \ \ %m
    " --------
    " GNU-Make
    " --------
    setlocal errorformat+=%f:%l:\ %m
    setlocal errorformat+=%f:%l:%t%.%#:\ %m
    setlocal errorformat+=%+G%.%#make.exe:\ %m
    setlocal errorformat+=%+G%.%#make%.%#.sh:\ %m
    setlocal errorformat+=%+G%.%#mkdir.exe:\ %m
    setlocal errorformat+=%+G%.%#cp.exe:\ %m
    setlocal errorformat+=%+G%.%#rm.exe:\ %m
    " ---------
    " BMSK make
    " ---------
    setlocal errorformat+=bmsk:\ %m
    " ------------
    " python error
    " ------------
    setlocal errorformat+=%+G%.%#python.exe:\ %m
    "setlocal errorformat+=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
    " -----
    " DAMOS
    " -----
    " Damos error
    setlocal errorformat +=%PDAM-S-INPUTFILEOPENED\ %f%*\\s
    setlocal errorformat +=%PDAM-S-OUTPUTFILEOPENED\ %f%*\\s
    setlocal errorformat +=%QDAM-S-FILECLOSED\ %f%*\\s
    "setlocal errorformat +=%PDAM-S-OSP-OPENING-SEQ-OSP\ %f%*\\s
    setlocal errorformat +=%QDAM-S-OSP-CLOSE\ %f%*\\s
    " ignore 'DAM-W-KONS-SW-IGNORED'
    setlocal errorformat+=%-O%.%#DAM-W-KONS-SW-IGNORED
    " Damos Info-Feld
    "setlocal errorformat +=%-I\|\ DAM-I-%m,
    "            \%-Z+-%#
    " Damos Warning- oder Error-Feld
    " DAM-W-...
    setlocal errorformat +=%A\ %#\|\ DAM-%t-%m,
                \%C\ %#\|\%*\\sZeile\ %l%m,
                \%C\ %#\|\%*\\sZeile\ %f:\ %l%m,
                \%C\ %#\|\ %#%m,
                \%-Z\ %#+-%#
    " Damos: Kenngrößen, die in mehr als einer SG-Funktion definiert sind:
    "        Kgs: ... Fkt: ...
    setlocal errorformat +=%+WKenngrößen%m
    setlocal errorformat +=%+WKgs:%m
    " Damos: Ram-Größen, die in einer SG-Funktion enthalten sind,
    "        aber nicht im OSp existieren:
    "        Ram: ... Fkt: ...
    setlocal errorformat +=%+WRam-Größen%m,
                \%+Zaber%m
    " Damos: Lokale Ram-Größen, die referenziert werden:
    "        Ram: ... Fkt: ...
    setlocal errorformat +=%+WLokale\ Ram-Größen%m
    setlocal errorformat +=%+WRam:%m
    "
    setlocal errorformat +=%W%\\%#%#DAM-S-KGR-PLS-EXCEEDED%m:%*\\s,
                \%CDAM-S-KGR-PLS-EXCEEDED%m,
                \%-Z+-%#
    " ignore uninterresting lines
    " ---------------------------
    " ignore 'ignoring option ...'
    setlocal errorformat+=%-Oignoring\ option%.%#
    " ignore 'file: 123: #error ...'
    setlocal errorformat+=%-O%*\\S\ %*\\d:\ #%.%#
endfunction

" make backups
set backup              " keep a backup file
set backupext=~

" Get values for a list of variables as dictionary
function s:GetMakeVars(varNameList)
    let varlist = {}
    try
        let vars = join(a:varNameList, ' ')
        let command = g:makeCommand . ' ' . s:GetMakeOptions() . ' getvar name="' . vars . '"'
        "echomsg command
        let output = system(command)
        let lines = split(output, "\n")
        if len(lines) == 1 && len(a:varNameList) == 1 && match(lines[0], '=') < 0
            " make output: value
            let RE = '\(.*\)'
            let SU = "let varlist['" . vars . "']='\\1'"
        else
            " make output: var=value
            let RE = '^\(\w\+\)=\(.*\)\s*'
            let SU = "let varlist['\\1']='\\2'"
        endif
        "echomsg 'getvars:'
        for line in lines
            "echomsg line
            if match(line, RE) >= 0
                let command = substitute(line, RE, SU, '')
                "echomsg command
                execute command
            endif
        endfor
        "echomsg ''
    catch
        echomsg 'Could not read make variables'
    endtry

    if varlist == {}
        echomsg 'Could not read any variables from makefile'
        echo 'Command:' command
        echo 'Make output is:'
        for line in lines
            echo line
        endfor
        echo '---'
    endif
    return varlist
endfunction

function s:GetMakeVar(varName)
    let var = s:GetMakeVars([a:varName])
    try
        let varValue = var[a:varName]
    catch
        let varValue = ''
        echomsg 'Could not read make-variable "' . a:varName . '"'
    endtry
    return varValue
endfunction

"-------------------------
function GetAllMakeVars()
"-------------------------
    let varnames = {}
    let varnames['Muster']          = 'Muster'
    let varnames['Egas']            = 'Egas'
    let varnames['Motor']           = 'Motor'
    let varnames['SW_Stand']        = 'Stand'
    let varnames['Xlint']           = 'DIAB_LINT_OPTION'
    let varnames['OutDir']          = 'OUTDIR'
    let varnames['ProductDir']      = 'OUTDIR_PRODUCTS'
    let varnames['DfilesDir']       = 'OUTDIR_D_FILES'
    let varnames['bmsk_stand']      = 'OUTDIR_STAND'
    let varnames['OutDirVariante']  = 'OUTDIR_VARIANTE'
    let varnames['CscopePrg']       = 'CSCOPE'
    let varnames['CscopeFile']      = 'CSCOPEFILE'
    let varnames['CTagsFile']       = 'CTAGFILE'
    let varnames['PTagsFile']       = 'PTAGFILE'
    let varnames['Goals']           = 'GOALS'
    let varnames['Programname']     = 'PROGRAMNAME'
    let varlist = s:GetMakeVars(values(varnames))
    for var in items(varnames)
        if has_key(varlist, var[1])
            let g:{var[0]} = varlist[var[1]]
        endif
    endfor
endfunction

" -------------------
function GetBmskDir()
" -------------------
    if !exists('g:bmskdir')
        echo 'Bitte erst Projekt wählen'
        SetBmskProject
    endif
    return g:bmskdir
endfunction

" ---------------------
function GetBmskSwDir()
" ---------------------
    if !exists('g:bmskdir')
        echo 'Bitte erst Projekt wählen'
        SetBmskProject
    endif
    return g:bmsk_sw
endfunction

" ------------------
function GetOutDir()
" ------------------
    if !exists('g:OutDir')
        let g:OutDir = s:GetMakeVar('OUTDIR')
    endif
    if (g:OutDir != '')
        let g:OutDir = fnamemodify(g:OutDir, ':p')
    endif
    return g:OutDir
endfunction

" ----------------------
function GetProductDir()
" ----------------------
    if !exists('g:ProductDir')
        let g:ProductDir = s:GetMakeVar('DELIVERY_PATH')
        if (g:ProductDir == '')
            let g:ProductDir = s:GetMakeVar('OUTDIR_PRODUCTS')
        endif
    endif
    if (g:ProductDir != '')
        let g:ProductDir = fnamemodify(g:ProductDir, ':p')
    endif
    return g:ProductDir
endfunction

" ---------------------
function GetDfilesDir()
" ---------------------
    if !exists('g:DfilesDir')
        let g:DfilesDir = s:GetMakeVar('D_FILES_DIR')
        if (g:DfilesDir == '')
            let g:DfilesDir = s:GetMakeVar('OUTDIR_D_FILES')
        endif
        if (g:DfilesDir != '')
            let g:DfilesDir = fnamemodify(g:DfilesDir, ':p')
        endif
    endif
    return g:DfilesDir
endfunction

" --------------------
function GetStandDir()
" --------------------
    if !exists('g:bmsk_stand')
        let g:bmsk_stand = s:GetMakeVar('OUTDIR_STAND')
    endif
    if (g:bmsk_stand != '')
        let g:bmsk_stand = fnamemodify(g:bmsk_stand, ':p')
    endif
    return g:bmsk_stand
endfunction

" --------------------------
function GetOutDirVariante()
" --------------------------
    if !exists('g:OutDirVariante')
        let g:OutDirVariante = s:GetMakeVar('OUTDIR_VARIANTE')
    endif
    if (g:OutDirVariante != '')
        let g:OutDirVariante = fnamemodify(g:OutDirVariante, ':p')
    endif
    return g:OutDirVariante
endfunction

" ----------------------
function GetCscopePrg()
" ----------------------
    if !exists('g:CscopePrg')
        let g:CscopePrg = s:GetMakeVar('CSCOPE')
    endif
    if (g:CscopePrg != '')
        let g:CscopePrg = fnamemodify(g:CscopePrg, ':p')
    endif
    return g:CscopePrg
endfunction

" ----------------------
function GetCscopeFile()
" ----------------------
    if !exists('g:CscopeFile')
        let g:CscopeFile = s:GetMakeVar('CSCOPEFILE')
    endif
    if (g:CscopeFile != '')
        let g:CscopeFile = fnamemodify(g:CscopeFile, ':p')
    endif
    return g:CscopeFile
endfunction

" ---------------------
function GetCTagsFile()
" ---------------------
    if !exists('g:CTagsFile')
        let g:CTagsFile = s:GetMakeVar('CTAGFILE')
    endif
    if (g:CTagsFile != '')
        let g:CTagsFile = fnamemodify(g:CTagsFile, ':p')
    endif
    return g:CTagsFile
endfunction

" ---------------------
function GetPTagsFile()
" ---------------------
    if !exists('g:PTagsFile')
        let g:PTagsFile = s:GetMakeVar('PTAGFILE')
    endif
    if (g:PTagsFile != '')
        let g:PTagsFile = fnamemodify(g:PTagsFile, ':p')
    endif
    return g:PTagsFile
endfunction

" -----------------
function GetGoals()
" -----------------
    if !exists('g:Goals')
        let g:Goals = s:GetMakeVar('GOALS')
    endif
    return g:Goals
endfunction

" -----------------------
function GetProgramname()
" -----------------------
    if !exists('g:Programname')
        let g:Programname = s:GetMakeVar('PROGRAMNAME')
    endif
    return g:Programname
endfunction

" define and include
"set define=^#\s*define
"set include=^#\s*include
"set includeexpr=''

"command CleanSRCfile %s/\.L\d{3,4\}/.L0000/ce
"command CleanSRCfile %s/^#\tr\d\{1,2\}\t\t\$\$\d\{2,3\}\n//ce
command CleanSRCfile %s/^#\t\(\(r\d\{1,2\}\t\)\|\(not allocated\)\)\t\(\(\$\$\d\{1,3\}\)\|\([xyz]\)\)\n//ce

"function s:GetA2Lfile()
"    let a2lfile = glob(GetProductDir() . '/*.a2l')
"    return a2lfile
"endfunction

" ----
" tags
" ----

command CscopeConnect call s:CscopeConnect()
function s:CscopeConnect()
    let reffile = GetCscopeFile()
    if (filereadable(reffile))
        execute 'cscope add' reffile
    endif
endfunction

" significant characters in tags
set taglength=0
set notagrelative

" ------------
" grep program
" ------------
command -nargs=? GrepBmsk call GrepFull(GetBmskSwDir(), '*.c *.h *.kgs', '<args>')

" ----------------
" Make and compile
" ----------------
command -complete=custom,GetAllBmskTargets -nargs=* Make call s:Make('<args>')
command -complete=custom,GetAllBmskTargets -nargs=* MakeDoku call s:MakeDoku('<args>')
command -nargs=* Lint Make <args> %:t:r.lint
command -complete=customlist,GetAllBmskSWStand -nargs=1 MakeAll call s:MakeAll('<args>')

" Programmstand compilieren
function s:Make(args)
    echo a:args
    cscope kill -1
    call s:SetBmskCompiler()
    execute 'make! ' . a:args .' '. s:GetMakeOptions()
    CscopeConnect
    clist
endfunction

function s:GetMakeOptions()
    let makeopts = ''
    if (g:Motor != '')
        let makeopts = makeopts . ' Motor=' . g:Motor
    endif
    if (g:Muster != '')
        let makeopts = makeopts . ' Muster=' . g:Muster
    endif
    if (g:Egas != '')
        let makeopts = makeopts . ' Egas=' . g:Egas
    endif
    if (g:Xlint != '')
        let makeopts = makeopts . ' DIAB_LINT_OPTION=' . g:Xlint
    endif
    if (g:SW_Stand != '')
        let makeopts = makeopts . ' Stand=' . g:SW_Stand
    endif
    return makeopts
endfunction

" Dokumentation erzeugen (Verwenden des LaTeX errorparsers)
function s:MakeDoku(args)
    echo a:args
    let command = 'Make ' . a:args . ' '
    if match(a:args, '\(^\|\s\)\w\+\($\|\s\+\)') < 0
        " kein Target angegeben, doku verwenden
        let command = command . 'doku '
    endif
    if match(a:args, '\<funktionen\>') < 0
        " keine Funktionen angegeben
        if &filetype == 'tex'
            let funktionen = expand('%:t:r')
        else
            let funktionen = ''
        endif
        let funktionen = inputdialog('funktionen:', funktionen, 'cancel')
        if funktionen == 'cancel'
            return
        endif
        let command = command . 'funktionen="' . funktionen . '"'
    endif

    cscope kill -1
    compiler tex
    let &makeprg = g:makeCommand . ' $*'
    let latexflags = '-interaction=nonstopmode'
    execute command . ' LATEXFLAGS=' . latexflags
    CscopeConnect
    clist
endfunction

" Erzeugen aller Programmstände
function s:MakeAll(Stand)
    " Software Stand gegebenenfalls einstellen
    if (a:Stand != '') && (g:SW_Stand != a:Stand)
        call SetSWStand(a:Stand)
    endif
    execute 'Make all' . g:SW_Stand
endfunction

" Alle Software-Stände als VimList
function GetAllBmskSWStand(ArgLead, CmdLine, CursorPos)
    let StandList = ['Test', 'Entwickler', 'Serie']
    return StandList
endfunction

" Alle Make-Targets als Text Liste
function GetAllBmskTargets(ArgLead, CmdLine, CursorPos)
    let goals = GetGoals()
    if goals == ''
        let targets = 'Programmstand'
        let targets = targets . "\n" . 'clean'
        let targets = targets . "\n" . 'cleanall'
        let targets = targets . "\n" . 'cleanProducts'
        let targets = targets . "\n" . 'allTest'
        let targets = targets . "\n" . 'allEntwickler'
        let targets = targets . "\n" . 'allSerie'
        let targets = targets . "\n" . 'patch_a2l'
        let targets = targets . "\n" . 'check_memory'
        let targets = targets . "\n" . 'create_csv'
        let targets = targets . "\n" . 'create_arcus_csv'
        let targets = targets . "\n" . 'import_arcus_csv'
        let targets = targets . "\n" . 'boschsig'
        let targets = targets . "\n" . 'archivate'
        let targets = targets . "\n" . 'lint file=' . expand('%:p')
        let targets = targets . "\n" . 'tags'
        let targets = targets . "\n" . 'ctags'
        let targets = targets . "\n" . 'ptags'
        let targets = targets . "\n" . 'cscope'
        let targets = targets . "\n" . 'ccm_products_checkout CCM=' . g:ccm
        let targets = targets . "\n" . 'help'
    else
        let targets = substitute(goals, '\s\+', '\n', 'g')
        let targets = targets . "\n" . expand('%:t:r') . '.obj'
        let targets = targets . "\n" . expand('%:t:r') . '.i'
        let targets = targets . "\n" . expand('%:t:r') . '.src'
        let targets = targets . "\n" . expand('%:t:r') . '.lint'
        let targets = targets . "\n" . 'FORCE_PROGID=no'
        let targets = targets . "\n" . 'MAKE_DBG=2'
        let targets = targets . "\n" . 'EXTRA_C_FLAGS='
        let targets = targets . "\n" . 'DIAB_OPTIMIZE='
        let targets = targets . "\n" . 'MAIN_MAKEFILES='
        let targets = targets . "\n" . 'ALL_EXIT='
    endif
    return targets
endfunction

" -----------------------------------
" include extra-variables to a2l-file
" -----------------------------------
command PatchA2L call s:A2L_EXTENTION()
function s:A2L_EXTENTION()
    call s:SetBmskCompiler()
    execute '!start make_fsw.bat patch_a2l ' . s:GetMakeOptions() . ' & pause'
endfunction

" -------------------------------------
" Compilierte Files auf Server copieren
" -------------------------------------
command COPYoutput call s:CopyOutputFilesToAustausch()
function s:CopyOutputFilesToAustausch()
    let destination = fnamemodify(g:myAustausch . '/' . g:Motor . g:Muster . g:Egas, ':p')
    echo destination
    if isdirectory(g:myAustausch)==0
        echo 'mkdir Liebl'
        call system(g:mkdir . g:myAustausch)
    endif
    if isdirectory(destination)==0
        echo 'mkdir' destination
        call system(g:mkdir . destination)
    endif
    call system(g:rm_f . destination . '\*.*')
    let sourceDir = GetProductDir()
    call s:CopyOutputFiles(sourceDir, destination)
endfunction

command CopyProgrammstand call s:CopyProgrammstand()
function s:CopyProgrammstand()
    let pstDir = browsedir('Verzeichnis des Programmstands', 'c:')
    let Variants = s:GetOutputVariants()
    for variante in Variants
        let varianteOrig = fnamemodify(GetOutDirVariante(), ':h:t')
        let sourceDir = substitute(GetProductDir(), varianteOrig, variante, '')
        let destDir = expand(pstDir . '/' . strpart(variante, 0, 2) . 'x' . '/' . variante)
        if !isdirectory(destDir)
            echo destDir . ' is not a directory'
        else
            call system(g:cp . sourceDir . '\\*.* ' . destDir)
        endif
    endfor
endfunction

function! s:GetOutputVariants()
    let Variants = split(system('dir /B out\\K*'), "\n")
    return Variants
endfunction

function s:CopyOutputFiles(sourceDir, destination)
    let destination = fnamemodify(a:destination, ':p')
    let ProgID = GetProgramname()
    let files = fnamemodify(a:sourceDir . '/' . ProgID, ':p') . '*.*'
    let command = g:cp . files . ' ' . destination
    echo command
    call system(command)
    let files = fnamemodify(a:sourceDir . '/' . strpart(ProgID, 3, 3) . '*.daf', ':p')
    let command = g:cp . files . ' ' . destination
    echo command
    call system(command)
endfunction

" ----------------------------
" Compilierte Files umbenennen
" ----------------------------
command -nargs=? RENAMEoutput call s:RENAMEoutput('<args>')
function s:RENAMEoutput(pattern)
    if (a:pattern == '')
        let l:pattern = inputdialog('pattern:', '_test01', '')
    else
        let l:pattern = a:pattern
    endif
    let product_path = GetProductDir()
    let ProgID = GetProgramname()
    call s:RenameFile(fnamemodify(product_path . '/' . ProgID . '.DCM', ':p'), l:pattern)
    call s:RenameFile(fnamemodify(product_path . '/' . ProgID . '.ELF', ':p'), l:pattern)
    call s:RenameFile(fnamemodify(product_path . '/' . ProgID . '.a2l', ':p'), l:pattern)
    call s:RenameFile(fnamemodify(product_path . '/' . ProgID . '_patch.a2l', ':p'), l:pattern)
    call s:RenameFile(fnamemodify(product_path . '/' . ProgID . '.map', ':p'), l:pattern)
    call s:RenameFile(fnamemodify(product_path . '/' . ProgID . '.paf', ':p'), l:pattern)
    call s:RenameFile(fnamemodify(product_path . '/' . ProgID . '.s19', ':p'), l:pattern)
    call s:RenameFile(fnamemodify(product_path . '/' . ProgID . '_BOSCH.s19', ':p'), l:pattern)
    call s:RenameFile(fnamemodify(product_path . '/' . strpart(ProgID, 3, 3) . 'BXXXX.daf', ':p'), l:pattern)
endfunction

function s:RenameFile(File, Pattern)
    if (filereadable(a:File))
        let newfile = fnamemodify(a:File, ':p:r') . a:Pattern . '.'
                    \ .  fnamemodify(a:File, ':e')
        call rename(a:File, newfile)
    endif
endfunction

"---------------------
" Task Report erzeugen
"---------------------
command TaskReport call s:TaskReport()
function s:TaskReport()
    let b:browsefilter = 'Textfiles \t*.txt\n'
    let file = browse(1, 'Select File for Task Report', 'c:', g:bmskProject . '.txt')
    execute 'Make ccm_task_report file=' . fnamemodify(file, ':p')
endfunction

" ------------------------------------------
" Überprüfen der File-Inodes der EEEmulation
" ------------------------------------------
command FindEEEmuFile call s:FindEEEmuFile()
function s:FindEEEmuFile()

    let typeFile   = '0000F1DE'
    let address    = 'S325\x\{8}'
    let linebreak  = '\(\x\{2}\n' . address . '\)\?'
    let longword   = '\x\{8}'
    let stateValid = 'BABABABA'
    let fileNames  = '\(000005FB\|000000FC\|000000E5\|000000BB\|00000B55\|00005B55\|00000CCB\|00EEEF15\)'

    let fileNameValid = typeFile
                \ . linebreak
                \ . fileNames
    let fileName = typeFile
                \ . linebreak
                \ . longword
    let fileStateValid = typeFile
                \ . linebreak
                \ . longword
                \ . linebreak
                \ . longword
                \ . linebreak
                \ . stateValid
    let fileState = typeFile
                \ . linebreak
                \ . longword
                \ . linebreak
                \ . longword
                \ . linebreak
                \ . longword
    let fileInode = typeFile
                \ . linebreak
                \ . longword
                \ . linebreak
                \ . longword
                \ . linebreak
                \ . longword

    execute 'syntax match fileInode "'      . fileInode
                \.'"                 contains=address,fileState,fileStateValid'
    execute 'syntax match fileState "'      . fileState
                \.'"hs=e-7 contained contains=address,fileName,fileNameValid'
    execute 'syntax match fileStateValid "' . fileStateValid
                \.'"hs=e-7 contained contains=address,fileName,fileNameValid'
    execute 'syntax match fileName "'       . fileName
                \.'"hs=e-7 contained contains=address'
    execute 'syntax match fileNameValid "'  . fileNameValid
                \.'"hs=e-7 contained contains=address'
    execute 'syntax match address "'        . address
                \.'"       contained contains=fileName,fileNameValid'

    hi def link fileInode      Constant
    hi def link fileState      PreCondit
    hi def link fileStateValid Label
    hi def link fileName       PreCondit
    hi def link fileNameValid  Identifier
    hi def link address        Constant

    " damit mit n weitergesprungen werden kann
    let @/ = typeFile
    setlocal nohlsearch
endfunction
