" =============================================================================
" File: factorus.vim
" Description: Vim plugin for automated refactoring
" =============================================================================

" Helper Functions {{{1

let s:opts = {
            \   'version'               : '1.96875',
            \   'project_dir'           : '',
            \   'min_extracted_lines'   : 3,
            \   'method_name'           : 'newFactorusMethod',
            \   'method_threshold'      : 0.9,
            \   'extract_heuristic'     : 'longest',
            \   'split_lines'           : 1,
            \   'line_length'           : 125,
            \   'show_changes'          : 1,
            \   'build_program'         : 'make',
            \   'build_task'            : '',
            \   'build_file'            : '',
            \   'build_options'         : '',
            \   'validate'              : 0,
            \   'default_lang'          : '',
            \   'add_default'           : 0,
            \   'qf'                    : []
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

    let l:ignore_defaults = ['.Factorus*', 'tags', 'cscope.out', '.*.sw*', '*.pyc']
    if !exists('g:factorus_ignored_files')
        let g:factorus_ignored_files = l:ignore_defaults
    else
        let g:factorus_ignored_files += l:ignore_defaults
        let g:factorus_ignored_files =  filter(g:factorus_ignored_files, 'index(g:factorus_ignored_files, v:val, v:key+1) == -1')
    endif

    let l:ignore_dir_defaults = ['.git']
    if !exists('g:factorus_ignored_dirs')
        let g:factorus_ignored_dirs = l:ignore_dir_defaults
    else
        let g:factorus_ignored_dirs += l:ignore_dir_defaults
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

if &cp || exists(':Factorus')
    finish
endif

if v:version < 700 || !has('patch-7.4.2204')
    echohl WarningMsg
    echom 'Factorus: Vim version is too old, please upgrade to 7.0 or later.'
    echohl None
    finish
endif

call s:init_vars()

" Commands {{{1

command! -nargs=0           Factorus            call factorus#version()
command! -nargs=0           FProjectDir         echo factorus#project_dir()
command! -nargs=1           FSetProjectDir      call factorus#set_project_dir()

command! -nargs=? -range=%  FExtractMethod      call factorus#command('extract_method', <line1>, <line2>, <f-args>)

command! -nargs=1           FRenameArg          call factorus#command('rename_something', <f-args>, 'Arg')
command! -nargs=1           FRenameClass        call factorus#command('rename_something', <f-args>, 'Class')
command! -nargs=1           FRenameField        call factorus#command('rename_something', <f-args>, 'Field') 
command! -nargs=1           FRenameMethod       call factorus#command('rename_something', <f-args>, 'Method')

command! -nargs=1           FRenameMacro        call factorus#command('rename_something', <f-args>, 'Macro')
command! -nargs=1           FRenameType         call factorus#command('rename_something', <f-args>, 'Type')

command! -nargs=?           FEncapsulate        call factorus#command('encapsulate_field',<f-args>)
command! -nargs=+           FAddParam           call factorus#command('add_param', <f-args>)  

command! -nargs=0           FRollback           call factorus#rollback()
command! -nargs=?           FRebuild            call factorus#rebuild(<f-args>)

" Modeline {{{1
" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1
