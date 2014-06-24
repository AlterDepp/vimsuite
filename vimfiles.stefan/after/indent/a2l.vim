" Vim indent file
" Language:     a2l
" Maintainer:   Stefan Liebl

if exists("b:did_indent")
    finish
endif
let b:did_indent = 1

setlocal indentexpr=GetA2LIndent()
setlocal nolisp
setlocal nosmartindent
setlocal autoindent
setlocal indentkeys+=},=/end

" Only define the function once
if exists("*GetA2LIndent")
    finish
endif

function GetA2LIndent()

    " Do not change indentation of commented lines.
    if exists("b:commentstring")
        if getline(v:lnum) =~ '^' . b:commentstring . '.*'
            return 0
        endif
    endif

    " Find a non-blank line above the current line, that's not a comment
    let lnum = prevnonblank(v:lnum - 1)
    if exists("b:commentstring")
        while getline(lnum) =~ '^' . b:commentstring
            let lnum = prevnonblank(lnum - 1)
            if lnum == 0
                break
            endif
        endwhile
    endif

    " At the start of the file use zero indent.
    if lnum == 0 | return 0
    endif

    let ind = indent(lnum)
    let line = getline(lnum)             " last line
    let cline = getline(v:lnum)          " current line

    " Add a 'shiftwidth' after beginning of environments.
    " Don't add it for /begin ... /end
    if line =~ '/begin'  && line !~ '/end'
        let ind = ind + &sw
    endif

    " Subtract a 'shiftwidth' when an environment ends
    if cline =~ '^\s*/end'
        let ind = ind - &sw
    endif

    return ind
endfunction

