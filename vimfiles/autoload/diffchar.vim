" diffchar.vim : Highlight the exact differences, based on characters and words
"
"  ____   _  ____  ____  _____  _   _  _____  ____   
" |    | | ||    ||    ||     || | | ||  _  ||  _ |  
" |  _  || ||  __||  __||     || | | || | | || | ||  
" | | | || || |__ | |__ |   __|| |_| || |_| || |_||_ 
" | |_| || ||  __||  __||  |   |     ||     ||  __  |
" |     || || |   | |   |  |__ |  _  ||  _  || |  | |
" |____| |_||_|   |_|   |_____||_| |_||_| |_||_|  |_|
"
" Last Change: 2016/03/09
" Version:     6.1
" Author:      Rick Howe <rdcxy754@ybb.ne.jp>

let s:save_cpo = &cpo
set cpo&vim

function! diffchar#DiffCharExpr()
	" find the fist diff trial call and return here
	if readfile(v:fname_in, '', 1) == ['line1'] &&
				\readfile(v:fname_new, '', 1) == ['line2']
		call writefile(['1c1'], v:fname_out)
		return
	endif

	" get a list of diff commands and write to output file
	for fn in ['ApplyInternalAlgorithm', 'ApplyDiffCommand']
		let dfcmd = s:{fn}(v:fname_in, v:fname_new)
		" if empty, try next
		if !empty(dfcmd) | break | endif
	endfor
	call writefile(dfcmd, v:fname_out)
endfunction

function! diffchar#SetDiffModeSync()
	if exists('t:DiffModeSync') ? !t:DiffModeSync : !g:DiffModeSync
		return
	endif

	if !exists('s:dmsync')
		" a filter command (not diff) also triggers FilterWritePre but
		" continueously triggers ShellFilterPost,
		" prepare here to clear s:dmsync
		au! dchar ShellFilterPost * call s:ClearDiffModeSync()

		let s:dmsync = {}
		let s:dmsync.ebuf = []
		" find all the diff mode winnr and bufnr at the first event of
		" a diff session.
		let s:dmsync.dwin = s:ValidDiffModeWins(range(1, winnr('$')))
		let s:dmsync.dbuf = map(copy(s:dmsync.dwin), 'winbufnr(v:val)')
		if min(s:dmsync.dbuf) == max(s:dmsync.dbuf)
			call s:ClearDiffModeSync()
			return
		endif
	endif

	" append current bufnr where the event happens
	if index(s:dmsync.dbuf, bufnr('%')) != -1
		let s:dmsync.ebuf += [bufnr('%')]
	endif

	if empty(filter(copy(s:dmsync.dbuf),
					\'index(s:dmsync.ebuf, v:val) == -1'))
		" when all the events of one diff session come, get winnr of
		" the first/last buffers for v:fname_in/v:fname_new
		let win = {}
		let cwin = winnr()
		for k in [1, 2]
			let w = filter(copy(s:dmsync.dwin), 'winbufnr(v:val) ==
					\s:dmsync.ebuf[k == 1 ? 0 : -1]')
			let win[k] = (len(w) > 1 &&
					\index(w, cwin) != -1) ? cwin : w[0]
		endfor

		" then set diffexpr to be called soon
		if !exists('s:save_dex')
			let s:save_dex = &diffexpr
		endif
		let &diffexpr = 'diffchar#DiffModeSyncExpr(' . string(win) . ')'

		" intialize here to be prepared for the next diff session
		call s:ClearDiffModeSync()
	endif
endfunction

function! s:ClearDiffModeSync()
	unlet! s:dmsync
	au! dchar ShellFilterPost *
endfunction

function! diffchar#DiffModeSyncExpr(win)
	" call saved diffexpr or DiffCharExpr() if empty
	call eval(empty(s:save_dex) ? 'diffchar#DiffCharExpr()' : s:save_dex)

	" clear current diffchar highlights if present
	if exists('t:DChar')
		call s:RefreshDiffCharWID()
		let cwin = winnr()
		if index(values(t:DChar.win), cwin) != -1
			call diffchar#ResetDiffChar(range(1, line('$')))
		else
			let save_ei = &eventignore | let &eventignore = 'all'
			exec t:DChar.win[1] . 'wincmd w'
			call diffchar#ResetDiffChar(range(1, line('$')))
			exec cwin . 'wincmd w'
			let &eventignore = save_ei
		endif
	endif

	" find 'c' command and extract the line to be changed
	let [c1, c2] = [[], []]
	for ct in filter(readfile(v:fname_out), 'v:val =~ "^\\d.*c"')
		let [p1, p2] = map(split(ct, 'c'), 'split(v:val, ",")')
		let cn = min([len(p1) == 1 ? 0 : p1[1] - p1[0],
					\len(p2) == 1 ? 0 : p2[1] - p2[0]])
		let [c1, c2] += [range(p1[0], p1[0] + cn),
						\range(p2[0], p2[0] + cn)]
	endfor

	" if there are changed lines and initialize successes
	if !empty(c1) && !empty(c2) && s:InitializeDiffChar() != -1
		" change window numbers and diff lines
		let t:DChar.win = a:win
		let t:DChar.vdl = {1: c1, 2: c2}

		" highlight the diff changed lines
		call s:MarkDiffCharWID(1)
		let cwin = winnr()
		if index(values(t:DChar.win), cwin) != -1
			call diffchar#ShowDiffChar(range(1, line('$')))
		else
			let save_ei = &eventignore | let &eventignore = 'all'
			exec t:DChar.win[1] . 'wincmd w'
			call diffchar#ShowDiffChar(range(1, line('$')))
			exec cwin . 'wincmd w'
			let &eventignore = save_ei
		endif
	endif

	" resume back to the original diffexpr
	if exists('s:save_dex')
		let &diffexpr = s:save_dex
		unlet s:save_dex
	endif
endfunction

function! s:ApplyInternalAlgorithm(f1, f2)
	" read both files to be diff traced
	let [f1, f2] = [readfile(a:f1), readfile(a:f2)]

	" handle icase and iwhite diff options
	let save_igc = &ignorecase
	let &ignorecase = (&diffopt =~ 'icase')
	if &diffopt =~ 'iwhite'
		for k in [1, 2]
			call map(f{k}, 'substitute(v:val, "\\s\\+", " ", "g")')
			call map(f{k}, 'substitute(v:val, "\\s\\+$", "", "")')
		endfor
	endif

	" trace the diff lines between f1/f2 until the end time
	let ses = s:TraceDiffChar(f1, f2, str2float(reltimestr(reltime())) +
			\(exists('t:DiffSplitTime') ?
				\t:DiffSplitTime : g:DiffSplitTime) / 1000.0)

	" restore ignorecase flag
	let &ignorecase = save_igc

	" if timeout, return here with empty result
	if ses == '*' | return [] | endif

	let dfcmd = []
	let [l1, l2] = [1, 1]
	for ed in split(ses, '\%(=\+\|[+-]\+\)\zs')
		let qn = len(ed)
		if ed[0] == '='		" one or more '='
			let [l1, l2] += [qn, qn]
		else			" one or more '[+-]'
			let q1 = len(escape(ed, '-')) - qn
			let q2 = qn - q1
			let dfcmd += [
				\((q1 > 1) ? l1 . ',' : '') . (l1 + q1 - 1) .
				\((q1 == 0) ? 'a' : (q2 == 0) ? 'd' : 'c') .
				\((q2 > 1) ? l2 . ',' : '') . (l2 + q2 - 1)]
			let [l1, l2] += [q1, q2]
		endif
	endfor

	return dfcmd
endfunction

function! s:ApplyDiffCommand(f1, f2)
	" execute a diff command
	let opt = '-a --binary '
	if &diffopt =~ 'icase' | let opt .= '-i ' | endif
	if &diffopt =~ 'iwhite' | let opt .= '-b ' | endif
	if exists('g:DiffOptions') | let opt .= g:DiffOptions . ' ' | endif
	" return diff commands only
	return filter(split(system('diff ' . opt . a:f1 . ' ' . a:f2), '\n'),
							\'v:val[0] =~ "\\d"')
endfunction

function! s:InitializeDiffChar()
	if min(tabpagebuflist()) == max(tabpagebuflist())
		echo 'Need more buffers displayed on this tab page!'
		return -1
	endif

	" define a DiffChar dictionary on this tab page
	let t:DChar = {}

	" select current window and next (diff mode if available) window
	" whose buffer is different
	let t:DChar.win = {}
	let cwin = winnr()
	let nwin = filter(range(cwin + 1, winnr('$')) + range(1, cwin - 1),
					\'winbufnr(v:val) != winbufnr(cwin)')
	let dwin = s:ValidDiffModeWins(copy(nwin))
	let [t:DChar.win[1], t:DChar.win[2]] =
				\[cwin, empty(dwin) ? nwin[0] : dwin[0]]
	call s:MarkDiffCharWID(1)

	" set highlight groups used for diffchar on this tab page
	let t:DChar.dhl = {'A': 'DiffAdd', 'C': 'DiffChange',
		\'D': 'DiffDelete', 'T': 'DiffText', 'Z': '_DiffDelPos',
		\'U': has('gui_running') ? 'Cursor' : 'VertSplit'}

	" find corresponding DiffChange/DiffText lines on diff mode windows
	if len(s:ValidDiffModeWins(values(t:DChar.win))) == 2
		let t:DChar.vdl = {}
		let dh = [hlID(t:DChar.dhl.C), hlID(t:DChar.dhl.T)]
		let save_ei = &eventignore | let &eventignore = 'all'
		for k in [1, 2]
			exec t:DChar.win[k] . 'wincmd w'
			call diff_hlID(0, 0)	" a workaround for vim defect
			let t:DChar.vdl[k] = filter(range(1, line('$')),
					\'index(dh, diff_hlID(v:val, 1)) != -1')
			if empty(t:DChar.vdl[k])
				unlet t:DChar.vdl
				break
			endif
		endfor
		exec cwin . 'wincmd w'
		let &eventignore = save_ei
	endif

	" set ignorecase and ignorespace flags
	let t:DChar.igc = (&diffopt =~ 'icase')
	let t:DChar.igs = (&diffopt =~ 'iwhite')

	" set line and its highlight id record
	let t:DChar.mid = {}
	let [t:DChar.mid[1], t:DChar.mid[2]] = [{}, {}]

	" set highlighted lines and columns record
	let t:DChar.hlc = {}
	let [t:DChar.hlc[1], t:DChar.hlc[2]] = [{}, {}]

	" set a difference unit type on this tab page and set a split pattern
	let du = exists('t:DiffUnit') ? t:DiffUnit : g:DiffUnit
	if du == 'Word1'	" \w\+ word and any \W character
		let t:DChar.usp = t:DChar.igs ? '\%(\s\+\|\w\+\|\W\)\zs' :
							\'\%(\w\+\|\W\)\zs'
	elseif du == 'Word2'	" non-space and space words
		let t:DChar.usp = '\%(\s\+\|\S\+\)\zs'
	elseif du == 'Word3'	" \< or \> boundaries
		let t:DChar.usp = '\<\|\>'
	elseif du == 'Char'	" any single character
		let t:DChar.usp = t:DChar.igs ? '\%(\s\+\|.\)\zs' : '\zs'
	elseif du =~ '^CSV(.\+)$'	" split characters
		let s = escape(du[4 : -2], '^-]')
		let t:DChar.usp = '\%([^'. s . ']\+\|[' . s . ']\)\zs'
	elseif du =~ '^SRE(.\+)$'	" split regular expression
		let t:DChar.usp = du[4 : -2]
	else
		let t:DChar.usp = t:DChar.igs ? '\%(\s\+\|\w\+\|\W\)\zs' :
							\'\%(\w\+\|\W\)\zs'
		echo 'Not a valid difference unit type. Use "Word1" instead.'
	endif

	" set a difference unit updating on this tab page
	" and a record of line values and number of total lines
	if exists('##TextChanged') && exists('##TextChangedI')
		if exists('t:DiffUpdate') ? t:DiffUpdate : g:DiffUpdate
			let t:DChar.lsv = {}
			let [t:DChar.lsv[1], t:DChar.lsv[2]] = [{}, {}]
		endif
	endif

	" Set a time length (ms) to apply the internal algorithm first
	let t:DChar.slt = exists('t:DiffSplitTime') ?
				\t:DiffSplitTime : g:DiffSplitTime

	" Set a diff mode synchronization flag
	let t:DChar.dsy = exists('t:DiffModeSync') ?
				\t:DiffModeSync : g:DiffModeSync

	" set a matching pair cursor id on this tab page
	let t:DChar.pci = {}

	" set a difference matching colors on this tab page
	let dc = exists('t:DiffColors') ? t:DiffColors : g:DiffColors
	let t:DChar.dmc = [t:DChar.dhl.T]
	if dc == 1
		let t:DChar.dmc += ['NonText', 'Search', 'VisualNOS']
	elseif dc == 2
		let t:DChar.dmc += ['NonText', 'Search', 'VisualNOS',
			\'ErrorMsg', 'MoreMsg', 'TabLine', 'Title']
	elseif dc == 3
		let t:DChar.dmc += ['NonText', 'Search', 'VisualNOS',
			\'ErrorMsg', 'MoreMsg', 'TabLine', 'Title',
			\'StatusLine', 'WarningMsg', 'Conceal', 'SpecialKey',
			\'ColorColumn', 'ModeMsg', 'SignColumn', 'Question']
	elseif dc == 100
		redir => hl | silent highlight | redir END
		let h = map(filter(split(hl, '\n'),
			\'v:val =~ "^\\S" && v:val =~ "="'), 'split(v:val)[0]')
		for c in values(t:DChar.dhl)
			let i = index(h, c) | if i != -1 | unlet h[i] | endif
		endfor
		while !empty(h)
			let r = localtime() % len(h)
			let t:DChar.dmc += [h[r]] | unlet h[r]
		endwhile
	endif

	" define a specific highlight group to show a position
	" of a deleted unit, _DiffDelPos = DiffChange +/- underline
	exec 'silent highlight clear ' . t:DChar.dhl.Z
	" get current DiffChange
	redir => hl | exec 'silent highlight ' . t:DChar.dhl.C | redir END
	let ha = {}
	for [ky, ag] in map(filter(split(hl, '\%(\n\|\s\)\+'),
				\'v:val =~ "="'), 'split(v:val, "=")')
		let ha[ky] = ag
	endfor
	" add or delete a specific attribute (underline)
	let at = 'underline'
	let hm = has('gui_running') ? 'gui' : &t_Co > 1 ? 'cterm' : 'term'
	let ha[hm] = !exists('ha[hm]') ? at :
			\match(ha[hm], at) == -1 ? ha[hm] . ',' . at :
			\substitute(ha[hm], at . ',\=\|,\=' . at, '', '')
	" set as a highlight
	exec 'silent highlight ' . t:DChar.dhl.Z . ' ' .
			\join(values(map(filter(ha, '!empty(v:val)'),
						\'v:key . "=" . v:val')))
endfunction

function! diffchar#ShowDiffChar(lines)
	" initialize when t:DChar is not defined
	if !exists('t:DChar')
		if s:InitializeDiffChar() == -1 | return | endif
		let first = 1
	else
		let first = empty(t:DChar.hlc[1]) || empty(t:DChar.hlc[2])
	endif

	" refresh window number of diffchar windows
	call s:RefreshDiffCharWID()

	" return if current window is not either of diffchar windows
	let cwin = winnr()
	for k in [1, 2, 0]
		if k == 0 | return | endif
		if t:DChar.win[k] == cwin | break | endif
	endfor

	" set a possible DiffChar line list among a:lines
	let [d1, d2] = exists('t:DChar.vdl') ?
		\s:DiffModeLines(k, a:lines) : [copy(a:lines), copy(a:lines)]

	" remove already highlighted lines and get those text
	for k in [1, 2]
		let hl = map(keys(t:DChar.hlc[k]), 'eval(v:val)')
		call filter(d{k}, 'index(hl, v:val) == -1')
		let u{k} = map(copy(d{k}),
			\'getbufline(winbufnr(t:DChar.win[k]), v:val)[0]')
		let n{k} = len(u{k})
	endfor

	" remove redundant lines in either window
	if n1 > n2
		unlet u1[n2 - n1 :] | unlet d1[n2 - n1 :] | let n1 = n2
	elseif n1 < n2
		unlet u2[n1 - n2 :] | unlet d2[n1 - n2 :] | let n2 = n1
	endif

	" set ignorecase flag
	let save_igc = &ignorecase
	let &ignorecase = t:DChar.igc

	for n in range(n1 - 1, 0, -1)
		if t:DChar.igs
			" delete \s\+ at line end
			let u1[n] = substitute(u1[n], '\s\+$', '', '')
			let u2[n] = substitute(u2[n], '\s\+$', '', '')
		endif
		if u1[n] == u2[n]
			" remove equivalent lines
			unlet u1[n] | unlet d1[n]
			unlet u2[n] | unlet d2[n]
			let [n1, n2] -= [1, 1]
		endif
	endfor
	if n1 == 0
		if empty(t:DChar.hlc[1]) || empty(t:DChar.hlc[2])
			call s:MarkDiffCharWID(0)
			unlet t:DChar
		endif
		let &ignorecase = save_igc
		return
	endif

	" a list of actual difference units for tracing
	call map(u1, 'split(v:val, t:DChar.usp)')
	call map(u2, 'split(v:val, t:DChar.usp)')

	" a list of different lines and columns
	let [lc1, lc2] = [{}, {}]
	let cmp = 0
	for fn in ['TraceWithInternalAlgorithm', 'TraceWithDiffCommand']
		" trace with this plugin's algorithm first,
		" if timeout, split to the diff command
		for [ln, cx] in items(s:{fn}(u1[cmp :], u2[cmp :]))
			let [lc1[d1[cmp + ln]], lc2[d2[cmp + ln]]] =
							\[cx[0], cx[1]]
		endfor
		let cmp = len(lc1)
		if cmp >= n1 | break | endif
	endfor
	call filter(lc1, '!empty(v:val)')
	call filter(lc2, '!empty(v:val)')

	" restore ignorecase flag
	let &ignorecase = save_igc

	" highlight lines and columns
	let save_ei = &eventignore | let &eventignore = 'all'
	for k in [1, 2]
		let buf{k} = winbufnr(t:DChar.win[k])
		exec t:DChar.win[k] . 'wincmd w'
		call s:HighlightDiffChar(k, lc{k})

		if exists('t:DChar.lsv')
			call extend(t:DChar.lsv[k], s:LinesValues(k,
				\map(keys(lc{k}), 'eval(v:val)')))
			let t:DChar.lsv[k][0] = line('$')
		endif
	endfor
	exec cwin . 'wincmd w'
	let &eventignore = save_ei

	if empty(t:DChar.hlc[1]) || empty(t:DChar.hlc[2])
		call s:MarkDiffCharWID(0)
		unlet t:DChar
		return
	endif

	" if not the first call in this tab page, return here
	if !first | return | endif

	" set events in each buffer
	for k in [1, 2]
		exec 'au! dchar BufWinLeave <buffer=' . buf{k} .
			\'> call diffchar#ResetDiffChar(range(1, line("$")))'
		if exists('##QuitPre')
			exec 'au! dchar QuitPre <buffer=' . buf{k} .
				\'> call s:SwitchDiffChar()'
		endif
	endfor
	if exists('t:DChar.lsv')
		for k in [1, 2]
			exec 'au! dchar TextChanged <buffer=' . buf{k} .
				\'> call s:UpdateDiffChar(' . k . ', "n")'
			exec 'au! dchar TextChangedI <buffer=' . buf{k} .
				\'> call s:UpdateDiffChar(' . k . ', "i")'
		endfor
	endif
	if t:DChar.dsy && exists('t:DChar.vdl')
		for k in [1, 2]
			exec 'au! dchar CursorHold <buffer=' . buf{k} .
				\'> call s:ResetSwitchDiffModeSync(' . k . ')'
		endfor
		if !exists('s:save_ut') &&
			\len(filter(map(range(1, tabpagenr('$')),
				\'gettabvar(v:val, "DChar")'),
					\'!empty(v:val) && v:val.dsy &&
						\exists("v:val.vdl")')) == 1
			let s:save_ut = &updatetime
			let &updatetime = 500
		endif
	endif

	if has('patch-7.4.682')
		call s:ToggleDiffHL(1)
	endif
endfunction

function! s:TraceWithInternalAlgorithm(u1, u2)
	" a list of commands with byte index per line
	let cbx = {}

	" set an end time for diff tracing
	let et = str2float(reltimestr(reltime())) + t:DChar.slt / 1000.0

	" compare each line and trace difference units
	for ln in range(len(a:u1))
		if t:DChar.igs
			" convert \s\+ to a single space
			let [u1, u2] = [map(copy(a:u1[ln]), 'substitute(
						\v:val, "\\s\\+", " ", "g")'),
					\map(copy(a:u2[ln]), 'substitute(
						\v:val, "\\s\\+", " ", "g")')]
		else
			let [u1, u2] = [a:u1[ln], a:u2[ln]]
		endif

		" get edit script
		let es = s:TraceDiffChar(u1, u2, et)

		" if timeout, break here
		if es == '*' | break | endif

		let cbx[ln] = s:GetComWithByteIdx(es, a:u1[ln], a:u2[ln])
	endfor

	return cbx
endfunction

function! s:TraceWithDiffCommand(u1, u2)
	" prepare 2 input files for diff
	let lns = '|'
	for k in [1, 2]
		" add '<line number>:' at the beginning of each unit,
		" enclose each line with '<line number>{<id>' and
		" '<line number>}<id>', and insert '|' between lines
		let g{k} = []
		let p = -1 | let p{k} = []	" line separator position
		for n in range(len(a:u{k}))
			let l = n + 1
			let g = [l . '{' . k] +
				\map(copy(a:u{k}[n]), 'l . ":" . v:val') +
						\[l . '}' . k] + [lns]
			let g{k} += g
			let p += len(g) | let p{k} += [p]
		endfor
		unlet g{k}[-1]
		unlet p{k}[-1]

		" write to a temp file for diff command
		let f{k} = tempname() | call writefile(g{k}, f{k})

		" initialize a list of edit symbols [=+-#] for each unit
		call map(g{k}, '"="')
	endfor

	" call diff and get output as a list
	let opt = '-a --binary '
	if t:DChar.igc | let opt .= '-i ' | endif
	if t:DChar.igs | let opt .= '-b ' | endif
	if exists('g:DiffOptions') | let opt .= g:DiffOptions . ' ' | endif
	let dfo = split(system('diff ' . opt . f1 . ' ' . f2), '\n')
	call delete(f1) | call delete(f2)

	" assign edit symbols [=+-#] to each unit
	for dc in filter(dfo, 'v:val[0] =~ "\\d"')
		let [se1, op, se2] = split(substitute(dc, '\a', ' & ', ''))
		let [s1, e1] = (se1 =~ ',') ? split(se1, ',') : [se1, se1]
		let [s2, e2] = (se2 =~ ',') ? split(se2, ',') : [se2, se2]
		let [s1, e1, s2, e2] -= [1, 1, 1, 1]
		if op == 'c'
			let g1[s1 : e1] = repeat(['-'], e1 - s1 + 1)
			let g2[s2 : e2] = repeat(['+'], e2 - s2 + 1)
		elseif op == 'd'
			let g1[s1 : e1] = repeat(['-'], e1 - s1 + 1)
			let g2[s2] .= '#'	" append add/del position mark
		else	"if op == 'a'
			let g1[s1] .= '#'	" append add/del position mark
			let g2[s2 : e2] = repeat(['+'], e2 - s2 + 1)
		endif
	endfor

	" separate lines and divide units
	for k in [1, 2]
		for p in p{k} | let g{k}[p] = lns | endfor
		let g{k} = map(split(join(g{k}, ''), lns),
			\'split(v:val, "\\%(=\\+\\|[+-]\\+\\|#\\)\\zs")')
	endfor

	" a list of commands with byte index per line
	let cbx = {}

	for ln in range(len(g1))
		call map(g1[ln], 'v:val[0] == "#" ? "" : v:val')
		call map(g2[ln], 'v:val[0] == "+" ? v:val : ""')
		let es = join(map(g1[ln], 'v:val . g2[ln][v:key]'), '')

		" delete the first and last [+-] of line begin/end symbols
		let es = substitute(es, '^[^+]*\zs+\|+\ze[^+]*$', '', 'g')
		let es = substitute(es, '^[^-]*\zs-\|-\ze[^-]*$', '', 'g')

		let cbx[ln] = s:GetComWithByteIdx(es, a:u1[ln], a:u2[ln])
	endfor

	return cbx
endfunction

function! s:GetComWithByteIdx(es, u1, u2)
	let [c1, c2] = [[], []]
	let [l1, l2, p1, p2] = [1, 1, 0, 0]
	for ed in split(a:es, '\%(=\+\|[+-]\+\)\zs')
		let qn = len(ed)
		if ed[0] == '='		" one or more '='
			for k in [1, 2]
				let [l{k}, p{k}] += [len(join(a:u{k}[p{k} :
						\p{k} + qn - 1], '')), qn]
			endfor
		else			" one or more '[+-]'
			let q1 = len(escape(ed, '-')) - qn
			let q2 = qn - q1
			for k in [1, 2]
				if q{k} > 0
					let r = len(join(a:u{k}[p{k} :
							\p{k} + q{k} - 1], ''))
					let h{k} = [l{k}, l{k} + r - 1]
					let [l{k}, p{k}] += [r, q{k}]
				else
					let h{k} = [l{k} - (0 < p{k} ?
						\len(split(a:u{k}[p{k} - 1],
							\'\zs')[-1]) : 0),
						\l{k} + (p{k} < len(a:u{k}) ?
						\len(split(a:u{k}[p{k}],
							\'\zs')[0]) : 0) - 1]
				endif
			endfor
			let [r1, r2] = (q1 == 0) ? ['d', 'a'] :
					\(q2 == 0) ? ['a', 'd'] : ['c', 'c']
			let [c1, c2] += [[[r1, h1]], [[r2, h2]]]
		endif
	endfor
	return [c1, c2]
endfunction

function! diffchar#ResetDiffChar(lines)
	if !exists('t:DChar') | return | endif

	" refresh window number of diffchar windows
	call s:RefreshDiffCharWID()

	" return if current window is not either of diffchar windows
	let cwin = winnr()
	for k in [1, 2, 0]
		if k == 0 | return | endif
		if t:DChar.win[k] == cwin | break | endif
	endfor

	" set a possible DiffChar line list among a:lines
	let [d1, d2] = exists('t:DChar.vdl') ?
		\s:DiffModeLines(k, a:lines) : [copy(a:lines), copy(a:lines)]

	" remove not highlighted lines
	let save_ei = &eventignore | let &eventignore = 'all'
	for k in [1, 2]
		let hl = map(keys(t:DChar.hlc[k]), 'eval(v:val)')
		call filter(d{k}, 'index(hl, v:val) != -1')

		let buf{k} = winbufnr(t:DChar.win[k])
		exec t:DChar.win[k] . 'wincmd w'
		call s:ClearDiffChar(k, d{k})
		call s:ResetDiffCharPair(k)

		if exists('t:DChar.lsv')
			call map(d{k}, 'remove(t:DChar.lsv[k], v:val)')
		endif
	endfor
	exec cwin . 'wincmd w'
	let &eventignore = save_ei

	if !empty(t:DChar.hlc[1]) && !empty(t:DChar.hlc[2])
		return
	endif

	" reset events and all when no highlight exists
	for k in [1, 2]
		exec 'au! dchar BufWinLeave <buffer=' . buf{k} . '>'
		if exists('##QuitPre')
			exec 'au! dchar QuitPre <buffer=' . buf{k} . '>'
		endif
	endfor
	if exists('t:DChar.lsv')
		for k in [1, 2]
			exec 'au! dchar TextChanged,TextChangedI <buffer=' .
								\buf{k} . '>'
		endfor
	endif
	if t:DChar.dsy && exists('t:DChar.vdl')
		for k in [1, 2]
			exec 'au! dchar CursorHold <buffer=' . buf{k} . '>'
		endfor
		if exists('s:save_ut') &&
			\len(filter(map(range(1, tabpagenr('$')),
				\'gettabvar(v:val, "DChar")'),
					\'!empty(v:val) && v:val.dsy &&
						\exists("v:val.vdl")')) == 1
			let &updatetime = s:save_ut
			unlet s:save_ut
		endif
	endif

	if has('patch-7.4.682')
		call s:ToggleDiffHL(0)
	endif
	call s:MarkDiffCharWID(0)
	unlet t:DChar
endfunction

function! diffchar#ToggleDiffChar(lines)
	if exists('t:DChar')
		call s:RefreshDiffCharWID()
		for k in [1, 2, 0]
			if k == 0 | return | endif
			if t:DChar.win[k] == winnr() | break | endif
		endfor
		for hl in keys(t:DChar.hlc[k])
			if index(a:lines, eval(hl)) != -1
				call diffchar#ResetDiffChar(a:lines)
				return
			endif
		endfor
	endif
	call diffchar#ShowDiffChar(a:lines)
endfunction

function! s:SwitchDiffChar()
	" if diffchar is on one of split windows and when that window quits,
	" catch QuitPre and switch to the rest (diff mode first) of the windows
	call s:RefreshDiffCharWID()
	let cwin = winnr()
	let swin = filter(range(cwin + 1, winnr('$')) + range(1, cwin - 1),
					\'winbufnr(v:val) == bufnr("%")')
	if !empty(swin) && index(values(t:DChar.win), cwin) != -1
		let win = t:DChar.win
		call diffchar#ResetDiffChar(range(1, line('$')))
		if s:InitializeDiffChar() != -1
			let dwin = s:ValidDiffModeWins(swin)
			let nwin = empty(dwin) ? swin[0] : dwin[0]
			let t:DChar.win = map(win,
					\'v:val == cwin ? nwin : v:val')

			call s:MarkDiffCharWID(1)

			let save_ei = &eventignore | let &eventignore = 'all'
			exec nwin . 'wincmd w'
			call diffchar#ShowDiffChar(range(1, line('$')))
			let &eventignore = save_ei
		endif
	endif
endfunction

function! s:HighlightDiffChar(key, lec)
	for [l, ec] in items(a:lec)
		if has_key(t:DChar.mid[a:key], l) | continue | endif
		let t:DChar.hlc[a:key][l] = ec

		" collect all the column positions per highlight group
		let ap = {}
		let cn = 0
		for [e, c] in ec
			if e == 'c'
				let hl = t:DChar.dmc[cn % len(t:DChar.dmc)]
				let cn += 1
			elseif e == 'a'
				let hl = t:DChar.dhl.A
			elseif e == 'd'
				let hl = t:DChar.dhl.Z
			endif
			let ap[hl] = get(ap, hl, []) + [c]
		endfor

		" do highlightings on all the lines and columns
		" with minimum matchaddpos() or one matchadd() call
		if exists('*matchaddpos')
			let t:DChar.mid[a:key][l] =
				\[matchaddpos(t:DChar.dhl.C, [[l]], 0)]
			for [hl, cp] in items(ap)
				call map(cp, '[l, v:val[0],
						\v:val[1] - v:val[0] + 1]')
				while !empty(cp)
					let t:DChar.mid[a:key][l] +=
						\[matchaddpos(hl, cp[:7], 0)]
					unlet cp[:7]
				endwhile
			endfor
		else
			let dl = '\%' . l . 'l'
			let t:DChar.mid[a:key][l] =
				\[matchadd(t:DChar.dhl.C, dl . '.', 0)]
			for [hl, cp] in items(ap)
				call map(cp, '"\\%>" . (v:val[0] - 1) .
					\"c\\%<" . (v:val[1] + 1) . "c"')
				let dc = len(cp) > 1 ?
					\'\%(' . join(cp, '\|') . '\)' : cp[0]
				let t:DChar.mid[a:key][l] +=
						\[matchadd(hl, dl . dc, 0)]
			endfor
		endif
	endfor
endfunction

function! s:ClearDiffChar(key, lines)
	for l in a:lines
		if has_key(t:DChar.mid[a:key], l)
			call map(t:DChar.mid[a:key][l], 'matchdelete(v:val)')
			unlet t:DChar.mid[a:key][l]
			unlet t:DChar.hlc[a:key][l]
		endif
	endfor
endfunction

function! s:UpdateDiffChar(key, mode)
	call s:RefreshDiffCharWID()

	let cwin = winnr()
	if cwin != t:DChar.win[a:key]
		let save_ei = &eventignore | let &eventignore = 'all'
		exec t:DChar.win[a:key] . 'wincmd w'
	endif

	" if number of lines was changed, reset all
	if t:DChar.lsv[a:key][0] != line('$')
		call diffchar#ResetDiffChar(
			\range(1, max([t:DChar.lsv[a:key][0], line('$')])))
	else
		" find changed lines which were highlighted
		let chl = map(keys(t:DChar.hlc[a:key]), 'eval(v:val)')
		if a:mode == 'i'
			call filter(chl, 'v:val == line(".")')
		endif
		let lsv = s:LinesValues(a:key, chl)
		call filter(chl, 'lsv[v:val] != t:DChar.lsv[a:key][v:val]')

		if !empty(chl)
			" save the current t:DChar in case all hl can be reset
			let sdc = deepcopy(t:DChar)

			" reset hl of changed lines
			call diffchar#ResetDiffChar(chl)

			" if all hl was reset, restore saved t:DChar except hl
			if !exists('t:DChar')
				let [sdc.mid[1], sdc.mid[2]] = [{}, {}]
				let [sdc.hlc[1], sdc.hlc[2]] = [{}, {}]
				if exists('sdc.dtm') | unlet sdc.dtm | endif
				if exists('sdc.lsv')
					let [sdc.lsv[1], sdc.lsv[2]] = [{}, {}]
				endif
				let t:DChar = sdc
				call s:MarkDiffCharWID(1)
			endif

			" show hl of changed lines
			call diffchar#ShowDiffChar(chl)

			" if hl lines are changed in diff mode, refresh diff HL
			if has('patch-7.4.682') && exists('t:DChar.vdl') &&
				\chl != map(keys(t:DChar.hlc[a:key]),
								\'eval(v:val)')
					call s:RestoreDiffHL()
					call s:OverwriteDiffHL()
			endif
		endif
	endif

	if exists('save_ei')
		exec cwin . 'wincmd w'
		let &eventignore = save_ei
	endif
endfunction

function! s:ResetSwitchDiffModeSync(key)
	" when diff mode turns off on the current window, reset it
	if !empty(s:ValidDiffModeWins([winnr()])) | return | endif

	call s:RefreshDiffCharWID()

	let cwin = winnr()
	if cwin != t:DChar.win[a:key] | return | endif

	let [win, vdl, dsy] = [t:DChar.win, t:DChar.vdl, t:DChar.dsy]

	call diffchar#ResetDiffChar(range(1, line('$')))

	" if there is another diff mode window of the same buffer and
	" need to contine diff mode sync, switch to that window
	if dsy
		let bwin = s:ValidDiffModeWins(filter(range(1, winnr('$')),
				\'winbufnr(v:val) == bufnr("%")'))
		if !empty(bwin) && s:InitializeDiffChar() != -1
			let t:DChar.win =
				\map(win, 'v:key == a:key ? bwin[0] : v:val')
			let t:DChar.vdl = vdl

			call s:MarkDiffCharWID(1)

			let save_ei = &eventignore | let &eventignore = 'all'
			exec t:DChar.win[1] . 'wincmd w'
			call diffchar#ShowDiffChar(range(1, line('$')))
			exec cwin . 'wincmd w'
			let &eventignore = save_ei
		endif
	endif
endfunction

function! s:DiffModeLines(key, lines)
	" in diff mode, need to compare the different line between windows
	" if current window is t:DChar.win[1], narrow a:lines within vdl[1]
	" and get the corresponding lines from vdl[2]
	let [d1, d2] = [copy(t:DChar.vdl[1]), copy(t:DChar.vdl[2])]
	let [i, j] = (a:key == 1) ? [1, 2] : [2, 1]
	call map(d{i}, 'index(a:lines, v:val) == -1 ? -1 : v:val')
	call filter(d{j}, 'd{i}[v:key] != -1')
	call filter(d{i}, 'v:val != -1')
	return [d1, d2]
endfunction

function! s:LinesValues(key, lines)
	let bnr = winbufnr(t:DChar.win[a:key])
	return eval('{' . join(map(copy(a:lines), 'v:val . ":" .
		\str2nr(sha256(getbufline(bnr, v:val)[0]), 16)'),
				\',') . '}')
endfunction

function! s:ValidDiffModeWins(wlist)
	" Try to use diffput to check if the diff mode is really valid or not.
	let cwin = winnr()
	let save_ei = &eventignore | let &eventignore = 'all'
	let vdmw = []
	for w in a:wlist
		if getwinvar(w, '&diff')
			exec w . 'wincmd w'
			try
				exec 'silent diffput 99999'
			catch /^Vim(diffput):E99:/
				" &diff == 1 but invalid diff mode
			catch /^Vim(diffput):/
				let vdmw += [w]
			endtry
		endif
	endfor
	exec cwin . 'wincmd w'
	let &eventignore = save_ei
	return vdmw
endfunction

function! diffchar#JumpDiffChar(dir, pos)
	" dir : 1 = forward, 0 = backward
	" pos : 1 = start, 0 = end
	if !exists('t:DChar') | return | endif

	" refresh window number of diffchar windows
	call s:RefreshDiffCharWID()

	" return if current window is not either of diffchar windows
	let cwin = winnr()
	for k in [1, 2, 0]
		if k == 0 | return | endif
		if t:DChar.win[k] == cwin | break | endif
	endfor

	let found = 0
	let l = line('.')
	while !found && 1 <= l && l <= line('$')
		if has_key(t:DChar.hlc[k], l)
			if l == line('.')
				let c = col('.')
				if !a:pos
					" end pos workaround for multibyte char
					let c += len(matchstr(getbufline(
						\winbufnr(cwin), l)[0],
						\'.', c - 1)) - 1
				endif
			else
				let c = a:dir ? 0 : 99999
			endif
			let hc = map(copy(t:DChar.hlc[k][l]),
						\'(v:val[0] == "d") ? "" :
						\v:val[1][a:pos ? 0 : 1]')
			if !a:dir
				let c = - c
				call map(reverse(hc),
						\'empty(v:val) ? "" : - v:val')
			endif
			for n in range(len(hc))
				if !empty(hc[n]) && c < hc[n]
					let c = hc[n]
					if !a:dir
						let c = - c
						let n = len(hc) - n - 1
					endif
					call cursor(l, c)
					call s:ShowDiffCharPair(k, l, n, a:pos)
					let found = 1
					break
				endif
			endfor
		endif
		let l = a:dir ? l + 1 : l - 1
	endwhile
endfunction

function! s:ShowDiffCharPair(key, line, col, pos)
	" show cursor on deleted or matching unit on another window
	let bkey = (a:key == 1) ? 2 : 1
	if exists('t:DChar.vdl')	" diff mode
		let bline = t:DChar.vdl[bkey][index(t:DChar.vdl[a:key], a:line)]
	else				" non-diff mode
		let bline = a:line
	endif
	let bl = getbufline(winbufnr(t:DChar.win[bkey]), bline)[0]
	let co = t:DChar.hlc[bkey][bline][a:col][1]
	let dc = bl[co[0] - 1 : co[1] - 1]

	let save_ei = &eventignore | let &eventignore = 'all'
	exec t:DChar.win[bkey] . 'wincmd w'

	call s:ResetDiffCharPair(bkey)
	let clen = len(split(dc, '\zs')[a:pos ? 0 : -1])
	let cpos = a:pos ? co[0] : co[1] - clen + 1
	if exists('*matchaddpos')
		let t:DChar.pci[bkey] = matchaddpos(t:DChar.dhl.U,
						\[[bline, cpos, clen]], 0)
	else
		let t:DChar.pci[bkey] = matchadd(t:DChar.dhl.U, '\%' . bline .
			\'l\%>' . (cpos - 1) . 'c\%<' . (cpos + clen) . 'c', 0)
	endif
	exec 'au! dchar WinEnter <buffer=' . winbufnr(t:DChar.win[bkey]) .
				\'> call s:ResetDiffCharPair(' . bkey . ')'

	exec t:DChar.win[a:key] . 'wincmd w'
	let &eventignore = save_ei

	" echo the deleted and matching unit with its color
	let [ed, co] = t:DChar.hlc[a:key][a:line][a:col]
	if ed == 'a'		" added unit
		let bl = getbufline(winbufnr(t:DChar.win[a:key]), a:line)[0]
		exec 'echohl ' . t:DChar.dhl.C
		echon (1 < co[0]) ? split(bl[: co[0] - 2], '\zs')[-1] : ''
		exec 'echohl ' . t:DChar.dhl.D
		echon repeat('-', strwidth(bl[co[0] - 1 : co[1] - 1]))
		exec 'echohl ' . t:DChar.dhl.C
		echon (co[1] < len(bl)) ? split(bl[co[1] :], '\zs')[0] : ''
		echohl None
	elseif ed == 'c'	" changed unit
		exec 'echohl ' . t:DChar.dmc[(count(
			\map(t:DChar.hlc[a:key][a:line][: a:col], 'v:val[0]'),
				\'c') - 1) % len(t:DChar.dmc)]
		echon dc
		echohl None
	endif
endfunction

function! s:ResetDiffCharPair(key)
	if exists('t:DChar.pci[a:key]')
		call matchdelete(t:DChar.pci[a:key])
		unlet t:DChar.pci[a:key]
		exec 'au! dchar WinEnter <buffer=' .
					\winbufnr(t:DChar.win[a:key]) . '>'
		echon ''
	endif
endfunction

function! s:MarkDiffCharWID(on)
	" mark w:DCharWID (1/2) on diffchar windows or delete them
	for wvr in map(range(1, winnr('$')), 'getwinvar(v:val, "")')
		if has_key(wvr, 'DCharWID') | unlet wvr.DCharWID | endif
	endfor
	if a:on
		call map([1, 2],
			\'setwinvar(t:DChar.win[v:val], "DCharWID", v:val)')
	endif
endfunction

function! s:RefreshDiffCharWID()
	" find diffchar windows and set their winnr to t:DChar.win again
	let t:DChar.win = {}
	for win in range(1, winnr('$'))
		let id = get(getwinvar(win, ''), 'DCharWID', 0)
		if id | let t:DChar.win[id] = win | endif
	endfor
endfunction

" "An O(NP) Sequence Comparison Algorithm"
" by S.Wu, U.Manber, G.Myers and W.Miller
function! s:TraceDiffChar(u1, u2, ...)
	let [l1, l2] = [len(a:u1), len(a:u2)]
	if l1 == 0 && l2 == 0 | return ''
	elseif l1 == 0 | return repeat('+', l2)
	elseif l2 == 0 | return repeat('-', l1)
	endif

	" reverse to be M >= N
	let [M, N, u1, u2, e1, e2] = (l1 >= l2) ?
				\[l1, l2, a:u1, a:u2, '+', '-'] :
				\[l2, l1, a:u2, a:u1, '-', '+']

	let D = M - N
	let fp = repeat([-1], M + N + 1)
	let etree = []		" [next edit, previous p, previous k]

	" check time limit when specified the end time
	let ckt = (a:0 > 0) ? 'str2float(reltimestr(reltime())) > a:1' : 0

	let p = -1
	while fp[D] != M
		" if timeout, return here with '*'
		if eval(ckt) | return '*' | endif
		let p += 1
		let epk = repeat([[]], p * 2 + D + 1)
		for k in range(-p, D - 1, 1) + range(D + p, D, -1)
			let [x, epk[k]] = (fp[k - 1] < fp[k + 1]) ?
				\[fp[k + 1], [e1, k < D ? p - 1 : p, k + 1]] :
				\[fp[k - 1] + 1, [e2, k > D ? p - 1 : p, k - 1]]
			let y = x - k
			while x < M && y < N && u1[x] == u2[y]
				let epk[k][0] .= '='
				let [x, y] += [1, 1]
			endwhile
			let fp[k] = x
		endfor
		let etree += [epk]
	endwhile

	" create a shortest edit script (SES) from last p and k
	let ses = ''
	while p != 0 || k != 0
		let [e, p, k] = etree[p][k]
		let ses = e . ses
	endwhile
	let ses = etree[p][k][0] . ses

	return ses[1:]		" remove the first entry
endfunction

if has('patch-7.4.682')
function! s:ToggleDiffHL(on)
	" no need in no-diff mode
	if !exists('t:DChar.vdl') | return | endif

	let tn = len(filter(map(range(1, tabpagenr('$')),
			\'gettabvar(v:val, "DChar")'),
				\'!empty(v:val) && exists("v:val.dtm")'))
	if a:on
		if tn == 0	" set event at first ON
			au! dchar TabEnter * call s:AdjustHLOption()
		endif
		" disable hl option and overwrite DiffChange/DiffText area
		call s:DisableHLOption()
		call s:OverwriteDiffHL()
	else
		if tn == 1	" clear event at last OFF
			au! dchar TabEnter *
		endif
		" restore hl option and DiffChange/DiffText area
		call s:RestoreHLOption()
		call s:RestoreDiffHL()
	endif
endfunction

function! s:AdjustHLOption()
	call eval(exists('t:DChar.vdl') ?
			\'s:DisableHLOption()' : 's:RestoreHLOption()')
endfunction

function! s:DisableHLOption()
	if !exists('s:save_hl')
		let s:save_hl = &highlight
		let &highlight = join(map(split(s:save_hl, ','),
			\'v:val[0] =~# "[CT]" ? v:val[0] . "-" : v:val'), ',')
	endif
endfunction

function! s:RestoreHLOption()
	if exists('s:save_hl')
		let &highlight = s:save_hl
		unlet s:save_hl
	endif
endfunction

function! s:OverwriteDiffHL()
	" overwrite DiffChange/DiffText area with its match
	if exists('t:DChar.dtm') | return | endif

	let t:DChar.dtm = {}

	let cwin = winnr()
	let save_ei = &eventignore | let &eventignore = 'all'

	for k in [1, 2]
		exec t:DChar.win[k] . 'wincmd w'

		let tl = []
		if !exists('s:save_dex')
			" normal case
			let dt = hlID(t:DChar.dhl.T)
			call diff_hlID(0, 0)	" a workaround for vim defect
			for l in t:DChar.vdl[k]
				let t = filter(range(1, col([l, '$']) - 1),
						\'diff_hlID(l, v:val) == dt')
				if empty(t) | continue | endif
				let [cs, ce] = [t[0], t[-1]]
				let tl += [[l, cs, ce - cs + 1]]
			endfor
		else
			" diffexpr exceptional case
			for l in t:DChar.vdl[k]
				let h = get(t:DChar.hlc[k], l, [])
				if empty(h) | continue | endif
				let cs = h[0][1][h[0][0] == 'd' ? 1 : 0]
				let ce = h[-1][1][h[-1][0] == 'd' ? 0 : 1]
				if cs > ce | continue | endif
				let tl += [[l, cs, ce - cs + 1]]
			endfor
		endif

		let t:DChar.dtm[k] = []
		for hl in ['C', 'T']
			let ll = (hl == 'C') ? t:DChar.vdl[k] : tl
			let p = 0
			while p < len(ll)
				let t:DChar.dtm[k] += [matchaddpos(
					\t:DChar.dhl[hl], ll[p : p + 7], -1)]
				let p += 8
			endwhile
		endfor
	endfor

	exec cwin . 'wincmd w'
	let &eventignore = save_ei
endfunction

function! s:RestoreDiffHL()
	" delete all the overwritten DiffChange/DiffText matches
	if !exists('t:DChar.dtm') | return | endif

	let cwin = winnr()
	let save_ei = &eventignore | let &eventignore = 'all'

	for k in [1, 2]
		exec t:DChar.win[k] . 'wincmd w'
		call map(t:DChar.dtm[k], 'matchdelete(v:val)')
	endfor

	exec cwin . 'wincmd w'
	let &eventignore = save_ei

	unlet t:DChar.dtm
endfunction
endif

let &cpo = s:save_cpo
unlet s:save_cpo
