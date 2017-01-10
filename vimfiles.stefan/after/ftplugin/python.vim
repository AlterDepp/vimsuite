" Stefans python-file plugin

" use spaces for tabs
setlocal expandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal formatoptions=croq

function! Set_python_tag_files()
python << endpython
import vim
import sys
import os
for p in sys.path:
    tags = os.path.join(p, 'tags')
    if os.path.exists(tags):
        cmd = "setlocal tags+=%s" % tags
        vim.command(cmd)
endpython
endfunction

call Set_python_tag_files()
nnoremap <TAB> :YcmCompleter GoTo<CR>
" commenting
let b:commentstring = '#'

" Grep options
let b:GrepFiles = '*.py'
