" Paf file specification
" :    (RecMark)
" 10   (RecLen)
" 0000 (Offset)
" 00   (RecTyp: 00=Data, 01=EndOfFile, 02=ExtendedSegmentAddress, 04=ExtendedLinearAddress, 10=EndOfDataBlock)
" xxx  (Data)
" 00   (Checksum)

" Get number of current byte of data
function! s:GetDataByte()
    let Pos = getpos('.')
    let Column = Pos[2]
    let FirstData = 10
    let LastData = len(getline(line('.'))) - 2
    if Column < FirstData
        let Column = FirstData
    endif
    if Column > LastData
        let Column = LastData
    endif
    let DataByte = eval('('.Column.'-'.FirstData.') / 2')
    return DataByte
endfunction

" Adresse der aktuellen Zeile berechnen und in der Statusline anzeigen
command! PafGetAddress call PafGetAddress()
function! PafGetAddress()
    let RE = ':\x\{2}\x\{4}02\(\x\{4}\)\x\{2}'
    let line = search(RE, 'bcnW')
    let ELAR = substitute(getline(line), RE, '0x\10', '')
    let RE = ':\x\{2}\x\{4}04\(\x\{4}\)\x\{2}'
    let line = search(RE, 'bcnW')
    let ESAR = substitute(getline(line), RE, '0x\10000', '')
    let RE = ':\x\{2}\(\x\{4}\)[01]0\x\+'
    let line = line('.')
    let LA = substitute(getline(line), RE, '0x\1', '')
    let BYTE = s:GetDataByte()
    let address = eval(ELAR  + ESAR + LA + BYTE)
    return printf('0x%08x', address)
endfunction

setlocal statusline=%{PafGetAddress()}
setlocal laststatus=2

