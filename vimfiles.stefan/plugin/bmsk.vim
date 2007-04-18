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
command -complete=custom,GetAllBmskProjects -nargs=? SetBmskProject
            \ call s:SetBmskProject('<args>')

function s:SetBmskProject(basedir)
    if (a:basedir == '')
        let makefile = ''
    else
        " set Workarea and basedir
        if (isdirectory(a:basedir))
            let basedir = a:basedir
            let makefile = fnamemodify(a:basedir . '/make_fsw.bat', ':p')
            if !filereadable(makefile)
                let makefile = glob(a:basedir . '/*/make_fsw.bat')
            endif
            if !filereadable(makefile)
                echoerr 'No makefile' makefile
            endif
        else
            echoerr 'No directory:' a:basedir
        endif
    endif
    call SetProject(makefile)
    let GetMakeOptsFunction = function('GetBmskMakeOpts')
    let g:GetAllMakeGoals = function('GetAllBmskTargets')
    let basedir = getcwd()
    call s:SetBmskDirs(basedir)
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
                    \'&Compile.&Build<tab>:Bmsk'.
                    \'   :Bmsk<CR>'
        exec 'anoremenu ..20 '.s:BMSKmenuname.
                    \'&Compile.&Alle\ Teststände<tab>:BmskAll\ Test'.
                    \'   :BmskAll Test<CR>'
        exec 'anoremenu ..30 '.s:BMSKmenuname.
                    \'&Compile.&Lint<tab>:Lint'.
                    \'   :Lint<CR>'
        exec 'anoremenu ..35 '.s:BMSKmenuname.
                    \'&Compile.&Doku\ erstellen<tab>:Bmsk\ doku'.
                    \'   :Bmsk doku<CR>'
        exec 'anoremenu ..36 '.s:BMSKmenuname.
                    \'&Compile.&Einzeldoku\ erstellen<tab>:BmskDoku\ doku\ funktionen="\.\.\."'.
                    \'   :BmskDoku<CR>'
        exec 'anoremenu ..40 '.s:BMSKmenuname.
                    \'&Compile.&Clean<tab>:Bmsk\ clean'.
                    \'   :Bmsk clean<CR>'
        exec 'anoremenu ..45 '.s:BMSKmenuname.
                    \'&Compile.&Clean\ all<tab>:Bmsk\ distclean'.
                    \'   :Bmsk distclean<CR>'
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
                    \'&Search.Update\ c&tags<tab>:Bmsk\ ctags'.
                    \'   :Bmsk ctags<CR>'
        exec 'anoremenu ..60 '.s:BMSKmenuname.
                    \'&Search.Update\ C&scope<tab>:Bmsk\ cscope'.
                    \'   :Bmsk cscope<CR>'
        exec 'anoremenu ..70 '.s:BMSKmenuname.
                    \'&Search.Disconnect\ C&scope<tab>:cscope\ kill\ -1'.
                    \'   :cscope kill -1<CR>'
        " BuildManager
        exec 'anoremenu .60.10 '.s:BMSKmenuname.
                    \'&BuildManager.&Entwicklerstand<tab>:BmskAll\ Entwickler'.
                    \'   :BmskAll Entwickler<CR>'
        exec 'anoremenu ..20 '.s:BMSKmenuname.
                    \'&BuildManager.&Serienstand<tab>:BmskAll\ Serie'.
                    \'   :BmskAll Serie<CR>'
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

    " Variablen erzeugen, damit GetMakeVar funktioniert
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
    compiler bmsk

    " Default-Werte aus Make übernehmen
    call GetAllMakeVars()

    if g:Muster == ''
        let g:Muster = GetMakeVar('Muster')
    endif
    if g:Egas == ''
        let g:Egas = GetMakeVar('Egas')
    endif
    if g:Motor == ''
        let g:Motor = GetMakeVar('Motor')
    endif
    if g:SW_Stand == ''
        let g:SW_Stand = GetMakeVar('Stand')
    endif
    if g:Xlint == ''
        let g:Xlint = GetMakeVar('DIAB_LINT_OPTION')
    endif

    " bmsk dirs
    let g:bmskWA         = fnamemodify(g:bmskdir, ':h:h')
    let g:bmskProject    = fnamemodify(g:bmskdir, ':h:h:t')
    let g:bmsk_sw        = fnamemodify(g:bmskdir . '/sw', ':p')
    let g:bmsk_bios      = fnamemodify(g:bmskdir . '/sw/bios', ':p')
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

    " Grep Dir and Extentions
    let g:GrepDir = g:bmsk_sw
    let g:GrepFiles = '*.c *.h *.kgs'

    call s:BmskRedrawMenu()
    call GetGoals()

    " Python
    let g:python = fnamemodify(g:bmskdir . '/tools/python/v2.1a2/python.exe', ':p')

    " Titel-Leiste
    set titlelen=100
    let &titlestring = '%t - (%-F) - %=BMSK: %{g:bmskProject}'
                \ . ' Motor: %{g:Motor} Muster: %{g:Muster} Egas: %{g:Egas} SW-Stand: %{g:SW_Stand}'

endfunction

" make backups
set backup              " keep a backup file
set backupext=~

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
    let varnames['OutDirVariante']  = 'OUTDIR_VARIANTE'
    let varnames['CscopePrg']       = 'CSCOPE'
    let varnames['CscopeFile']      = 'CSCOPEFILE'
    let varnames['CTagsFile']       = 'CTAGFILE'
    let varnames['PTagsFile']       = 'PTAGFILE'
    let varnames['Goals']           = 'GOALS'
    let varnames['Programname']     = 'PROGRAMNAME'
    let varlist = GetMakeVars(values(varnames))
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
        let g:OutDir = GetMakeVar('OUTDIR')
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
        let g:ProductDir = GetMakeVar('DELIVERY_PATH')
        if (g:ProductDir == '')
            let g:ProductDir = GetMakeVar('OUTDIR_PRODUCTS')
        endif
    endif
    if (g:ProductDir != '')
        let g:ProductDir = fnamemodify(g:ProductDir, ':p')
    endif
    return g:ProductDir
endfunction

" --------------------------
function GetOutDirVariante()
" --------------------------
    if !exists('g:OutDirVariante')
        let g:OutDirVariante = GetMakeVar('OUTDIR_VARIANTE')
    endif
    if (g:OutDirVariante != '')
        let g:OutDirVariante = fnamemodify(g:OutDirVariante, ':p')
    endif
    return g:OutDirVariante
endfunction

" -----------------
function GetGoals()
" -----------------
    if !exists('g:Goals')
        let g:Goals = GetMakeVar('GOALS')
    endif
    return split(g:Goals)
endfunction

" -----------------------
function GetProgramname()
" -----------------------
    if !exists('g:Programname')
        let g:Programname = GetMakeVar('PROGRAMNAME')
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
command -complete=customlist,GetAllBmskTargets -nargs=* Bmsk Make <args>
command -complete=customlist,GetAllBmskTargets -nargs=* BmskDoku call s:BmskDoku('<args>')
command -nargs=* Lint Make <args> %:t:r.lint
command -complete=customlist,GetAllBmskSWStand -nargs=1 BmskAll call s:BmskAll('<args>')

" make options
function GetBmskMakeOpts()
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

" reformat i-file
command ReformatIFile call Reformat_IFile()
function Reformat_IFile() abort
    let cName = expand('%:t:r') . '.c'
    let CR = '\<CR>'
    DelAllMultipleEmptyLines
    " do not wrap over end of file
    setlocal nowrapscan
    " go to top of file
    execute 'normal gg'
    " do unil error
    while 1
        " delete until line of c-file
        execute 'normal d/\c^# \d\+ ".*\(' . cName . '\)' . CR
        " go to line of include-file
        execute  'normal /\c^# \d\+ ".*\(' . cName . '\)\@<!"' . CR
    endwhile
endfunction

" Dokumentation erzeugen (Verwenden des LaTeX errorparsers)
function s:BmskDoku(args)
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
    let &makeprg = g:makeprg . ' $*'
    let latexflags = '-interaction=nonstopmode'
    execute command . ' LATEXFLAGS=' . latexflags
    CscopeConnect
    clist
endfunction

" Erzeugen aller Programmstände
function s:BmskAll(Stand)
    " Software Stand gegebenenfalls einstellen
    if (a:Stand != '') && (g:SW_Stand != a:Stand)
        call SetSWStand(a:Stand)
    endif
    execute 'Bmsk all' . g:SW_Stand
endfunction

" Alle Software-Stände als VimList
function GetAllBmskSWStand(ArgLead, CmdLine, CursorPos)
    let StandList = ['Test', 'Entwickler', 'Serie']
    return StandList
endfunction

" Alle Make-Targets als Text Liste
function GetAllBmskTargets(...)
    let goals = GetGoals()
    if goals == []
        let goals += ['Programmstand']
        let goals += ['clean']
        let goals += ['cleanall']
        let goals += ['cleanProducts']
        let goals += ['allTest']
        let goals += ['allEntwickler']
        let goals += ['allSerie']
        let goals += ['patch_a2l']
        let goals += ['check_memory']
        let goals += ['create_csv']
        let goals += ['create_arcus_csv']
        let goals += ['import_arcus_csv']
        let goals += ['boschsig']
        let goals += ['archivate']
        let goals += ['lint file=' . expand('%:p')]
        let goals += ['tags']
        let goals += ['ctags']
        let goals += ['ptags']
        let goals += ['cscope']
        let goals += ['ccm_products_checkout CCM=' . g:ccm]
        let goals += ['help']
    else
        let goals += [expand('%:t:r') . '.obj']
        let goals += [expand('%:t:r') . '.i']
        let goals += [expand('%:t:r') . '.src']
        let goals += [expand('%:t:r') . '.lint']
        let goals += ['FORCE_PROGID=no']
        let goals += ['MAKE_DBG=2']
        let goals += ['EXTRA_C_FLAGS=']
        let goals += ['DIAB_OPTIMIZE=']
        let goals += ['MAIN_MAKEFILES=']
        let goals += ['ALL_EXIT=']
    endif
    return goals
endfunction

" -----------------------------------
" include extra-variables to a2l-file
" -----------------------------------
command PatchA2L call s:A2L_EXTENTION()
function s:A2L_EXTENTION()
    execute 'compiler bmsk'
    execute '!start make_fsw.bat patch_a2l ' . g:makeopts . ' & pause'
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
    execute 'Bmsk ccm_task_report file=' . fnamemodify(file, ':p')
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
