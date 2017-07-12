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
let s:errors = {'Invalid'       : 'Invalid expression under cursor.',
            \   'Duplicate'     : 'New name is same as old name.',
            \   'NoLines'       : 'Nothing to extract.',
            \   'EncapStatic'   : 'Cannot encapsulate a static variable.',
            \   'EncapLocal'    : 'Cannot encapsulate a local variable.'
            \  }

" Commands {{{1
" factorus#command {{{2
function! factorus#command(func,...)
    let a:ext = &filetype
    let [a:res,a:err] = ['','']
    let a:file = expand('%:p')

    let a:pos = [line('.'),col('.')]
    try
        let Func = function(a:ext . '#factorus#' . a:func,a:000)
        let a:res = Func()
        let a:file = expand('%:p')
        if g:factorus_show_changes > 0 && a:func == 'renameSomething' && index(a:000,'factorusRollback') < 0 && a:000[-1] != 'Arg'
            copen
        endif
    catch /^Vim(\a\+):E117:/
        if match(v:exception,'\<' . a:func . '\>') >= 0
            let a:lang = index(keys(s:langs),a:ext) >= 0 ? s:langs[a:ext] : 'this language'
            let a:name = a:func == 'renameSomething' ? 'rename' . a:000[-1] : a:func
            let a:err = 'Factorus: ' . a:name . ' is not available for ' . a:lang . '.'
        else
            let a:err = v:exception
        endif
    catch /^Factorus:/
        let a:custom = index(keys(s:errors),join(split(v:exception,':')[1:]))
        if a:custom >= 0
            let a:err = 'Factorus: ' . s:errors[split(v:exception,':')[1]]
        else
            let a:err = 'Factorus: ' . v:exception
        endif
    catch /.*/
        let a:err = 'An unexpected error has occurred: ' . v:exception . ', at ' . v:throwpoint
    endtry

    redraw
    if a:err != ''
        echo a:err
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
        call factorus#command('renameSomething',a:old,g:factorus_history['args'][-1],'factorusRollback')
        let a:echo = 'Rolled back renaming of ' . substitute(g:factorus_history['args'][-2],'\(.\)\(.*\)','\L\1\E\2','') . ' ' . a:old
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
