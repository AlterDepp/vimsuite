command -nargs=1 -complete=dir DlcPro call s:ProjectDlcproSet('device-control', '<args>')
command -nargs=1 -complete=dir DlcProShg call s:ProjectDlcproSet('shg', '<args>')
command -nargs=1 -complete=dir Topmode call s:ProjectDlcproSet('topmode', '<args>')
command -nargs=1 -complete=dir TopmodeGui call s:ProjectDlcproSet('topmode-gui', '<args>')
function s:ProjectDlcproSet(project_type, project_base_dir)
    let g:project_type = a:project_type

    " directories
    if a:project_base_dir != ''
        if (isdirectory(fnamemodify(a:project_base_dir, ':p').'/../src'))
            let s:ProjectBaseDir = fnamemodify(a:project_base_dir, ':p:h:h')
        else
            let s:ProjectBaseDir = fnamemodify(a:project_base_dir, ':p')
        endif
    else
        " defaults
        if (g:project_type == 'device-control')
            let s:ProjectBaseDir = '/home/liebl/dlcpro/firmware'
        elseif (g:project_type == 'shg')
            let s:ProjectBaseDir = '/home/liebl/dlcpro/shg-firmware'
        elseif (g:project_type == 'topmode')
            let s:ProjectBaseDir = '/home/liebl/topmode/firmware'
        elseif (g:project_type == 'topmode-gui')
            let s:ProjectBaseDir = '/home/liebl/topmode/pc-gui'
        else
            echo "no project"
        endif
    endif
    if (g:project_type == 'device-control')
        let s:Program = '/device-control/device-control'
        let g:ProgramRemote = '/opt/app/bin/device-control'
        set wildignore+=**/shg-firmware/**
    elseif (g:project_type == 'shg')
        let s:Program = '/device-control/device-control-shg'
        set wildignore+=**/firmware/src/device-control/**
    elseif (g:project_type == 'topmode')
        let s:Program = '/topmode'
    elseif (g:project_type == 'topmode-gui')
        let s:Program = '/TOPAS_Topmode'
    else
        echo "no project"
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
    let g:GdbPort = '2345'
    if (g:project_type == 'topmode')
        let g:GdbHost = 'topmode_stefan'
        let s:GdbSlave = '~/tools/gdb-slave-topmode.sh'
    else
        let g:GdbHost = 'dlcpro_stefan'
        let s:GdbSlave = '~/tools/gdb-slave.sh'
    endif
    let g:GdbPath = '/opt/OSELAS.Toolchain-2012.12.1/arm-cortexa8-linux-gnueabi/gcc-4.7.3-glibc-2.16.0-binutils-2.22-kernel-3.6-sanitized/bin/arm-cortexa8-linux-gnueabi-gdb'
    command! DlcProFirmwareUpdate call s:CopyFirmware('update')
    command! DlcProFirmwareDebug call s:CopyFirmware('start-debug')
    command! DlcProFirmwareAttach call s:CopyFirmware('attach-debug')
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
                \s:ProjectBaseDir.'/.ycm_extra_conf.py',
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
    call asyncrun#quickfix_toggle(10, 1)
    execute 'AsyncRun -mode='.a:async_mode.' -save=2 -program=make @ --directory='.g:ProjectBuildDir.' '.a:args
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
    let args .= " -DCMAKE_TOOLCHAIN_FILE=../".g:ProjectSrcDirRel."/Toolchain-target.cmake"
    let args .= " -DCMAKE_BUILD_TYPE=".a:build_type
    let args .= " -DCMAKE_EXPORT_COMPILE_COMMANDS=1"
    if (g:project_type == 'device-control')
        "let args .= " -DLICENSE_TOOL=1"
        let args .= " -DBUILD_TARGET=target"
        let args .= " -DQT5_INSTALL_PATH=dlcpro-sdk/sysroot-target/usr/local/Qt-5.4.1"
    elseif (g:project_type == 'topmode')
        let args .= " -DSYSROOT=~/topmode/topmode-sdk/sysroot-target"
    endif
    execute 'AsyncRun -mode='.a:async_mode.' -save=2 -cwd='.g:ProjectBuildDir.' @ cmake '.args
endfunction

function s:CopyFirmware(command)
    let command = 'bash '.s:GdbSlave.' -h '.g:GdbHost.' '.a:command
"    if a:command == 'update' || a:command == 'start-debug'
        let command .= ' '.g:Program
"    endif
    echom command
    call system(command)
endfunction

function DlcProDebugGfV(program)
    execute 'GdbFromVimRemote '.g:GdbHost.':'.g:GdbPort
    execute 'GdbFromVimSymbolFile '.g:Program
    " GdbFromVimContinue
"    execute 'D set sysroot '.g:ProjectBuildDir.'/dlcpro-sdk/sysroot-target'
endfunction

function s:DlcProDebug(program)
    DlcProFirmwareDebug
    ConqueGdbTab
"    execute "ConqueGdbCommand file ".g:Program
"    execute "ConqueGdbCommand target remote ".g:GdbHost.":".g:GdbPort
"    ConqueGdbCommand break main
"    ConqueGdbCommand continue

    execute "ConqueGdbCommand target extended-remote ".g:GdbHost.":".g:GdbPort
    execute "ConqueGdbCommand set remote exec-file ".g:ProgramRemote
    execute "ConqueGdbCommand file ".g:Program
    ConqueGdbCommand break main
    ConqueGdbCommand run

    "ConqueGdbCommand set sysroot /home/liebl/dlcpro/firmware/build/dlcpro-sdk/sysroot-target/
    ConqueGdbCommand set sysroot /opt/OSELAS.Toolchain-2012.12.1/arm-cortexa8-linux-gnueabi/gcc-4.7.3-glibc-2.16.0-binutils-2.22-kernel-3.6-sanitized/sysroot-arm-cortexa8-linux-gnueabi
    ConqueGdbCommand set solib-search-path /opt/OSELAS.Toolchain-2012.12.1/arm-cortexa8-linux-gnueabi/gcc-4.7.3-glibc-2.16.0-binutils-2.22-kernel-3.6-sanitized/arm-cortexa8-linux-gnueabi/lib/

endfunction

" ================
" Regression Tests
" ================
command -nargs=1 DlcProRegtest       call s:DlcProRegtest(g:GdbHost,       "",            "",  "dlpro", "1", "",                  "<args>")
command -nargs=1 DlcProRegtestDlPro  call s:DlcProRegtest("192.168.54.24", "elad-dlcpro", "2", "dlpro", "1", "",                  "<args>")
command -nargs=1 DlcProRegtestTaPro  call s:DlcProRegtest("192.168.54.9",  "elad-dlcpro", "3", "tapro", "1", "-m 'not usbstick'", "<args>")
command -nargs=1 DlcProRegtestCtl    call s:DlcProRegtest("192.168.54.27", "elad-dlcpro", "1", "ctl",   "1", "-m 'not usbstick'", "<args>")
command -nargs=1 DlcProRegtestDualDl call s:DlcProRegtest("192.168.54.28", "elad-dlcpro", "4", "dlpro", "2", "-m 'not usbstick'", "<args>")
command -nargs=1 DlcProRegtestShgPro call s:DlcProRegtest("192.168.54.29", "elad-dlcpro", "5", "shg",   "1", "-m 'not usbstick'", "<args>")
function s:DlcProRegtest(ip, powerswitch_ip, powerplug, tests, laser_no, opts, arguments)
    let archive_dir = g:ProjectBuildDir."/artifacts"
    let dlcprolicense_builddir = s:ProjectSrcDir."/build/libdlcprolicense"
    let dlcprolicensetool = dlcprolicense_builddir."/dlcprolicense-tool"
    let cmd =
                \"python3 -u -m pytest ".
                \"--showlocals --tb=long --verbose --cache-clear  ".
                \"--junit-xml=".a:tests.".result.xml ".
                \"--tests=".a:tests." ".
                \"--laser_no=".a:laser_no." ".
                \"--connection_type=network ".
                \"--log_file=".a:tests.".regtest.log ".
                \"--target_ip=".a:ip." ".
                \"--powerswitch_ip=".a:powerswitch_ip." ",
                \"--power_plug=".a:powerplug." ".
                \"--powerswitch_passwd=nimda ".
                \"--version_file=".archive_dir."/VERSION ".
                \"--svnrevision=".archive_dir."/svnrevision.h ".
                \"--firmware_file=".archive_dir."/DLCpro-archive.fw ".
                \"--license_tool=".dlcprolicensetool." ".
                \"--license_keyfile=".s:ProjectSrcDir."/license/libdlcprolicense/rsa-private.key ".
                \"--shutdown_after_test ".
                \a:opts." ".a:arguments
"    echom cmd
    call term_start(cmd)
endfunction

" ======
" Format
" ======
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

" ======
" Pytest
" ======
command! -nargs=* Pytest call s:Pytest('<args>')
function s:Pytest(testscripts)
    let async_mode = 0
    let archive_dir = g:ProjectBuildDir."/artifacts"
    call asyncrun#quickfix_toggle(10, 1)
    let args = ''
    let args .= ' --target_ip="'.g:GdbHost.'"'
    let args .= ' --version_file="'.archive_dir.'/VERSION'.'"'
    let args .= ' --svnrevision_file="'.archive_dir.'/svnrevision.h'.'"'
    let args .= ' --firmware_file="'.archive_dir.'/DLCpro-archive.fw'.'"'
    let args .= ' --capture=no'
    execute 'AsyncRun -mode='.async_mode.' -save=2 -cwd='.s:ProjectSrcDir.'/test @ python3 -m pytest '.args.' '.a:testscripts
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

" update python tags
" cd ~/dclpro/firmware
" ctags --recurse --languages=python src
