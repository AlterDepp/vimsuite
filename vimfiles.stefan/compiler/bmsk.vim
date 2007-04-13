" Vim compiler file
" Compiler:	diab data 4.4
" Maintainer:	Stefan Liebl
" Last Change:	13.06.2002 

"if exists('current_compiler')
"  finish
"endif
"let current_compiler = 'bcc'

set errorformat=
" tex-errorformat laden
let b:forceRedoTexCompiler = 'yes'
let g:Tex_ShowallLines = 1
"execute 'source ' . expand(g:vimfiles . '/compiler/tex.vim')

if exists('g:make_log')
    let &shellpipe = '| ' . g:tee . PathNormpath(make_log)  . ' | ' . g:tee
else
    let &shellpipe = '| ' . g:tee
endif
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

" make options
let g:makeopts = ''
if (g:Motor != '')
    let g:makeopts = g:makeopts . ' Motor=' . g:Motor
endif
if (g:Muster != '')
    let g:makeopts = g:makeopts . ' Muster=' . Muster
endif
if (g:Egas != '')
    let g:makeopts = g:makeopts . ' Egas=' . g:Egas
endif
if (Xlint != '')
    let g:makeopts = g:makeopts . ' DIAB_LINT_OPTION=' . Xlint
endif
if (g:SW_Stand != '')
    let g:makeopts = g:makeopts . ' Stand=' . g:SW_Stand
endif

" reformat i-file
command! ReformatIFile call Reformat_IFile()
function! Reformat_IFile() abort
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

