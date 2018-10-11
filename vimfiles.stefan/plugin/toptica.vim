command -nargs=1 -complete=dir DlcPro call s:ProjectDlcproSet('dlcpro', '<args>')
command -nargs=1 -complete=dir DlcProShg call s:ProjectDlcproSet('shg', '<args>')
command -nargs=1 -complete=dir DlcProGui call s:ProjectDlcproSet('dlcpro-gui', '<args>')
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
        if (g:project_type == 'dlcpro')
            let s:ProjectBaseDir = '/home/liebl/dlcpro/firmware'
        elseif (g:project_type == 'shg')
            let s:ProjectBaseDir = '/home/liebl/dlcpro/shg-firmware'
        elseif (g:project_type == 'dlcpro-gui')
            let s:ProjectBaseDir = '/home/liebl/dlcpro/pc-gui'
        elseif (g:project_type == 'topmode')
            let s:ProjectBaseDir = '/home/liebl/topmode/firmware'
        elseif (g:project_type == 'topmode-gui')
            let s:ProjectBaseDir = '/home/liebl/topmode/pc-gui'
        else
            echo "no project"
        endif
    endif
    if (g:project_type == 'dlcpro')
        let s:Program = '/device-control/device-control'
        let g:ProgramRemote = '/opt/app/bin/device-control'
        set wildignore+=**/shg-firmware/**
    elseif (g:project_type == 'shg')
        let s:Program = '/shg-firmware/device-control/device-control-shg'
        let g:ProgramRemote = '/opt/app/bin/device-control-shg'
        set wildignore+=**/firmware/src/device-control/**
    elseif (g:project_type == 'dlcpro-gui')
        let s:Program = '/TOPAS_DLC_pro'
    elseif (g:project_type == 'topmode')
        let s:Program = '/topmode'
        let g:ProgramRemote = '/usr/toptica/topmode'
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
    let s:makegoals = ['artifacts', 'device-control', 'user-interface', 'doxygen', 'fw-updates', 'shg-firmware', 'docu-ul0', 'code-generation', 'dependency-graphs', 'clean', 'distclean', 'help', 'jamplayer', 'dlcpro-slot']
    let s:makeopts = ['-j3', 'VERBOSE=1']
    let g:Program = g:ProjectBuildDir.s:Program
    command! -complete=custom,GetAllMakeCompletions -nargs=* Make call s:Make('<args>', 0)
    command! MakeTestBuild call s:MakeTestBuild()

    " cmake
    command! -nargs=1 -complete=custom,CmakeBuildTypes Cmake call s:Cmake('<args>', 0)
    function! CmakeBuildTypes(ArgLead, CmdLine, CorsorPos)
        return join(['Debug', 'RelWithDebInfo'], "\n")
    endfunction

    " configure quickfix window for asyncrun
    augroup QuickfixStatus
        autocmd BufWinEnter quickfix setlocal 
                    \ statusline=%t\ [%{g:asyncrun_status}]\ %{exists('w:quickfix_title')?\ '\ '.w:quickfix_title\ :\ ''}\ %=%-15(%l,%c%V%)\ %P
    augroup END

    " debugger
    if (g:project_type == 'topmode')
        let g:GdbHost = 'topmode_stefan'
        let s:GdbSlave = '~/tools/gdb-slave-topmode.sh'
        let g:GdbPort = '2345'
        let g:GdbRoot = "/opt/OSELAS.Toolchain-2011.11.3/arm-cortexa8-linux-gnueabi/gcc-4.6.2-glibc-2.14.1-binutils-2.21.1a-kernel-2.6.39-sanitized"
    elseif (g:project_type == 'shg')
        let g:GdbHost = 'dlcpro_stefan'
        let s:GdbSlave = '~/tools/shgcntl'
        let g:GdbPort = '6666'
        let g:GdbRoot = "/opt/OSELAS.Toolchain-2012.12.1/arm-cortexa8-linux-gnueabi/gcc-4.7.3-glibc-2.16.0-binutils-2.22-kernel-3.6-sanitized"
    else
        let g:GdbHost = 'dlcpro_stefan'
        let s:GdbSlave = '~/tools/gdb-slave.sh'
        let g:GdbPort = '2345'
        let g:GdbRoot = "/opt/OSELAS.Toolchain-2012.12.1/arm-cortexa8-linux-gnueabi/gcc-4.7.3-glibc-2.16.0-binutils-2.22-kernel-3.6-sanitized"
    endif
    let g:ConqueGdb_GdbExe = g:GdbRoot.'/bin/arm-cortexa8-linux-gnueabi-gdb'
    command! DlcProFirmwareUpdate call s:CopyFirmware('update')
    command! DlcProFirmwareDebug call s:CopyFirmware('start-debug')
    command! DlcProFirmwareAttach call s:CopyFirmware('attach-debug')
    command! DlcProFirmwareStart call s:CopyFirmware('start')
    command! DlcProDebug call s:DlcProDebug(g:Program, 0)
    command! DlcProDebugAttach call s:DlcProDebug(g:Program, 1)

    " vc-plugin
    let g:vc_branch_url = ['https://svn.toptica.com/svn/DiSiRa/SW/firmware/branches']
    let g:vc_trunk_url = 'https://svn.toptica.com/svn/DiSiRa/SW/firmware/trunk'

    " update device-contol.xml for Topas-GUI
    command DlcProUpdateTopasXml '!svnmucc put -m \'update "device-control.xml"\' ".g:ProjectBuildDir.'/device-control/device-control.xml https://svn.toptica.com/svn/topas_dlc_pro/trunk/res/device-control.xml'

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
    if (g:project_type == 'dlcpro')
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

let g:DlcProBasePath = "/jenkins/workspace/pro--firmware_release_1.9.0-DCESJ5C5R577IG5QFEWTML22UFDDZCJDGFLMDA4DCD3V2ZAGVEJA/source/"
function s:DlcProDebug(program, attach)
    if (a:attach == 0)
        DlcProFirmwareDebug
        sleep 1
        ConqueGdbTab
        execute "ConqueGdbCommand target extended-remote localhost:".g:GdbPort
        execute "ConqueGdbCommand set remote exec-file ".g:ProgramRemote
        execute "ConqueGdbCommand file ".g:Program
        ConqueGdbCommand break main
        ConqueGdbCommand run
    else
        DlcProFirmwareAttach
        sleep 1
        execute "ConqueGdbTab ".g:Program
        execute "ConqueGdbCommand target remote localhost:".g:GdbPort
        " get remote src path with gdb: info sources or gdb: break main
        execute "ConqueGdbCommand set substitute-path ".g:DlcProBasePath." ".s:ProjectSrcDir
    endif

    execute "ConqueGdbCommand set sysroot ".g:GdbRoot."/sysroot-arm-cortexa8-linux-gnueabi"
    execute "ConqueGdbCommand set solib-search-path ".g:GdbRoot."/arm-cortexa8-linux-gnueabi/lib/"
    ConqueGdbCommand set can-use-hw-watchpoints 0
endfunction

" ================
" Regression Tests
" ================
command -nargs=1 -complete=file DlcProRegtest        call s:DlcProRegtest('g:GdbHost',     '',            '0', '1', 'DLpro',     '--capture=no --skip_fw_update', '<args>')
command -nargs=1 -complete=file DlcProRegtestDlPro   call s:DlcProRegtest('192.168.54.24', 'elab-dlcpro', '2', '1', 'DLpro',     '',                              '<f-args>')
command -nargs=1 -complete=file DlcProRegtestTaPro   call s:DlcProRegtest('192.168.54.9',  'elab-dlcpro', '3', '1', 'TApro',     '-m "not usb and not usbstick"', '<f-args>')
command -nargs=1 -complete=file DlcProRegtestCtl     call s:DlcProRegtest('192.168.54.27', 'elab-dlcpro', '1', '1', 'CTL',       '-m "not usb and not usbstick"', '<f-args>')
command -nargs=1 -complete=file DlcProRegtestDualDl  call s:DlcProRegtest('192.168.54.28', 'elab-dlcpro', '4', '2', 'DLpro',     '-m "not usb and not usbstick"', '<f-args>')
command -nargs=1 -complete=file DlcProRegtestDualDl1 call s:DlcProRegtest('192.168.54.28', 'elab-dlcpro', '4', '1', 'DLpro',     '-m "not usb and not usbstick"', '<f-args>')
command -nargs=1 -complete=file DlcProRegtestShgPro  call s:DlcProRegtest('192.168.54.29', 'elab-dlcpro', '5', '1', 'TA-SHGpro', '-m "not usb and not usbstick"', '<f-args>')
function s:DlcProRegtest(ip, powerswitch_ip, powerplug, laser_count, laser_type, opts, arguments)
    execute "wa"
    if (a:ip == 'g:GdbHost')
        let ip = g:GdbHost
    else
        let ip = a:ip
    endif
    let archive_dir = g:ProjectBuildDir."/artifacts"

    " Build license tool
    let license_builddir = s:ProjectBaseDir.'/build.license'
    let licensetool = license_builddir."/libdlcprolicense/dlcprolicense-tool"
    let license_cmake = "cmake -DLICENSE_TOOL=1 -DCMAKE_BUILD_TYPE=Release ".s:ProjectSrcDir."/license"
    let license_make = "make dlcprolicense-tool"
    if !executable(licensetool)
        call mkdir(license_builddir, "p")
        call term_start(license_cmake, {'cwd' : license_builddir})
        sleep 2
        call term_start(license_make, {'cwd' : license_builddir})
        sleep 5
    endif

    " Execute pytest
    let test_dir = s:ProjectSrcDir."/test"
    let test_cmd =
                \"python3 -u -m pytest ".
                \"--showlocals --tb=long --verbose --cache-clear ".
                \"--junit-xml=regtest.".a:laser_type.".xml ".
                \"--laser_count=".a:laser_count." ".
                \"--laser_type=".a:laser_type." ".
                \"--log_file=regtest.".a:laser_type.".log ".
                \"--target_ip=".ip." ".
                \"--powerswitch_ip=".a:powerswitch_ip." ".
                \"--powerswitch_passwd=nimda ".
                \"--power_plug=".a:powerplug." ".
                \"--power_plug_fan=8"." ".
                \"--version_file=".archive_dir."/VERSION ".
                \"--vcsid_file=".archive_dir."/vcsid.h ".
                \"--firmware_file=".archive_dir."/DLCpro-archive.fw ".
                \"--license_tool=".licensetool." ".
                \"--license_keyfile=".s:ProjectSrcDir."/license/libdlcprolicense/rsa-private.key ".
                \"--skip_shutdown_after_test ".
                \a:opts." ".a:arguments
    echom test_cmd
    call term_start(test_cmd, {'cwd' : test_dir})
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
