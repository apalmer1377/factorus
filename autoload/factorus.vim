" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" Initialization {{{1

if exists(':Factorus') == 0
    runtime plugin/factorus.vim
endif
let g:loaded_factorus = 1

" Dictionaries {{{1
" Language Dictionary {{{2
let s:langs = { 'java'          : 'Java',
            \   'python'        : 'Python',
            \   'c'             : 'C',
            \   'cpp'           : 'C++',
            \   'go'            : 'Go',
            \   'ruby'          : 'Ruby',
            \   'php'           : 'Php',
            \   'rust'          : 'Rust',
            \   'javascript'    : 'Javascript',
            \   'perl'          : 'Perl'
            \ }

" Error Dictionary {{{2
let s:errors = {
            \   'Invalid'       : 'Invalid expression under cursor.',
            \   'Duplicate'     : 'New name is same as old name.',
            \   'NoLines'       : 'Nothing to extract.',
            \   'EncapStatic'   : 'Cannot encapsulate a static variable.',
            \   'EncapLocal'    : 'Cannot encapsulate a local variable.'
            \}

" Build Dictionary {{{2
let s:build_files = {   
            \       'make'      : 'Makefile',
            \       'ant'       : 'build.xml',
            \       'mvn'       : 'pom.xml',
            \       'gradle'    : 'build.gradle',
            \       'rake'      : 'Rakefile'
            \}

" Misc Functions {{{1

function! factorus#isRollback(a)
    return (len(a:a) > 0 && a:a[-1] == 'factorusRollback')
endfunction

function! s:handleError(func,ext,error,opt)
    let [a:exception,a:throwpoint] = a:error

    for buf in getbufinfo()
        if index(s:open_bufs,buf['name']) < 0
            execute 'bwipeout ' . buf['bufnr']
        endif
    endfor

    let a:roll = index(keys(g:factorus_history),'old') >= 0 ? 1 : 0
    if match(a:exception,'Unknown function') >= 0
        if match(a:exception,'\(\<' . a:func . '\>\|\(s:\|factorus#\)rename\)') >= 0
            let a:lang = index(keys(s:langs),a:ext) >= 0 ? s:langs[a:ext] : 'this language'
            let a:name = a:func == 'renameSomething' ? 'rename' . a:opt[-1] : a:func
            let a:err = 'Factorus: ' . a:name . ' is not available for ' . a:lang . '.'
            let a:roll = 0
        else
            let a:err = a:exception
        endif
    elseif match(a:exception,'^Factorus:') >= 0
        let a:tail = substitute(join(split(a:exception,':')[1:]),',.*','','')
        let a:err = index(keys(s:errors),a:tail) >= 0 ? 'Factorus: ' . s:errors[a:tail] : a:exception
    else
        let a:err = 'An unexpected error has occurred: ' . a:exception . ', at ' . a:throwpoint
    endif

    if a:roll == 1 && a:func == 'renameSomething' && !factorus#isRollback(a:opt)
        call factorus#rollback()
    endif

    redraw
    echom a:err
endfunction

" Commands {{{1
" factorus#version {{{2
function! factorus#version()
    echo 'Factorus: version ' . g:factorus_version
endfunction

" factorus#rebuild {{{2
function! factorus#rebuild(...)
    if exists('g:factorus_build_win')
        execute 'bwipeout ' . g:factorus_build_win
    endif

    let a:strip_dir = '\(.*\/\)\=\(.*\)'
    let a:prev_dir = getcwd()
    let a:project_dir = g:factorus_project_dir == '' ? system('git rev-parse --show-toplevel') : g:factorus_project_dir
    execute 'cd ' . a:project_dir

    let a:file_find = g:factorus_build_file == '' ? s:build_files[g:factorus_build_program] : g:factorus_build_file
    try
        let [a:build_path,a:file_find] = split(substitute(a:file_find,a:strip_dir,'\1|\2',''),'|')
        let a:path_find = ' -path "' . a:build_path . '" '
    catch /.*/
        let a:file_find = substitute(a:file_find,a:strip_dir,'\2','')
        let a:path_find = ''
    endtry

    try
        let a:file = split(system('ls ' . a:file_find),'\n')[0]
        if a:file != a:file_find
            let a:file = split(system('find ' . getcwd() . a:path_find . ' -name "' . a:file_find . '"'),'\n')[0]
        else
            let a:file = expand('%:p:h') . '/' . a:file
        endif
    catch /.*/
        execute 'cd ' . a:prev_dir
        echom 'Factorus: build file not found'
        return
    endtry

    let a:build_dir = substitute(a:file,a:strip_dir,'\1','')
    execute 'cd ' . a:build_dir

    let a:build_task = a:0 > 0 ? a:1 : g:factorus_build_task
    let a:command = g:factorus_build_program . ' ' . a:build_task . ' ' . g:factorus_build_options

    redraw
    echo 'Running ' . a:command
    let a:res = ['Build Output',''] + split(system(a:command),'\n')
    while match(a:res[-1],'^\s*$') >= 0
        call remove(a:res,len(a:res)-1)
    endwhile

    let g:factorus_build_win = substitute('FRebuild_' . g:factorus_build_program,'\s','_','g')
    execute 'silent keepalt botright vertical ' . winwidth(0) . 'split ' . g:factorus_build_win
    call append(0,a:res)
    d

    setlocal noreadonly
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal textwidth=0

    execute 'cd ' . a:prev_dir
    redraw
    echo 'Build completed.'
endfunction

" factorus#command {{{2
function! factorus#command(func,...)
    let s:open_bufs = map(getbufinfo(),{n,val -> val['name']})
    let a:hl = &hlsearch
    let &hlsearch = 0

    let a:file = expand('%:p')
    let a:pos = [line('.'),col('.')]
    let a:ext = &filetype
    if expand('%:e') == 'h'
        let a:ext = g:factorus_default_lang == '' ? 'cpp' : g:factorus_default_lang
    endif

    if !factorus#isRollback(a:000)
        let g:factorus_history = {'file' : a:file, 'function' : a:func, 'pos' : copy(a:pos), 'args' : a:000}
    endif

    try
        let Func = function(a:ext . '#factorus#' . a:func,a:000)
        let a:res = Func()
        let a:file = expand('%:p')
        if !factorus#isRollback(a:000)
            if g:factorus_show_changes > 0 && (a:func == 'renameSomething' || a:func == 'addParam')
                copen
            endif

            if g:factorus_validate == 1
                redraw
                echo 'Validating changes...'
                call factorus#rebuild()
            endif
        endif
    catch /.*/
        let a:res = ''
        let a:error = [v:exception,v:throwpoint]
        call s:handleError(a:func,a:ext,a:error,a:000)
    endtry

    let &hlsearch = a:hl
    let g:factorus_history = {'file' : a:file, 'function' : a:func, 'pos' : copy(a:pos), 'args' : a:000, 'old' : a:res}
    return a:res
endfunction

" factorus#rollback {{{2
function! factorus#rollback()
    if !exists('g:factorus_history') || index(keys(g:factorus_history),'old') < 0 || len(g:factorus_history['old']) == 0
        echo 'Nothing to roll back.'
        return
    endif
    echo 'Rolling back previous action...'
    let a:func = g:factorus_history['function']
    let a:old = g:factorus_history['old']

    if a:func == 'renameSomething' && g:factorus_history['args'][-1] == 'Class'
        cclose
    endif

    let a:curr = expand('%:p')
    if a:curr != g:factorus_history['file']
        execute 'silent tabedit ' . g:factorus_history['file']
    endif
    call cursor(g:factorus_history['pos'][0],g:factorus_history['pos'][1])

    if a:func == 'addParam'
        let a:echo = factorus#command('addParam',a:old[1],a:old[1],'factorusRollback')
    elseif a:func == 'renameSomething'
        let a:echo = factorus#command('renameSomething',a:old,g:factorus_history['args'][-1],'factorusRollback')
    else
        let a:echo = factorus#command(a:func,'factorusRollback')
    endif
    let g:factorus_history['old'] = ''

    if a:curr != g:factorus_history['file'] && (a:func != 'renameSomething' || g:factorus_history['args'][-2] != 'Class')
        if winnr("$") == 1 && tabpagenr("$") > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr("$")
          tabclose | tabprev
        else
          q
        endif
    endif

    if a:echo != ''
        redraw
        echo a:echo
    endif
endfunction
