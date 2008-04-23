" vim: filetype=vim

" ========
" Settings
" ========
let s:path = "c:/wa/bmsx,,c:/wa/bmsx/src/**,c:/wa/bmsx/out/k48_c1/d"
let s:tags = "c:/wa/bmsx/src/config/damos/tags,c:/wa/tools/python/2.5.1/tags,c:/wa/bmsx/src/make/tools/scons/tags,c:/wa/tools/shade/programme/makefile/v2.9.2/tags,c:/wa/bmsx/src/sg/z6xv/bosch/make.tags,c:/wa/bmsx/src/make/tags,c:/wa/bmsx/src/fsw/**/tags,c:/wa/bmsx/src/kt/**/tags,c:/wa/bmsx/src/bdl/**/tags,c:/wa/bmsx/src/sg/**/tags,c:/wa/bmsx/src/os/**/tags"
let s:cscopeprg = "c:/wa/bmsx/src/make/tools/tags/cscope.exe"
let s:cscopefile = "c:/wa/bmsx/out/k48_c1/cscope.out"
let s:makegoals = ["-h","-c","objs","lsts","metric","libs","doxygen-view-fsw","asms","doxygen-install-server","branch","ctags","doxygen-view-bdl","bosch-osp-ref","lint","tags","developertest","delivery","funktionsdoku","doxygen-view-os","doxygen-view-make","doxygen-view-sg","damos-dfiles","doxygen","doxygen-view-kt","vim-config","doxygen-view","shade","distclean","cscope","integrationstest","shade-config","lint-project","labelstex","kgs-ref","miktex-update","bmw-a2l","stags","a2l-parse","dtags","merged-a2l","shade-proj-tags","doxygen-conf","ptags","doxygen-install","damos-osp","functionstex","damos-config","mtags","shade-tags","tags-all"]
let s:makeopts = ["Motor=","Muster=","Stand=","verbose=","EXTRA_CCFLAGS=","funktionen=","CR=","text="]
let s:Motor = "K48"
let s:MotorVarianten = ["K48","K4X-EGAS","KXX","K7X-EGAS","K2X-EGAS"]
let s:Muster = "C1"
let s:MusterVarianten = ["C1"]
let s:SW_Stand = "Test"
let s:StandVarianten = ["Test","Release","Bosch"]
let s:basedir = "c:/wa/bmsx"
let s:Project = "bmsx"
let s:makeCommand = "c:/wa/bmsx/make.bat"
let g:sessionfile = "c:/wa/bmsx/out/session.vim"

