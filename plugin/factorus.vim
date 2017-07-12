" =============================================================================
" File: factorus.vim
" Description: Vim plugin for automated refactoring
" =============================================================================

" Helper Functions {{{1

let s:opts = {
            \   'version'               : '1.875',
            \   'project_dir'           : '',
            \   'min_extracted_lines'   : 2,
            \   'method_name'           : 'newFactorusMethod',
            \   'method_threshold'      : 0.9,
            \   'extract_heuristic'     : 'longest',
            \   'split_lines'           : 1,
            \   'line_length'           : 125,
            \   'show_changes'          : 0
            \ }

function! s:init_var(var,val)
    if !exists('g:factorus_' . a:var)
        execute 'let g:factorus_' . a:var . ' = ' . string(a:val)
    endif
endfunction

function! s:init_vars()
    for var in keys(s:opts)
        call s:init_var(var,s:opts[var])
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

" Initialization {{{1

if &cp || exists('g:loaded_factorus')
    finish
endif

if v:version < 700
    echohl WarningMsg
    echom 'Factorus: Vim version is too old, please upgrade to 7.0 or later.'
    echohl None
    finish
endif

call s:init_vars()

" Commands {{{1

command! -nargs=0 Factorus          call factorus#version()

command! -nargs=0 FExtractMethod    call factorus#command('extractMethod')

command! -nargs=1 FRenameArg        call factorus#command('renameSomething', <f-args>, 'Arg')
command! -nargs=1 FRenameClass      call factorus#command('renameSomething', <f-args>, 'Class')
command! -nargs=1 FRenameMethod     call factorus#command('renameSomething', <f-args>, 'Method')
command! -nargs=1 FRenameField      call factorus#command('renameSomething', <f-args>, 'Field') 

command! -nargs=0 FEncapsulate      call factorus#command('encapsulateField')
command! -nargs=+ FAddParam         call factorus#command('addParam', <f-args>)  

command! -nargs=0 FRollback         call factorus#rollback()

" Modeline {{{1
" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1
