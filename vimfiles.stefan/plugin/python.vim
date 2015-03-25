" ===========================================================================
"        File: python.vim
"      Author: Stefan Liebl (S.Liebl@gmx.de)
" Description: options for python-vim
" ===========================================================================

if !has('win32')
    finish
endif

if exists('g:pythonPath')
    if !has('python')
        " keine python.dll gefunden
        if !isdirectory(g:pythonPath)
            echo 'g:pythonPath=' . g:pythonPath . ' nicht gefunden'
            finish
        else
            " pythonPath zum Suchpfad hinzufügen
            let PATH = $PATH
            let paths = split(tolower(PATH), ';')
            if ( count(paths, tolower(g:pythonPath)) > 0)
                " ist schon drin, abbrechen
                echo 'kein python.exe in g:pythonPath=' . g:pythonPath . ' gefunden'
                finish
            else
                " andere Python Verzeichnisse aus PATH löschen
"                for p in paths
"                    if (match(p, 'python') >= 0)
"                        call remove(paths, index(paths, p))
"                    endif
"                endfor
                " bei Bedarf ';' an PATH anhängen
                call add(paths, g:pythonPath)
                let PATH = join(paths, ';')
                echo 'Python = ' . g:pythonPath
                echo 'PATH:' PATH
                let $PATH = PATH
            endif
        endif
    endif

    " Jetzt sollte es eigentlich gehen
    if !has('python')
        echoe 'kein Python-Modul für vim'
        finish
    endif

"    let s:pythonLibPath = expand(g:pythonPath . '/lib')
"    let s:pythonDllPath = expand(g:pythonPath . '/dlls')
endif

"try
"python <<EOF
"import sys
"#print sys.version
"import vim
"sys.path.append(vim.eval('s:pythonLibPath'))
"sys.path.append(vim.eval('s:pythonDllPath'))
"EOF
"catch /^Vim\%((\a\+)\)\=:E370/	" python not available
"    echo 'python not found'
"    echo 'add python to your path-variable'
"    echo 'otherwise some features from MyTools are not available'
"catch /^Vim\%((\a\+)\)\=:E263/	" python not available
"    echo 'python not found 2'
"catch
"    echo 'python.vim: irgendwas geht nicht'
"endtry

EchoDebug 'loaded python.vim'
