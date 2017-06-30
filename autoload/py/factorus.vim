" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

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
function! s:getAdjacentTag(dir)
    return searchpos(s:function_def,'Wnc' . a:dir)
endfunction

function! s:getClassTag()
    let a:res = searchpos(s:class_def,'Wnbc')
    if a:res == [0,0]
        return a:res
    endif
    let a:close = py#factorus#getClosingIndent(0)
    let a:orig = [line('.'),col('.')]
    call cursor(a:res[0],a:res[1])
    let a:class_close = py#factorus#getClosingIndent(1)
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

function! py#factorus#getClosingIndent(stack)
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

function! s:getNextDec(...)
    if a:0 == 0
    elseif a:0 == 1
        let a:get_variable = '^[[:space:]>]*\(' . s:python_identifier . '\)\s*=\s*\(' . a:1 . '\).*'
        let a:index = '\1'
    else
    endif

    let a:line = line('.')
    let a:col = col('.')

    let a:match = searchpos(a:get_variable,'Wn')
    if a:0 == 0
        while a:match != [0,0] && match(getline(a:match[0]),'\<return\>') >= 0
            call cursor(a:match[0],a:match[1])
            let a:match = searchpos(a:get_variable,'Wn')
        endwhile
        call cursor(a:line,a:col)
    endif

    if s:isBefore([a:line,a:col],a:match) == 1
        let a:var = substitute(getline(a:match[0]),a:get_variable,a:index,'')
        return [a:var,a:match]
    endif

    return ['none',[0,0]]

endfunction

function! s:jumpToNearest(vars,next,paren) abort
    let a:start = [line('.'),col('.')]
    let [a:min,a:jump,a:add] = a:next[1][0] > 0 ? [a:next[1],a:next[0],1] : [[line('$'),1000], 'none' ,1]
    let a:count = len(a:vars) - 1

    while a:count >= 0
        let a:var = a:vars[a:count]
        let a:search = '^\s*[^/*]*' . a:var[0] . a:paren
        let a:match = searchpos(a:search,'Wn') 
        if s:isBefore(a:var[1],a:match) == 1
            call remove(a:vars,a:count)
        elseif a:match != [0,0] && s:isBefore(a:match,a:min)
            let a:add = 0
            let a:min = copy(a:match)
            let a:jump = a:var[0]
        endif
        let a:count -= 1
    endwhile

    call cursor(a:min[0],a:min[1])

    return [a:jump,a:add]
endfunction

" File-Updating Functions {{{2

function! s:getSuperClasses()
    let a:class_tag = s:getClassTag()
    let a:class_name = expand('%:t:r')
    let a:super_search = '.*\s' . a:class_name . '\s\+' . s:sub_class . '\s\+\<\(' . s:factorus_java_identifier . '\)\>.*{.*'
    let a:sups = [expand('%:p')]

    let a:imp = match(getline(a:class_tag),'\s' . s:sub_class . '\s')
    if a:imp < 0
        return a:sups
    endif
    let a:super = substitute(getline(a:class_tag),a:super_search,'\2','')

    let a:possibles = split(system('find -name "' . a:super . '.java"'),'\n')
    for poss in a:possibles
        execute 'silent tabedit ' poss
        let a:sups += s:getSuperClasses()
        bdelete
    endfor

    return a:sups
endfunction

function! s:getSubClasses(class_name)
    let a:sub_file = '.' . a:class_name . '.Subs'
    let a:temp_file = '.' . a:class_name . 'E'

    let a:search = s:sub_class . '.*\<' . a:class_name . '\>'
    call s:findTags(a:temp_file, a:search, 'no')
    call system('> ' . a:sub_file)

    let a:sub = readfile(a:temp_file)

    while a:sub != []
        call system('cat ' . a:temp_file . ' >> ' . a:sub_file)
        let a:sub_classes = '\(' . join(map(a:sub,{n,file -> substitute(file,s:strip_dir . '\.py','\2','')}),'\|') . '\)'
        let a:search = s:sub_class . '.*\<' . a:sub_classes . '\>'
        call s:findTags(a:temp_file, a:search, 'no')
        let a:sub = readfile(a:temp_file)
    endwhile
    let a:sub = readfile(a:sub_file)

    call system('rm -rf ' . a:sub_file)
    call system('rm -rf ' . a:temp_file)
    return a:sub
endfunction

function! s:updateClassFile(class_name,old_name,new_name) abort
    let a:prev = [line('.'),col('.')]
    call cursor(1,1)
    let a:restricted = 0
    let a:here = line('.')

    let a:search = ['\([^.]\|\<this\>\.\)\<\(' . a:old_name . '\)\>' , '\(\<this\>\.\)\<\(' . a:old_name . '\)\>']

    let [a:dec,a:next] = s:getNextDec(a:class_name,a:old_name)
    if a:next[0] == 0
        let a:next = line('$')
    endif

    let a:rep = searchpos(a:search[a:restricted],'Wn')
    while a:rep != [0,0]

        if a:rep[0] >= a:next[0]
            call cursor(a:next[0],1)
            let a:restricted = 1 - a:restricted
            if a:restricted == 1
                let a:next = s:getNextTag()
            else
                let [a:dec,a:next] = s:getNextDec(a:class_name,a:old_name)
                if a:next[0] == 0
                    let a:next = [line('$'),1]
                endif
            endif
        else
            call cursor(a:rep[0],1)
            execute 's/' . a:search[a:restricted] . '/\1' . a:new_name . '/g'
        endif

        let a:here = line('.')
        let a:rep = searchpos(a:search[a:restricted],'Wn')
        if a:rep == [0,0]
            call cursor(a:next[0],1)
            let a:rep = searchpos(a:search[1-a:restricted],'Wn')
        endif

    endwhile
    call cursor(a:prev[0],a:prev[1])

    silent write
endfunction

function! s:updateDeclaration(method_name,new_name)
    let a:orig = [line('.'),col('.')]
    call cursor(1,1)

    let a:prev = [line('.'),col('.')]
    let a:next = searchpos('^\s*def\s*\(\<' . a:method_name . '\>\)\s*(.*'

    while a:next[0] != a:prev[0]
        call cursor(a:next[0],a:next[1])
        let a:prev = [line('.'),col('.')]
        let a:next = searchpos('^\s*def\s*\(\<' . a:method_name . '\>\)\s*(.*'
        let a:match = match(getline('.'),'\<' . a:method_name . '\>')
        if a:match < 0
            continue
        endif
        execute 's/\<' . a:method_name . '\>/' . a:new_name . '/'
    endwhile
    silent write

    call cursor(a:orig[0],a:orig[1])
endfunction

function! s:updateSubClassFiles(class_name,old_name,new_name,paren,is_global)

    let a:subs = s:getSubClasses(a:class_name)
    let a:is_method = a:paren == '(' ? 1 : 0
    let a:modules = {s:getModule(expand('%:p')) : [expand('%:p')]}

    for file in a:subs

        let a:sub_module = s:getModule(file)
        if index(keys(a:modules), a:sub_module) < 0
            let a:modules[a:sub_module] = [file]
        else
            let a:modules[a:sub_module] = a:modules[a:sub_module] + [file]
        endif

        execute 'silent tabedit ' . file
        if a:is_global == 1 || a:paren == '('
            call s:updateFile(a:old_name,a:new_name,a:is_method,0,a:is_global)
            if a:paren == '('
                call s:updateDeclaration(a:old_name,a:new_name)
            endif
        else
            call s:updateClassFile(a:sub_class,a:old_name,a:new_name)
        endif

        bdelete
    endfor
    silent edit

    return a:modules
endfunction

function! s:getImports(module,name)
    let a:from = 'from\s*' . a:module . '\s*import'
    let a:import = 'import\s*' . a:module
    let a:import_use = a:module . '\.' . a:name

    let a:temp_file = '.' . a:name . 'Imports'
    call s:findTags(a:temp_file,a:import,'no')
    call s:narrowTags(a:temp_file,a:import_use)
    call s:findTags(a:temp_file,a:from,'yes')
    call s:narrowTags(a:temp_file,'\<' . a:name . '\>')

    let a:res = readfile(a:temp_file)
    call system('rm -rf ' . a:temp_file)
    return a:res
endfunction

function! s:getAllImports(module,name)
    let a:res = []
    let a:temp = s:getImports(a:module,a:name)

    while a:temp != []
        let a:res += a:temp
        call uniq(a:res)
        let a:cycle = []
        for file in a:temp
            let a:next_module = s:getModule(file)
            for tfile in s:getImports(a:next_module,a:name)
                if index(a:res,tfile) < 0
                    call add(a:cycle,tfile)
                endif
            endfor
        endfor
        let a:temp = uniq(a:cycle)
    endwhile

    return a:res
endfunction

function! s:updateImports(module,name,new_name)
    let a:curr_file = expand('%:p')
    let a:imports = s:getAllImports(a:module,a:name)

    for file in a:imports
        let a:next_module = s:getModule(file)
        execute 'silent tabedit ' . file
        execute '%s/\(from\s*' . a:next_module .'\s*import\_.\{-\}\)' . a:name . '\(.*\)/\1' . a:new_name . '\2/ge'
        silent write
        if file == a:curr_file
            q
        else
            bdelete
        endif
    endfor

    return {a:module : a:imports}
endfunction

function! s:updateNonLocalFiles(modules,class_name,old_name,new_name,paren,is_global)
    let a:temp_file = '.NonLocal'

    let a:base_file = expand('%:p')
    for file in a:modules
            execute 'silent tabedit ' . file
            if a:is_global == 1
                let a:search = '\<' . a:old_name . '\>' . a:paren
                execute 'silent %s/\([^.]\)' . a:search . '/\1' . a:new_name . a:paren . '/ge'
            else
                call s:updateMethodFile(a:class_name,a:old_name,a:new_name,a:paren)
            endif
            silent write

            if file == a:base_file
                q
            else
                bdelete
            endif
    endfor
   
    call system('rm -rf ' . a:temp_file)
endfunction

function! s:updateMethodFile(class_name,method_name,new_name,paren) abort
    let a:vars = []
    let a:here = line('.')
    let a:next = s:getNextDec(a:class_name)

    while a:here < line('$')
        let [a:jump,a:add] = s:jumpToNearest(a:vars,a:next,a:paren)

        if line('.') == a:here
            break
        elseif a:add == 1
            call add(a:vars,[a:next[0] . '\.' . a:method_name,py#factorus#getClosingIndent(0)])
            let a:next = s:getNextDec(a:class_name)
        else
            let a:rep = substitute(a:jump,'\.' . a:method_name,'.' . a:new_name,'')
            execute 's/\(\s\=!\=\s\=\)' . a:jump . '\s*' . a:paren . '/\1' . a:rep . a:paren . '/g'
        endif
        let a:here = line('.')
    endwhile
    let a:dec_rep = '\(\(' . a:class_name . '\)\s*(.*)\.\)' . a:method_name . a:paren
    execute '%s/' . a:dec_rep . '/\1' . a:new_name . a:paren . '/ge'
    silent write
endfunction

function! s:updateFile(old_name,new_name,is_method,is_local,is_global)
    let a:orig = line('.')

    if a:is_local == 1
        let a:query = '\([^.]\)\<' . a:old_name . '\>'
        execute 's/' . a:query . '/\1' . a:new_name . '/g'

        call s:gotoTag(0)
        let a:closing = py#factorus#getClosingIndent(1)

        let a:next = searchpos(a:query,'Wn')
        while s:isBefore(a:next,a:closing)
            if a:next == [0,0]
                break
            endif
            call cursor(a:next[0],a:next[1])
            execute 's/' . a:query . '/\1' . a:new_name . '/g'

            let a:next = searchpos(a:query,'Wn')
        endwhile
    else
        let a:paren = a:is_method == 1 ? '(' : ''
        execute 'silent %s/\([^.]\)\<' . a:old_name . '\>' . a:paren . '/\1' . a:new_name . a:paren . '/ge'
    endif

    call cursor(a:orig,1)
    silent write
endfunction

" Global Functions {{{1

" Insertion Functions {{{2

function! py#factorus#addParam(param_name)

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

"NOTE: This is dangerous, because it renames all instances of the method
"everywhere to new_name.  Python's lack of strict typing make it nearly
"impossible to accurately do this, so the function does a clean sweep through
"the whole project.
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
                execute a:find[0] . ',' . a:end[0] . 's/\<' . a:method_name . '\>/' . a:new_name . '/e'
                let a:find = searchpos('from.*import\_[^:)]\{-\}\<' . a:keyword . '\>','W')
                let a:end = searchpos('\<' . a:method_name . '\>','Wne')
            endwhile
            silent write
            if expand('%:p') == a:file_name
                q
            else
                bdelete
            endif
    endfor
    call system('rm -rf ' . a:temp_file)

    redraw
    let a:keyword = a:is_global == 1 ? ' global' : ''
    echo 'Re-named' . a:keyword . ' method ' . a:method_name . ' to ' . a:new_name
endfunction

function! py#factorus#renameSomething(new_name,type)
    let a:prev_dir = getcwd()
    execute 'cd ' . expand('%:p:h')
    "let a:project_dir = g:factorus_project_dir == '' ? system('git rev-parse --show-toplevel') : g:factorus_project_dir
    let a:project_dir = system('git rev-parse --show-toplevel')
    execute 'cd ' a:project_dir

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
        execute 'cd ' a:prev_dir
    endtry
endfunction

" Extraction Functions {{{2

function! py#factorus#extractMethod()

endfunction
