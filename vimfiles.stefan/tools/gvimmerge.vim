function s:OpenDiffTab(left, right)
    tabnew
    execute 'buffer' a:left
    diffthis
    execute 'rightbelow vertical sbuffer' a:right
    diffthis
endfunction

function s:FixLineendings()
    if !exists('b:reload_dos') && !&binary && &ff=='unix' && (0 < search('\r$', 'nc'))
        edit ++ff=dos
        echom 'fixed lineendings'
        let b:reload_dos = 1
    endif
endfunction

function s:OpenMergeTabs()
    set columns=200
    call s:OpenDiffTab(1, 4)
    call s:FixLineendings()
    setlocal noreadonly modifiable
    call s:OpenDiffTab(2, 4)
    call s:OpenDiffTab(3, 4)
    call s:OpenDiffTab(1, 2)
    call s:OpenDiffTab(1, 3)
    call s:OpenDiffTab(2, 3)
    tabfirst
    tabclose
endfunction

call s:OpenMergeTabs()
