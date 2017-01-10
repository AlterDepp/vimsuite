command DlcPro call s:ProjectDlcproSet('device-control')
command DlcProShg call s:ProjectDlcproSet('shg')
function s:ProjectDlcproSet(project_type)
    " directories
    if (a:project_type == 'device-control')
        let s:ProjectBaseDir = '/home/liebl/dlcpro/firmware'
        let s:Program = '/device-control/device-control'
        set wildignore+=**/shg-firmware/**
    else
        let s:ProjectBaseDir = '/home/liebl/dlcpro/shg-firmware'
        let s:Program = '/device-control/device-control-shg'
        set wildignore+=**/firmware/**
    endif
    let g:ProjectSrcDirRel = 'src'
    let s:ProjectSrcDir = s:ProjectBaseDir.'/'.g:ProjectSrcDirRel
    let g:ProjectBuildDir = s:ProjectBaseDir.'/build'

    " vim path
    execute 'cd '.s:ProjectSrcDir
    execute 'set path-=./**'
    execute 'set path+=' .  s:ProjectBaseDir.'/**'

    " editor settings
    set spell spelllang=en,de
    set expandtab
    set cinoptions=:2,=2,l1,g2,h2,N-2,t0,+0,(0,w1,Ws,m1,)100,*100

    " python tags
    execute "set tags+=" . s:ProjectBaseDir . '/tags'

    " compiler
    compiler gcc
    let s:makegoals = ['artifacts', 'device-control', 'user-interface', 'doxygen', 'shg-firmware', 'docu-ul0', 'code-generation', 'dependency-graphs']
    let s:makeopts = ['-j4']
    let g:Program = g:ProjectBuildDir.s:Program
    command! -complete=custom,GetAllMakeCompletions -nargs=* Make call s:Make('<args>')

    " cmake
    command! -nargs=? Cmake call s:Cmake('<args>')

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

    " vim-clang
    command! ClangFormat pyfile /usr/share/vim/addons/syntax/clang-format.py

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
function GetAllMakeCompletions(ArgLead, CmdLine, CursorPos)
    return join(s:makegoals + s:makeopts + glob(a:ArgLead.'*', 1, 1), "\n")
endfunction

function s:Make(args)
    wa
    call asyncrun#quickfix_toggle(10, 1)
    execute 'AsyncRun -save=1 -program=make @ --directory='.g:ProjectBuildDir.' '.a:args
endfunction

function s:Cmake(build_type)
    if a:build_type == ''
        let build_type = 'Debug'
    else
        let build_type = a:build_type
    endif
    call asyncrun#quickfix_toggle(10, 1)
    let args = ""
    let args .= " ../".g:ProjectSrcDirRel."/"
    let args .= " --graphviz=dependencies.dot"
    let args .= " -DBUILD_TARGET=target"
    let args .= " -DCMAKE_TOOLCHAIN_FILE=../".g:ProjectSrcDirRel."/Toolchain-target.cmake"
    let args .= " -DQT5_INSTALL_PATH=dlcpro-sdk/sysroot-target/usr/local/Qt-5.4.1"
    let args .= " -DCMAKE_BUILD_TYPE=".build_type
    let args .= " -DCMAKE_EXPORT_COMPILE_COMMANDS=1"
    execute 'AsyncRun -save=1 -cwd='.g:ProjectBuildDir.' @ cmake '.args
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
