" Stefans gitcommit-filetype-plugin

" add branch name to commit message, replace 'feature/DLCPRO-1234-abc' by 'DLCPRO-1234'
nnoremap <buffer> gcc :execute 'normal i'.substitute(fugitive#head(), '\%(.*/\)*\([^-]\+-\d*\).*', '\1', '')<CR>A: 
nnoremap <buffer> ccc :Gcommit<CR>:execute 'normal i'.substitute(fugitive#head(), '\%(.*/\)*\([^-]\+-\d*\).*', '\1', '')<CR>A: 

