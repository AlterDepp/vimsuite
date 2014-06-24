" Stefans vim-file plugin

" ----
" TABS
" ----
setlocal noexpandtab
setlocal shiftwidth=4
setlocal tabstop=4

setlocal formatoptions=tcroq

command! -nargs=1 -range HtmlAddTag call HtmlAddTag("<args>", <line1>, <line2>)
function! HtmlAddTag(tag, line1, line2)
	let s:visualStart = '`<'
	let s:visualEnd   = '`>'
	" für Endtag nur das erste Wort verwenden:
	let l:endtag = substitute(a:tag, '\s*\(\w\+\).*', '\1', '')
	execute('normal ' . s:visualStart . '"vd'
				\	. s:visualEnd . 'i<' . a:tag . ">\<C-R>v</" . l:endtag . '>')
endfunction

" Tag Select/Wrapper
" These mappings and TagSelection function will allow you to place
" an XML tag around either the current word, or the current selected
" text
"nmap _t viw_t
"vnoremap _t <Esc>:call TagSelection()<CR>
"
"nmap _t viw_t
"vnoremap _t <Esc>:call TagSelection()<CR>
"
"function! TagSelection()
"  let l:tag = input("Tag name? ")
"  " exec "normal `>a</" . l:tag . ">\e"
"  " Strip off all but the first work in the tag for the end tag
"  exec "normal `>a</" .
"              \ substitute( l:tag, '[ \t"]*\(\<\w*\>\).*', '\1>\e', "" )
"  exec "normal `<i"
"              \ substitute( l:tag, '[ \t"]*\(\<.*\)', '<\1>\e', "" )
"endfunction


" commenting
"let b:commentstring = '"'

" Grep options
let b:GrepFiles = '*.html *.htm'
