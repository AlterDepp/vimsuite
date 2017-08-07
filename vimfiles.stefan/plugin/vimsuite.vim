" ===========================================================================
"        File: vimsuite.vim
"      Author: Stefan Liebl (S.Liebl@gmx.de)
" Description: some usefull tools
" ===========================================================================

" ------------------
" Draw Vimsuite-Menu
" ------------------
let s:VimSuiteMenuLocation = 70
let s:VimSuiteMenuName = '&VimSuite.'

function s:RedrawMenu()
    " Compile
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.30 '.s:VimSuiteMenuName.
                \'&Compile.&Build<tab>:Make'.
                \'   :Make<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.30 '.s:VimSuiteMenuName.
                \'&Compile.&Lint<tab>:Make\ lint'.
                \'   :Make lint<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.30 '.s:VimSuiteMenuName.
                \'&Compile.&Clean<tab>:Make\ clean'.
                \'   :Make clean<CR>'
    exec 'anoremenu '.s:VimSuiteMenuLocation.'.30 '.s:VimSuiteMenuName.
                \'&Compile.&Run<tab>:Make\ run'.
                \'   :Make run<CR>'
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
                \'&Search.Update\ c&tags<tab>:Make\ tags'.
                \'   :Make tags<CR>'
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
                \'&Diff.&end\ diffs<tab>:diffoff'.
                \'   :diffoff<CR>'
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

" Open multiple files
command -nargs=+ -complete=file EditFiles call EditFiles('<args>')
function EditFiles(wildcards)
    for wildcard in split(a:wildcards)
        for file in split(expand(wildcard))
            execute('edit ' . file)
        endfor
    endfor
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

func GitGrep(...)
  let save = &grepprg
  set grepprg=git\ grep\ -n\ $*
  let s = 'grep'
  for i in a:000
    let s = s . ' ' . i
  endfor
  exe s
  let &grepprg = save
endfun
command -nargs=? GitGrep call GitGrep(<f-args>)

" Options for GitV
let g:Gitv_WipeAllOnClose = 1
let g:Gitv_TruncateCommitSubjects = 1

" Remove all buffers which are not found by findfile()
" ----------------------------------------------------
command BuffersCleanup call s:BuffersCleanup()
function s:BuffersCleanup()
    let buffers = getbufinfo()
    for buffer in buffers
        if buffer['listed']
            let path = fnamemodify(buffer['name'], ':p')
            let name = fnamemodify(path, ':t')
            let found = fnamemodify(findfile(name), ':p')
            if found != path && buffer['listed']
                echo 'delete buffer '.path
                execute 'bdelete ' buffer['bufnr']
            else
                echo 'keep buffer '.path
            endif
        endif
    endfor
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
        if !exists("b:commentstring")
            let commentstring = b:commentstring
        else
            let commentstring = '#'
        endif
        if (match(line,'^' . commentstring)>=0)
            let line = '@' . line
"            echo line
            call setline(line_nr, line)
        endif
        let line_nr = line_nr + 1
    endwhile
    " indent all lines
    execute 'normal ' . a:fromline . 'G=' . a:toline . 'G'
    " reindent commented lines
    let substCmd = 's?^\s*@' . commentstring . '?' . commentstring . '?'
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
command -range -nargs=+ IndentWordNum call IndentWords(<f-args>, <line1>, <line2>)
" handle range
function IndentWords(wordNum, pos, fromline, toline)
    let cursorLine = line(".")
    let cursorCol = col(".")
    if (a:fromline > 1)
        call cursor(a:fromline-1, 255)
    else
        call cursor(a:fromline, 1)
    endif
    let line_nr = a:fromline
    while (line_nr <= a:toline)
        call cursor(line_nr, 1)
        call IndentWordNum(a:wordNum, a:pos)
        let line_nr = line_nr + 1
    endwhile
    call cursor(cursorLine, cursorCol)
endfunction
" handle one line
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

" ----------------
" Find Ugly C Code
" ----------------

"function s:SingleChar(x, ...)
"    if a:0 > 0
"        let a = a:1
"    else
"        let a = a:x
"    endif
"    if a:0 > 1
"        let b = a:2
"    else
"        let b = a:x
"    endif
"    let string = '[' . a . ']\@<!' . a:x . '[' . b . ']\@!'
"    return string
"endfunction
"
"function s:SpaceAround(x)
"    let string = '\%(\%(^\| \)\@<!' . a:x . '\)\|\%(' . a:x . ' \@!\)'
"    return string
"endfunction

command FindUglyC call FindUglyC()
function FindUglyC()
    let KeyWords = ['if', 'for', 'while', 'switch', 'return', '[&|=]']
    let KeyWordString = join(KeyWords, '\|')
    let SpaceBeforeParenthesis = '\(' . KeyWordString . '\)\zs('
    let NoSpaceBeforeParenthesis = '\(' . KeyWordString . '\|\(^\s*\)' . '\)\@<! ('
    let NoSpaceAfterKomma = ',\zs[^ ]'
    let SpaceAfterOpenParenthesis = '(\zs '
    let SpaceBeforeCloseParenthesis = ' )'
    let SpaceBeforeBracket = ' \['
    let SpaceAtLineend = '\s\+$'
    let ReturnWithParenthesis = 'return\s*\zs(.*)\s*;'
"    let Operator1 = ['+', '-', '\*', '\/', '|', '&']
"    let Operator1a = []
"    for x in Operator1
"        let Operator1a += [s:SpaceAround(s:SingleChar(x, x . '/\*', x . '=/\*-'))]
"    endfor
"    let Operator1String = join(Operator1a, '\|')
"    let Operator2 = []
"    for x in Operator1
"        let Operator2 += [s:SpaceAround(x . x)]
"        let Operator2 += [s:SpaceAround(x . '=')]
"    endfor
"    let Operator2String = join(Operator2, '\|')

    let UglyCstring = '\%(' . join([
                \ SpaceBeforeParenthesis,
                \ NoSpaceBeforeParenthesis,
                \ NoSpaceAfterKomma,
                \ SpaceBeforeBracket,
                \ SpaceAfterOpenParenthesis,
                \ SpaceBeforeCloseParenthesis,
                \ SpaceAtLineend,
                \ ReturnWithParenthesis,
                \ ], '\)\|\%(') . '\)'
    let @/ = UglyCstring
    set hlsearch
    execute '/' . UglyCstring
endfunction

" options for Vimball
let g:vimball_home = expand(g:vimsuite . '/vimfiles')

" GetLatestVimScripts
command GetLatestVimScriptsThroughProxy call s:GetLatestVimScriptsThroughProxy()
function s:GetLatestVimScriptsThroughProxy()
    " Get Proxy data
    let proxy = input('Proxy: ', 'proxy.muc:8080')
    let user = input('User: ', 'qx13468')
    let password = inputsecret('Password: ')
    let $http_proxy = 'http://' . user . ':' . password . '@' . proxy
    " Set HOME for autoinstall
    let home = $HOME
    let $HOME=g:vimsuite
    " Get the scripts
    GetLatestVimScripts
    " reset HOME
    let $HOME = home
endfunction
let g:GetLatestVimScripts_wget = g:wget
let g:GetLatestVimScripts_mv = g:mv

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


" ---------
" templates
" ---------
command InsertCHeader call Insert_Header('file_c.tpl')
command InsertHHeader call Insert_Header('file_h.tpl')
command InsertKGSHeader call Insert_Header('file_kgs.tpl')
command InsertFHeader call Insert_Header('funct.tpl')
command InsertHTMLHeader call Insert_Header('html.tpl')
function Insert_Header(file)
    let file = g:vimfiles . '/templates/' . a:file
    execute ':read ' . file
    " expand template
    let l:filename = expand('%:t')
    execute ':%s/%filename/' . l:filename . '/e'
    let l:basename = substitute(expand('%:t:r'), '.*', '\U\0', '')
    execute ':%s/%basename/' . l:basename . '/e'
    let l:date = strftime("%d.%m.%Y")
    execute ':%s/%date/' . l:date . '/e'
    if !exists("g:DoxygenToolkit_authorName")
        let g:DoxygenToolkit_authorName = input("Enter name of the author (gernarally yours...) : ")
    endif
    execute ':%s/%author/' . g:DoxygenToolkit_authorName . '/e'
endfunction

" -------
" Outlook
" -------

command OutlookBugfix call s:OutlookBugfix()
function s:OutlookBugfix()
    silent execute ':%s$^\(\%([^,]*,\)\{55}\)"\/o[^,]*\"\(,"EX","[^(]*(\)\([^)]*\)\()",\)$\1"\3"\2\3\4$c'
    silent execute ':%s$^\(\%([^,]*,\)\{47}\)"\/o[^,]*\"\(,"EX","[^(]*(\)\([^)]*\)\()",\)$\1"\3"\2\3\4$c'
endfunction

" ---------
" VC plugin
" ---------
let g:vc_ignore_repos="-git"
let g:vc_browse_cach_all = 1

EchoDebug 'loaded tools.vim'
