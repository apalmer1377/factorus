" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" Initialization {{{1

" Dictionary of filetypes to languages for messaging
let s:langs = {'java' : 'java',
            \  'py'   : 'python',
            \  'vim'  : 'vimscript',
            \  'c'    : 'C',
            \  'cpp'  : 'C++'
            \ }
if exists(':Factorus') == 0
    runtime plugin/factorus.vim
endif

function! factorus#command(func,...)
    let a:ext = expand('%:e')

    try
        let Func = function(s:langs[a:ext] . '#factorus#' . a:func,a:000)
        call Func()
    catch /.*\(Unknown\|not present\).*/
        let a:lang = index(keys(s:langs),a:ext) >= 0 ? s:langs[a:ext] : 'this language'
        echo 'Factorus: ' . a:func . ' is not available for ' . a:lang . '.'
    endtry
endfunction
