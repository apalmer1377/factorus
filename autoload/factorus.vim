" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" Initialization {{{1

" Dictionary of filetypes to languages for messaging
let s:langs = {'java' : 'Java',
            \  'py'   : 'Python',
            \  'vim'  : 'Vimscript',
            \  'c'    : 'C',
            \  'cpp'  : 'C++'
            \ }
if exists(':Factorus') == 0
    runtime plugin/factorus.vim
endif

function! factorus#command(func,...)
    let a:ext = expand('%:e')

    try
        let Func = function(a:ext . '#factorus#' . a:func,a:000)
        call Func()
    catch /.*Unknown.*/
        let a:lang = index(keys(s:langs),a:ext) >= 0 ? s:langs[a:ext] : 'this language'
        let a:name = a:func
        if a:func == 'renameSomething'
            if a:000[-1] == 'class'
                let a:name = 'renameClass'
            elseif a:000[-1] == 'method'
                let a:name = 'renameMethod'
            elseif a:000[-1] == 'field'
                let a:name = 'renameField'
            elseif a:000[-1] == 'arg'
                let a:name = 'renameArg'
            endif
        endif

        echo 'Factorus: ' . a:name . ' is not available for ' . a:lang . '.'
    endtry
endfunction
