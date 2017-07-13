" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" Initialization {{{1

if exists(':Factorus') == 0
    runtime plugin/factorus.vim
endif
let g:loaded_factorus = 1

" Dictionaries {{{1
" Language Dictionary {{{2
let s:langs = { 'java'      : 'Java',
            \   'python'    : 'Python',
            \   'cpp'       : 'C++',
            \   'ruby'      : 'Ruby',
            \   'cs'        : 'C#',
            \   'c'         : 'C',
            \   'vim'       : 'Vimscript'
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
            \       'gradle'    : 'build.gradle'
            \}

" Commands {{{1
" factorus#version {{{2
function! factorus#version()
    echo 'Factorus: version ' . g:factorus_version
endfunction

" factorus#rebuild {{{2
function! factorus#rebuild(...)
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
        let a:file = split(system('find ' . getcwd() . a:path_find . ' -name "' . a:file_find . '"'),'\n')[0]
    catch /.*/
        execute 'cd ' . a:prev_dir
        throw 'Factorus:' . v:exception
    endtry

    let a:build_dir = substitute(a:file,a:strip_dir,'\1','')
    execute 'cd ' . a:build_dir

    let a:build_task = a:0 > 0 ? a:1 : g:factorus_build_task
    let a:command = g:factorus_build_program . ' ' . a:build_task . ' ' . g:factorus_build_options
    echo 'Running ' . a:command
    let a:res = split(system(a:command),'\n')

    echo 'Build Output:'
    for line in a:res
        echo line
    endfor

    execute 'cd ' . a:prev_dir
endfunction

" factorus#command {{{2
function! factorus#command(func,...)
    let a:ext = &filetype
    let [a:res,a:err] = ['','']
    let a:file = expand('%:p')

    let a:pos = [line('.'),col('.')]
    if a:0 == 0 || a:000[-1] != 'factorusRollback'
        let g:factorus_history = {'file' : a:file, 'function' : a:func, 'pos' : copy(a:pos), 'args' : a:000}
    endif

    let a:open_bufs = []
    let a:buf_nrs = []
    for buf in getbufinfo()
        call add(a:open_bufs,buf['name'])
        call add(a:buf_nrs,buf['bufnr'])
    endfor
    let a:curr_buf = a:buf_nrs[index(a:open_bufs,expand('%:p'))]
    let a:buf_setting = &switchbuf

    try
        let Func = function(a:ext . '#factorus#' . a:func,a:000)
        let a:res = Func()
        let a:file = expand('%:p')
        if a:0 == 0 || a:000[-1] != 'factorusRollback'
            if g:factorus_show_changes > 0 && a:func == 'renameSomething'
                copen
            endif

            if g:factorus_validate == 1
                redraw
                echo 'Validating changes...'
                call factorus#rebuild()
            endif
        endif
    catch /.*/
        for buf in getbufinfo()
            if index(a:open_bufs,buf['name']) < 0
                execute 'bwipeout ' . buf['bufnr']
            endif
        endfor

        if a:func == 'renameSomething' && (a:0 == 0 || a:000[-1] != 'factorusRollback')
            call factorus#rollback()
        endif

        if match(v:exception,'^Vim(\a\+):E117:') >= 0
            if match(v:exception,'\<' . a:func . '\>') >= 0
                let a:lang = index(keys(s:langs),a:ext) >= 0 ? s:langs[a:ext] : 'this language'
                let a:name = a:func == 'renameSomething' ? 'rename' . a:000[-1] : a:func
                let a:err = 'Factorus: ' . a:name . ' is not available for ' . a:lang . '.'
            else
                let a:err = 'Factorus: ' . v:exception
            endif
        elseif match(v:exception,'^Factorus:') >= 0
            let a:custom = index(keys(s:errors),join(split(v:exception,':')[1:]))
            if a:custom >= 0
                let a:err = 'Factorus: ' . s:errors[split(v:exception,':')[1]]
            else
                let a:err = 'Factorus: ' . v:exception
            endif
        else
            let a:err = 'An unexpected error has occurred: ' . v:exception . ', at ' . v:throwpoint
        endif
    endtry

    redraw
    if a:err != ''
        let a:res = a:err
        if (a:0 == 0 || a:000[-1] != 'factorusRollback')
            echo a:err
        endif
    endif

    let g:factorus_history = {'file' : a:file, 'function' : a:func, 'pos' : copy(a:pos), 'args' : a:000, 'old' : a:res}
    return a:res
endfunction

" factorus#rollback {{{2
function! factorus#rollback()
    if !exists('g:factorus_history') || len(g:factorus_history['old']) == 0
        echo 'Nothing to roll back.'
        return
    endif
    echo 'Rolling back previous action...'

    let a:curr = expand('%:p')
    if a:curr != g:factorus_history['file']
        execute 'silent tabedit ' . g:factorus_history['file']
    endif
    call cursor(g:factorus_history['pos'][0],g:factorus_history['pos'][1])

    let a:func = g:factorus_history['function']
    let a:old = g:factorus_history['old']

    if a:func == 'addParam'
        let a:echo = factorus#command('addParam',a:old,a:old,'factorusRollback')
    elseif a:func == 'renameSomething'
        let a:echo = factorus#command('renameSomething',a:old,g:factorus_history['args'][-1],'factorusRollback')
    else
        let a:echo = factorus#command(a:func,'factorusRollback')
    endif
    let g:factorus_history['old'] = ''

    if a:curr != g:factorus_history['file'] && (g:factorus_history['function'] != 'renameSomething' || g:factorus_history['args'][-2] != 'Class')
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
