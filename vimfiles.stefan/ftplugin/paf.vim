
" Adresse der aktuellen Zeile berechnen und in der Statusline anzeigen
command PafGetAddress! call PafGetAddress()
function! PafGetAddress()
    let RE = ':\x\{2}\x\{4}02\(\x\{4}\)\x\{2}'
    let line = search(RE, 'bcnW')
    let ELAR = substitute(getline(line), RE, '0x\10', '')
    let RE = ':\x\{2}\x\{4}04\(\x\{4}\)\x\{2}'
    let line = search(RE, 'bcnW')
    let ESAR = substitute(getline(line), RE, '0x\10000', '')
    let RE = ':\x\{2}\(\x\{4}\)00\x\+'
    let line = line('.')
    let LA = substitute(getline(line), RE, '0x\1', '')
    let address = eval(ELAR  + ESAR + LA)
    return printf('0x%08x', address)
endfunction

setlocal statusline=%{PafGetAddress()}
setlocal laststatus=2

