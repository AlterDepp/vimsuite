
" Parse Intel Hex Line into Dictionary
function! s:HexParseLine(line)
    let Pattern = '^:\(..\)\(....\)\(..\)\(.*\)\(..\)$'
    let Length   = substitute(a:line, Pattern, '\1', '')
    let Address  = substitute(a:line, Pattern, '\2', '')
    let Type     = substitute(a:line, Pattern, '\3', '')
    let Data     = substitute(a:line, Pattern, '\4', '')
    let Checksum = substitute(a:line, Pattern, '\5', '')
    let LineDict = {
                \'Length': Length,
                \'Address': Address,
                \'Type': Type,
                \'Data': Data,
                \'Checksum': Checksum,
                \}
    return LineDict
endfunction

" Get number of current byte of data
function! s:HexGetDataByte()
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

" Get Address of current cursor position
function! s:HexGetAddress()
    let AddressLineNumber = search('^:......04*', 'bcnW')
    let AddressLine = getline(AddressLineNumber)
    let LineDict = s:HexParseLine(AddressLine)
    let ExtLinAddress = LineDict['Data']

    let LineDict = s:HexParseLine(getline(line('.')))
    let AddressOffset = LineDict['Address']

    let LineAddressOffset = s:HexGetDataByte()

    let Address = eval(
                \  ' (0x'.ExtLinAddress.' * 0x10000)'
                \ .'+(0x'.AddressOffset.')'
                \ .'+(  '.LineAddressOffset.')'
                \ )
    return printf('0x%x', Address)
endfunction

" Split data string in List of byte strings
function! HexSplitData(DataString)
    let DataList = split(a:DataString, '..\zs')
    return DataList
endfunction

" Get ASCII representation of current data
function! s:HexGetAsciiLine()
    let String = ''
    let LineDict = s:HexParseLine(getline(line('.')))
    let Data = LineDict['Data']
    let DataList = HexSplitData(Data)
    for Byte in DataList
        let ByteVal = eval('0x'.Byte)
        let String .= nr2char(ByteVal)
    endfor
    return String
endfunction

" Get value of current data under cursor for a:Bytes
function! HexGetVal(Bytes)
    let StartByte = s:HexGetDataByte()
    let HexString = ''
    let LineDict = s:HexParseLine(getline(line('.')))
    let Data = LineDict['Data']
    let DataList = HexSplitData(Data)
    if (StartByte + a:Bytes) <= len(DataList)
        let ByteNum = 0
        while ByteNum < a:Bytes
            let HexString .= DataList[StartByte + ByteNum]
            let ByteNum += 1
        endwhile
        return eval('0x'.HexString)
    else
        return -1
endfunction

" Get actual values for 1, 2, 4 Bytes in hex and dez
function! s:HexGetDezValuesString()
    let String = ''
    for i in [1, 2, 4]
        let Byte = HexGetVal(i)
        if Byte != -1
            let String .= ' ' . printf('0x%x (%d)', Byte, Byte)
        endif
    endfor
    return String
endfunction

" Build string for statusline
function! HexStatusLine()
    let StatusLine =
                \   ' Address: '
                \ . s:HexGetAddress()
                \ . ' Values: '
                \ . s:HexGetDezValuesString()
"                \ . ' Data: '
"                \ . s:HexGetAsciiLine()
    return StatusLine
endfunction

"command! HexAddress call Test()
"function! Test()
"    echo HexStatusLine()
"endfunction

command! HexStatusLine set statusline=%!HexStatusLine()
command! HexStatusLineOff set statusline=
" Update statusline with HEX info
set statusline=%!HexStatusLine()
" Always show statusline
set laststatus=2
