" settings for flog

" Only for testing
function Flog_echo_command(command, ...)
    echom flog#format_command(a:command)
endfunction

nnoremap <buffer> <silent> rb :call flog#run_command('Git reset %h',  1, 1)<CR>
nnoremap <buffer> <silent> rbh :call flog#run_command('Git reset --hard %h',  1, 1)<CR>

nnoremap <buffer> <silent> cp :call flog#run_command('Git cherry-pick %h',  1, 1)<CR>
vnoremap <buffer> <silent> cp :<C-U>call flog#run_command("Git cherry-pick %(h'>)^..%(h'<)", 1, 1)<CR>
"vnoremap <buffer> <silent> cp :<C-U>call Flog_echo_command("Git cherry-pick %(h'>)^..%(h'<)", 1, 1)<CR>
