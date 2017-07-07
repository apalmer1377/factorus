" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" Initialization {{{1

" Dictionary of filetypes to languages for messaging
let s:langs = {'java' : 'Java',
            \  'py'   : 'Python',
            \  'vim'  : 'Vimscript',
            \  'c'    : 'C',
            \  'cpp'  : 'C++',
            \  'cs'   : 'C#'
            \ }

if exists(':Factorus') == 0
    runtime plugin/factorus.vim
endif

function! factorus#command(func,...)
    let a:ext = expand('%:e')
    let a:res = ''

    try
        let Func = function(a:ext . '#factorus#' . a:func,a:000)
        let a:res = Func()
    catch /.*Unknown.*/
        redraw
        let a:lang = index(keys(s:langs),a:ext) >= 0 ? s:langs[a:ext] : 'this language'
        let a:name = a:func
        if a:func == 'renameSomething'
            let a:name = 'rename' . a:000[-1]
        endif

        echo 'Factorus: ' . a:name . ' is not available for ' . a:lang . '.'
    finally
        let g:factorus_history = {'file' : expand('%:p'), 'function' : a:func, 'pos' : [line('.'),col('.')], 'args' : a:000, 'old' : a:res}
    endtry
endfunction

function! factorus#rollback()
    if len(g:factorus_history['old']) == 0
        echo 'Nothing to roll back.
        return
    endif
    echo 'Rolling back previous action...'

    if expand('%:p') != g:factorus_history['file']
        execute 'silent tabedit ' . g:factorus_history['file']
    endif
    call cursor(g:factorus_history['pos'][0],g:factorus_history['pos'][1])

    let a:func = g:factorus_history['function']
    if a:func == 'addParam'
        call factorus#command('addParam','','','rollback')
    elseif a:func == 'renameSomething'
        let a:old = g:factorus_history['old']
        call factorus#command('renameSomething',a:old,g:factorus_history['args'][-1])
        let g:factorus_history['old'] = 0
        redraw
        echo 'Rolled back renaming of ' . substitute(g:factorus_history['args'][-1],'\(.\)\(.*\)','\L\1\E\2','') . ' ' . a:old
    else
        call factorus#command(a:func,'rollback')
    endif

    if expand('%:p') != g:factorus_history['file']
        if winnr("$") == 1 && tabpagenr("$") > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr("$")
          tabclose | tabprev
        else
          q
        endif
    endif
endfunction
