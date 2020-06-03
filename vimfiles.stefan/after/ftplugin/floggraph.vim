" settings for flog

nmap <buffer> <silent> rb :call flog#run_command('Git reset %h',  1, 1)<CR>
nmap <buffer> <silent> rbh :call flog#run_command('Git reset --hard %h',  1, 1)<CR>

nmap <buffer> <silent> cp :call flog#run_command('Git cherry-pick %h',  1, 1)<CR>
"nmap <buffer> <silent> d :call flog#run_command('Git cherry-pick %h',  1, 1)<CR>
