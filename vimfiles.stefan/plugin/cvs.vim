" ===========================================================================
"        File: cvs.vim
"      Author: Stefan Liebl (S.Liebl@gmx.de)
" Description: handles version controlling with CVS
" ===========================================================================

"  --------------------
"  config datei für CVS
"  --------------------
if !exists('g:cvs')
    let g:cvs       = 'cvs '
endif


"  --------
"  commands
"  --------
"command -nargs=0 CHANGEABLE call GetChangeable('qx13468')
command -nargs=0 CVSdiff   call s:CVSshowDifferences(expand('%:t'))
command -nargs=0 CVSedit   call s:CVSedit(expand('%:t'))
command -nargs=0 CVSunedit   call s:CVSunedit(expand('%:t'))
command -nargs=0 CVScommit call s:CVScommit(expand('%:t'))
command -nargs=0 CVSstatus call s:CVSstatus(expand('%:t'))

"---------------------------
function s:CVSedit(filename)
"---------------------------
	let expression = g:cvs . ' edit ' . a:filename
	let output = system(expression)
	execute(':edit')
	echo output
endfunction

"-----------------------------
function s:CVSunedit(filename)
"-----------------------------
	let expression = g:cvs . ' unedit ' . a:filename
	let output = system(expression)
	execute(':edit')
	echo output
endfunction

"-----------------------------
function s:CVScommit(filename)
"-----------------------------
	let expression = g:cvs . ' commit ' . a:filename
	let output = system(expression)
	execute(':edit')
	echo output
endfunction

"-----------------------------
function s:CVSstatus(filename)
"-----------------------------
	let expression = g:cvs . ' status ' . a:filename
	let output = system(expression)
	execute(':edit')
	echo output
endfunction

"--------------------------------------
function s:CVSdiff(filename, patchfile)
"--------------------------------------
	silent execute '!' . g:cvs ' diff -u ' . a:filename . ' > ' . a:patchfile
endfunction

"--------------------------------------
function s:CVSshowDifferences(filename)
"--------------------------------------
	let patchfile = tempname()
	echo 'patchfile: ' . patchfile
	call s:CVSdiff(a:filename, patchfile)
	set patchexpr=ReversePatch()
	execute 'vertical diffpatch ' . patchfile
endfunction

EchoDebug 'loaded cvs.vim'
