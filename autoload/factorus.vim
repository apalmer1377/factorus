" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" Initialization {{{1

if exists(':Factorus') == 0
    runtime plugin/factorus.vim
endif

function! factorus#command(func,...)
    let a:ext = expand('%:e')

    let Func = function(a:ext . '#factorus#' . a:func,a:000)
    call Func()
endfunction
