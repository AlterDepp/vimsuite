command -nargs=? -complete=dir DlcPro call s:ProjectDlcproSet('device-control', '<args>')
command -nargs=? -complete=dir DlcProShg call s:ProjectDlcproSet('shg', '<args>')
function s:ProjectDlcproSet(project_type, project_base_dir)
    " directories
    if a:project_base_dir != ''
        if (isdirectory(fnamemodify(a:project_base_dir, ':p').'/../src'))
            let s:ProjectBaseDir = fnamemodify(a:project_base_dir, ':p:h:h')
        else
            let s:ProjectBaseDir = fnamemodify(a:project_base_dir, ':p')
        endif
    else
        " defaults
        if (a:project_type == 'device-control')
            let s:ProjectBaseDir = '/home/liebl/dlcpro/firmware'
        else
            let s:ProjectBaseDir = '/home/liebl/dlcpro/shg-firmware'
        endif
    endif
    if (a:project_type == 'device-control')
        let s:Program = '/device-control/device-control'
        set wildignore+=**/shg-firmware/**
    else
        let s:Program = '/device-control/device-control-shg'
        set wildignore+=**/firmware/**
    endif
    let g:ProjectSrcDirRel = 'src'
    let s:ProjectSrcDir = s:ProjectBaseDir.'/'.g:ProjectSrcDirRel
    let g:ProjectBuildDir = s:ProjectBaseDir.'/build'

    " vim path
    execute 'cd '.s:ProjectSrcDir
    execute 'set path-=./**'
    execute 'set path+=' .  s:ProjectSrcDir.'/**'
    execute 'set path+=' .  g:ProjectBuildDir.'/**'
    execute 'set path+=/opt/OSELAS.Toolchain-2012.12.1/arm-cortexa8-linux-gnueabi/gcc-4.7.3-glibc-2.16.0-binutils-2.22-kernel-3.6-sanitized/sysroot-arm-cortexa8-linux-gnueabi/usr/include'

    " editor settings
    set spell spelllang=en,de
    set expandtab
    set cinoptions=l1,g2,h2,N-2,t0,+0,(0,w1,Ws,m1,)100,*100
    set textwidth=120

    " python tags
    execute "set tags+=" . s:ProjectBaseDir . '/tags'

    " compiler
    compiler gcc
    let s:makegoals = ['artifacts', 'device-control', 'user-interface', 'doxygen', 'shg-firmware', 'docu-ul0', 'code-generation', 'dependency-graphs', 'clean', 'distclean', 'help', 'jamplayer', 'dlcpro-slot']
    let s:makeopts = ['-j3', 'VERBOSE=1']
    let g:Program = g:ProjectBuildDir.s:Program
    command! -complete=custom,GetAllMakeCompletions -nargs=* Make call s:Make('<args>', 0)
    command! MakeTestBuild call s:MakeTestBuild()

    " cmake
    command! -nargs=1 -complete=custom,CmakeBuildTypes Cmake call s:Cmake('<args>', 0)
    function! CmakeBuildTypes(ArgLead, CmdLine, CorsorPos)
        return join(['Debug', 'Release', 'RelWithDebInfo'], "\n")
    endfunction

    " configure quickfix window for asyncrun
    augroup QuickfixStatus
        autocmd BufWinEnter quickfix setlocal 
                    \ statusline=%t\ [%{g:asyncrun_status}]\ %{exists('w:quickfix_title')?\ '\ '.w:quickfix_title\ :\ ''}\ %=%-15(%l,%c%V%)\ %P
    augroup END

    " debugger
    let g:GdbHost = 'dlcpro_stefan'
    let g:GdbPort = '2345'
    let s:GdbSlave = '~/tools/gdb-slave.sh'
    let g:GdbPath = '/opt/OSELAS.Toolchain-2012.12.1/arm-cortexa8-linux-gnueabi/gcc-4.7.3-glibc-2.16.0-binutils-2.22-kernel-3.6-sanitized/bin/arm-cortexa8-linux-gnueabi-gdb'
    command! DlcProFirmwareUpdate call s:CopyFirmware('update')
    command! DlcProFirmwareDebug call s:CopyFirmware('debug')
    command! DlcProFirmwareStart call s:CopyFirmware('start')
    command! DlcProDebug call s:DlcProDebug(g:Program)

    " vc-plugin
    let g:vc_branch_url = ['https://svn.toptica.com/svn/DiSiRa/SW/firmware/branches']
    let g:vc_trunk_url = 'https://svn.toptica.com/svn/DiSiRa/SW/firmware/trunk'

    " update device-contol.xml for Topas-GUI
    command DlcProUpdateTopasXml '!svnmucc put -m \'update "device-control.xml"\' ".g:ProjectBuildDir.'/device-control/device-control.xml https://svn.toptica.com/svn/topas_dlc_pro/trunk/res/device-control.xml'

    " vim-clang
    command! ClangFormat call ClangFormat()
    " hint: formatexpr=ClangFormat() is set in ft/c.vim
"    map <C-I> :pyf /usr/share/vim/addons/syntax/clang-format.py<cr>
"    imap <C-I> <c-o>:pyf /usr/share/vim/addons/syntax/clang-format.py<cr>

    " YouCompleteMe plugin
    "set completeopt-=preview
    "let g:ycm_add_preview_to_completeopt = 0
    "let g:ycm_autoclose_preview_window_after_completion = 0
    "let g:ycm_autoclose_preview_window_after_insertion = 0
    "let g:ycm_key_previous_completion = ['<TAB>', '<Down>', '<Enter>']
    let g:ycm_extra_conf_globlist = [
                \'~/dlcpro/firmware/.ycm_extra_conf.py',
                \'!~/tools/vimsuite/vimfiles.YouCompleteMe/*',
                \]

    " rtags
    command! RtagsIncludeTree execute('!rc --dependencies %')

    " little helpers
    command! -nargs=? BuildDirStash call s:BuildDirStash('<args>')
    command! -nargs=? BuildDirUnStash call s:BuildDirUnStash('<args>')

endfunction

" ====
" Make
" ====
function GetAllMakeCompletions(ArgLead, CmdLine, CursorPos)
    return join(s:makegoals + s:makeopts + glob(a:ArgLead.'*', 1, 1), "\n")
endfunction

function s:Make(args, async_mode)
    wa
    call asyncrun#quickfix_toggle(10, 1)
    execute 'AsyncRun -mode='.a:async_mode.' -save=1 -program=make @ --directory='.g:ProjectBuildDir.' '.a:args
endfunction

function s:MakeTestBuild()
    call s:BuildDirStash('save')
    call s:Cmake('Release', 1)
    call s:Make('-j4 device-control artifacts doxygen user-interface', 1)
    call s:BuildDirStash('release-test')
    call s:BuildDirUnStash('save')
endfunction

function s:Cmake(build_type, async_mode)
    if !isdirectory(g:ProjectBuildDir)
        call mkdir(g:ProjectBuildDir)
    endif
    execute "!rm ".g:ProjectBuildDir."/build-type*"
    execute "!touch ".g:ProjectBuildDir."/build-type:".a:build_type
    call asyncrun#quickfix_toggle(10, 1)
    let args = ""
    let args .= " ../".g:ProjectSrcDirRel."/"
    let args .= " --graphviz=dependencies.dot"
    let args .= " -DBUILD_TARGET=target"
    let args .= " -DCMAKE_TOOLCHAIN_FILE=../".g:ProjectSrcDirRel."/Toolchain-target.cmake"
    let args .= " -DQT5_INSTALL_PATH=dlcpro-sdk/sysroot-target/usr/local/Qt-5.4.1"
    let args .= " -DCMAKE_BUILD_TYPE=".a:build_type
    let args .= " -DCMAKE_EXPORT_COMPILE_COMMANDS=1"
"    let args .= " -DLICENSE_TOOL=1"
    execute 'AsyncRun -mode='.a:async_mode.' -save=1 -cwd='.g:ProjectBuildDir.' @ cmake '.args
endfunction

function s:CopyFirmware(command)
    let command = 'bash '.s:GdbSlave.' -h '.g:GdbHost.' '.a:command
    if a:command == 'update'
        let command .= ' '.g:Program
    endif
    echom command
    call system(command)
endfunction

function DlcProDebugGfV(program)
    execute 'GdbFromVimRemote ' g:GdbHost ':' g:GdbPort
    execute 'GdbFromVimSymbolFile ' g:Program
    " GdbFromVimContinue
"    execute 'D set sysroot '.g:ProjectBuildDir.'/dlcpro-sdk/sysroot-target'
endfunction

function s:DlcProDebug(program)
    DlcProFirmwareDebug
    let g:pyclewn_terminal = 'konsole, -e'
    let g:pyclewn_args = '--pgm='.g:GdbPath
    Pyclewn gdb
    Cmapkeys
    sleep 1
    execute 'Ctarget remote ' g:GdbHost.':'.g:GdbPort
    sleep 1
    execute 'Cfile ' g:Program
"    sleep 1
"    execute 'C set sysroot '.g:ProjectBuildDir.'/dlcpro-sdk/sysroot-target'
"    Ccontinue
endfunction

function ClangFormat()
    if (v:count > 0)
        let startline = v:lnum
        let endline = v:lnum + v:count
        let l:lines = startline.':'.endline
    else
        let l:lines='all'
    endif
    pyf /usr/share/vim/addons/syntax/clang-format.py
endfunction

" ===============
" Stash / Unstash
" ===============
function s:BuildDirStash(suffix)
    if a:suffix != ''
        let suffix = a:suffix
    else
        let suffix = fugitive#head()
    endif
    let target_dir = g:ProjectBuildDir.'.'.suffix
    let subsuffix = 1
    while isdirectory(target_dir)
        let target_dir = g:ProjectBuildDir.'.'.suffix.'.'.subsuffix
        let subsuffix += 1
    endwhile
    call rename(g:ProjectBuildDir, target_dir)

    " create new build dir and copy eclipse files
    call mkdir(g:ProjectBuildDir)
    call execute('!cp '.target_dir.'/.cproject '.g:ProjectBuildDir, 'silent!')
    call execute('!cp '.target_dir.'/.project '.g:ProjectBuildDir, 'silent!')
endfunction

function s:BuildDirUnStash(suffix)
    if a:suffix != ''
        let suffix = a:suffix
    else
        let suffix = fugitive#head()
    endif
    let source_dir = g:ProjectBuildDir.'.'.suffix
    if !isdirectory(source_dir)
        echoerr 'source directory '.source_dir.' not found'
    elseif isdirectory(g:ProjectBuildDir) && !empty(globpath(g:ProjectBuildDir, '*', 0, 1))
        echoerr 'target directory '.g:ProjectBuildDir.' exists and is not empty'
    else
        echom 'restore '.source_dir.' to '.g:ProjectBuildDir
        call delete(expand(g:ProjectBuildDir), 'rf')
        call rename(expand(source_dir), expand(g:ProjectBuildDir))
    endif
endfunction

" update PDH-firmware
"/opt/app/bin/jamplayer -sm3 -aconfigure PDD.jam
"/opt/app/bin/jamplayer -sm3 -aprogram PDD.jam
"/opt/app/bin/jamplayer -sm3 -areconfigure /opt/app/fpga-configurations/reconfigure.jam

" read/write eeprom
"/opt/app/bin/eepromio
