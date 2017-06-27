" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

" Search Constants {{{1

let s:start_chars = '[_A-Za-z]'
let s:search_chars = '[_0-9A-Za-z]*'
let s:python_identifier = s:start_chars . s:search_chars

let s:function_def = '^\s*def\s*' . s:python_identifier . '\s*('
let s:class_def = '^\s*class\s*' . s:python_identifier . '\s*[(:]'

" Script-Defined Functions {{{1

function! s:getAdjacentTag(dir)
    return searchpos(s:function_def,'Wnc' . a:dir)
endfunction

function! s:getClassTag()
    return searchpos(s:class_def,'Wnbc')
endfunction

function! python#factorus#gotoTag(head)
    let a:tag = a:head == 1 ? s:getClassTag() : s:getAdjacentTag('b') 
    if a:tag[0] <= line('.')
        call cursor(a:tag[0],a:tag[1])
    else
        echo 'No tag found'
    endif
endfunction

" Global Functions {{{1

" Renaming Function {{{2

function! python#factorus#renameMethod(new_name)
    
endfunction
