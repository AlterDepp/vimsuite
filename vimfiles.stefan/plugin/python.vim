" ===========================================================================
"        File: python.vim
"      Author: Stefan Liebl (S.Liebl@gmx.de)
" Description: options for python-vim
" ===========================================================================

if !has('win32')
    finish
endif

if !has('python')
    " noch keine python.dll gefunden
        " tools zum Suchpfad hinzufügen
        if (match($PATH, '\c' . escape(g:vimtools, '\')) >= 0)
            " ist schon drin, abbrechen
            echo 'keine python.dll in g:vimtools=' . g:vimtools . ' gefunden'
            finish
        else
            " bei Bedarf ';' an PATH anhängen
            if (match($PATH, ';$') < 0)
                let $PATH = $PATH . ';'
            endif
            let $PATH = $PATH . g:vimtools . ';'
            "echo 'Python = ' . g:vimtools
        endif
endif

if !has('python')
    " immer noch keine python.dll gefunden
    if !isdirectory(g:pythonPath)
        echo 'g:pythonPath=' . g:pythonPath . ' nicht gefunden'
        finish
    else
        " pythonPath zum Suchpfad hinzufügen
        if (match($PATH, '\c' . escape(g:pythonPath, '\')) >= 0)
            " ist schon drin, abbrechen
            echo 'kein python.exe in g:pythonPath=' . g:pythonPath . ' gefunden'
            finish
        else
            " bei Bedarf ';' an PATH anhängen
            if (match($PATH, ';$') < 0)
                let $PATH = $PATH . ';'
            endif
            let $PATH = $PATH . g:pythonPath . ';'
            "echo 'Python = ' . g:pythonPath
        endif
    endif
endif

" Jetzt sollte es eigentlich gehen
if !has('python')
    echoe 'kein Python-Modul für vim'
    finish
endif

let s:pythonLibPath = expand(g:pythonPath . '/lib')
let s:pythonDllPath = expand(g:pythonPath . '/dlls')

try
python <<EOF
import sys
#print sys.version
import vim
sys.path.append(vim.eval('s:pythonLibPath'))
sys.path.append(vim.eval('s:pythonDllPath'))
EOF
catch /^Vim\%((\a\+)\)\=:E370/	" python not available
    echo 'python not found'
    echo 'add python to your path-variable'
    echo 'otherwise some features from MyTools are not available'
catch /^Vim\%((\a\+)\)\=:E263/	" python not available
    echo 'python not found 2'
catch
    echo 'python.vim: irgendwas geht nicht'
endtry

EchoDebug 'loaded python.vim'
