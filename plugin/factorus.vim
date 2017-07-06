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

    let a:ignore_defaults = ['.Factorus*', 'tags', 'cscope.out', '.*.sw*', '*.pyc']
    if !exists('g:factorus_ignored_files')
        let g:factorus_ignored_files = a:ignore_defaults
    else
        let g:factorus_ignored_files += a:ignore_defaults
        let g:factorus_ignored_files =  filter(g:factorus_ignored_files, 'index(g:factorus_ignored_files, v:val, v:key+1) == -1')
    endif

    let a:ignore_dir_defaults = ['.git']
    if !exists('g:factorus_ignored_dirs')
        let g:factorus_ignored_dirs = a:ignore_dir_defaults
    else
        let g:factorus_ignored_dirs += a:ignore_dir_defaults
        call filter(g:factorus_ignored_dirs, 'index(g:factorus_ignored_dirs, v:val, v:key+1)==-1')
    endif

    let g:factorus_ignore_string = ' '

    for dir in g:factorus_ignored_dirs
        let g:factorus_ignore_string .= '\! -path "*/' . dir . '/*" '
    endfor

    for file in g:factorus_ignored_files
        let g:factorus_ignore_string .= '\! -name "' . file . '" '
    endfor
    let g:factorus_ignore_string = substitute(g:factorus_ignore_string,'\/\/','/','g')
endfunction
call s:init_vars()

command! -nargs=0 FExtractMethod    call factorus#command('extractMethod')

command! -nargs=1 FRenameArg        call factorus#command('renameSomething', <f-args>, 'Arg')
command! -nargs=1 FRenameClass      call factorus#command('renameSomething', <f-args>, 'Class')
command! -nargs=1 FRenameMethod     call factorus#command('renameSomething', <f-args>, 'Method')
command! -nargs=1 FRenameField      call factorus#command('renameSomething', <f-args>, 'Field') 

command! -nargs=0 FEncapsulate      call factorus#command('encapsulateField')
command! -nargs=+ FAddParam         call factorus#command('addParam', <f-args>)  

command! -nargs=0 FRollback         call factorus#rollback()
