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
    let [l:exception,l:throwpoint] = a:error

    for buf in getbufinfo()
        if index(s:open_bufs,buf['name']) < 0
            execute 'bwipeout ' . buf['bufnr']
        endif
    endfor

    let l:roll = index(keys(g:factorus_history),'old') >= 0 ? 1 : 0
    if match(l:exception,'Unknown function') >= 0
        if match(l:exception,'\(\<' . a:func . '\>\|\(s:\|factorus#\)rename\)') >= 0
            let l:lang = index(keys(s:langs),a:ext) >= 0 ? s:langs[a:ext] : 'this language'
            let l:name = a:func == 'renameSomething' ? 'rename' . a:opt[-1] : a:func
            let l:err = 'Factorus: ' . l:name . ' is not available for ' . l:lang . '.'
            let l:roll = 0
        else
            let l:err = l:exception
        endif
    elseif match(l:exception,'^Factorus:') >= 0
        let l:tail = substitute(join(split(l:exception,':')[1:]),',.*','','')
        let l:err = index(keys(s:errors),l:tail) >= 0 ? 'Factorus: ' . s:errors[l:tail] : l:exception
    else
        let l:err = 'An unexpected error has occurred: ' . l:exception . ', at ' . l:throwpoint
    endif

    if l:roll == 1 && a:func == 'renameSomething' && !factorus#isRollback(a:opt)
        call factorus#rollback()
    endif

    redraw
    echom l:err
endfunction

" Commands {{{1
" factorus#version {{{2
function! factorus#version()
    echo 'Factorus: version ' . g:factorus_version
endfunction

" factorus#projectDir {{{2
function! factorus#projectDir()
    let l:dir = g:factorus_project_dir == '' ? substitute(system('git rev-parse --show-toplevel'),'\n\+$','','') : g:factorus_project_dir
    if empty(glob(l:dir))
        let l:dir = getcwd()
    endif
    return l:dir
endfunction

" factorus#setProjectDir {{{2
function! factorus#setProjectDir(dir)
    let g:factorus_project_dir = a:dir
endfunction

" factorus#rebuild {{{2
function! factorus#rebuild(...)
    if exists('g:factorus_build_win')
        execute 'bwipeout ' . g:factorus_build_win
    endif

    let l:strip_dir = '\(.*\/\)\=\(.*\)'
    let l:prev_dir = getcwd()
    let l:project_dir = factorus#projectDir()
    execute 'cd ' . l:project_dir

    let l:file_find = g:factorus_build_file == '' ? s:build_files[g:factorus_build_program] : g:factorus_build_file
    try
        let [l:build_path,l:file_find] = split(substitute(l:file_find,l:strip_dir,'\1|\2',''),'|')
        let l:path_find = ' -path "' . l:build_path . '" '
    catch /.*/
        let l:file_find = substitute(l:file_find,l:strip_dir,'\2','')
        let l:path_find = ''
    endtry

    try
        let l:file = split(system('ls ' . l:file_find),'\n')[0]
        if l:file != l:file_find
            let l:file = split(system('find ' . getcwd() . l:path_find . ' -name "' . l:file_find . '"'),'\n')[0]
        else
            let l:file = expand('%:p:h') . '/' . l:file
        endif
    catch /.*/
        execute 'cd ' . l:prev_dir
        echom 'Factorus: build file not found'
        return
    endtry

    let l:build_dir = substitute(l:file,l:strip_dir,'\1','')
    execute 'cd ' . l:build_dir

    let l:build_task = a:0 > 0 ? a:1 : g:factorus_build_task
    let l:command = g:factorus_build_program . ' ' . l:build_task . ' ' . g:factorus_build_options

    redraw
    echo 'Running ' . l:command
    let l:res = ['Build Output',''] + split(system(l:command),'\n')
    while match(l:res[-1],'^\s*$') >= 0
        call remove(l:res,len(l:res)-1)
    endwhile

    let g:factorus_build_win = substitute('FRebuild_' . g:factorus_build_program,'\s','_','g')
    execute 'silent keepalt botright vertical ' . winwidth(0) . 'split ' . g:factorus_build_win
    call append(0,l:res)
    d

    setlocal noreadonly
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal textwidth=0

    execute 'cd ' . l:prev_dir
    redraw
    echo 'Build completed.'
endfunction

" factorus#command {{{2
function! factorus#command(func,...)
    let s:open_bufs = map(getbufinfo(),{n,val -> val['name']})
    let l:hl = &hlsearch
    let &hlsearch = 0

    let l:file = expand('%:p')
    let l:pos = [line('.'),col('.')]
    let l:ext = &filetype
    if expand('%:e') == 'h'
        let l:ext = g:factorus_default_lang == '' ? 'cpp' : g:factorus_default_lang
    endif

    if !factorus#isRollback(a:000)
        let g:factorus_history = {'file' : l:file, 'function' : a:func, 'pos' : copy(l:pos), 'args' : a:000}
    endif

    try
        let Func = function(l:ext . '#factorus#' . a:func,a:000)
        let l:res = Func()
        let l:file = expand('%:p')
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
        let l:res = ''
        let l:error = [v:exception,v:throwpoint]
        call s:handleError(a:func,l:ext,l:error,a:000)
    endtry

    let &hlsearch = l:hl
    let g:factorus_history = {'file' : l:file, 'function' : a:func, 'pos' : copy(l:pos), 'args' : a:000, 'old' : l:res}
    return l:res
endfunction

" factorus#rollback {{{2
function! factorus#rollback()
    if !exists('g:factorus_history') || index(keys(g:factorus_history),'old') < 0 || len(g:factorus_history['old']) == 0
        echo 'Nothing to roll back.'
        return
    endif
    echo 'Rolling back previous action...'
    let l:func = g:factorus_history['function']
    let l:old = g:factorus_history['old']

    if l:func == 'renameSomething' && g:factorus_history['args'][-1] == 'Class'
        cclose
    endif

    let l:curr = expand('%:p')
    if l:curr != g:factorus_history['file']
        execute 'silent tabedit ' . g:factorus_history['file']
    endif
    call cursor(g:factorus_history['pos'][0],g:factorus_history['pos'][1])

    if l:func == 'addParam'
        let l:echo = factorus#command('addParam',l:old[1],l:old[1],'factorusRollback')
    elseif l:func == 'renameSomething'
        let l:echo = factorus#command('renameSomething',l:old,g:factorus_history['args'][-1],'factorusRollback')
    else
        let l:echo = factorus#command(l:func,'factorusRollback')
    endif
    let g:factorus_history['old'] = ''

    if l:curr != g:factorus_history['file'] && (l:func != 'renameSomething' || g:factorus_history['args'][-2] != 'Class')
        if winnr("$") == 1 && tabpagenr("$") > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr("$")
          tabclose | tabprev
        else
          q
        endif
    endif

    if l:echo != ''
        redraw
        echo l:echo
    endif
endfunction
