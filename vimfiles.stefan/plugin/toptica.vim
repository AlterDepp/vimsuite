command DlcPro call s:ProjectDlcproSet()
function s:ProjectDlcproSet()
    compiler gcc
    let s:makegoals = ['artifacts', 'device-control', 'user-interface', 'doxygen']
    let s:makeopts = ['-j4']
    let s:ProjectBaseDir = '/home/liebl/dlcpro/firmware'
    let s:ProjectSrcDir = s:ProjectBaseDir.'/src'
    let s:ProjectBuildDir = s:ProjectBaseDir.'/build'
    let g:Program = s:ProjectBuildDir.'/device-control/device-control'
    execute 'cd '.s:ProjectSrcDir
    execute 'set path-=./**'
    execute 'set path+=' .  s:ProjectBaseDir.'/**'
    set wildignore+=**/shg-firmware/**
    let g:GdbHost = 'dlcpro_stefan'
    let g:GdbPort = '2345'
    let s:GdbSlave = '~/tools/gdb-slave.sh'
    let g:GdbPath = '/opt/OSELAS.Toolchain-2012.12.1/arm-cortexa8-linux-gnueabi/gcc-4.7.3-glibc-2.16.0-binutils-2.22-kernel-3.6-sanitized/bin/arm-cortexa8-linux-gnueabi-gdb'
    set spell spelllang=en,de
    set expandtab
    set cinoptions=:2,=2,l1,g2,h2,N-2,t0,+0,(0,w1,Ws,m1,)100,*100

    command! -complete=custom,GetAllMakeCompletions -nargs=* Make call s:Make('<args>')
    command! DlcProFirmwareUpdate call CopyFirmware('update')
    command! DlcProFirmwareDebug call CopyFirmware('debug')
    command! DlcProFirmwareStart call CopyFirmware('start')
    command! DlcProDebug call DlcProDebug(g:Program)

    " vc-plugin
    let g:vc_branch_url = ['https://svn.toptica.com/svn/DiSiRa/SW/firmware/branches']
    let g:vc_trunk_url = 'https://svn.toptica.com/svn/DiSiRa/SW/firmware/trunk'

    " vim-clang
"    let g:clang_cpp_options = '-std=c++11'
"    let g:clang_compilation_database = s:ProjectBuildDir

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

endfunction
 
" ====
" Make
" ====
function s:GetMakeOptions(args)
    let makeopts =  a:args
    return makeopts
endfunction

function GetAllMakeCompletions(ArgLead, CmdLine, CursorPos)
    return join(s:makegoals + s:makeopts + glob(a:ArgLead.'*', 1, 1), "\n")
endfunction

function s:Make(args)
    echo a:args
    execute 'cd '.s:ProjectBuildDir.' | make ' . s:GetMakeOptions(a:args) . ' | cd -'
    execute 'cd '.s:ProjectSrcDir
    try
        clist
    catch /E42/ " list is empty
        echo 'no output'
    endtry
endfunction

function CopyFirmware(command)
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
"    execute 'D set sysroot '.s:ProjectBuildDir.'/dlcpro-sdk/sysroot-target'
endfunction

function DlcProDebug(program)
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
"    execute 'C set sysroot '.s:ProjectBuildDir.'/dlcpro-sdk/sysroot-target'
"    Ccontinue
endfunction
