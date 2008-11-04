" ===========================================================================
"        File: basics.vim
"      Author: Stefan Liebl (S.Liebl@gmx.de)
" Description: some usefull standard functions
"
"              Must be first file in this directory
" ===========================================================================

if (v:version < 700)
    echo 'update your vim'
endif

" ----------------
" useful functions
" ----------------
function GetLine()
    let line_nr = line('.')
    let line = getline(line_nr)
    return line
endfunction

function PrintLine(text)
    let line_nr = line('.')
    let line = GetLine()
    echo a:text . line_nr . ' ' . line
endfunction

command -nargs=1 EchoDebug call EchoDebug(<args>)
function EchoDebug(text)
    if exists('g:debug')
        if (g:debug > 0)
            execute 'echo "' . a:text . '"'
        endif
    endif
endfunction

" Go back in jumplist to an older file
function! GotoLastFile()
    let actfilename = expand('%')
    let filename = actfilename
    while filename == actfilename
        execute "normal \<C-O>"
        let filename = expand('%')
    endwhile
endfunction

" inputdialog whitch updates Variable and returns result
function VariableUpdateDialog(prompt, varName, ...)
    execute 'let l:var=' . a:varName
    if a:0 > 0
        let l:var = inputdialog(a:prompt, l:var, a:1)
    else
        let l:var = inputdialog(a:prompt, l:var)
    endif
    execute 'let ' . a:varName . '= l:var'
    return l:var
endfunction

"command -nargs=1 PathNormpath call PathNormpath('<fargs>')
"function PathNormpath(string)
"    if (v:version > 602)
"        try
"python <<EOF
"import vim
"import os
"string = vim.eval('a:string')
"if string is '':
"    path = ''
"else:
"    path = os.path.normpath(string)
"    path = os.path.normcase(path)
"vim.command("let result = '" + path + "'")
"EOF
"        catch /^Vim\%((\a\+)\)\=:E370/	" python not available
"            " normalize /
"            let result = expand(a:string)
"            " delete multiple \
"            let result = substitute(result, '\([^\\]\)\\\+', '\1\\', 'g')
"        endtry
"    else
"        " normalize /
"        let result = expand(a:string)
"        " delete multiple \
"        let result = substitute(result, '\([^\\]\)\\\+', '\1\\', 'g')
"    endif
"    return result
"endfunction

function Single_quote(text)
    let output = "'" . a:text . "'"
    return output
endfunction

function Double_quote(text)
    let output = '"' . a:text . '"'
    return output
endfunction

function Eval(expression)
    if (v:version > 602)
        try
python <<EOF
import vim
result = str(eval(vim.eval('a:expression')))
#print 'result:', result
vim.command('let result = \"' + result + '\"')
EOF
        catch /^Vim\%((\a\+)\)\=:E370/	" python not available
            throw 'Eval needs python'
            let result = a:expression
        endtry
    else
        echoerr 'Eval needs python'
        let result = a:expression
    endif
    return result
endfunction

function ToInt(expression)
    if (v:version > 602)
        try
            let expression = substitute(a:expression, '\.\d\+', '', '')
python <<EOF
import vim
result = str(int(vim.eval('expression')))
#print 'result: ', result
vim.command('let result = \"' + result + '\"')
EOF
        catch /^Vim\%((\a\+)\)\=:E370/	" python not available
            throw 'ToInt needs python'
            let result = a:expression
        endtry
    else
        echoerr 'ToInt needs python'
        let result = a:expression
    endif
    return result
endfunction

function ToHex(expression, bits)
    if (v:version > 602)
        try
            let expression = substitute(a:expression, 'L', '', '')
python <<EOF
import vim
result = hex(long(int(vim.eval('expression'))))
#print 'result: ', result
vim.command('let result = \"' + result + '\"')
EOF
            if (a:bits != 0)
                let digits = a:bits / 4
                let result = substitute(result, '\(0x\)\x*\(\x\{' . digits . '}\>\)', '\1\2', '')
                "echo 'result:'.result.':'. a:bits digits
            endif
        catch /^Vim\%((\a\+)\)\=:E370/	" python not available
            throw 'ToHex needs python'
            let result = a:expression
        endtry
    else
        echoerr 'ToHex needs python'
        let result = a:expression
    endif
    return result
endfunction

" get date
function GetDate()
    let l:full_date = system('date /T')
    let l:day  =  matchstr(l:full_date,'\a\+')
    let l:date =  matchstr(l:full_date,'[0-9.]\+')
    return l:date
endfunction

"function Wait(seconds)
"    let starttime = localtime()
"    while ((localtime() - starttime) < a:seconds)
"    endwhile
"endfunction

function ReversePatch()
    silent execute '!patch -R -o' v:fname_out v:fname_in '<' v:fname_diff
endfunction

EchoDebug 'loaded _stefan.vim'

