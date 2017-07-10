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

function! s:trim(string)
    return substitute(a:string,'\(^\s*\|\s*$\)','','g')
endfunction

function! s:isAlone()
    let a:file = expand('%:p')
    let a:count = 0
    for buf in getbufinfo()
        if buf['name'] == a:file
            if len(buf['windows']) > 1
                return 0
            endif
            return 1
        endif
    endfor
    return 1
endfunction

function! s:safeClose()
    let a:prev = 0
    if winnr("$") == 1 && tabpagenr("$") > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr("$")
        let a:prev = 1
    endif

    if index(s:open_bufs,expand('%:p')) < 0 && s:isAlone() == 1
        bwipeout
    else
        q
    endif

    if a:prev == 1
        tabprev
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
    let a:fout = a:append == 'yes' ? '>>' : '>'
    call system('find ' . getcwd() . g:factorus_ignore_string . '-exec grep -l "' . a:search_string . '" {} + ' . a:fout . ' ' . a:temp_file . ' 2> /dev/null')
endfunction

function! s:narrowTags(temp_file,search_string)
    let a:n_temp_file = a:temp_file . '.narrow'
    call system('cat ' . a:temp_file . ' | xargs grep -l "' . a:search_string . '" {} + > ' . a:n_temp_file)
    call system('mv ' . a:n_temp_file . ' ' . a:temp_file)
endfunction

function! s:addQuickFix(temp_file,search_string)
    let a:res = split(system('cat ' . a:temp_file . ' | xargs grep -n "' . a:search_string . '"'),'\n')
    call map(a:res,{n,val -> split(val,':')})
    call map(a:res,{n,val -> {'filename' : val[0], 'lnum' : val[1], 'text' : s:trim(join(val[2:],':'))}})
    let s:qf += a:res
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
        call add(s:qf,{'filename' : expand('%:p'), 'lnum' : line('.'), 'text' : s:trim(getline('.'))})
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
        let a:search = a:period . '\<' . a:old_name . '\>' . a:paren
        try
            execute 'silent lvimgrep /' . a:search . '/j %:p'
            let s:qf += map(getloclist(0),{n,val -> {'filename' : expand('%:p'), 'lnum' : val['lnum'], 'text' : s:trim(val['text'])}})
        catch /.*/
        endtry
        call setloclist(0,[])

        execute 'silent %s/' . a:search . '/\1' . a:new_name . a:paren . '/ge'
    endif

    call cursor(a:orig,1)
    silent write
endfunction

" Extraction {{{2

function! s:getArgs() abort
    let a:prev = [line('.'),col('.')]
    call s:gotoTag(0)
    let a:oparen = search('(','Wn')
    let a:cparen = search(')','Wn')
    
    let a:dec = join(getline(a:oparen,a:cparen))
    let a:dec = substitute(a:dec,'.*(\(.*\)).*','\1','')
    if a:dec == ''
        return []
    endif
    let a:args = split(a:dec,',')
    call map(a:args,{n,val -> substitute(val,'=.*$','','')})
    call filter(a:args,'match(v:val,"[''\"]") < 0')

    call cursor(a:prev[0],a:prev[1])
    return a:args
endfunction

function! s:getLocalDecs(close)
    let a:orig = [line('.'),col('.')]
    let a:here = [line('.'),col('.')]
    let a:next = searchpos(

    let a:vars = s:getArgs()
    while s:isBefore(a:next[1],a:close)
        if a:next[1] == [0,0]
            break
        endif
        
        let [a:type,a:name] = split(a:next[0],'|')
        call add(a:vars,[a:name,a:type,a:next[1][0]])

        call cursor(a:next[1][0],a:next[1][1])
        let a:next = s:getNextDec()
    endwhile
    call cursor(a:orig[0],a:orig[1])

    return a:vars
endfunction

function! s:getAllBlocks(close)

endfunction

function! s:getAllRelevantLines(vars,names,close)

endfunction

" Global Functions {{{1

" Insertion Functions {{{2

function! py#factorus#addParam(param_name,...)
    if a:0 > 0 && a:000[-1] == 'factorusRollback'
        call s:gotoTag(0)
        execute 'silent s/,\=\s\=\<' . a:param_name . '\>[^)]*)/)/e'
        execute 'silent s/(\<' . a:param_name . '\>,\=\s\=/(/e'
        silent write
        return 'Removed new parameter ' . a:param_name
    endif

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
    return a:param_name
endfunction

" Renaming Functions {{{2

function! s:renameArg(new_name)
    let a:var = expand('<cword>')
    call s:updateFile(a:var,a:new_name,0,1,0)

    echo 'Re-named ' . a:var . ' to ' . a:new_name
    return a:var
endfunction

function! s:renameClass(new_name) abort
    let a:class_line = s:getClassTag()[0]
    let a:class_name = substitute(getline(a:class_line),s:class_def,'\1','')
    if a:class_name == a:new_name
        throw 'Factorus:Duplicate'
    endif    

    let a:module_name = s:getModule(expand('%:p'))

    let a:temp_file = '.Factorus' . a:class_name
    let a:module_name = substitute(a:module_name,'\.','\\.','g')
    let a:module_name = substitute(a:module_name,'\(.*\)\(\\\..*\)','\\(\1\\)\\{0,1\\}\2','')
    call s:findTags(a:temp_file,'\<' . a:class_name . '\>','no')
    call s:addQuickFix(a:temp_file,'\<' . a:class_name . '\>')

    call system('cat ' . a:temp_file . ' | xargs sed -i "s/\<' . a:class_name . '\>/' . a:new_name . '/g"') 
    call system('rm -rf ' . a:temp_file
    silent edit

    echo 'Re-named class ' . a:class_name . ' to ' . a:new_name
    return a:class_name
endfunction

function! s:renameMethod(new_name)
    call s:gotoTag(0)
    let a:class = s:getClassTag()

    let a:method_name = substitute(getline('.'),s:function_def,'\1','')
    if a:method_name == a:new_name
        throw 'Factorus:Duplicate'
    endif

    let a:is_global = a:class == [0,0] ? 1 : 0
    let a:class_name = a:class == [0,0] ? '' : substitute(getline(a:class[0]),s:class_def,'\1','')

    call s:updateFile(a:method_name,a:new_name,1,0,a:is_global)

    let a:keyword = a:is_global == 1 ? a:method_name : '\(' . a:class_name . '\|' . a:method_name . '\)'
    let a:period = a:is_global == 1 ? '\([^.]\)\{0,1\}' : '\(\.\)'

    let a:file_name = expand('%:p')
    let a:temp_file = '.Factorus' . a:method_name
    call s:findTags(a:temp_file,'\<' . a:method_name . '\>','no')
    call s:addQuickFix(a:temp_file,'\<' . a:method_name . '\>')
    call system('cat ' . a:temp_file . ' | xargs sed -i "s/' . a:period . '\<' . a:method_name . '\>/\1' . a:new_name . '/g"')

    call s:findTags(a:temp_file,'\<' . a:method_name . '\>','no')
    for file in readfile(a:temp_file)
        execute 'silent tabedit ' . file
        let a:find =  searchpos('from.*import\_[^:)]\{-\}\<' . a:keyword. '\>','Wc')
        let a:end = searchpos('\<' . a:method_name . '\>','Wne')
        while  a:find != [0,0]
            call add(s:qf,{'filename' : expand('%:p'), 'lnum' : line('.'), 'text' : s:trim(join(getline(a:find[0],a:end[0])))})
            execute 'silent ' . a:find[0] . ',' . a:end[0] . 's/\<' . a:method_name . '\>/' . a:new_name . '/e'
            let a:find = searchpos('from.*import\_[^:)]\{-\}\<' . a:keyword . '\>','W')
            let a:end = searchpos('\<' . a:method_name . '\>','Wne')
        endwhile
        silent write
        call s:safeClose()
    endfor
    call system('rm -rf ' . a:temp_file)

    redraw
    let a:keyword = a:is_global == 1 ? ' global' : ''
    echo 'Re-named' . a:keyword . ' method ' . a:method_name . ' to ' . a:new_name
    return a:method_name
endfunction

function! py#factorus#renameSomething(new_name,type,...)
    let s:open_bufs = []
    let s:qf = []

    let a:prev_dir = getcwd()
    let a:buf_nrs = []
    for buf in getbufinfo()
        call add(s:open_bufs,buf['name'])
        call add(a:buf_nrs,buf['bufnr'])
    endfor
    let a:curr_buf = a:buf_nrs[index(s:open_bufs,expand('%:p'))]
    let a:buf_setting = &switchbuf

    execute 'silent cd ' . expand('%:p:h')
    let a:project_dir = system('git rev-parse --show-toplevel')
    execute 'silent cd ' a:project_dir

    let a:res = ''
    try
        let Rename = function('s:rename' . a:type)
        let a:res = Rename(a:new_name)
        execute 'silent cd ' a:prev_dir
        if a:type != 'Class'
            let &switchbuf = 'useopen,usetab'
            execute 'silent sbuffer ' . a:curr_buf
            let &switchbuf = a:buf_setting
        endif
                                                   
        call setqflist(s:qf)                              
        return a:res
    catch /.*/
        call system('rm -rf .Factorus*')
        execute 'silent cd ' a:prev_dir
        if a:type != 'Class'
            let &switchbuf = 'useopen,usetab'
            execute 'silent sbuffer ' . a:curr_buf
            let &switchbuf = a:buf_setting
        endif
        throw v:exception
    endtry
endfunction

" Extraction Functions {{{2

function! s:rollbackExtraction()
    let a:open = search('public .*' . g:factorus_method_name . '(')
    let a:close = s:getClosingIndent(1)[0]

    if match(getline(a:open - 1),'^\s*$') >= 0
        let a:open -= 1
    endif
    if match(getline(a:close + 1),'^\s*$') >= 0
        let a:close += 1
    endif

    execute 'silent ' . a:open . ',' . a:close . 'delete'

    call search('\<' . g:factorus_method_name . '\>(')
    call s:gotoTag(0)
    let a:open = line('.')
    let a:close = s:getClosingIndent(1)[0]

    execute 'silent ' . a:open . ',' . a:close . 'delete'
    call append(line('.')-1,g:factorus_history['old'][1])
    call cursor(a:open,1)
    silent write
endfunction

function! py#factorus#extractMethod(...)
    if a:0 > 0 && a:1 == 'factorusRollback'
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif
    echo 'Extracting new method...'
    call s:gotoTag(0)
    let a:tab = substitute(getline('.'),'\(\s*\).*','\1','')
    let a:method_name = substitute(getline('.'),'.*\s\+\(' . s:java_identifier . '\)\s*(.*','\1','')

    let [a:open,a:close] = [line('.'),s:getClosingIndent(1)]
    let a:old_lines = getline(a:open,a:close[0])

    call searchpos('{','W')

    let a:method_length = (a:close[0] - (line('.') + 1)) * 1.0
    let a:vars = s:getLocalDecs(a:close)
    let a:names = map(deepcopy(a:vars),{n,var -> var[0]})
    let a:decs = map(deepcopy(a:vars),{n,var -> var[2]})
    let a:compact = [a:names,a:decs]
    let a:blocks = s:getAllBlocks(a:close)

    let a:best_var = ['','',0]
    let a:best_lines = []
    let [a:all,a:isos] = s:getAllRelevantLines(a:vars,a:names,a:close)

    redraw
    echo 'Finding best lines...'
    for var in a:vars
        let a:iso = s:getIsolatedLines(var,a:compact,a:all,a:blocks,a:close)
        let a:isos[var[0]][var[2]] = copy(a:iso)
        let a:ratio = (len(a:iso) / a:method_length)

        if g:factorus_extract_heuristic == 'longest'
            if len(a:iso) > len(a:best_lines) && index(a:iso,a:open) < 0 && a:ratio < g:factorus_method_threshold
                let a:best_var = var
                let a:best_lines = copy(a:iso)
            endif 
        elseif g:factorus_extract_heuristic == 'greedy'
            if len(a:iso) >= g:factorus_min_extracted_lines && a:ratio < g:factorus_method_threshold
                let a:best_var = var
                let a:best_lines = copy(a:iso)
            endif
        endif
    endfor

    if len(a:best_lines) < g:factorus_min_extracted_lines
        redraw
        echo 'Nothing to extract'
        return
    endif

    redraw
    echo 'Almost done...'
    if index(a:best_lines,a:best_var[2]) < 0 && a:best_var[2] != a:open
        let a:stop = a:best_var[2]
        let a:dec_lines = [a:stop]
        while match(getline(a:stop),';') < 0
            let a:stop += 1
            call add(a:dec_lines,a:stop)
        endwhile

        let a:best_lines = a:dec_lines + a:best_lines
    endif

    let a:new_args = s:getNewArgs(a:best_lines,a:vars,a:all,a:best_var)
    let [a:wrapped,a:wrapped_args] = s:wrapDecs(a:best_var,a:best_lines,a:vars,a:all,a:isos,a:new_args,a:close)
    while a:wrapped != a:best_lines
        let [a:best_lines,a:new_args] = [a:wrapped,a:wrapped_args]
        let [a:wrapped,a:wrapped_args] = s:wrapDecs(a:best_var,a:best_lines,a:vars,a:all,a:isos,a:new_args,a:close)
    endwhile

    if a:best_var[2] == a:open && index(a:new_args,a:best_var) < 0
        call add(a:new_args,a:best_var)
    endif

    let a:best_lines = s:wrapAnnotations(a:best_lines)

    let a:new_args = s:getNewArgs(a:best_lines,a:vars,a:all,a:best_var)
    let [a:final,a:rep] = s:buildNewMethod(a:best_var,a:best_lines,a:new_args,a:blocks,a:vars,a:all,a:tab,a:close)

    call append(a:close[0],a:final)
    call append(a:best_lines[-1],a:rep)

    let a:i = len(a:best_lines) - 1
    while a:i >= 0
        call cursor(a:best_lines[a:i],1)
        d 
        let a:i -= 1
    endwhile

    call search('public.*' . g:factorus_method_name . '(')
    silent write
    redraw
    echo 'Extracted ' . len(a:best_lines) . ' lines from ' . a:method_name
    return [a:method_name,a:old_lines]
endfunction
