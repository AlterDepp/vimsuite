" Vim filetype plugin
" Language:	damos Kenngroessen Beschreibungs Datei
" Maintainer:	Stefan Liebl <S.Liebl@gmx.de>
" URL:		
" Credits:	

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
    finish
endif

" ----
" TABS
" ----
" tab width
let tabwidth = 4
let &l:tabstop = tabwidth
" spaces for tabs
"let &softtabstop = tabwidth
" smart indent tabs (use spaces for indent else tabs)
"set smarttab
" use spaces for tabs
setlocal expandtab

" autoindent
" indent mode - one of autoindent, smartindent or cindent
" set autoindent
" set smartindent
"set cindent
setlocal cinoptions=*200,)100,(s,w1
let &l:shiftwidth = tabwidth
setlocal formatoptions=wan2croql
setlocal formatexpr=KgsFormat()

" commenting
" ----------
let b:commentstring = "\/\/"

" spell check
setlocal spell

" Grep options
let b:GrepFiles = '*.kgs'

" formatting
" ----------
let s:levelSgFunktion = 0 * &sw
let s:levelBlock      = 1 * &sw
let s:levelKeyword    = 2 * &sw
let s:lenKeyword      = 27
let s:lenBlockNameId  = (s:levelKeyword - s:levelBlock) + s:lenKeyword

if exists("*KgsFormat")
    finish
endif

" function for gq command
" -----------------------
function KgsFormat()
    if mode() !~ '[iR]'
        " not in insert mode
        let lstart = v:lnum
        let lend = lstart + v:count - 1
        while v:lnum <= lend
            let level = GetKgsIndent()
            let line = getline(v:lnum)
            if level == s:levelSgFunktion
                " nix tun
            elseif level == s:levelBlock
                " Definition eines Blocks
                let list = matchlist(line, '^\s*\(\w\+\)\s\+\(\w\+;\?\)\s*\(.*\)\?\s*')
                let NameId = printf('%s %s', list[1], list[2])
                let line = printf('%-' . s:lenBlockNameId . 's %s', NameId, list[3])
            elseif level == s:levelKeyword
                " Parameter eines Blocks
                let list = matchlist(line, '^\s*\(\w\+\)\s\+\(.\{-}\)\s\{-}\(;\)\?\(.*\)\?')
                let line = printf('%-' . s:lenKeyword . 's %s%s%s', list[1], list[2], list[3], list[4])
            else
            endif
            " delete leading spaces
            let line = substitute(line, '^\s*\(.*\)', '\1', '')
            " indent
            let line = printf('%' . level . 's%s', '', line)
            " delete trailing spaces
            let line = substitute(line, '\(.\{-}\)\s*$', '\1', '')
            call setline(v:lnum, line)
            let v:lnum = v:lnum + 1
        endwhile
    endif
endfunction

" ------------
" KGS Reformat
" ------------

function ReformatKGS()
    let cursorLine = line('.')
    let cursorCol = col('.')
    "do gq over all
    execute 'normal ggVGgq'
    call cursor(cursorLine, cursorCol)
endfunction

" ---------------------------------------------------------
" Physikalischen Wert zu Testwert eines Kennwerts ermitteln
" Cursor muss sich im .kgs-File auf dem Kennwert befinden
" ---------------------------------------------------------
function s:GetOspPoly(Nr, OspLine)
    if match(a:OspLine, 'Poly') >= 0
        let valRegEx = '[^:;]\+'
        let pxPos = matchend(a:OspLine, 'P' . a:Nr . '=')
        if pxPos >=0
            let pxVal = matchstr(a:OspLine, valRegEx, pxPos)
        else 
            let pxVal = '0.0'
        endif
    else
        echo 'kein Polynom'
        let pxVal = '0.0'
    endif
    return pxVal
endfunction

function s:GetOspMas(OspLine)
    let masRegEx = '[^:;"]\+'
    let masPos = matchend(a:OspLine, 'Mas="')
    if masPos >=0
        let mas = matchstr(a:OspLine, masRegEx, masPos)
    else 
        let mas = '-'
    endif
    return mas
endfunction

function s:GetOspPolyPhysValue(int, p)
    "        P2 - (int - P5) * P4
    " phys = --------------------
    "        (int - P5) * P3 - P1
    "
"    echo 'P1: ' a:p[1] ' P2:' a:p[2] ' P3:' a:p[3] ' P4:' a:p[4] ' P5:' a:p[5]
    let polynom = '(' . a:p[2] . ' - ((' . a:int . ' - ' . a:p[5] . ') * '
                \ . a:p[4] .  ')) / (((' . a:int . ' - ' . a:p[5] . ') * '
                \ . a:p[3] . ') - ' . a:p[1] . ')'
"    echo polynom
    let phys = Eval(polynom)
    return phys
endfunction

function s:GetOspPolyIntValue(phys, p)
    "        P1 * phys + P2
    " int  = -------------- + P5
    "        P3 * phys + P4
    "
"    echo 'P1: ' a:p[1] ' P2:' a:p[2] ' P3:' a:p[3] ' P4:' a:p[4] ' P5:' a:p[5]
    let polynom = '((((' . a:p[1] . ' * ' . a:phys . ') + ' . a:p[2] . ') / (('
                \ .  a:p[3] . ' * ' . a:phys . ') + ' . a:p[4] . ')) + ' . a:p[5] . ')'
"    echo polynom
    let float = Eval(polynom)
    let int = ToInt(float)
    return int
endfunction

command -nargs=1 GetOspPhysValue call s:GetOspPhysValue('<args>')
function s:GetOspPhysValue(int)
    execute 'normal yiw'
    let umrechnung = @0
    echo 'umrechnung:' umrechnung
    let umr = s:GetPolynom(umrechnung)
    if umr != {}
        let Mas = umr['Mas']
        let p = umr['p']
        let phys = s:GetOspPolyPhysValue(a:int, p)
        echo 'Int:' a:int 'Phys:' phys Mas
    else
        echo 'kein Polynom'
        return
    endif
endfunction

command -nargs=1 GetOspIntValue call s:GetOspIntValue('<args>')
function s:GetOspIntValue(phys)
    execute 'normal yiw'
    let umrechnung = @0
    echo 'umrechnung:' umrechnung
    let umr = s:GetPolynom(umrechnung)
    if umr != {}
        let Mas = umr['Mas']
        let p = umr['p']
        let int = s:GetOspPolyIntValue(a:phys, p)
        let hex = ToHex(int, 0)
        echo 'Phys:' a:phys Mas 'Int:' int 'Hex:' hex
    else
        echo 'kein Polynom'
        return
    endif
endfunction

function s:GetPolynom(umrechnung)
    let umr = {}
    let p = [0] " dummy
    " jump to tag
    execute 'tag ' a:umrechnung
    let ext = fnamemodify(expand('%'), ':e')
    if ext == 'osp'
        let OspLine = getline('.')
        if match(OspLine, 'Poly') >= 0
            let p += [s:GetOspPoly('1', OspLine)]
            let p += [s:GetOspPoly('2', OspLine)]
            let p += [s:GetOspPoly('3', OspLine)]
            let p += [s:GetOspPoly('4', OspLine)]
            let p += [s:GetOspPoly('5', OspLine)]
            let umr['Mas'] = s:GetOspMas(OspLine)
        endif
    elseif ext == 'xmo'
        " default Values
        let p += [0]
        let p += [0]
        let p += [0]
        let p += [0]
        let p += [0]
        let umr['Mas'] = '-'

        call search('<obj n="' . a:umrechnung . '">')
        let XmlTags = XmlGetTag()
"        try
            let XmlTag = XmlTags[0]
            if XmlTag['Attributes']['Value'] == a:umrechnung
                let elements = XmlTag['Elements']
                for element in elements
                    if type(element) == 4
                        let name = element['Name']
                        if name == 'Mas'
                            let umr['Mas'] = element['Elements'][0]
                        else
                            let nr = substitute(name, 'P\(\d\)', '\1', '')
                            if nr != name
                                let p[str2nr(nr)] = element['Elements'][0]
                            else
                                echoerr 'Unknown attribute' name
                            endif
                        endif
                    endif
                    unlet element
                endfor
            else
                echoerr 'Error: Wrong conversion' XmlTag['Attributes']['n']
            endif
"        catch
"            echoerr 'Error: couldnt parse tag'
"        endtry
    else
        echoerr 'no OSP file: ' . ext
    endif
    " return from tag
    execute 'pop'
    " Poynom
    echo 'umrechnung:' a:umrechnung
    echo 'P1:' p[1] 'P2:' p[2] 'P3:' p[3] 'P4:' p[4] 'P5:' p[5]
    let umr['p'] = p
    return umr
endfunction

command GetOspTestValues call s:GetOspTestValues()
function s:GetOspTestValues()
    execute 'normal yiw'
    let umrechnung = @0
    echo 'umrechnung:' umrechnung
    let umr = s:GetPolynom(umrechnung)
    if umr != {}
        let Mas = umr['Mas']
        let p = umr['p']
        let int = '0'
        let hex = ToHex(int, 8)
        let phys = s:GetOspPolyPhysValue(int, p)
        echo s:formatValues(int, hex, phys, Mas)
        let int = '1'
        let hex = ToHex(int, 8)
        let phys = s:GetOspPolyPhysValue(int, p)
        echo s:formatValues(int, hex, phys, Mas)
        let int = '127'
        let hex = ToHex(int, 8)
        let phys = s:GetOspPolyPhysValue(int, p)
        echo s:formatValues(int, hex, phys, Mas)
        let int = '-128'
        let hex = ToHex(int, 8)
        let phys = s:GetOspPolyPhysValue(int, p)
        echo s:formatValues(int, hex, phys, Mas)
        let int = '255'
        let hex = ToHex(int, 8)
        let phys = s:GetOspPolyPhysValue(int, p)
        echo s:formatValues(int, hex, phys, Mas)
        let int = '32767'
        let hex = ToHex(int, 16)
        let phys = s:GetOspPolyPhysValue(int, p)
        echo s:formatValues(int, hex, phys, Mas)
        let int = '-32768'
        let hex = ToHex(int, 16)
        let phys = s:GetOspPolyPhysValue(int, p)
        echo s:formatValues(int, hex, phys, Mas)
        let int = '65535'
        let hex = ToHex(int, 16)
        let phys = s:GetOspPolyPhysValue(int, p)
        echo s:formatValues(int, hex, phys, Mas)
        let int = '2147483647L'
        let hex = ToHex(int, 32)
        let phys = s:GetOspPolyPhysValue(int, p)
        echo s:formatValues(int, hex, phys, Mas)
        let int = '-2147483648L'
        let hex = ToHex(int, 32)
        let phys = s:GetOspPolyPhysValue(int, p)
        echo s:formatValues(int, hex, phys, Mas)
        let int = '4294967295L'
        let hex = '0xffffffff'
        let phys = s:GetOspPolyPhysValue(int, p)
        echo s:formatValues(int, hex, phys, Mas)
    else
        echo 'kein Polynom'
        return
    endif
endfunction

function s:formatValues(int, hex, phys, mas)
        return printf('Int: %12s Hex: %12s Phys: %s %s',a:int, a:hex, a:phys, a:mas)
endfunction

command GetKgsTestWertp call s:GetKgsTestWertp()
function s:GetKgsTestWertp()
    " position markieren
    execute 'normal mx'
    " kennwert namen speichern
    execute 'normal yiw'
    let kennwert = @0
    echo 'kennwert:' kennwert
    " Position von { und } merken
    call search('{')
    let startLineNr = line('.')
    execute 'normal %'
    let endLineNr = line('.')
    execute 'normal %'
    " umrechnungs-Formel hohlen
    call cursor(startLineNr, 0)
    call search('umrechnung', 'W')
    execute 'normal wyiw'
    let umrechnung = @0
    echo 'umrechnung:' umrechnung
    let umr = s:GetPolynom(umrechnung)
    if umr != {}
        let Mas = umr['Mas']
        let p = umr['p']
        " test_wert lesen
        call cursor(startLineNr, 0)
        call search('test_wert', 'W')
        while search('\x\+\s*}\?\s*[,;]', 'W') > 0
            if line('.') <= endLineNr
                execute 'normal yiw'
                let test_wert = @0
                " Poynom
                let phys = s:GetOspPolyPhysValue(test_wert, p)
                echo 'test_wert:' test_wert 'umrechnung:' umrechnung 'Phys:' phys
            endif
        endwhile
    else
        echo 'kein Polynom'
        return
    endif
    execute 'normal `x'
endfunction

" ------------------------------------------------------------
" Zum überprüfen von Testwerten
" Im Fenster 1 muss sich konserve_2.kon befinden
" Im Fenster 3 muss sich konserve_4.kon befinden
" Im Fenster 2 wird das .kgs-File geöffnet, das den Kennwert definiert
" Im Fenster 4 wird das .c-File zum .kgs-File geöffnet
" ------------------------------------------------------------
command -nargs=1 DamosCheckValues call s:DamosCheckValues('<args>')
function s:DamosCheckValues(kennwert)
    " find kennwert in kgs-file
    2wincmd w
    execute 'tselect ' . a:kennwert
    execute 'normal 0jzok'
    call search(a:kennwert)
    execute 'normal gm'
    let @/ = a:kennwert . '\>'
    " get c-file-name and find kennwert
    let cFile = expand('%:p:r') . '.c'
    4wincmd w
    execute 'edit ' . cFile
    execute 'normal zR!'
    execute 'normal n'
    1wincmd w
    execute 'normal n'
    3wincmd w
    execute 'normal n'
    2wincmd w
endfunction

" --------------------------------------------------
" Sucht den Wert eines Kennwerts aus einer Konserve,
" die als erster Parameter übergeben wird
" --------------------------------------------------
function s:DamosGetKonserveVal(konserve, kennwert)
    let kwPos = match(a:konserve, a:kennwert)
"    echo 'kwPos: ' . kwPos
    if kwPos >= 0
        let wertLine = matchstr(a:konserve, 'WERT\s\p\+', kwPos)
        echo 'wertLine:' wertLine
        let wert = substitute(wertLine, 'WERT\s\+\([0-9.,]\+\)' , '\1', '')
    else
        echo a:kennwert 'not found in' a:konserve
        let wert = '-'
    endif
    return wert
endfunction

command -nargs=+ DamosCheckKonserven call s:DamosCheckKonserven(<f-args>)
function s:DamosCheckKonserven(kennwert, newValue)
    let output = DamosCheckKonserve('konserve_2.kon', a:kennwert, a:newValue)
    echo output
    let output = DamosCheckKonserve('konserve_4.kon', a:kennwert, a:newValue)
    echo output
endfunction

" -------------------------------------------------------
" Überprüft, ab welcher Version der Konserve ein Kennwert
" einen bestimmten Wert hat
" -------------------------------------------------------
function s:DamosCheckKonserve(konserve, kennwert, newValue)
    " Get object from Continuus
    silent let k2_obj = CCM_get_object(a:konserve)
    silent let k2_root = CCM_get_hist_root(k2_obj)
    let k2_obj = k2_root
    while k2_obj != ''
        let k2_content = CCM_view_object(k2_obj)
        let wert = s:DamosGetKonserveVal(k2_content, a:kennwert)
        if wert != '-'
            echo a:kennwert . ': ' . wert . '\n'
            let equal = Eval(wert . ' == ' . a:newValue)
            if equal == 0
                let output = a:kennwert  . ': not equal in: ' . k2_obj
                silent let owner = CCM_get_owner(k2_obj)
                let output = output . ' owner: ' . owner
                return output
            endif
        endif
        silent let k2_obj = CCM_get_successor(k2_obj)
    endwhile
    return 'nix'
endfunction

