command -nargs=1 -complete=dir DlcPro call s:ProjectSet('dlcpro', '<args>')
command -nargs=1 -complete=dir DlcProShg call s:ProjectSet('shg', '<args>')
command -nargs=1 -complete=dir DlcProGui call s:ProjectSet('dlcpro-gui', '<args>')
command -nargs=1 -complete=dir DlcProCan call s:ProjectSet('dlcpro-can', '<args>')
command -nargs=1 -complete=dir DlcProSpecalyser call s:ProjectSet('dlcpro-specalyser', '<args>')
command DlcproEmissionOn call s:DlcproEmission('1')
command DlcproEmissionOff call s:DlcproEmission('0')
command DlcproShutup call s:DlcproShutup()
command -nargs=1 -complete=dir Topmode call s:ProjectSet('topmode', '<args>')
command -nargs=1 -complete=dir TopmodeGui call s:ProjectSet('topmode-gui', '<args>')
command -nargs=1 -complete=dir DigiFalc call s:ProjectSet('digifalc', '<args>')
command -nargs=1 -complete=dir ServoBoard call s:ProjectSet('servoboard', '<args>')
command -nargs=1 -complete=dir DlMotor call s:ProjectSet('dl-motor', '<args>')
command DeviceFirmwareUpdate call s:DeviceFirmwareUpdate()
function s:ProjectSet(project_type, project_base_dir)
    let g:project_type = a:project_type

    " directories
    if a:project_base_dir != ''
        if (isdirectory(fnamemodify(a:project_base_dir, ':p:h:h').'/src'))
            let s:ProjectBaseDir = fnamemodify(a:project_base_dir, ':p:h:h')
        elseif (isdirectory(fnamemodify(a:project_base_dir, ':p:h').'/src'))
            let s:ProjectBaseDir = fnamemodify(a:project_base_dir, ':p:h')
        else
            let s:ProjectBaseDir = fnamemodify(a:project_base_dir, ':p')
        endif
    else
        " defaults
        if (g:project_type == 'dlcpro')
            let s:ProjectBaseDir = '/home/stefan/dlcpro/firmware'
        elseif (g:project_type == 'dlcpro-can')
            let s:ProjectBaseDir = '/home/stefan/dlcpro/firmware'
        elseif (g:project_type == 'dlcpro-specalyser')
            let s:ProjectBaseDir = '/home/stefan/dlcpro/firmware'
        elseif (g:project_type == 'shg')
            let s:ProjectBaseDir = '/home/stefan/dlcpro/shg-firmware'
        elseif (g:project_type == 'dlcpro-gui')
            let s:ProjectBaseDir = '/home/stefan/dlcpro/pc-gui'
        elseif (g:project_type == 'topmode')
            let s:ProjectBaseDir = '/home/stefan/topmode/firmware'
        elseif (g:project_type == 'topmode-gui')
            let s:ProjectBaseDir = '/home/stefan/topmode/pc-gui'
        elseif (g:project_type == 'digifalc')
            let s:ProjectBaseDir = '/home/stefan/dlcpro/falc/firmware'
        elseif (g:project_type == 'servoboard')
            let s:ProjectBaseDir = '/home/stefan/dlcpro/mta/firmware'
        elseif (g:project_type == 'dl-motor')
            let s:ProjectBaseDir = '/home/stefan/dlcpro/dl-motor'
        else
            echo "no project"
        endif
    endif

    let g:ProjectSrcDirRel = 'src'
    let s:ProjectSrcDir = s:ProjectBaseDir.'/'.g:ProjectSrcDirRel
    let g:ProjectBuildDir = s:ProjectBaseDir.'/build'

    " vim path
    execute 'cd '.s:ProjectSrcDir
    execute 'set path-=./**'
    execute 'set path+=' .  s:ProjectSrcDir.'/**'
    execute 'set path+=' .  g:ProjectBuildDir.'/**'
    let s:oselas_include = '/sysroot-arm-cortexa8-linux-gnueabi/usr/include'
"    let s:oselas_gdb = '/opt/OSELAS.Toolchain-2018.12.0/arm-v7a-linux-gnueabi/gcc-8.2.1-glibc-2.28-binutils-2.31.1-kernel-3.6-sanitized/bin/arm-v7a-linux-gnueabi-gdb'
    let s:oselas_gdb = '/opt/OSELAS.Toolchain-2012.12.1/arm-cortexa8-linux-gnueabi/gcc-4.7.3-glibc-2.16.0-binutils-2.22-kernel-3.6-sanitized/bin/arm-cortexa8-linux-gnueabi-gdb'
"    let s:oselas_gdb = '/opt/OSELAS.Toolchain-2020.08.0/arm-v7a-linux-gnueabi/gcc-10.2.1-clang-10.0.1-glibc-2.32-binutils-2.35-kernel-5.8-sanitized/bin/arm-v7a-linux-gnueabi-gdb'
    let s:jlink_path = '/home/stefan/opt/JLink_Linux_V654a_x86_64'
"    let s:jlink_path = '/home/stefan/opt/JLink_Linux_V688b_x86_64'

    if (g:project_type == 'dlcpro')
        let s:Program = '/device-control/device-control'
        let s:Elffile = s:Program
        let g:ProgramRemote = '/opt/app/bin/device-control'
        set wildignore-=**/firmware/src/device-control/**
        set wildignore+=**/shg-firmware/**
        let s:makegoals = ['artifacts', 'device-control', 'user-interface', 'doxygen', 'fw-updates', 'shg-firmware', 'can-updater', 'specalyser', 'docu-ul0', 'code-generation', 'dependency-graphs', 'clean', 'distclean', 'help', 'jamplayer', 'dlcpro-slot']
        let g:DeviceIP = 'DLC_PRO__040083'
        let g:GdbPort = '2345'
        let g:GccRoot = "/opt/OSELAS.Toolchain-2012.12.1/arm-cortexa8-linux-gnueabi/gcc-4.7.3-glibc-2.16.0-binutils-2.22-kernel-3.6-sanitized"
        let g:termdebugger = s:oselas_gdb
"        let g:ConqueGdb_GdbExe = g:GccRoot.'/bin/arm-cortexa8-linux-gnueabi-gdb'
        let g:SshOpts = ""
        let g:SshOpts2 = ""
        execute 'set path+=' .  g:GccRoot . s:oselas_include
    elseif (g:project_type == 'dlcpro-can')
        let s:Program = '/canopen/can-updater'
        let s:Elffile = s:Program
        let g:ProgramRemote = '/opt/app/bin/can-updater'
        set wildignore-=**/firmware/src/device-control/**
        set wildignore+=**/shg-firmware/**
        let s:makegoals = []
        let g:DeviceIP = 'DLC_PRO__040083'
        let g:GdbPort = '2345'
        let g:GccRoot = "/opt/OSELAS.Toolchain-2012.12.1/arm-cortexa8-linux-gnueabi/gcc-4.7.3-glibc-2.16.0-binutils-2.22-kernel-3.6-sanitized"
        let g:termdebugger = s:oselas_gdb
"        let g:ConqueGdb_GdbExe = g:GccRoot.'/bin/arm-cortexa8-linux-gnueabi-gdb'
        let g:SshOpts = ""
        let g:SshOpts2 = ""
        execute 'set path+=' .  g:GccRoot . s:oselas_include
"        let g:ycm_clangd_args = ['-I'.g:GccRoot . s:oselas_include]
    elseif (g:project_type == 'dlcpro-specalyser')
        let s:Program = '/specalyser/specalyser'
        let s:Elffile = s:Program
        let g:ProgramRemote = '/opt/app/bin/specalyser'
        set wildignore-=**/firmware/src/device-control/**
        set wildignore+=**/shg-firmware/**
        let s:makegoals = []
        let g:DeviceIP = 'DLC_PRO__040083'
        let g:GdbPort = '2345'
        let g:GccRoot = "/opt/OSELAS.Toolchain-2012.12.1/arm-cortexa8-linux-gnueabi/gcc-4.7.3-glibc-2.16.0-binutils-2.22-kernel-3.6-sanitized"
        let g:termdebugger = s:oselas_gdb
"        let g:ConqueGdb_GdbExe = g:GccRoot.'/bin/arm-cortexa8-linux-gnueabi-gdb'
        let g:SshOpts = ""
        let g:SshOpts2 = ""
        execute 'set path+=' .  g:GccRoot . s:oselas_include
"        let g:ycm_clangd_args = ['-I'.g:GccRoot . s:oselas_include]
    elseif (g:project_type == 'shg')
        let s:Program = '/shg-firmware/device-control/device-control-shg'
        let s:Elffile = s:Program
        let g:ProgramRemote = '/opt/app/bin/device-control-shg'
        set wildignore-=**/shg-firmware/**
        set wildignore+=**/firmware/src/device-control/**
        let s:makegoals = ['artifacts', 'device-control', 'user-interface', 'doxygen', 'fw-updates', 'shg-firmware', 'can-updater', 'specalyser', 'docu-ul0', 'code-generation', 'dependency-graphs', 'clean', 'distclean', 'help', 'jamplayer', 'dlcpro-slot']
        let g:DeviceIP = 'DLC_PRO__040083'
        let g:GdbPort = '6666'
        let g:GccRoot = "/opt/OSELAS.Toolchain-2012.12.1/arm-cortexa8-linux-gnueabi/gcc-4.7.3-glibc-2.16.0-binutils-2.22-kernel-3.6-sanitized"
        let g:termdebugger = s:oselas_gdb
"        let g:ConqueGdb_GdbExe = g:GccRoot.'/bin/arm-cortexa8-linux-gnueabi-gdb'
        let g:SshOpts = '-o ForwardAgent=yes -o ProxyCommand="ssh -q -W shg:22 root@%h" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR'
        let g:SshOpts2 = "-L localhost:1998:localhost:1998 -L localhost:1999:localhost:1999"
        execute 'set path+=' .  g:GccRoot . s:oselas_include
"        let g:ycm_clangd_args = ['-I'.g:GccRoot . s:oselas_include]
    elseif (g:project_type == 'dlcpro-gui')
        let s:Program = '/TOPAS_DLC_pro'
        let s:Elffile = s:Program
        let s:makegoals = []
        let g:termdebugger = 'gdb'
    elseif (g:project_type == 'topmode')
        let s:Program = '/topmode'
        let s:Elffile = s:Program
        let g:ProgramRemote = '/usr/toptica/topmode'
        let s:makegoals = []
        let g:DeviceIP = 'topmode_stefan'
        let g:GdbPort = '2345'
        let g:GccRoot = "/opt/OSELAS.Toolchain-2011.11.3/arm-cortexa8-linux-gnueabi/gcc-4.6.2-glibc-2.14.1-binutils-2.21.1a-kernel-2.6.39-sanitized"
        let g:termdebugger = s:oselas_gdb
        let g:ConqueGdb_GdbExe = g:GccRoot.'/bin/arm-cortexa8-linux-gnueabi-gdb'
        let g:SshOpts = ""
        let g:SshOpts2 = ""
        execute 'set path+=' .  g:GccRoot . s:oselas_include
"        let g:ycm_clangd_args = ['-I'.g:GccRoot . s:oselas_include]
    elseif (g:project_type == 'topmode-gui')
        let s:Program = '/TOPAS_Topmode'
        let s:Elffile = s:Program
        let s:makegoals = []
        let g:termdebugger = 'gdb'
    elseif (g:project_type == 'digifalc')
        let s:Program = '/digifalc-image.bin'
        let s:Elffile = '/application/digifalc.elf'
        let s:makegoals = ['firmware-update', 'html-docs', 'doxygen', 'digifalc.elf', 'bootloader.elf']
        let &makeprg = 'cmake --build . --target'
        let g:GdbPort = '2331'
        let g:GccRoot = '/opt/gcc-arm-none-eabi-8-2019-q3-update'
        let g:termdebugger = g:GccRoot.'/bin/arm-none-eabi-gdb'
        let $PATH = $PATH.':'.g:GccRoot.'/bin'
    elseif (g:project_type == 'servoboard')
        let s:Program = '/servo-board-image.bin'
        let s:Elffile = '/application/servo-board.elf'
        let s:makegoals = ['firmware-update', 'html-docs', 'doxygen', 'servo-board.elf', 'bootloader.elf']
        let &makeprg = 'cmake --build . --target'
        let g:GdbPort = '2331'
        let g:GccRoot = '/opt/gcc-arm-none-eabi-8-2019-q3-update'
        let g:termdebugger = g:GccRoot.'/bin/arm-none-eabi-gdb'
        let $PATH = $PATH.':'.g:GccRoot.'/bin'
    elseif (g:project_type == 'dl-motor')
        let s:Program = '/dl-motor-image.bin'
        let s:Elffile = '/application/dl-motor.elf'
        let s:makegoals = ['firmware-update', 'html-docs', 'doxygen', 'dl-motor.elf', 'bootloader.elf']
        let &makeprg = 'cmake --build . --target'
        let g:GdbPort = '2331'
        let g:GccRoot = '/home/stefan/opt/gcc/gcc-arm-none-eabi-9-2020-q2-update'
        let g:termdebugger = g:GccRoot.'/bin/arm-none-eabi-gdb'
        let $PATH = g:GccRoot.'/bin'.':'.$PATH
    else
        echo "no project"
    endif

    " editor settings
    set spell spelllang=en,de
    set expandtab
    set cinoptions=l1,g2,h2,N-2,t0,+0,(0,w1,Ws,m1,)100,*100
    set textwidth=120

    " python tags
    execute "set tags+=" . s:ProjectBaseDir . '/tags'

    " compiler
    compiler gcc
    let s:makeopts = ['-j3', 'VERBOSE=1']
    let g:Program = g:ProjectBuildDir.s:Program
    let g:Elffile = g:ProjectBuildDir.s:Elffile
    command! -complete=custom,GetAllMakeCompletions -nargs=* MakeCmd call s:Make('<args>', 0)
    command! MakeTestBuild call s:MakeTestBuild()
    command! -nargs=* Ctest call s:Ctest('<args>')

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

    function! s:DeviceFirmwareUpdate()
        if (g:project_type == 'dlcpro-can')
            call s:DeviceUpdateProgramLinux()
        elseif ((g:project_type == 'digifalc') || (g:project_type == 'servoboard') || (g:project_type == 'dl-motor'))
            call s:JLinkFlashProgram()
        else
            call s:DeviceFirmwareUpdateStartLinux()
        endif
    endfunction

    command! DeviceDebug call s:DeviceDebug(0)
    command! DeviceDebugAttach call s:DeviceDebug(1)
    command! DeviceStartGdbServer call s:DeviceStartGdbServer()
    command! DeviceStartGdbServerAttach call s:DeviceStartGdbServerAttach()

    " update device-contol.xml for Topas-GUI
    command! DlcProUpdateTopasXml '!svnmucc put -m \'update "device-control.xml"\' ".g:ProjectBuildDir.'/device-control/device-control.xml https://svn.toptica.com/svn/topas_dlc_pro/trunk/res/device-control.xml'

    " YouCompleteMe plugin
    "set completeopt-=preview
    "let g:ycm_add_preview_to_completeopt = 0
    "let g:ycm_autoclose_preview_window_after_completion = 0
    "let g:ycm_autoclose_preview_window_after_insertion = 0
    "let g:ycm_key_previous_completion = ['<TAB>', '<Down>', '<Enter>']
"    let g:ycm_extra_conf_globlist = [
"                \s:ProjectBaseDir.'/.ycm_extra_conf.py',
"                \'!~/tools/vimsuite/vimfiles.YouCompleteMe/*',
"                \]

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
"    execute 'AsyncRun -mode='.a:async_mode.' -save=2 -program=make @ --directory='.g:ProjectBuildDir.' '.a:args
    execute 'AsyncRun -mode='.a:async_mode.' -save=2 -program=make -cwd='.g:ProjectBuildDir. ' @ '.a:args
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
    let args .= " -DCMAKE_BUILD_TYPE=".a:build_type
    let args .= " -DCMAKE_EXPORT_COMPILE_COMMANDS=1"
    if (g:project_type == 'dlcpro')
        let args .= " -DCMAKE_TOOLCHAIN_FILE=../".g:ProjectSrcDirRel."/Toolchain-target.cmake"
        let args .= " -DBUILD_TARGET=target"
        let args .= " -DQT5_INSTALL_PATH=dlcpro-sdk/sysroot-target/usr/local/Qt-5.4.1"
    elseif (g:project_type == 'topmode')
        let args .= " -DCMAKE_TOOLCHAIN_FILE=../".g:ProjectSrcDirRel."/Toolchain-target.cmake"
        let args .= " -DSYSROOT=~/topmode/topmode-sdk/sysroot-target"
    elseif (g:project_type == 'topmode-gui')
    elseif ((g:project_type == 'digifalc') || (g:project_type == 'servoboard') || (g:project_type == 'dl-motor'))
        let args .= " -G Ninja"
        let args .= " -DCMAKE_TOOLCHAIN_FILE=../".g:ProjectSrcDirRel."/GNU\\ Arm\\ Embedded.toolchain.cmake"
    endif
    execute 'AsyncRun -mode='.a:async_mode.' -save=2 -cwd='.g:ProjectBuildDir.' @ cmake '.args
endfunction

function s:Ctest(args)
    let cmd = 'ctest --build-and-test ./src unit-tests --build-generator "Unix Makefiles" --build-target unit_tests --nocompress-output -T Test --build-options -DCMAKE_BUILD_TYPE=Debug --test-command ctest'
    call asyncrun#quickfix_toggle(10, 0)
    execute 'AsyncRun -mode=1 -save=2 -cwd='.s:ProjectBaseDir.' @ ' . cmd .' '. a:args
endfunction

function s:Call_and_log(cmd)
    echom a:cmd
    let r = system(a:cmd)
    let e = v:shell_error
    if (e != 0)
        echom 'return value: '.e.', output: "'.r.'"'
    endif
    return v:shell_error
endfunction

"function s:CopyFirmware(command)
"    let command = 'bash '.s:GdbSlave.' -h '.g:DeviceIP.' '.a:command
""    if a:command == 'update' || a:command == 'start-debug'
"        let command .= ' '.g:Program
""    endif
"    echom command
"    call system(command)
"endfunction

function s:DlcproEmission(state)
    call s:Call_and_log('ssh '.g:SshOpts.' root@'.g:DeviceIP.' "echo '.state.' > /sys/bus/i2c/devices/200-0028/emission_button_state"')
endfunction

function s:DlcproShutup()
    call s:Call_and_log('ssh '.g:SshOpts.' root@'.g:DeviceIP.' "modprobe -r tam3517_busser"')
endfunction

function s:JLinkFlashProgram()
    call term_start(s:ProjectSrcDir.'/flash_firmware.py -j '.s:jlink_path.'/JLinkExe -a 0x8000000 '.g:Program)
endfunction

function s:DeviceUpdateProgramLinux()
    call s:Call_and_log('ssh '.g:SshOpts.' root@'.g:DeviceIP.' "killall -q gdbserver start-dc.sh '.fnamemodify(g:ProgramRemote, ':t').'"')
    sleep 2
"    call s:Call_and_log('ssh '.g:SshOpts.' root@'.g:DeviceIP.' "killall -q -9 gdbserver start-dc.sh '.g:ProgramRemote.'"')
    call s:Call_and_log('ssh '.g:SshOpts.' root@'.g:DeviceIP.' "killall -q -9 gdbserver start-dc.sh '.fnamemodify(g:ProgramRemote, ':t').'"')
    let r = s:Call_and_log('ssh '.g:SshOpts.' root@'.g:DeviceIP.' "mount -o rw,remount / && rm -f '.g:ProgramRemote.'" && scp '.g:SshOpts.' "'.g:Program.'" "root@'.g:DeviceIP.':'.g:ProgramRemote.'"')
    return r
endfunction

function s:DeviceFirmwareUpdateStartLinux()
    let r = s:DeviceUpdateProgramLinux()
    if (r == 0)
        call s:Call_and_log('ssh '.g:SshOpts.' -f root@'.g:DeviceIP.' "{ exec '.g:ProgramRemote.' 2>&1 | logger -t "'.g:ProgramRemote.'" -p user.err; } &"')
    endif
endfunction

function s:DeviceStartGdbServer()
    if ((g:project_type == 'digifalc') || (g:project_type == 'servoboard') || (g:project_type == 'dl-motor'))
        call s:Call_and_log('pkill --full JLinkGDBServer')
"        call s:Call_and_log('/opt/SEGGER/JLink/JLinkGDBServer -if SWD -device STM32H743XI &')
"        call s:Call_and_log('/opt/SEGGER/JLink/JLinkGDBServer -if SWD -device STM32H743ZI2 &')
"        call s:Call_and_log('/opt/SEGGER/JLink/JLinkGDBServer -if SWD -device STM32H743ZI &')
        call s:Call_and_log(s:jlink_path.'/JLinkGDBServer -if SWD -device STM32H743ZI &')
    else
        call s:Call_and_log('pkill --full gdbserver')
        call s:Call_and_log('ssh '.g:SshOpts.' root@'.g:DeviceIP.' "killall -q -9 gdbserver start-dc.sh '.fnamemodify(g:ProgramRemote, ':t').'"')
        call s:Call_and_log('ssh '.g:SshOpts.' -L localhost:'.g:GdbPort.':localhost:'.g:GdbPort.' "root@'.g:DeviceIP.'" '.g:SshOpts2.' gdbserver --multi localhost:'.g:GdbPort.' &')
    endif
endfunction

function s:DeviceStartGdbServerAttach()
    if ((g:project_type == 'digifalc') || (g:project_type == 'servoboard') || (g:project_type == 'dl-motor'))
    else
        call s:Call_and_log('pkill --full gdbserver')
        call s:Call_and_log('ssh '.g:SshOpts.' -L localhost:'.g:GdbPort.':localhost:'.g:GdbPort.' "root@'.g:DeviceIP.'" '.g:SshOpts2.' "gdbserver localhost:'.g:GdbPort.' --attach \`pidof '.fnamemodify(g:ProgramRemote, ':t').'\` &"')
    endif
endfunction

function s:SendToTerm(command)
    call term_sendkeys('', a:command . "\n")
    sleep 1
endfunction

function s:SendToConque(command)
    execute 'ConqueGdbCommand ' . a:command
endfunction

function s:SendToDebugger(command)
    if ((g:project_type == 'digifalc') || (g:project_type == 'servoboard') || (g:project_type == 'dl-motor'))
        call s:SendToTerm(a:command)
    else
        call s:SendToConque(a:command)
    endif
endfunction

function s:StartDebugger(elffile, attach)
    if ((g:project_type == 'digifalc') || (g:project_type == 'servoboard') || (g:project_type == 'dl-motor'))
        if (a:attach == 0)
            Termdebug
        else
            execute 'Termdebug ' . a:elffile
        endif
    else
        if (a:attach == 0)
            ConqueGdbTab
        else
            execute 'ConqueGdbTab '.a:elffile
        endif
    endif
endfunction

let g:DlcProBasePath = "/jenkins/workspace/pro--firmware_release_1.9.0-DCESJ5C5R577IG5QFEWTML22UFDDZCJDGFLMDA4DCD3V2ZAGVEJA/source/"
function s:DeviceDebug(attach)
    if (a:attach == 0)
"        let r = s:DeviceFirmwareUpdate()
        let r = 0
        if (r != 0)
            echoerr "DeviceFirmwareUpdate() failed!"
        else
            sleep 2
            call s:DeviceStartGdbServer()
            sleep 2
            call s:StartDebugger(g:Elffile, a:attach)
"            call s:SendToDebugger('')
            call s:SendToDebugger('target extended-remote localhost:'.g:GdbPort)
            if exists("g:ProgramRemote")
                call s:SendToDebugger('set remote exec-file '.g:ProgramRemote)
            endif
            call s:SendToDebugger('file '.g:Elffile)
"            call s:SendToDebugger('y')
            sleep 3
            call s:SendToDebugger('break main')
            call s:SendToDebugger('run')
"            call s:SendToDebugger('y')
        endif
    else
        call s:DeviceStartGdbServerAttach()
        sleep 1
        call s:StartDebugger(a:attach)
        call s:SendToDebugger('target remote localhost:'.g:GdbPort)
        " get remote src path with gdb: info sources or gdb: break main
        call s:SendToDebugger('set substitute-path '.g:DlcProBasePath.' '.s:ProjectSrcDir)
    endif

"    call s:SendToDebugger('set solib-search-path '.g:GccRoot.'/arm-cortexa8-linux-gnueabi/lib/'.':'.g:GccRoot.'/sysroot-arm-cortexa8-linux-gnueabi/lib/'.':'.g:GccRoot.'/sysroot-arm-cortexa8-linux-gnueabi/usr/lib/')
"    call s:SendToDebugger('set can-use-hw-watchpoints 0')
endfunction

" ================
" Regression Tests
" ================
function g:DlcProRegtestCmd(arguments)
    return s:DlcProRegtestCmd('',              '',            '0', '1', '',          '--capture=no',                  a:arguments)
endfunction
function g:DlcProRegtestDlProCmd(arguments)
    return s:DlcProRegtestCmd('192.168.54.24', 'elab-dlcpro', '2', '1', 'DLpro',     '',                              a:arguments)
endfunction
function g:DlcProRegtestTaProCmd(arguments)
    return s:DlcProRegtestCmd('192.168.54.9',  'elab-dlcpro', '3', '1', 'TApro',     '-m "not usb and not usbstick"', a:arguments)
endfunction
function g:DlcProRegtestCtlCmd(arguments)
    return s:DlcProRegtestCmd('192.168.54.27', 'elab-dlcpro', '1', '1', 'CTL',       '-m "not usb and not usbstick"', a:arguments)
endfunction
function g:DlcProRegtestDualDlCmd(arguments)
    return s:DlcProRegtestCmd('192.168.54.28', 'elab-dlcpro', '4', '2', 'DLpro',     '-m "not usb and not usbstick"', a:arguments)
endfunction
function g:DlcProRegtestDualDl1Cmd(arguments)
    return s:DlcProRegtestCmd('192.168.54.28', 'elab-dlcpro', '4', '1', 'DLpro',     '-m "not usb and not usbstick"', a:arguments)
endfunction
function g:DlcProRegtestShgProCmd(arguments)
    return s:DlcProRegtestCmd('192.168.54.29', 'elab-dlcpro', '7', '1', 'TA-SHGpro', '-m "not usb and not usbstick"', a:arguments)
endfunction

command -nargs=1 -complete=file DlcProRegtest        call s:DlcProRegtest(g:DlcProRegtestCmd('<args>'))
command -nargs=1 -complete=file DlcProRegtestDlPro   call s:DlcProRegtest(g:DlcProRegtestDlProCmd()'args')
command -nargs=1 -complete=file DlcProRegtestTaPro   call s:DlcProRegtest(g:DlcProRegtestTaProCmd()'args')
command -nargs=1 -complete=file DlcProRegtestCtl     call s:DlcProRegtest(g:DlcProRegtestCtlCmd()'args')
command -nargs=1 -complete=file DlcProRegtestDualDl  call s:DlcProRegtest(g:DlcProRegtestDualDl1Cmd()'args')
command -nargs=1 -complete=file DlcProRegtestDualDl1 call s:DlcProRegtest(g:DlcProRegtestDualDl1Cmd()'args')
command -nargs=1 -complete=file DlcProRegtestShgPro  call s:DlcProRegtest(g:DlcProRegtestShgProCmd()'args')

let g:DlcProRegtest_fast_restart = 1
"let g:DlcProRegtest_marks = "-m (not not_yet_active and not usb and not usbstick and not si1 and not servo_control and not eom)"
let g:DlcProRegtest_marks = ""
let g:DlcProRegtest_lasertype = "DLpro"
let g:DlcProRegtest_powerswitch_ip = ""

function s:DlcProRegtestCmd(ip, powerswitch_ip, powerplug, laser_count, laser_type, opts, arguments)
    if (a:ip == '')
        let ip = g:DeviceIP
    else
        let ip = a:ip
    endif
    if (a:laser_type == '')
        let laser_type = g:DlcProRegtest_lasertype
    else
        let laser_type = a:laser_type
    endif
    if (a:powerswitch_ip == '')
        let powerswitch_ip = g:DlcProRegtest_powerswitch_ip
    else
        let powerswitch_ip = a:powerswitch_ip
    endif

    let archive_dir = g:ProjectBuildDir."/artifacts"
    let license_builddir = s:ProjectBaseDir.'/build.license'
    let licensetool = license_builddir."/libdlcprolicense/dlcprolicense-tool"

    let test_cmd =
                \s:ProjectSrcDir."/test/python-env/bin/python -u -m pytest ".
                \"--showlocals --tb=long --verbose --cache-clear ".
                \"-o junit_family=xunit1 ".
                \"--junit-xml=regtest.".laser_type.".xml ".
                \"--debug_build ".
                \"--laser_count=".a:laser_count." ".
                \"--laser1_type=".laser_type." ".
                \"--log_file=regtest.".laser_type.".log ".
                \"--target_ip=".ip." ".
                \"--powerswitch_ip=".powerswitch_ip." ".
                \"--powerswitch_passwd=nimda ".
                \"--power_plug=".a:powerplug." ".
                \"--power_plug_fan=8"." ".
                \"--version_file=".archive_dir."/VERSION ".
                \"--firmware_file=".archive_dir."/DLCpro-archive.fw ".
                \"--license_tool=".licensetool." ".
                \"--license_keyfile=".s:ProjectSrcDir."/license/libdlcprolicense/rsa-private.key ".
                \"--skip_shutdown_after_test ".
                \"--skip_fw_update ".
                \"--log-file-level=DEBUG "
                \""

    if (g:DlcProRegtest_fast_restart == 1)
        let test_cmd .= "--fast_restart "
    endif

    " hint: --collect-only
    "--log-cli-level=DEBUG --log-file-level=DEBUG

    let test_cmd .= a:opts." ".a:arguments." ". g:DlcProRegtest_marks
    let @+ = test_cmd
    return test_cmd
endfunction

function s:DlcProRegtest(test_cmd)
    execute "wa"

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

    " Build command
    echom a:test_cmd

    " Execute pytest
    execute "terminal ++shell cd " s:ProjectSrcDir. "/test && " . a:test_cmd
"    call term_start(a:test_cmd, {'cwd' : s:ProjectSrcDir."/test"})
endfunction

" -------------
" YouCompleteMe
" -------------
"let g:ycm_max_diagnostics_to_display = 1000
"let g:ycm_clangd_uses_ycmd_caching = 0
"let g:ycm_cache_omnifunc = 0
"let g:ycm_filter_diagnostics = {
"            \ "cpp": {
"            \   "regex": [
"            \       "'auto_ptr<boost::signals2::detail::foreign_weak_ptr_impl_base>' is deprecated",
"            \       "'boost/tuple.hpp' file not found",
"            \       "no template named 'tuple' in namespace 'boost'",
"            \       "no matching function for call to 'throw_exception'",
"            \       "variable templates are a C\\+\\+14 extension",
"            \       "inline variables are a C\\+\\+17 extension",
"            \       "expected ',' or '>' in template-parameter-list",
"            \       "expected a qualified name after 'typename'",
"            \       "expected ';' at end of declaration list",
"            \       "'std::unordered_set::_Hashtable' \\(aka 'int'\\) is not a class, namespace, or enumeration",
"            \       "no template named '__uset_hashtable'",
"            \   ],
"            \ }
"            \}

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

" ------
" Pandoc
" ------
command TopticaBeamer execute('!pandoc -s -t beamer -H toptica-style.tex -o %:r.pdf %')
