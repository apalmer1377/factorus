" =============================================================================
" File: factorus.vim
" Description: Vim plugin for refactoring
"
" =============================================================================
"

function! s:init(var,val)
    if !exists('g:factorus_' . a:var)
        execute 'let g:factorus_' . a:var . ' = ' . string(a:val)
    endif
endfunction

function! s:init_vars()
    let a:vars = [
        \ [ 'project_dir' , '' ],
        \ [ 'ignored_files' , [ 'tags' , 'cscope.out' , '.*swp' ] ]
    \ ]

    for [var,val] in a:vars
        call s:init(var,val)
    endfor
endfunction
call s:init_vars()

command! -nargs=0 FactorusCurrentTag    call factorus#gotoTag(0)
command! -nargs=1 FactorusClass         call factorus#refactorThis(<f-args>,'class')
command! -nargs=1 FactorusMethod        call factorus#refactorThis(<f-args>,'method')
command! -nargs=1 FactorusField         call factorus#refactorThis(<f-args>,'field') 
command! -nargs=0 FactorusGetSet        call factorus#encapsulateField()
