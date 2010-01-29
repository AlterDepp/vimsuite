
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
    let AddressLineNumber = search('^:02*', 'bcnW')
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
    let ByteNum = 0
    while ByteNum < a:Bytes
        try
            let HexString .= DataList[StartByte + ByteNum]
        catch /^Vim\%((\a\+)\)\=:E684/
            throw 'oops'
        finally
            let ByteNum += 1
        endtry
    endwhile
    return eval('0x'.HexString)
endfunction

" Get actual values for 1, 2, 4 Bytes in hex and dez
function! s:HexGetDezValuesString()
    let String = ''
    for i in [1, 2, 4]
        try
            let Byte = HexGetVal(i)
        catch /oops/
            break
        endtry
        let String .= ' ' . printf('0x%x (%d)', Byte, Byte)
    endfor
    return String
endfunction

" Build string for statusline
function! HexStatusLine()
    let StatusLine =
                \   ' Address: '
                \ . s:HexGetAddress()
                \ . ' Data: '
                \ . s:HexGetAsciiLine()
                \ . ' Values: '
                \ . s:HexGetDezValuesString()
    return StatusLine
endfunction

"command! HexAddress call Test()
"function! Test()
"    echo HexStatusLine()
"endfunction

command HexStatusLine set statusline=%!HexStatusLine()
" Update statusline with HEX info
set statusline=%!HexStatusLine()
" Always show statusline
set laststatus=2
