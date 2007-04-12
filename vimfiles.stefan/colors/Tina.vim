" Vim color file
" Author: Stefan Liebl
" Last Change: 2005 Jan 23

" First remove all existing highlighting.
hi clear
if exists("syntax_on")
  syntax reset
endif

let colors_name = "Tina"

" Farben einstellen:
" - Cursor auf Text plazieren
" - :SyntaxShowGroup
"   gibt die syntax GRUPPE aus
" - :highlight GRUPPE
"   gibt entweder eine weitere syntax GRUPPE2 aus, dann Befehl mit dieser Gruppe wiederholen
"   oder gibt das Farbschema der Gruppe aus. Dieses sollte sich dann in dieser Datei wiederfinden lassen
" - Farbschema in dieser Datei ändern
"   term   für Konsole ohne Farbe (gibt's eigentlich nirgends)
"   cterm  für Konsole mit Farbe
"   gui    für kvim, gvim
"
" Farben für cterm:
" 0 Black
" 1 Red         (is bold)
"   DarkRed     (not bold)
" 2 Green       (is bold)
"   DarkGreen   (not bold)
" 3 Yellow      (is bold)
"   DarkYellow  (not bold)
" 4 Blue        (is bold)
"   DarkBlue    (not bold)
" 5 Magenta     (is bold)
"   DarkMagenta (not bold)
" 6 Cyan        (is bold)
"   DarkCyan    (not bold)
" 7 Grey        (not bold) (==White not bold)
"   DarkGrey    (bold)
"   White       (is bold)
"
hi Normal                                   ctermfg=Grey     ctermbg=Black            guifg=White     guibg=SeaGreen

hi SpecialKey   term=bold                   ctermfg=DarkBlue                          guifg=DarkBlue
hi NonText      term=NONE       cterm=NONE  ctermfg=DarkBlue              gui=NONE    guifg=DarkBlue
hi Directory    term=bold                   ctermfg=DarkBlue                          guifg=Blue
hi ErrorMsg     term=standout   cterm=bold  ctermfg=Grey     ctermbg=Red  gui=bold    guifg=White     guibg=LightRed
hi IncSearch    term=reverse    cterm=reverse                             gui=reverse
hi Search       term=reverse                                 ctermbg=Brown            guifg=Black     guibg=LightGreen
hi MoreMsg      term=bold                   ctermfg=Grey                  gui=bold    guifg=White
hi ModeMsg      term=bold       cterm=bold                                gui=bold    guifg=Black
hi LineNr       term=underline              ctermfg=Yellow                            guifg=Orange    guibg=SeaGreen
hi Question     term=standout               ctermfg=Grey                  gui=bold    guifg=White
hi StatusLine   term=bold,reverse cterm=bold,reverse                      gui=bold    guifg=White     guibg=Black
hi StatusLineNC term=reverse    cterm=reverse                             gui=bold    guifg=PeachPuff guibg=Gray45
hi VertSplit    term=reverse    cterm=reverse                             gui=bold    guifg=White     guibg=Gray45
hi Title        term=bold                   ctermfg=Magenta               gui=bold    guifg=LightRed
hi Visual       term=reverse    cterm=reverse                             gui=reverse                 guibg=Black
hi VisualNOS    term=bold,underline cterm=bold,underline                  gui=bold,underline
hi WarningMsg   term=standout               ctermfg=Red                   gui=bold    guifg=Red       guibg=LightGreen
hi WildMenu     term=standout               ctermfg=Black    ctermbg=Brown            guifg=Black     guibg=Yellow
hi Folded       term=standout               ctermfg=Black    ctermbg=DarkGreen        guifg=Black     guibg=DarkGreen
hi FoldColumn   term=standout               ctermfg=DarkBlue ctermbg=Grey             guifg=DarkBlue  guibg=Gray80
hi DiffAdd      term=bold                                    ctermbg=Red                              guibg=Red
hi DiffChange   term=bold                                    ctermbg=Magenta                          guibg=DarkGreen
hi DiffDelete   term=bold       cterm=bold  ctermfg=DarkBlue ctermbg=White gui=bold   guifg=LightBlue guibg=White
hi DiffText     term=reverse    cterm=bold                   ctermbg=Red  gui=bold                    guibg=Red
hi Cursor                                                                             guifg=bg        guibg=fg
hi lCursor                                                                            guifg=bg        guibg=fg

" Colors for syntax highlighting
hi Comment      term=bold                   ctermfg=DarkYellow            gui=NONE    guifg=Yellow
hi Constant     term=underline              ctermfg=DarkMagenta                       guifg=Black
hi Special      term=bold                   ctermfg=DarkBlue                          guifg=Blue
hi Identifier   term=underline              ctermfg=DarkCyan                          guifg=Cyan
hi Statement    term=bold                   ctermfg=DarkCyan              gui=bold    guifg=Cyan
hi PreProc      term=underline              ctermfg=DarkRed                           guifg=LightRed
hi Type         term=underline              ctermfg=DarkCyan              gui=bold    guifg=Cyan
hi Ignore                       cterm=bold  ctermfg=White                             guifg=bg
hi Error        term=reverse    cterm=bold  ctermfg=White    ctermbg=LightRed gui=bold guifg=White    guibg=LightRed
hi Todo         term=standout               ctermfg=DarkBlue ctermbg=Yellow           guifg=Blue      guibg=Yellow
hi Function     term=bold                   ctermfg=DarkGreen             gui=bold    guifg=Green
hi Label        term=bold                   ctermfg=DarkBlue              gui=bold    guifg=Blue
hi Underlined   term=underline  cterm=underline ctermfg=DarkBlue          gui=underline guifg=Blue

