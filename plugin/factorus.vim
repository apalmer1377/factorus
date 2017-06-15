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
        \ [ 'ignored_files' , [ 'tags' , 'cscope.out' ] ]
    \ ]

    for [var,val] in a:vars
        call s:init(var,val)
    endfor
endfunction
call s:init_vars()

command! -nargs=0 FExtractMethod    call factorus#extractMethod()

command! -nargs=1 FRenameArg        call factorus#renameSomething(<f-args>,'arg')
command! -nargs=1 FRenameClass      call factorus#renameSomething(<f-args>,'class')
command! -nargs=1 FRenameMethod     call factorus#renameSomething(<f-args>,'method')
command! -nargs=1 FRenameField      call factorus#renameSomething(<f-args>,'field') 

command! -nargs=0 FEncapsulate      call factorus#encapsulateField()
command! -nargs=+ FAddParam         call factorus#addParam(<f-args>)  
