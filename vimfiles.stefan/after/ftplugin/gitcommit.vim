" Stefans gitcommit-filetype-plugin

" add branch name to commit message
nnoremap <buffer> gcc :execute 'normal i'.fugitive#head()<CR>A: 
nnoremap <buffer> ccc :Gcommit<CR>:execute 'normal i'.fugitive#head()<CR>A: 
