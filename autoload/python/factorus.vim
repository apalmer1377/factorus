" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

" Search Constants {{{1

let s:start_chars = '[_A-Za-z]'
let s:search_chars = '[_0-9A-Za-z]*'
let s:python_identifier = s:start_chars . s:search_chars

let s:function_def = 'def\s*' . s:python_identifier . '\s*('
let s:class_def = 'class\s*' . s:python_identifier . '\s*[(:]'

" Script-Defined Functions {{{1


" Global Functions {{{1

" Renaming Function {{{2

function! python#factorus#renameMethod(new_name)
    
endfunction
