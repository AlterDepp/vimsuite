" Vim syntax file
" Language:	damos Kenngroessen Beschreibungs Datei
" Maintainer:	Stefan Liebl <S.Liebl@gmx.de>
" URL:		
" Credits:	

" load c-syntax
execute('source ' . $VIMRUNTIME . '/syntax/c.vim')

"syntax keyword kgsFunctions sg_funktion contained
syntax keyword kgsFunctions     sg_funktion variante revision
syntax keyword kgsDefinitions   fkt_bezeichner kgs_bezeichner ram_bezeichner

syntax keyword kgsDefinitions   systemkonstante 
syntax keyword kgsRefgroessen   ref_systemkonstante
syntax keyword kgsDefinitions   ram_groesse lok_ram_groesse
syntax keyword kgsRefgroessen   ref_ram_groesse
syntax keyword kgsDefinitions   kennwert lok_kennwert
syntax keyword kgsRefgroessen   ref_kennwert
syntax keyword kgsDefinitions   kennwerteblock lok_kennwerteblock
syntax keyword kgsRefgroessen   ref_kennwerteblock
syntax keyword kgsDefinitions   kennlinie lok_kennlinie
syntax keyword kgsRefgroessen   ref_kennlinie
syntax keyword kgsDefinitions   kennfeld lok_kennfeld
syntax keyword kgsRefgroessen   ref_kennfeld
syntax keyword kgsDefinitions   festkennlinie lok_festkennlinie
syntax keyword kgsRefgroessen   ref_festkennlinie
syntax keyword kgsDefinitions   festkennfeld lok_festkennfeld
syntax keyword kgsRefgroessen   ref_festkennfeld
syntax keyword kgsDefinitions   gruppenkennlinie lok_gruppenkennlinie
syntax keyword kgsRefgroessen   ref_gruppenkennlinie
syntax keyword kgsDefinitions   gruppenkennfeld lok_gruppenkennfeld
syntax keyword kgsRefgroessen   ref_gruppenkennfeld
syntax keyword kgsDefinitions   gruppenstuetzstellen lok_gruppenstuetzstellen
syntax keyword kgsRefgroessen   ref_gruppenstuetzstellen
syntax keyword kgsDefinitions   kenngroessen_gruppe lok_kenngroessen_gruppe
syntax keyword kgsRefgroessen   ref_kenngroessen_gruppe
syntax keyword kgsDefinitions   ram_groessen_gruppe lok_ram_groessen_gruppe
syntax keyword kgsRefgroessen   ref_ram_groessen_gruppe

syntax keyword kgsKomponents    umrechnung codesyntax datentyp adressierschema
syntax keyword kgsKomponents    bitanzahl element_anzahl bitbasis_typ bitposition
syntax keyword kgsKomponents    bitbasis_name init_wertp minp_w maxp_w
syntax keyword kgsKomponents    ablageschema umrechnung anzahl
syntax keyword kgsKomponents    test_wertp test_wert_text nicht_im_eprom
syntax keyword kgsKomponents    eingangsgroesse_x eingangsgroesse_y ergebnisgroesse
syntax keyword kgsKomponents    anzahl_stuetzstellen_x anzahl_stuetzstellen_y
syntax keyword kgsKomponents    anzahl_test_stuetzstellen_x anzahl_test_stuetzstellen_y
syntax keyword kgsKomponents    gruppenstuetzstellen_x gruppenstuetzstellen_y
syntax keyword kgsKomponents    kenntext ref_kenntext
syntax keyword kgsKomponents    minp_x minp_y maxp_x maxp_y
syntax keyword kgsKomponents    shift_x offset_x shift_y offset_y
syntax keyword kgsKomponents    test_stuetzstellenp_x test_stuetzstellenp_y
syntax keyword kgsKomponents    nicht_applizierbar
syntax keyword kgsKomponents    unwirksamkeitswert
syntax keyword kgsKomponents    deutsch
syntax keyword kgsDeprecated    min_w min_x min_y max_w max_x max_y init_wert test_wert
syntax keyword kgsDeprecated    test_stuetzstellen_x test_stuetzstellen_y
syntax keyword kgsDeprecated    kopfdaten_applizierbar


highlight def link kgsFunctions Function
highlight def link kgsDefinitions Function
highlight def link kgsRefgroessen Function
highlight def link kgsKomponents Type
highlight def link kgsDeprecated ToDo
