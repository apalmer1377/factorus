" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8
source factorus.vim

" Search Constants {{{1

" Local Functions {{{1

" get_object_attributes {{{3

" Gets the attributes of an object to be renamed, in the form of a dictionary.
" Which attributes get returned depends on a:type.
function! s:get_object_attributes(type)
    let l:attributes = {}
    " Get the definition of the object, its name, whether or not it's local or
    " static, etc.
    return l:attributes
endfunction

" get_referring_files {{{3

" Gets any files that may refer to a:object. These files will be updated in
" update_referring_files. 
function! s:get_referring_files(object)
    let l:files = []
    " Find files that make reference to the object by name.
    return l:files
endfunction

" update_referring_files {{{3

" Updates all references to a:object in a:files.
function! s:update_referring_files(object, files)

    return l:res
endfunction

" Global Functions {{{1
" rename_something {{{2

" Renames some object of type a:type to a:new_name.
function! factorus#rename_something(new_name, type, ...)
    let [l:orig, l:prev_dir, l:curr_buf] = set_environment()

    try
        if IsRollback(a:000)
            " Roll back previous rename command.
            let l:res = rollback_rename(a:new_name, a:type)
            let g:factorus_qf = []
        else
            " Rename desired thing.
            let g:factorus_qf = []

            let l:object = s:get_object_attributes(a:type)
            let l:files = s:get_referring_files(l:object)
            let l:res = s:update_referring_files(l:object, l:files)

            if g:factorus_show_changes > 0
                call set_changes(l:res, 'rename', a:type)
            endif
        endif
    catch /.*/
        " Reset environment and abort.
        call reset_environment(l:orig, l:prev_dir, l:curr_buf, a:type)
        let l:err = match(v:exception, '^Factorus:') >= 0 ? v:exception : 'Factorus:' . v:exception
        throw l:err . ', at ' . v:throwpoint
    endtry
endfunction

" extractMethod {{{2
function! factorus#extract_method()

endfunction
