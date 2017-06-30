" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" Search Constants {{{1

let s:start_chars = '[_A-Za-z]'
let s:search_chars = '[_0-9A-Za-z]*'
let s:python_identifier = s:start_chars . s:search_chars

let s:function_def = '^\s*def\s*\<\(' . s:python_identifier . '\)\>\s*(.*'
let s:class_def = '^\s*class\s*\(' . s:python_identifier . '\)\s*[(:].*'
let s:sub_class = '^\s*class\s*\(' . s:python_identifier . '\)\s*('
let s:strip_dir = '\(.*\/\)\=\(.*\)'


" Script-Defined Functions {{{1

" General Functions {{{2

function! s:safeClose(file)
    if index(s:open_bufs,a:file) < 0 
        bdelete
    else
        q
    endif
endfunction

function! s:getAdjacentTag(dir)
    return searchpos(s:function_def,'Wnc' . a:dir)
endfunction

function! s:getClassTag()
    let a:res = searchpos(s:class_def,'Wnbc')
    if a:res == [0,0]
        return a:res
    endif
    let a:close = s:getClosingIndent(0)
    let a:orig = [line('.'),col('.')]
    call cursor(a:res[0],a:res[1])
    let a:class_close = s:getClosingIndent(1)
    if s:isBefore(a:class_close,a:close) == 1
        let a:res = [0,0]
    endif
    call cursor(a:orig[0],a:orig[1])
    return a:res
endfunction

function! s:isBefore(x,y)
    if a:x[0] < a:y[0] || (a:x[0] == a:y[0] && a:x[1] < a:y[1])
        return 1
    endif
    return 0
endfunction

function! s:gotoTag(head)
    let a:tag = a:head == 1 ? s:getClassTag() : s:getAdjacentTag('b') 
    if a:tag[0] <= line('.') && a:tag != [0,0]
        call cursor(a:tag[0],a:tag[1])
    else
        echo 'No tag found'
    endif
endfunction

function! s:getClosingIndent(stack)
    let a:indent = substitute(getline('.'),'^\(\s*\)[^[:space:]].*','\1','')
    let a:l = len(a:indent) - 1
    if a:stack == 0
        if a:l < 0
            return [line('.'),col('.')]
        endif
        let a:back_line = search('^\s\{,' . a:l . '}[^[:space:]].*','Wnb')
        let a:indent = substitute(getline(a:back_line),'^\(\s*\)[^[:space:]].*','\1','')
    endif
    let a:res = searchpos('^' . a:indent . '[^[:space:]]','Wn')
    if a:res == [0,0]
        return [line('$'),1]
    endif
    return searchpos('^' . a:indent . '[^[:space:]]','Wn')
endfunction

" Tag-Related Functions {{{2

function! s:findTags(temp_file,search_string,append)
    let a:ignore = ''
    for file in g:factorus_ignored_files
        let a:ignore .= '\! -name "' . file . '" '
    endfor
    let a:fout = a:append == 'yes' ? '>>' : '>'
    call system('find ' . getcwd() . ' -name "*" \! -path "*/.git/*" \! -name ".*" ' . a:ignore . 
                \ '-exec grep -l "' . a:search_string . '" {} + ' . a:fout . ' ' . a:temp_file . ' 2> /dev/null')
endfunction

function! s:narrowTags(temp_file,search_string)
    let a:n_temp_file = a:temp_file . '.narrow'
    call system('cat ' . a:temp_file . ' | xargs grep -l "' . a:search_string . '" {} + > ' . a:n_temp_file)
    call system('mv ' . a:n_temp_file . ' ' . a:temp_file)
endfunction

" Class-Related Functions {{{2

function! s:getModule(file)
    let a:git = system('git rev-parse --show-toplevel')
    let a:module = strpart(a:file,len(a:git))
    let a:module = substitute(substitute(a:module,'\.py$','',''),'\/','.','g')
    return a:module
endfunction

" File-Updating Functions {{{2

function! s:updateFile(old_name,new_name,is_method,is_local,is_global)
    let a:orig = line('.')

    if a:is_local == 1
        let a:query = '\([^.]\)\<' . a:old_name . '\>'
        execute 'silent s/' . a:query . '/\1' . a:new_name . '/g'

        call s:gotoTag(0)
        let a:closing = s:getClosingIndent(1)

        let a:next = searchpos(a:query,'Wn')
        while s:isBefore(a:next,a:closing)
            if a:next == [0,0]
                break
            endif
            call cursor(a:next[0],a:next[1])
            execute 'silent s/' . a:query . '/\1' . a:new_name . '/g'

            let a:next = searchpos(a:query,'Wn')
        endwhile
    else
        let a:paren = a:is_method == 1 ? '(' : ''
        let a:period = a:is_global == 1 ? '\([^.]\)\{0,1\}' : '\(\.\)'

        execute 'silent %s/' . a:period . '\<' . a:old_name . '\>' . a:paren . '/\1' . a:new_name . a:paren . '/ge'
    endif

    call cursor(a:orig,1)
    silent write
endfunction

" Global Functions {{{1

" Insertion Functions {{{2

function! py#factorus#addParam(param_name,...)
    let a:orig = [line('.'),col('.')]
    call s:gotoTag(0)

    if a:0 == 0
        let a:next = searchpos('(','Wn')
        let a:line = substitute(getline(a:next[0]), '(', '(' . a:param_name . ', ', '')
    else
        let a:next = searchpos(')','Wn')
        let a:line = substitute(getline(a:next[0]), ')', ', ' . a:param_name . '=' . a:1 . ')', '')
    endif

    execute 'silent ' .  a:next[0] . 'd'
    call append(a:next[0] - 1,a:line)

    silent write
    silent edit
    call cursor(a:orig[0],a:orig[1])

    echo 'Added parameter ' . a:param_name . ' to method'
endfunction

" Renaming Functions {{{2

function! py#factorus#renameArg(new_name)
    let a:var = expand('<cword>')
    call s:updateFile(a:var,a:new_name,0,1,0)

    echo 'Re-named ' . a:var . ' to ' . a:new_name
endfunction

function! py#factorus#renameClass(new_name) abort
    let a:class_line = s:getClassTag()[0]
    let a:class_name = substitute(getline(a:class_line),s:class_def,'\1','')
    if a:class_name == a:new_name
        throw 'DUPLICATE'
    endif    

    let a:module_name = s:getModule(expand('%:p'))

    let a:temp_file = '.' . a:class_name
    let a:module_name = substitute(a:module_name,'\.','\\.','g')
    let a:module_name = substitute(a:module_name,'\(.*\)\(\\\..*\)','\\(\1\\)\\{0,1\\}\2','')
    call s:findTags(a:temp_file,a:class_name,'no')

    call system('cat ' . a:temp_file . ' | xargs sed -i "s/\<' . a:class_name . '\>/' . a:new_name . '/g"') 
    call system('rm -rf ' . a:temp_file
    silent edit

    echo 'Re-named class ' . a:class_name . ' to ' . a:new_name
endfunction

function! py#factorus#renameMethod(new_name)
    call s:gotoTag(0)
    let a:class = s:getClassTag()

    let a:method_name = substitute(getline('.'),s:function_def,'\1','')
    if a:method_name == a:new_name
        throw 'DUPLICATE'
    endif

    let a:is_global = a:class == [0,0] ? 1 : 0
    let a:class_name = a:class == [0,0] ? '' : substitute(getline(a:class[0]),s:class_def,'\1','')

    call s:updateFile(a:method_name,a:new_name,1,0,a:is_global)

    let a:keyword = a:is_global == 1 ? a:method_name : '\(' . a:class_name . '\|' . a:method_name . '\)'
    let a:period = a:is_global == 1 ? '\([^.]\)\{0,1\}' : '\(\.\)'

    let a:file_name = expand('%:p')
    let a:temp_file = '.' . a:method_name
    call s:findTags(a:temp_file,a:method_name,'no')
    call system('cat ' . a:temp_file . ' | xargs sed -i "s/' . a:period . '\<' . a:method_name . '\>/\1' . a:new_name . '/g"')

    call s:findTags(a:temp_file,a:method_name,'no')
    for file in readfile(a:temp_file)
            execute 'silent tabedit ' . file
            let a:find =  searchpos('from.*import\_[^:)]\{-\}\<' . a:keyword. '\>','Wc')
            let a:end = searchpos('\<' . a:method_name . '\>','Wne')
            while  a:find != [0,0]
                execute 'silent ' . a:find[0] . ',' . a:end[0] . 's/\<' . a:method_name . '\>/' . a:new_name . '/e'
                let a:find = searchpos('from.*import\_[^:)]\{-\}\<' . a:keyword . '\>','W')
                let a:end = searchpos('\<' . a:method_name . '\>','Wne')
            endwhile
            silent write
            call s:safeClose(file)
    endfor
    call system('rm -rf ' . a:temp_file)

    redraw
    let a:keyword = a:is_global == 1 ? ' global' : ''
    echo 'Re-named' . a:keyword . ' method ' . a:method_name . ' to ' . a:new_name
endfunction

function! py#factorus#renameSomething(new_name,type)
    let a:prev_dir = getcwd()
    let s:open_bufs = []
    for buf in getbufinfo()
        call add(s:open_bufs,buf['name'])
    endfor
    let a:curr_buf = index(s:open_bufs,expand('%:p'))
    let a:buf_setting = &switchbuf 

    execute 'silent cd ' . expand('%:p:h')
    "let a:project_dir = g:factorus_project_dir == '' ? system('git rev-parse --show-toplevel') : g:factorus_project_dir
    let a:project_dir = system('git rev-parse --show-toplevel')
    execute 'silent cd ' a:project_dir

    try
        if a:type == 'class'
            call py#factorus#renameClass(a:new_name)
        elseif a:type == 'method' 
            call py#factorus#renameMethod(a:new_name)
        elseif a:type == 'field'
            call py#factorus#renameField(a:new_name)
        elseif a:type == 'arg'
            call py#factorus#renameArg(a:new_name)
        else
            echo 'Unknown option ' . a:type
        endif
    catch /.*INVALID.*/
        echo 'Factorus: Invalid expression under cursor'
    catch /.*DUPLICATE.*/
        echo 'Factorus: New name is the same as old name'
    catch /.*/
        throw 'Unknown function'
    finally
        execute 'silent cd ' a:prev_dir
        let &switchbuf = 'useopen,usetab'
        execute 'silent sbuffer ' . a:curr_buf
        let &switchbuf = a:buf_setting
    endtry

endfunction

" Extraction Functions {{{2

function! py#factorus#extractMethod()

endfunction
