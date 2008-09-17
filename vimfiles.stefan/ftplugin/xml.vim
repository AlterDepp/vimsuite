"let s:ElementRegex = '\s*\(.*\)<\(\w\+\)\%(\s\+\(\w\+\)="\(.\{-}\)"\)*>\([^<]\{-}\)</\2>\(.*\)\s*'
let s:TagRegex = '\s*<\(\w\+\)\%(\s\+\(\w\+\)="\(.\{-}\)"\)*>\(.\{-}\)</\1>\(.*\)\s*'

" ---------------------
" Parse XML-Tag in Text
" Return a dictionary
" ---------------------
function! XmlGetTags(Text)
    let Text = a:Text
    let Elements = []
    " get all elements
    while Text != ''
        let TagName = substitute(Text, s:TagRegex, '\1', '')
        if ((TagName != '') && (TagName != Text))
            " found outer tag
            let Tag = {}
            let Tag['Name'] = TagName
            let Tag['Attributes'] = {}
            let TagAttributeName = substitute(Text, s:TagRegex, '\2', '')
            if TagAttributeName != ''
                let Tag['Attributes']['Name'] = TagAttributeName
                let TagAttributeValue = substitute(Text, s:TagRegex, '\3', '')
                let Tag['Attributes']['Value'] = TagAttributeValue
            endif
            " check for inner tags
            let subText = substitute(Text, s:TagRegex, '\4', '')
            let Tag['Elements'] = XmlGetTags(subText)
            let Elements += [Tag]
            let Text = substitute(Text, s:TagRegex, '\5', '')
        elseif match(Text, '\s*[^<>]*\s*') >= 0
            " only text
            let Elements += [substitute(Text, '\s*\(.\{-}\)\s*', '\1', '')]
            let Text = ''
        else
            " Error in parser
            echo 'No Tag' Text
            return []
        endif
    endwhile
    return Elements
endfunction

let s:OpenTagRegex = '<\(\w\+\)'
let s:CloseTagRegex = '</\1'

" ---------------------------------------
" Find tag pair under cursor and parse it
" Returns a dictionary
" ---------------------------------------
function! XmlGetTag()
    " save cursor position
    let save_cursor = getpos('.')

    " find tag pair
    let StartLine = line('.')
    let EndLine = searchpair(s:OpenTagRegex, '', s:CloseTagRegex)
    call setpos('.', save_cursor)

    " store tag pair
    let Text = join(getline(StartLine, EndLine))

    " parse tag pair
    let Tag = XmlGetTags(Text)
"    echo 'Tag' Tag

    " reset position
    call setpos('.', save_cursor)
    return Tag
endfunction
