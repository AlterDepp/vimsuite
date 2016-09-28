" Pyclewn run time file.
" Maintainer:   <xdegaye at users dot sourceforge dot net>

if exists('g:loaded_pyclewn')
  let g:loaded_pyclewn = 1
  finish
endif

" Enable balloon_eval.
if has("balloon_eval")
    set ballooneval
    set balloondelay=100
endif

" The 'Pyclewn' command starts pyclewn and vim netbeans interface.
command -nargs=* -complete=file Pyclewn call pyclewn#start#StartClewn(<f-args>)
