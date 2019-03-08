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

" Local Functions {{{1
" Universal Functions {{{2
" General {{{3

function! s:isBefore(x,y)
    if a:x[0] < a:y[0] || (a:x[0] == a:y[0] && a:x[1] < a:y[1])
        return 1
    endif
    return 0
endfunction

function! s:contains(range,line)
    if a:line >= a:range[0] && a:line <= a:range[1]
        return 1
    endif
    return 0
endfunction

function! s:isSmallerRange(x,y)
    if (a:x[1] - a:x[0]) < (a:y[1] - a:y[0])
        return 1
    endif
    return 0
endfunction

function! s:trim(string)
    return substitute(a:string,'\(^\s*\|\s*$\)','','g')
endfunction

function! s:merge(a,b)
    let l:i = 0
    let l:j = 0
    let l:c = []

    while l:i < len(a:a) || l:j < len(a:b)
        if l:j >= len(a:b)
            call add(l:c,a:a[l:i])
            let l:i += 1
        elseif l:i >= len(a:a)
            call add(l:c,a:b[l:j])
            let l:j += 1
        elseif l:j >= len(a:b) || a:a[l:i] < a:b[l:j]
            call add(l:c,a:a[l:i])
            let l:i += 1
        elseif l:i >= len(a:a) || a:b[l:j] < a:a[l:i]
            call add(l:c,a:b[l:j])
            let l:j += 1
        else
            call add(l:c,a:a[l:i])
            let l:i += 1
            let l:j += 1
        endif
    endwhile
    return l:c
endfunction

function! s:compare(x,y)
    if a:x[0] < a:y[0]
        return -1
    elseif a:x[0] > a:y[0]
        return 1
    else
        if a:x[1] > a:y[1]
            return -1
        elseif a:x[1] < a:y[1]
            return 1
        else
            return 0
        endif
    endif
endfunction

" File Navigation {{{3

function! s:isAlone()
    let l:file = expand('%:p')
    let l:count = 0
    for buf in getbufinfo()
        if buf['name'] == l:file
            if len(buf['windows']) > 1
                return 0
            endif
            return 1
        endif
    endfor
    return 1
endfunction

function! s:safeClose()
    let l:prev = 0
    if winnr("$") == 1 && tabpagenr("$") > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr("$")
        let l:prev = 1
    endif

    if index(s:open_bufs,expand('%:p')) < 0 && s:isAlone() == 1
        bwipeout
    else
        q
    endif

    if l:prev == 1
        tabprev
    endif
endfunction

function! s:findTags(temp_file,search_string,append)
    let l:fout = a:append == 'yes' ? '>>' : '>'
    call system('cat ' . s:temp_file . ' | xargs grep -l "' . a:search_string . '"' .  l:fout . a:temp_file . ' 2> /dev/null')
endfunction

function! s:narrowTags(temp_file,search_string)
    let l:n_temp_file = a:temp_file . '.narrow'
    call system('cat ' . a:temp_file . ' | xargs grep -l "' . a:search_string . '" {} + > ' . l:n_temp_file)
    call system('mv ' . l:n_temp_file . ' ' . a:temp_file)
endfunction

function! s:updateQuickFix(temp_file,search_string)
    let l:res = split(system('cat ' . a:temp_file . ' | xargs grep -n "' . a:search_string . '"'),'\n')
    call map(l:res,{n,val -> split(val,':')})
    if len(split(system('cat ' . a:temp_file),'\n')) == 1
        call map(l:res,{n,val -> {'filename' : expand('%:p'), 'lnum' : val[0], 'text' : s:trim(join(val[1:],':'))}})
    else
        call map(l:res,{n,val -> {'filename' : val[0], 'lnum' : val[1], 'text' : s:trim(join(val[2:],':'))}})
    endif
    let g:factorus_qf += l:res
endfunction

function! s:setQuickFix(type)
    let l:title = a:type . ' : '
    if g:factorus_show_changes == 1
        let l:title .= 'ChangedFiles'
    elseif g:factorus_show_changes == 2
        let l:title .= 'UnchangedFiles'
    else
        let l:title .= 'AllFiles'
    endif

    call setqflist(s:qf)
    call setqflist(s:qf,'r',{'title' : l:title})
endfunction

function! s:getUnchanged(search)
    let l:qf = []

    let l:temp_file = '.FactorusUnchanged'
    call s:findTags(l:temp_file,a:search,'no')

    let l:count = 0
    for file in readfile(l:temp_file)
        let l:lines = split(system('grep -n "' . a:search . '" ' . file),'\n')  

        let l:count += len(l:lines)
        for line in l:lines
            let l:un = split(line,':')
            call add(l:qf,{'lnum' : l:un[0], 'filename' : file, 'text' : s:trim(join(l:un[1:],''))})
        endfor
    endfor

    call system('rm -rf ' . l:temp_file)
    return l:qf
endfunction

" Utilities {{{2

function! s:isQuoted(pat,state)
    let l:temp = a:state
    let l:mat = match(l:temp,a:pat)
    let l:res = 1
    while l:mat >= 0 && l:res == 1
        let l:begin = strpart(l:temp,0,l:mat)
        let l:quotes = len(l:begin) - len(substitute(l:begin,'["'']','','g'))
        if l:quotes % 2 == 1
            let l:res = 1
        else
            let l:res = 0
        endif
        let l:temp = substitute(l:temp,a:pat,'','')
        let l:mat = match(l:temp,a:pat)
    endwhile
    return l:res
endfunction

" Tag Navigation {{{2
" getAdjacentTag {{{3
function! s:getAdjacentTag(dir)
    return searchpos(s:function_def,'Wnc' . a:dir)
endfunction

" getClosingIndent {{{3
function! s:getClosingIndent(stack,...)
    let l:orig = [line('.'),col('.')]
    if a:0 > 0
        call cursor(a:1[0],a:1[1])
    endif
    let l:indent = substitute(getline('.'),'^\(\s*\)[^[:space:]].*','\1','')
    let l:l = a:stack == 1 ? len(l:indent) : len(l:indent) - 1
    if l:l < 0
        return [0,0]
    endif
    let l:indent = '^\s\{,' . l:l . '\}'

    let l:res = searchpos(l:indent . '[^[:space:]]','Wn')
    call cursor(l:orig[0],l:orig[1])
    return l:res
endfunction

" getClassTag {{{3
function! s:getClassTag()
    let l:res = searchpos(s:class_def,'Wnbc')
    if l:res == [0,0]
        return l:res
    endif
    let l:close = s:getClosingIndent(0)
    let l:orig = [line('.'),col('.')]
    call cursor(l:res[0],l:res[1])
    let l:class_close = s:getClosingIndent(1)
    if s:isBefore(l:class_close,l:close) == 1
        let l:res = [0,0]
    endif
    call cursor(l:orig[0],l:orig[1])
    return l:res
endfunction

" gotoTag {{{3
function! s:gotoTag(head)
    let l:tag = a:head == 1 ? s:getClassTag() : s:getAdjacentTag('b') 
    if l:tag[0] <= line('.') && l:tag != [0,0]
        call cursor(l:tag[0],l:tag[1])
    else
        echo 'No tag found'
    endif
endfunction

" Class Hierarchy {{{2
" getModule {{{3
function! s:getModule(file)
    let l:project_dir = factorus#ProjectDir()
    let l:module = strpart(a:file,len(l:project_dir))
    let l:module = substitute(substitute(l:module,'\.py$','',''),'\/','.','g')
    return l:module
endfunction

" Declarations {{{2
" getArgs {{{3
function! s:getArgs() abort
    let l:prev = [line('.'),col('.')]
    call s:gotoTag(0)
    let l:oparen = search('(','Wn')
    let l:cparen = search(')','Wn')
    
    let l:dec = join(getline(l:oparen,l:cparen))
    let l:dec = substitute(l:dec,'.*(\(.*\)).*','\1','')
    if l:dec == ''
        return []
    endif
    let l:args = split(l:dec,',')
    call map(l:args,{n,val -> substitute(val,'=.*$','','')})
    call filter(l:args,'match(v:val,"[''\"]") < 0')
    call map(l:args,{n,val -> substitute(val,'\(^\s*\|\s*$\)','','g')})
    call map(l:args,{n,val -> [val,line('.')]})

    call cursor(l:prev[0],l:prev[1])
    return l:args
endfunction

" getLocalDecs {{{3
function! s:getLocalDecs(close)
    let l:orig = [line('.'),col('.')]
    let l:here = [line('.'),col('.')]
    let l:search = '.*\<\(' . s:python_identifier . '\)\>\s*=.*'
    let l:next = searchpos(l:search,'Wn')

    let l:vars = s:getArgs()
    let l:names = map(deepcopy(l:vars),{n,val -> val[0]})
    while s:isBefore(l:next,a:close)
        if l:next == [0,0]
            break
        endif
        
        let l:name = substitute(getline(l:next[0]),l:search,'\1','')
        call add(l:vars,[l:name,l:next[0]])
        call add(l:names,l:name)

        call cursor(l:next[0],l:next[1])
        let l:next = searchpos(l:search,'Wn')
    endwhile
    call cursor(l:orig[0],l:orig[1])

    let i = 0
    while i < len(l:names)
        let l:ind = index(l:names,l:names[i],i+1)
        if l:ind >= 0
            call remove(l:names,l:ind)
            call remove(l:vars,l:ind)
            continue
        endif
        let i += 1
    endwhile

    return l:vars
endfunction

" References {{{2
" getNextReference {{{3
function! s:getNextReference(var,type,...)
    if a:type == 'right'
        let l:search = '^\s*\(' . s:python_identifier . '\)\s*[(.=].*\<\(' . a:var . '\)\>.*$'
        let l:index = '\1'
        let l:alt_index = '\2'
    elseif a:type == 'left'
        let l:search = '^\s*\<\(' . a:var . '\)\>\s*[-+*/]\=[.=][^=].*$'
        let l:index = '\1'
        let l:alt_index = '\1'
    elseif a:type == 'cond'
        let l:search = '^\s*\(for\|while\|if\|elif\).*\<\(' . a:var . '\)\>.*:'
        let l:index = '\1'
        let l:alt_index = '\2'
    elseif a:type == 'return'
        let l:search = '^\s*\<return\>.*\<\(' . a:var . '\)\>.*'
        let l:index = '\1'
        let l:alt_index = '\1'
    endif

    let l:line = searchpos(l:search,'Wn')

    if l:line[0] > line('.')
        let l:state = getline(l:line[0])
        let l:loc = substitute(l:state,l:search,l:index,'')
        if a:0 > 0 && a:1 == 1
            let l:name = substitute(l:state,l:search,l:alt_index,'')
            return [l:loc,l:line,l:name]
        endif
        return [l:loc,l:line]
    endif
        
    return (a:0 > 0 && a:1 == 1) ? ['none',[0,0],'none'] : ['none',[0,0]]
endfunction

" getNextUse {{{3
function! s:getNextUse(var,...)
    let l:right = s:getNextReference(a:var,'right',a:0)
    let l:left = s:getNextReference(a:var,'left',a:0)
    let l:cond = s:getNextReference(a:var,'cond',a:0)
    let l:return = s:getNextReference(a:var,'return',a:0)

    let l:min = [l:right[0],copy(l:right[1]),'right']
    let l:min_name = a:0 > 0 ? l:right[2] : ''

    let l:poss = [l:right,l:left,l:cond,l:return]
    let l:idents = ['right','left','cond','return']
    for i in range(4)
        let temp = l:poss[i]
        if temp[1] != [0,0] && (s:isBefore(temp[1],l:min[1]) == 1 || l:min[1] == [0,0])
            let l:min = [temp[0],copy(temp[1]),l:idents[i]]
            if a:0 > 0
                let l:min_name = temp[2]
            endif
        endif
    endfor

    if a:0 > 0
        call add(l:min,l:min_name)
    endif

    return l:min
endfunction

" File-Updating {{{2
" updateFile {{{3
function! s:updateFile(old_name,new_name,is_method,is_local,is_global)
    let l:orig = line('.')

    if a:is_local == 1
        let l:query = '\([^.]\)\<' . a:old_name . '\>'
        call add(s:qf,{'filename' : expand('%:p'), 'lnum' : line('.'), 'text' : s:trim(getline('.'))})
        execute 'silent s/' . l:query . '/\1' . a:new_name . '/g'

        call s:gotoTag(0)
        let l:closing = s:getClosingIndent(1)

        let l:next = searchpos(l:query,'Wn')
        while s:isBefore(l:next,l:closing)
            if l:next == [0,0]
                break
            endif
            call cursor(l:next[0],l:next[1])
            execute 'silent s/' . l:query . '/\1' . a:new_name . '/g'

            let l:next = searchpos(l:query,'Wn')
        endwhile
    else
        let l:paren = a:is_method == 1 ? '(' : ''
        let l:period = a:is_global == 1 ? '\([^.]\)\{0,1\}' : '\(\.\)'
        let l:search = l:period . '\<' . a:old_name . '\>' . l:paren
        try
            execute 'silent lvimgrep /' . l:search . '/j %:p'
            let s:qf += map(getloclist(0),{n,val -> {'filename' : expand('%:p'), 'lnum' : val['lnum'], 'text' : s:trim(val['text'])}})
        catch /.*/
        endtry
        call setloclist(0,[])

        execute 'silent %s/' . l:search . '/\1' . a:new_name . l:paren . '/ge'
    endif

    call cursor(l:orig,1)
    silent write!
endfunction

" Renaming {{{2
" renameArg {{{3
function! s:renameArg(new_name,...) abort
    let l:var = expand('<cword>')
    let g:factorus_history['old'] = l:var

    call s:updateFile(l:var,a:new_name,0,1,0)

    if !factorus#isRollback(a:000)
        redraw
        echo 'Re-named ' . l:var . ' to ' . a:new_name
    endif
    return l:var
endfunction

" renameClass {{{3
function! s:renameClass(new_name,...) abort
    let l:class_line = s:getClassTag()[0]
    let l:class_name = substitute(getline(l:class_line),s:class_def,'\1','')
    if l:class_name == a:new_name
        throw 'Factorus:Duplicate'
    endif    
    let g:factorus_history['old'] = l:class_name

    let l:module_name = s:getModule(expand('%:p'))

    let l:temp_file = '.Factorus' . l:class_name
    let l:module_name = substitute(l:module_name,'\.','\\.','g')
    let l:module_name = substitute(l:module_name,'\(.*\)\(\\\..*\)','\\(\1\\)\\{0,1\\}\2','')
    call s:findTags(l:temp_file,'\<' . l:class_name . '\>','no')
    call s:updateQuickFix(l:temp_file,'\<' . l:class_name . '\>')

    try
        call system('cat ' . l:temp_file . ' | xargs sed -i "s/\<' . l:class_name . '\>/' . a:new_name . '/g"') 
        call system('rm -rf ' . l:temp_file)
    catch /.*/
        call system('cat ' . l:temp_file . ' | xargs sed -i "s/' . l:period . '\<' . l:method_name . '\>/\1' . a:new_name . '/g"')
        call system('rm -rf ' . l:temp_file)
        throw 'Factorus: ' . v:exception . ', at ' . v:throwpoint
    endtry

    silent edit!

    if !factorus#isRollback(a:000)
        redraw
        echo 'Re-named class ' . l:class_name . ' to ' . a:new_name
    endif
    return l:class_name
endfunction

" renameMethod {{{3
function! s:renameMethod(new_name,...) abort
    call s:gotoTag(0)
    let l:class = s:getClassTag()

    let l:method_name = substitute(getline('.'),s:function_def,'\1','')
    if l:method_name == a:new_name
        throw 'Factorus:Duplicate'
    endif
    let g:factorus_history['old'] = l:method_name

    let l:is_global = l:class == [0,0] ? 1 : 0
    let l:class_name = l:class == [0,0] ? '' : substitute(getline(l:class[0]),s:class_def,'\1','')

    call s:updateFile(l:method_name,a:new_name,1,0,l:is_global)

    let l:keyword = l:is_global == 1 ? l:method_name : '\(' . l:class_name . '\|' . l:method_name . '\)'
    let l:period = l:is_global == 1 ? '\([^.]\)\{0,1\}' : '\(\.\)'

    let l:file_name = expand('%:p')
    let l:temp_file = '.Factorus' . l:method_name
    call s:findTags(l:temp_file,l:period . '\<' . l:method_name . '\>','no')
    call s:updateQuickFix(l:temp_file,l:period . '\<' . l:method_name . '\>')
    try
        call system('cat ' . l:temp_file . ' | xargs sed -i "s/' . l:period . '\<' . l:method_name . '\>/\1' . a:new_name . '/g"')
        call system('rm -rf ' . l:temp_file)
    catch /.*/
        call system('cat ' . l:temp_file . ' | xargs sed -i "s/' . l:period . '\<' . l:method_name . '\>/\1' . a:new_name . '/g"')
        call system('rm -rf ' . l:temp_file)
        throw 'Factorus: ' . v:exception . ', at ' . v:throwpoint
    endtry

    silent edit!

    if !factorus#isRollback(a:000)
        redraw
        let l:keyword = l:is_global == 1 ? ' global' : ''
        echo 'Re-named' . l:keyword . ' method ' . l:method_name . ' to ' . a:new_name
    endif
    return l:method_name
endfunction

" Extraction {{{2
" getContainingBlock {{{3
function! s:getContainingBlock(line,ranges,exclude)
    for range in a:ranges
        if range[0] > a:line
            return [a:line,a:line]
        endif

        if range[1] >= a:line && range[0] > a:exclude[0]
            return range
        endif
    endfor
    return [a:line,a:line]
endfunction

" getAllBlocks {{{3
function! s:getAllBlocks(close)
    let l:if = '\<if\>.*:'
    let l:for = '\<for\>.*:'
    let l:while = '\<while\>.*:'
    let l:try = '\<try\>.*:'
    let l:search = '\(' . l:if . '\|' . l:for . '\|' . l:while . '\|' . l:try . '\)'

    let l:orig = [line('.'),col('.')]
    call s:gotoTag(0)
    let l:blocks = [[line('.'),a:close[0]]]

    let l:open = searchpos(':','Wn')
    let l:next = searchpos(l:search,'Wn')
    while l:next[0] <= a:close[0]
        if l:next == [0,0]
            break
        endif
        call cursor(l:next[0],l:next[1])

        if match(getline('.'),'\<else\>') >= 0
            let l:next = searchpos(l:search,'Wn')
            continue
        endif

        if match(getline('.'),'\<\(if\|try\)\>') >= 0
            let l:open = [line('.'),col('.')]
            let l:loc_close = s:getClosingIndent(1)

            let l:o = line('.')
            while match(getline(l:loc_close[0]),'\<\(else\|elif\|except\|finally\)\>.*') >= 0
                if len(substitute(getline(l:loc_close[0]),'^\(\s*\)[[:space:]].*','\1','')) < len(substitute(getline('.'),'^\(\s*\)[[:space:]].*','\1',''))
                    break
                endif
                call cursor(l:loc_close[0],l:loc_close[1])
                call add(l:blocks,[l:o,l:loc_close[0]-1])
                let l:o = line('.')
                let l:loc_close = s:getClosingIndent(1)
            endwhile

            call add(l:blocks,[l:o,l:loc_close[0]-1])
            call add(l:blocks,[l:open[0],l:loc_close[0]-1])
            call cursor(l:open[0],l:open[1])
        else
            let l:loc_close = s:getClosingIndent(1)
            call add(l:blocks,[line('.'),l:loc_close[0]-1])
        endif

        let l:next = searchpos(l:search,'Wn')
    endwhile

    call cursor(l:orig[0],l:orig[1])
    return uniq(sort(l:blocks,'s:compare'))
endfunction

" getAllRelevantLines {{{3
function! s:getAllRelevantLines(vars,names,close)
    let l:orig = [line('.'),col('.')]
    let l:begin = s:getAdjacentTag('b')

    let l:lines = {}
    let a:closes = {}
    let l:isos = {}
    for var in a:vars
        call cursor(var[1],1)
        let l:local_close = var[1] == l:begin[0] ? s:getClosingIndent(1) : s:getClosingIndent(0)
        let a:closes[var[0]] = copy(l:local_close)
        call cursor(l:orig[0],l:orig[1])
        if index(keys(l:lines),var[0]) < 0
            let l:lines[var[0]] = [var[1]]
        else
            call add(l:lines,var[1])
        endif
        let l:isos[var[0]] = []
    endfor

    let l:search = join(a:names,'\|')
    let l:next = s:getNextUse(l:search,1)

    while s:isBefore(l:next[1],a:close) == 1
        if l:next[1] == [0,0]
            break
        endif

        let l:pause = copy(l:next)
        let l:new_search = l:search
        while l:pause[1] == l:next[1]
            let l:name = l:next[3]

            let l:ldec = l:lines[l:name][0]

            let l:quoted = s:isQuoted('\<' . l:name . '\>',getline(l:next[1][0]))
            if l:quoted == 0 
                if index(l:lines[l:name],l:next[1][0]) < 0
                    call add(l:lines[l:name],l:next[1][0])
                endif
            endif

            if match(l:new_search,'\\|') < 0
                break
            endif

            let l:new_search = substitute(l:new_search,'\\|\<' . l:name . '\>','','')
            let l:new_search = substitute(l:new_search,'\<' . l:name . '\>\\|','','')

            let l:next = s:getNextUse(l:new_search,1)
        endwhile
        let l:next = copy(l:pause)

        call cursor(l:next[1][0],l:next[1][1])
        let l:next = s:getNextUse(l:search,1)
    endwhile
    
    call cursor(l:orig[0],l:orig[1])
    return [l:lines,l:isos]
endfunction

" isIsolatedBlock {{{3
function! s:isIsolatedBlock(block,var,rels,close)
    let l:orig = [line('.'),col('.')]
    call cursor(a:block[0],1)
    if a:block[1] - a:block[0] == 0
        call cursor(line('.')-1,1)
    endif

    let l:search = join(keys(a:rels),'\|')
    let l:search = substitute(l:search,'\\|\<' . a:var[0] . '\>','','')
    let l:search = substitute(l:search,'\<' . a:var[0] . '\>\\|','','')
    let l:ref = s:getNextReference(l:search,'left',1)
    let l:return = search('\<\(return\)\>','Wn')
    let l:continue = search('\<\(continue\|break\)\>','Wn')

    let l:res = 1
    if s:contains(a:block,l:return) == 1
        let l:res = 0
    elseif s:contains(a:block,l:continue) && match(getline(a:block[0]),'\<\(for\|while\)\>') < 0
        let l:res = 0
    else
        while l:ref[1] != [0,0] && s:isBefore(l:ref[1],[a:block[1]+1,1]) == 1
            let l:i = a:rels[l:ref[2]][0]
            if s:contains(a:block,l:i) == 0
                let l:res = 0
                break
            endif
            call cursor(l:ref[1][0],l:ref[1][1])
            let l:ref = s:getNextReference(l:search,'left',1)
        endwhile
    endif

    call cursor(l:orig[0],l:orig[1])
    return l:res
endfunction

" getIsolatedLines {{{3
function! s:getIsolatedLines(var,names,rels,blocks,close)
    let l:refs = a:rels[a:var[0]]

    if len(l:refs) == 1
        return []
    endif

    let l:orig = [line('.'),col('.')]
    let [l:name,l:dec] = a:var

    let l:wraps = []
    if match(getline(a:var[1]),'\<for\>') >= 0
        let l:for = s:getContainingBlock(l:dec,a:blocks,a:blocks[0])
        if s:isIsolatedBlock(l:for,a:var,a:rels,a:close) == 0
            return []
        endif
    endif
    let l:dec_block = s:getContainingBlock(l:dec,a:blocks,a:blocks[0])
    if l:dec_block[1] - l:dec_block[0] == 0
        call add(l:wraps,copy(a:blocks[0]))
    endif
    call add(l:wraps,s:getContainingBlock(l:refs[1],a:blocks,a:blocks[0]))

    let l:usable = []
    for i in range(len(l:wraps))
        let twrap = l:wraps[i]
        let l:temp = []

        let l:next_use = s:getNextReference(a:var[0],'right')
        call cursor(l:next_use[1][0],l:next_use[1][1])

        let l:block = [0,0]
        for j in range(i,len(l:refs)-1)
            let line = l:refs[j]
            if line == l:next_use[1][0]
                if index(a:names,l:next_use[0]) >= 0
                    break
                endif
                call cursor(l:next_use[1][0],l:next_use[1][1])
                let l:next_use = s:getNextReference(a:var[0],'right')
            endif
            if line >= l:block[0] && line <= l:block[1]
                continue
            endif

            let l:block = s:getContainingBlock(line,a:blocks,twrap)
            if l:block[0] < twrap[0] || l:block[1] > twrap[1]
                break
            endif

            if s:isIsolatedBlock(l:block,a:var,a:rels,a:close) == 0 
                break
            endif

            let l:i = l:block[0]
            while l:i <= l:block[1]
                if index(l:temp,l:i) < 0
                    call add(l:temp,l:i)
                endif
                let l:i += 1
            endwhile
        endfor

        if len(l:temp) > len(l:usable)
            let l:usable = copy(l:temp)
        endif

        call cursor(l:orig[0],l:orig[1])
    endfor

    return l:usable
endfunction

" Method-Building {{{2
" getNewArgs {{{3
function! s:getNewArgs(lines,vars,rels,...)
    let l:names = map(deepcopy(a:vars),{n,var -> var[0]})
    let l:search = '\(' . join(l:names,'\|') . '\)'
    let l:search = '^.*\<' . l:search . '\>.*'
    let l:args = []

    for line in a:lines
        let l:this = getline(line)
        if match(l:this,'^\s*\(\/\/\|*\)') >= 0
            continue
        endif
        let l:new = substitute(l:this,l:search,'\1','')
        while l:new != l:this
            let l:spot = a:rels[l:new]
            let l:next_var = filter(deepcopy(a:vars),'v:val[0] == l:new')[0]

            if index(l:args,l:next_var) < 0 && index(a:lines,l:spot) < 0 && (a:0 == 0 || l:next_var[0] != a:1[0] || l:next_var[1] == a:1[1]) 
                call add(l:args,l:next_var)
            endif
            let l:this = substitute(l:this,'\<' . l:new . '\>','','g')
            let l:new = substitute(l:this,l:search,'\1','')
        endwhile
    endfor
    return l:args
endfunction

" wrapDecs {{{3
function! s:wrapDecs(var,lines,vars,rels,isos,args,close)
    let l:head = s:getAdjacentTag('b')
    let l:orig = [line('.'),col('.')]
    let l:fin = copy(a:lines)
    let l:fin_args = deepcopy(a:args)
    for arg in a:args

        if arg[1] == l:head[0]
            continue
        endif

        let l:wrap = 1
        let l:name = arg[0]
        let l:next = s:getNextUse(l:name)

        while l:next[1] != [0,0] && s:isBefore(l:next[1],a:close) == 1
            if l:next[2] != 'left' && index(a:lines,l:next[1][0]) < 0
                let l:wrap = 0    
                break
            endif
            call cursor(l:next[1][0],l:next[1][1])
            let l:next = s:getNextUse(l:name)
        endwhile

        if l:wrap == 1
            let l:relevant = a:rels[arg[0]][arg[2]]
            let l:stop = arg[1]
            let l:dec = [l:stop]
            while match(getline(l:stop),';') < 0
                let l:stop += 1
                call add(l:dec,l:stop)
            endwhile
            let l:iso = l:dec + a:isos[arg[0]]

            let l:con = 1
            for rel in l:relevant
                if index(l:iso,rel) < 0 && index(a:lines,rel) < 0
                    let l:con = 0
                    break
                endif
            endfor
            if l:con == 0
                continue
            endif

            let l:next_args = s:getNewArgs(l:iso,a:vars,a:rels,arg)
            let l:fin = uniq(s:merge(l:fin,l:iso))

            call remove(l:fin_args,index(l:fin_args,arg))
            for narg in l:next_args
                if index(l:fin_args,narg) < 0 && narg[0] != a:var[0]
                    call add(l:fin_args,narg)
                endif
            endfor
        endif
        call cursor(l:orig[0],l:orig[1])
    endfor

    call cursor(l:orig[0],l:orig[1])
    return [l:fin,l:fin_args]
endfunction

" buildArgs {{{3
function! s:buildArgs(args)
    let l:defs = map(deepcopy(a:args),{n,arg -> arg[0]})
    return join(l:defs,',')
endfunction

" formatMethod {{{3
function! s:formatMethod(def,body,return,lines,spaces)
    let l:paren = stridx(a:def[0],'(')
    let a:def_space = repeat(' ',l:paren+1)
    call map(a:def,{n,line -> a:spaces[0] . (n > 0 ? a:def_space : '') . substitute(line,'^\s*\(.*\)','\1','')})

    let l:dspaces = join(a:spaces,'')
    let l:i = 0

    call map(a:body,{n,line -> substitute(line,'^\s*\(.*\)','\1','')})
    let l:next_closes = []
    while l:i < len(a:lines)
        if len(l:next_closes) > 0 && s:isBefore(l:next_closes[-1],[a:lines[l:i],1])
            call remove(l:next_closes,len(l:next_closes)-1)
        endif

        let l:tspaces = l:dspaces . repeat(a:spaces[1],len(l:next_closes))
        let a:body[l:i] = l:tspaces . a:body[l:i]

        if match(a:body[l:i],':\s*$') >= 0
            call add(l:next_closes,s:getClosingIndent(1,[a:lines[l:i],1]))
        endif

        let l:i += 1
    endwhile
    call add(a:body,l:dspaces . substitute(a:return,'^\s*\(.*\)','\1',''))
endfunction

" buildNewMethod {{{3
function! s:buildNewMethod(lines,args,ranges,vars,rels,tab,close,...)
    call cursor(a:lines[-1],1)
    let l:return = ''
    let l:call = ''

    let l:outer = s:getContainingBlock(a:lines[0],a:ranges,a:ranges[0])
    let l:include_dec = 1
    for var in a:vars
        if index(a:lines,var[1]) >= 0
            let l:outside = s:getNextUse(var[0])    
            if l:outside[1] != [0,0] && s:isBefore(l:outside[1],a:close) == 1
                let l:contain = s:getContainingBlock(var[1],a:ranges,a:ranges[0])
                if l:contain[0] <= l:outer[0] || l:contain[1] >= l:outer[1]
                    let l:type = var[1]
                    let l:return = 'return ' . var[0]
                    let l:call = var[0] . ' = '

                    let i = 0
                    while i < len(a:lines)
                        let line = getline(a:lines[i])
                        if match(line,'\<\(if\|elif\|while\|for\)\>') < 0 && match(line,'\<' . var[0] . '\>') >= 0
                            break
                        endif
                        let i += 1
                    endwhile

                    if i == len(a:lines)
                        break
                    endif

                    let l:inner = s:getContainingBlock(a:lines[i+1],a:ranges,l:outer)
                    if l:inner[1] - l:inner[0] > 0
                        let l:removes = []
                        for j in range(i+1)
                            if match(getline(a:lines[j]),'\<' . var[0] . '\>') >= 0
                                call add(l:removes,j)
                            endif
                        endfor
                        for rem in reverse(l:removes)
                            call remove(a:lines,rem)
                        endfor
                        let l:include_dec = 0
                    endif
                    break
                endif
            endif
        endif
    endfor
    let l:body = map(copy(a:lines),{n,line -> getline(line)})

    let l:name = a:0 == 0 ? g:factorus_method_name : a:1
    let l:arg_string = s:buildArgs(a:args)
    let l:build_string = 'def ' . l:name . '(' . l:arg_string . '):'
    let l:temp = join(reverse(split(l:build_string, '.\zs')), '')
    let l:def = []

    if g:factorus_split_lines == 1
        while len(l:temp) >= g:factorus_line_length
            let i = stridx(l:temp,'|',len(l:temp) - g:factorus_line_length)
            if i <= 0
                break
            endif
            let l:segment = strpart(l:temp,0,i)
            let l:segment = join(reverse(split(l:segment, '.\zs')), '')
            let l:segment = substitute(l:segment,'|',',','g')
            call add(l:def,l:segment)
            let l:temp = strpart(l:temp,i)
        endwhile
    endif

    let l:temp = join(reverse(split(l:temp, '.\zs')), '')
    let l:temp = substitute(l:temp,'|',',','g')
    call add(l:def,l:temp)
    call reverse(l:def)

    call s:formatMethod(l:def,l:body,l:return,a:lines,a:tab)
    let l:final = l:def + l:body + ['']

    let l:call_space = substitute(getline(s:getContainingBlock(a:lines[-1],a:ranges,a:ranges[0])[0]),'\(\s*\).*','\1','')
    let l:rep = [l:call_space . l:call . l:name . '(' . l:arg_string . ')']

    return [l:final,l:rep]
endfunction

" Rollback {{{2
" rollbackExtraction {{{3
function! s:rollbackExtraction()
    let l:open = search('def ' . g:factorus_method_name . '(')
    let l:close = s:getClosingIndent(1)[0] - 1

    if match(getline(l:open - 1),'^\s*$') >= 0
        let l:open -= 1
    endif
    if match(getline(l:close + 1),'^\s*$') >= 0
        let l:close += 1
    endif

    execute 'silent ' . l:open . ',' . l:close . 'delete'

    call search('\<' . g:factorus_method_name . '\>(')
    call s:gotoTag(0)
    let l:open = line('.')
    let l:close = s:getClosingIndent(1)[0] - 1

    execute 'silent ' . l:open . ',' . l:close . 'delete'
    call append(line('.')-1,g:factorus_history['old'][1])
    call cursor(l:open,1)
    silent write!
endfunction

" Global Functions {{{1
" addParam {{{2
function! python#factorus#addParam(param_name,...)
    if factorus#isRollback(a:000)
        call s:gotoTag(0)
        execute 'silent s/,\=\s\=\<' . a:param_name . '\>[^)]*)/)/e'
        execute 'silent s/(\<' . a:param_name . '\>,\=\s\=/(/e'
        silent write!
        return 'Removed new parameter ' . a:param_name
    endif

    let l:orig = [line('.'),col('.')]
    call s:gotoTag(0)

    if a:0 == 0
        let l:next = searchpos('(','Wn')
        let l:line = substitute(getline(l:next[0]), '(', '(' . a:param_name . ', ', '')
    else
        let l:next = searchpos(')','Wn')
        let l:line = substitute(getline(l:next[0]), ')', ', ' . a:param_name . '=' . a:1 . ')', '')
    endif

    execute 'silent ' .  l:next[0] . 'd'
    call append(l:next[0] - 1,l:line)

    silent write!
    silent edit!
    call cursor(l:orig[0],l:orig[1])

    redraw
    echo 'Added parameter ' . a:param_name . ' to method'
    return a:param_name
endfunction

" renameSomething {{{2
function! python#factorus#renameSomething(new_name,type,...)
    let l:orig = [line('.'),col('.')]
    let s:open_bufs = []
    let s:qf = []

    let l:prev_dir = getcwd()
    let l:buf_nrs = []
    for buf in getbufinfo()
        call add(s:open_bufs,buf['name'])
        call add(l:buf_nrs,buf['bufnr'])
    endfor
    let l:curr_buf = l:buf_nrs[index(s:open_bufs,expand('%:p'))]
    let l:buf_setting = &switchbuf

    execute 'silent cd ' . expand('%:p:h')
    let l:project_dir = factorus#projectDir()
    execute 'silent cd ' l:project_dir

    let s:temp_file = '.FactorusTemp'
    call system('find ' . getcwd() . g:factorus_ignore_string . ' > ' . s:temp_file)

    let l:res = ''
    try
        let Rename = function('s:rename' . a:type)
        let l:res = Rename(a:new_name)

        if factorus#isRollback(a:000)
            let l:res = 'Rolled back renaming of ' . substitute(g:factorus_history['args'][-1],'\(.\)\(.*\)','\L\1\E\2','') . ' ' . g:factorus_history['old']
        else
            if g:factorus_show_changes > 0
                let l:ch = len(s:qf)
                let l:ch_i = l:ch == 1 ? ' instance ' : ' instances '
                let l:un = s:getUnchanged('\<' . l:res . '\>')
                let l:un_l = len(l:un)
                let l:un_i = l:un_l == 1 ? ' instance ' : ' instances '

                let l:first_line = l:ch . l:ch_i . 'modified' 
                let l:first_line .= a:type == 'Arg' ? '.' : ', ' . l:un_l . l:un_i . 'left unmodified.'

                if g:factorus_show_changes > 1 && a:type != 'Arg'
                    let l:un = [{'pattern' : 'Unmodified'}] + l:un
                    if g:factorus_show_changes == 2
                        let s:qf = []
                    endif
                    let s:qf += l:un
                endif

                if g:factorus_show_changes % 2 == 1
                    let s:qf = [{'pattern' : 'Modified'}] + s:qf
                endif
                let s:qf = [{'text' : l:first_line,'pattern' : 'rename' . a:type}] + s:qf

                call s:setQuickFix(a:type)
            endif
        endif
        call system('rm -rf ' . s:temp_file)

        execute 'silent cd ' l:prev_dir
        if a:type != 'Class'
            let &switchbuf = 'useopen,usetab'
            execute 'silent sbuffer ' . l:curr_buf
            let &switchbuf = l:buf_setting
        endif
        call cursor(l:orig[0],l:orig[1])

        return l:res
    catch /.*/
        call system('rm -rf .Factorus*')
        execute 'silent cd ' l:prev_dir
        if a:type != 'Class'
            let &switchbuf = 'useopen,usetab'
            execute 'silent sbuffer ' . l:curr_buf
            let &switchbuf = l:buf_setting
        endif
        let l:err = match(v:exception,'^Factorus:') >= 0 ? v:exception : 'Factorus:' . v:exception
        throw l:err . ', at ' . v:throwpoint
    endtry
endfunction

" extractMethod {{{2
function! python#factorus#extractMethod(...)
    if factorus#isRollback(a:000)
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif

    echo 'Extracting new method...'
    call s:gotoTag(0)
    let l:tab = [substitute(getline('.'),'\(\s*\).*','\1',''),substitute(getline(line('.')+1),'\(\s*\).*','\1','')]
    let l:method_name = substitute(getline('.'),'^\s*def\s\+\<\(' . s:python_identifier . '\)\s*(.*','\1','')

    let [l:open,l:close] = [line('.'),s:getClosingIndent(1)]
    let l:old_lines = getline(l:open,l:close[0]-1)

    call searchpos(':','W')

    let l:method_length = (l:close[0] - (line('.') + 1)) * 1.0
    let l:vars = s:getLocalDecs(l:close)
    let l:names = map(deepcopy(l:vars),{n,var -> var[0]})
    let l:blocks = s:getAllBlocks(l:close)

    let l:best_var = ['','',0]
    let l:best_lines = []
    let [l:all,l:isos] = s:getAllRelevantLines(l:vars,l:names,l:close)

    redraw
    echo 'Finding best lines...'
    for var in l:vars
        let l:iso = s:getIsolatedLines(var,l:names,l:all,l:blocks,l:close)
        let l:isos[var[0]] = copy(l:iso)
        let l:ratio = (len(l:iso) / l:method_length)

        if g:factorus_extract_heuristic == 'longest'
            if len(l:iso) > len(l:best_lines) && index(l:iso,l:open) < 0 && l:ratio < g:factorus_method_threshold
                let l:best_var = var
                let l:best_lines = copy(l:iso)
            endif 
        elseif g:factorus_extract_heuristic == 'greedy'
            if len(l:iso) >= g:factorus_min_extracted_lines && l:ratio < g:factorus_method_threshold
                let l:best_var = var
                let l:best_lines = copy(l:iso)
            endif
        endif
    endfor

    if len(l:best_lines) < g:factorus_min_extracted_lines
        redraw
        echo 'Nothing to extract'
        return
    endif

    redraw
    echo 'Almost done...'
    if index(l:best_lines,l:best_var[1]) < 0 && l:best_var[1] != l:open
        let l:best_lines = [l:best_var[1]] + l:best_lines
    endif

    let l:new_args = s:getNewArgs(l:best_lines,l:vars,l:all,l:best_var)
    let [l:wrapped,l:wrapped_args] = s:wrapDecs(l:best_var,l:best_lines,l:vars,l:all,l:isos,l:new_args,l:close)
    while l:wrapped != l:best_lines
        let [l:best_lines,l:new_args] = [l:wrapped,l:wrapped_args]
        let [l:wrapped,l:wrapped_args] = s:wrapDecs(l:best_var,l:best_lines,l:vars,l:all,l:isos,l:new_args,l:close)
    endwhile

    if l:best_var[1] == l:open && index(l:new_args,l:best_var) < 0
        call add(l:new_args,l:best_var)
    endif

    let l:new_args = s:getNewArgs(l:best_lines,l:vars,l:all,l:best_var)
    let [l:final,l:rep] = s:buildNewMethod(l:best_lines,l:new_args,l:blocks,l:vars,l:all,l:tab,l:close)

    call append(l:close[0]-1,l:final)
    call append(l:best_lines[-1],l:rep)

    let l:i = len(l:best_lines) - 1
    while l:i >= 0
        call cursor(l:best_lines[l:i],1)
        d 
        let l:i -= 1
    endwhile

    call search('def ' . g:factorus_method_name . '(')
    silent write!
    redraw
    echo 'Extracted ' . len(l:best_lines) . ' lines from ' . l:method_name
    return [l:method_name,l:old_lines]
endfunction

"manualExtract {{{2
function! python#factorus#manualExtract(...)
    if factorus#isRollback(a:000)
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif
    let l:name = a:0 <= 2 ? g:factorus_method_name : a:3

    echo 'Extracting new method...'
    call s:gotoTag(0)
    let l:tab = [substitute(getline('.'),'\(\s*\).*','\1',''),substitute(getline(line('.')+1),'\(\s*\).*','\1','')]
    let l:method_name = substitute(getline('.'),'^\s*def\s\+\<\(' . s:python_identifier . '\)\s*(.*','\1','')

    let [l:open,l:close] = [line('.'),s:getClosingIndent(1)]

    let l:extract_lines = range(a:1,a:2)
    let l:old_lines = getline(l:open,l:close[0]-1)

    let l:vars = s:getLocalDecs(l:close)
    let l:names = map(deepcopy(l:vars),{n,var -> var[0]})
    let l:blocks = s:getAllBlocks(l:close)
    let [l:all,l:isos] = s:getAllRelevantLines(l:vars,l:names,l:close)

    let l:new_args = s:getNewArgs(l:extract_lines,l:vars,l:all)
    let [l:final,l:rep] = s:buildNewMethod(l:extract_lines,l:new_args,l:blocks,l:vars,l:all,l:tab,l:close,l:name)

    call append(l:close[0],l:final)
    call append(l:extract_lines[-1],l:rep)

    let l:i = len(l:extract_lines) - 1
    while l:i >= 0
        call cursor(l:extract_lines[l:i],1)
        d 
        let l:i -= 1
    endwhile

    call search('def\s*\<' . l:name . '\>(')
    silent write!
    redraw
    echo 'Extracted ' . len(l:extract_lines) . ' lines from ' . l:method_name

    return [l:name,l:old_lines]
endfunction
