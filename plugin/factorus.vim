" =============================================================================
" File: factorus.vim
" Description: Vim plugin for automated refactoring
" =============================================================================

function! s:init(var,val)
    if !exists('g:factorus_' . a:var)
        execute 'let g:factorus_' . a:var . ' = ' . string(a:val)
    endif
endfunction

function! s:init_vars()
    let a:vars = [
        \ [ 'project_dir' , '' ],
        \ [ 'min_extracted_lines' , 2 ],
        \ [ 'method_name' , 'newFactorusMethod' ],
        \ [ 'method_threshold' , 0.9 ],
        \ [ 'extract_heuristic' , 'longest' ],
        \ [ 'split_lines' , 1 ],
        \ [ 'line_length' , 125 ]
    \ ]

    for [var,val] in a:vars
        call s:init(var,val)
    endfor

    let a:ignore_defaults = ['tags', 'cscope.out','*.pyc']
    if !exists('g:factorus_ignored_files')
        let g:factorus_ignored_files = a:ignore_defaults
    else
        let g:factorus_ignored_files += a:ignore_defaults
    endif
endfunction
call s:init_vars()

command! -nargs=0 FExtractMethod    call factorus#command('extractMethod')

command! -nargs=1 FRenameArg        call factorus#command('renameSomething', <f-args>, 'arg')
command! -nargs=1 FRenameClass      call factorus#command('renameSomething', <f-args>, 'class')
command! -nargs=1 FRenameMethod     call factorus#command('renameSomething', <f-args>, 'method')
command! -nargs=1 FRenameField      call factorus#command('renameSomething', <f-args>, 'field') 

command! -nargs=0 FEncapsulate      call factorus#command('encapsulateField')
command! -nargs=+ FAddParam         call factorus#command('addParam', <f-args>)  
