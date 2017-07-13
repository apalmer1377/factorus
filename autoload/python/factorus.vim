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
    let a:i = 0
    let a:j = 0
    let a:c = []

    while a:i < len(a:a) || a:j < len(a:b)
        if a:j >= len(a:b)
            call add(a:c,a:a[a:i])
            let a:i += 1
        elseif a:i >= len(a:a)
            call add(a:c,a:b[a:j])
            let a:j += 1
        elseif a:j >= len(a:b) || a:a[a:i] < a:b[a:j]
            call add(a:c,a:a[a:i])
            let a:i += 1
        elseif a:i >= len(a:a) || a:b[a:j] < a:a[a:i]
            call add(a:c,a:b[a:j])
            let a:j += 1
        else
            call add(a:c,a:a[a:i])
            let a:i += 1
            let a:j += 1
        endif
    endwhile
    return a:c
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

function! s:findTags(temp_file,search_string,append)
    let a:fout = a:append == 'yes' ? '>>' : '>'
    call system('find ' . getcwd() . g:factorus_ignore_string . '-exec grep -l "' . a:search_string . '" {} + ' . a:fout . ' ' . a:temp_file . ' 2> /dev/null')
endfunction

function! s:narrowTags(temp_file,search_string)
    let a:n_temp_file = a:temp_file . '.narrow'
    call system('cat ' . a:temp_file . ' | xargs grep -l "' . a:search_string . '" {} + > ' . a:n_temp_file)
    call system('mv ' . a:n_temp_file . ' ' . a:temp_file)
endfunction

function! s:updateQuickFix(temp_file,search_string)
    let a:res = split(system('cat ' . a:temp_file . ' | xargs grep -n "' . a:search_string . '"'),'\n')
    call map(a:res,{n,val -> split(val,':')})
    call map(a:res,{n,val -> {'filename' : val[0], 'lnum' : val[1], 'text' : s:trim(join(val[2:],':'))}})
    let s:qf += a:res
endfunction

function! s:setQuickFix(type)
    let a:title = a:type . ' : '
    if g:factorus_show_changes == 1
        let a:title .= 'ChangedFiles'
    elseif g:factorus_show_changes == 2
        let a:title .= 'UnchangedFiles'
    else
        let a:title .= 'AllFiles'
    endif

    call setqflist(s:qf)
    call setqflist(s:qf,'r',{'title' : a:title})
endfunction

function! s:getUnchanged(search)
    let a:qf = []

    let a:temp_file = '.FactorusUnchanged'
    call s:findTags(a:temp_file,a:search,'no')

    let a:count = 0
    for file in readfile(a:temp_file)
        let a:lines = split(system('grep -n "' . a:search . '" ' . file),'\n')  

        let a:count += len(a:lines)
        for line in a:lines
            let a:un = split(line,':')
            call add(a:qf,{'lnum' : a:un[0], 'filename' : file, 'text' : s:trim(join(a:un[1:],''))})
        endfor
    endfor

    call system('rm -rf ' . a:temp_file)
    return a:qf
endfunction

" Utilities {{{2

function! s:isQuoted(pat,state)
    let a:temp = a:state
    let a:mat = match(a:temp,a:pat)
    let a:res = 1
    while a:mat >= 0 && a:res == 1
        let a:begin = strpart(a:temp,0,a:mat)
        let a:quotes = len(a:begin) - len(substitute(a:begin,'["'']','','g'))
        if a:quotes % 2 == 1
            let a:res = 1
        else
            let a:res = 0
        endif
        let a:temp = substitute(a:temp,a:pat,'','')
        let a:mat = match(a:temp,a:pat)
    endwhile
    return a:res
endfunction

" Tag Navigation {{{2
" getAdjacentTag {{{3
function! s:getAdjacentTag(dir)
    return searchpos(s:function_def,'Wnc' . a:dir)
endfunction

" getClosingIndent {{{3
function! s:getClosingIndent(stack,...)
    let a:orig = [line('.'),col('.')]
    if a:0 > 0
        call cursor(a:1[0],a:1[1])
    endif
    let a:indent = substitute(getline('.'),'^\(\s*\)[^[:space:]].*','\1','')
    let a:l = a:stack == 1 ? len(a:indent) : len(a:indent) - 1
    if a:l < 0
        return [0,0]
    endif
    let a:indent = '^\s\{,' . a:l . '\}'

    let a:res = searchpos(a:indent . '[^[:space:]]','Wn')
    call cursor(a:orig[0],a:orig[1])
    return a:res
endfunction

" getClassTag {{{3
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

" gotoTag {{{3
function! s:gotoTag(head)
    let a:tag = a:head == 1 ? s:getClassTag() : s:getAdjacentTag('b') 
    if a:tag[0] <= line('.') && a:tag != [0,0]
        call cursor(a:tag[0],a:tag[1])
    else
        echo 'No tag found'
    endif
endfunction

" Class Hierarchy {{{2
" getModule {{{3
function! s:getModule(file)
    let a:git = system('git rev-parse --show-toplevel')
    let a:module = strpart(a:file,len(a:git))
    let a:module = substitute(substitute(a:module,'\.py$','',''),'\/','.','g')
    return a:module
endfunction

" Declarations {{{2
" getArgs {{{3
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
    call map(a:args,{n,val -> substitute(val,'\(^\s*\|\s*$\)','','g')})
    call map(a:args,{n,val -> [val,line('.')]})

    call cursor(a:prev[0],a:prev[1])
    return a:args
endfunction

" getLocalDecs {{{3
function! s:getLocalDecs(close)
    let a:orig = [line('.'),col('.')]
    let a:here = [line('.'),col('.')]
    let a:search = '.*\<\(' . s:python_identifier . '\)\>\s*=.*'
    let a:next = searchpos(a:search,'Wn')

    let a:vars = s:getArgs()
    let a:names = map(deepcopy(a:vars),{n,val -> val[0]})
    while s:isBefore(a:next,a:close)
        if a:next == [0,0]
            break
        endif
        
        let a:name = substitute(getline(a:next[0]),a:search,'\1','')
        call add(a:vars,[a:name,a:next[0]])
        call add(a:names,a:name)

        call cursor(a:next[0],a:next[1])
        let a:next = searchpos(a:search,'Wn')
    endwhile
    call cursor(a:orig[0],a:orig[1])

    let i = 0
    while i < len(a:names)
        let a:ind = index(a:names,a:names[i],i+1)
        if a:ind >= 0
            call remove(a:names,a:ind)
            call remove(a:vars,a:ind)
            continue
        endif
        let i += 1
    endwhile

    return a:vars
endfunction

" References {{{2
" getNextReference {{{3
function! s:getNextReference(var,type,...)
    if a:type == 'right'
        let a:search = '^\s*\(' . s:python_identifier . '\)\s*[(.=].*\<\(' . a:var . '\)\>.*$'
        let a:index = '\1'
        let a:alt_index = '\2'
    elseif a:type == 'left'
        let a:search = '^\s*\<\(' . a:var . '\)\>\s*[-+*/]\=[.=][^=].*$'
        let a:index = '\1'
        let a:alt_index = '\1'
    elseif a:type == 'cond'
        let a:search = '^\s*\(for\|while\|if\|elif\).*\<\(' . a:var . '\)\>.*:'
        let a:index = '\1'
        let a:alt_index = '\2'
    elseif a:type == 'return'
        let a:search = '^\s*\<return\>.*\<\(' . a:var . '\)\>.*'
        let a:index = '\1'
        let a:alt_index = '\1'
    endif

    let a:line = searchpos(a:search,'Wn')

    if a:line[0] > line('.')
        let a:state = getline(a:line[0])
        let a:loc = substitute(a:state,a:search,a:index,'')
        if a:0 > 0 && a:1 == 1
            let a:name = substitute(a:state,a:search,a:alt_index,'')
            return [a:loc,a:line,a:name]
        endif
        return [a:loc,a:line]
    endif
        
    return (a:0 > 0 && a:1 == 1) ? ['none',[0,0],'none'] : ['none',[0,0]]
endfunction

" getNextUse {{{3
function! s:getNextUse(var,...)
    let a:right = s:getNextReference(a:var,'right',a:0)
    let a:left = s:getNextReference(a:var,'left',a:0)
    let a:cond = s:getNextReference(a:var,'cond',a:0)
    let a:return = s:getNextReference(a:var,'return',a:0)

    let a:min = [a:right[0],copy(a:right[1]),'right']
    let a:min_name = a:0 > 0 ? a:right[2] : ''

    let a:poss = [a:right,a:left,a:cond,a:return]
    let a:idents = ['right','left','cond','return']
    for i in range(4)
        let temp = a:poss[i]
        if temp[1] != [0,0] && (s:isBefore(temp[1],a:min[1]) == 1 || a:min[1] == [0,0])
            let a:min = [temp[0],copy(temp[1]),a:idents[i]]
            if a:0 > 0
                let a:min_name = temp[2]
            endif
        endif
    endfor

    if a:0 > 0
        call add(a:min,a:min_name)
    endif

    return a:min
endfunction

" File-Updating {{{2
" updateFile {{{3
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

" Renaming {{{2
" renameArg {{{3
function! s:renameArg(new_name)
    let a:var = expand('<cword>')
    call s:updateFile(a:var,a:new_name,0,1,0)

    echo 'Re-named ' . a:var . ' to ' . a:new_name
    return a:var
endfunction

" renameClass {{{3
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
    call s:updateQuickFix(a:temp_file,'\<' . a:class_name . '\>')

    call system('cat ' . a:temp_file . ' | xargs sed -i "s/\<' . a:class_name . '\>/' . a:new_name . '/g"') 
    call system('rm -rf ' . a:temp_file)
    silent edit

    echo 'Re-named class ' . a:class_name . ' to ' . a:new_name
    return a:class_name
endfunction

" renameMethod {{{3
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
    call s:findTags(a:temp_file,a:period . '\<' . a:method_name . '\>','no')
    call s:updateQuickFix(a:temp_file,a:period . '\<' . a:method_name . '\>')
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
    silent edit
    let a:keyword = a:is_global == 1 ? ' global' : ''
    echo 'Re-named' . a:keyword . ' method ' . a:method_name . ' to ' . a:new_name
    return a:method_name
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
    let a:if = '\<if\>.*:'
    let a:for = '\<for\>.*:'
    let a:while = '\<while\>.*:'
    let a:try = '\<try\>.*:'
    let a:search = '\(' . a:if . '\|' . a:for . '\|' . a:while . '\|' . a:try . '\)'

    let a:orig = [line('.'),col('.')]
    call s:gotoTag(0)
    let a:blocks = [[line('.'),a:close[0]]]

    let a:open = searchpos(':','Wn')
    let a:next = searchpos(a:search,'Wn')
    while a:next[0] <= a:close[0]
        if a:next == [0,0]
            break
        endif
        call cursor(a:next[0],a:next[1])

        if match(getline('.'),'\<else\>') >= 0
            let a:next = searchpos(a:search,'Wn')
            continue
        endif

        if match(getline('.'),'\<\(if\|try\)\>') >= 0
            let a:open = [line('.'),col('.')]
            let a:loc_close = s:getClosingIndent(1)

            let a:o = line('.')
            while match(getline(a:loc_close[0]),'\<\(else\|elif\|except\|finally\)\>.*') >= 0
                if len(substitute(getline(a:loc_close[0]),'^\(\s*\)[[:space:]].*','\1','')) < len(substitute(getline('.'),'^\(\s*\)[[:space:]].*','\1',''))
                    break
                endif
                call cursor(a:loc_close[0],a:loc_close[1])
                call add(a:blocks,[a:o,a:loc_close[0]-1])
                let a:o = line('.')
                let a:loc_close = s:getClosingIndent(1)
            endwhile

            call add(a:blocks,[a:o,a:loc_close[0]-1])
            call add(a:blocks,[a:open[0],a:loc_close[0]-1])
            call cursor(a:open[0],a:open[1])
        else
            let a:loc_close = s:getClosingIndent(1)
            call add(a:blocks,[line('.'),a:loc_close[0]-1])
        endif

        let a:next = searchpos(a:search,'Wn')
    endwhile

    call cursor(a:orig[0],a:orig[1])
    return uniq(sort(a:blocks,'s:compare'))
endfunction

" getAllRelevantLines {{{3
function! s:getAllRelevantLines(vars,names,close)
    let a:orig = [line('.'),col('.')]
    let a:begin = s:getAdjacentTag('b')

    let a:lines = {}
    let a:closes = {}
    let a:isos = {}
    for var in a:vars
        call cursor(var[1],1)
        let a:local_close = var[1] == a:begin[0] ? s:getClosingIndent(1) : s:getClosingIndent(0)
        let a:closes[var[0]] = copy(a:local_close)
        call cursor(a:orig[0],a:orig[1])
        if index(keys(a:lines),var[0]) < 0
            let a:lines[var[0]] = [var[1]]
        else
            call add(a:lines,var[1])
        endif
        let a:isos[var[0]] = []
    endfor

    let a:search = join(a:names,'\|')
    let a:next = s:getNextUse(a:search,1)

    while s:isBefore(a:next[1],a:close) == 1
        if a:next[1] == [0,0]
            break
        endif

        let a:pause = copy(a:next)
        let a:new_search = a:search
        while a:pause[1] == a:next[1]
            let a:name = a:next[3]

            let a:ldec = a:lines[a:name][0]

            let a:quoted = s:isQuoted('\<' . a:name . '\>',getline(a:next[1][0]))
            if a:quoted == 0 
                if index(a:lines[a:name],a:next[1][0]) < 0
                    call add(a:lines[a:name],a:next[1][0])
                endif
            endif

            if match(a:new_search,'\\|') < 0
                break
            endif

            let a:new_search = substitute(a:new_search,'\\|\<' . a:name . '\>','','')
            let a:new_search = substitute(a:new_search,'\<' . a:name . '\>\\|','','')

            let a:next = s:getNextUse(a:new_search,1)
        endwhile
        let a:next = copy(a:pause)

        call cursor(a:next[1][0],a:next[1][1])
        let a:next = s:getNextUse(a:search,1)
    endwhile
    
    call cursor(a:orig[0],a:orig[1])
    return [a:lines,a:isos]
endfunction

" isIsolatedBlock {{{3
function! s:isIsolatedBlock(block,var,rels,close)
    let a:orig = [line('.'),col('.')]
    call cursor(a:block[0],1)
    if a:block[1] - a:block[0] == 0
        call cursor(line('.')-1,1)
    endif

    let a:search = join(keys(a:rels),'\|')
    let a:search = substitute(a:search,'\\|\<' . a:var[0] . '\>','','')
    let a:search = substitute(a:search,'\<' . a:var[0] . '\>\\|','','')
    let a:ref = s:getNextReference(a:search,'left',1)
    let a:return = search('\<\(return\)\>','Wn')
    let a:continue = search('\<\(continue\|break\)\>','Wn')

    let a:res = 1
    if s:contains(a:block,a:return) == 1
        let a:res = 0
    elseif s:contains(a:block,a:continue) && match(getline(a:block[0]),'\<\(for\|while\)\>') < 0
        let a:res = 0
    else
        while a:ref[1] != [0,0] && s:isBefore(a:ref[1],[a:block[1]+1,1]) == 1
            let a:i = a:rels[a:ref[2]][0]
            if s:contains(a:block,a:i) == 0
                let a:res = 0
                break
            endif
            call cursor(a:ref[1][0],a:ref[1][1])
            let a:ref = s:getNextReference(a:search,'left',1)
        endwhile
    endif

    call cursor(a:orig[0],a:orig[1])
    return a:res
endfunction

" getIsolatedLines {{{3
function! s:getIsolatedLines(var,names,rels,blocks,close)
    let a:refs = a:rels[a:var[0]]

    if len(a:refs) == 1
        return []
    endif

    let a:orig = [line('.'),col('.')]
    let [a:name,a:dec] = a:var

    let a:wraps = []
    if match(getline(a:var[1]),'\<for\>') >= 0
        let a:for = s:getContainingBlock(a:dec,a:blocks,a:blocks[0])
        if s:isIsolatedBlock(a:for,a:var,a:rels,a:close) == 0
            return []
        endif
    endif
    let a:dec_block = s:getContainingBlock(a:dec,a:blocks,a:blocks[0])
    if a:dec_block[1] - a:dec_block[0] == 0
        call add(a:wraps,copy(a:blocks[0]))
    endif
    call add(a:wraps,s:getContainingBlock(a:refs[1],a:blocks,a:blocks[0]))

    let a:usable = []
    for i in range(len(a:wraps))
        let twrap = a:wraps[i]
        let a:temp = []

        let a:next_use = s:getNextReference(a:var[0],'right')
        call cursor(a:next_use[1][0],a:next_use[1][1])

        let a:block = [0,0]
        for j in range(i,len(a:refs)-1)
            let line = a:refs[j]
            if line == a:next_use[1][0]
                if index(a:names,a:next_use[0]) >= 0
                    break
                endif
                call cursor(a:next_use[1][0],a:next_use[1][1])
                let a:next_use = s:getNextReference(a:var[0],'right')
            endif
            if line >= a:block[0] && line <= a:block[1]
                continue
            endif

            let a:block = s:getContainingBlock(line,a:blocks,twrap)
            if a:block[0] < twrap[0] || a:block[1] > twrap[1]
                break
            endif

            if s:isIsolatedBlock(a:block,a:var,a:rels,a:close) == 0 
                break
            endif

            let a:i = a:block[0]
            while a:i <= a:block[1]
                if index(a:temp,a:i) < 0
                    call add(a:temp,a:i)
                endif
                let a:i += 1
            endwhile
        endfor

        if len(a:temp) > len(a:usable)
            let a:usable = copy(a:temp)
        endif

        call cursor(a:orig[0],a:orig[1])
    endfor

    return a:usable
endfunction

" Method-Building {{{2
" getNewArgs {{{3
function! s:getNewArgs(lines,vars,rels,var)
    let a:names = map(deepcopy(a:vars),{n,var -> var[0]})
    let a:search = '\(' . join(a:names,'\|') . '\)'
    let a:search = '^.*\<' . a:search . '\>.*'
    let a:args = []

    for line in a:lines
        let a:this = getline(line)
        if match(a:this,'^\s*\(\/\/\|*\)') >= 0
            continue
        endif
        let a:new = substitute(a:this,a:search,'\1','')
        while a:new != a:this
            let a:spot = a:rels[a:new]
            let a:next_var = filter(deepcopy(a:vars),'v:val[0] == a:new')[0]

            if index(a:args,a:next_var) < 0 && index(a:lines,a:spot) < 0 && (a:next_var[0] != a:var[0] || a:next_var[1] == a:var[1]) 
                call add(a:args,a:next_var)
            endif
            let a:this = substitute(a:this,'\<' . a:new . '\>','','g')
            let a:new = substitute(a:this,a:search,'\1','')
        endwhile
    endfor
    return a:args
endfunction

" wrapDecs {{{3
function! s:wrapDecs(var,lines,vars,rels,isos,args,close)
    let a:head = s:getAdjacentTag('b')
    let a:orig = [line('.'),col('.')]
    let a:fin = copy(a:lines)
    let a:fin_args = deepcopy(a:args)
    for arg in a:args

        if arg[1] == a:head[0]
            continue
        endif

        let a:wrap = 1
        let a:name = arg[0]
        let a:next = s:getNextUse(a:name)

        while a:next[1] != [0,0] && s:isBefore(a:next[1],a:close) == 1
            if a:next[2] != 'left' && index(a:lines,a:next[1][0]) < 0
                let a:wrap = 0    
                break
            endif
            call cursor(a:next[1][0],a:next[1][1])
            let a:next = s:getNextUse(a:name)
        endwhile

        if a:wrap == 1
            let a:relevant = a:rels[arg[0]][arg[2]]
            let a:stop = arg[1]
            let a:dec = [a:stop]
            while match(getline(a:stop),';') < 0
                let a:stop += 1
                call add(a:dec,a:stop)
            endwhile
            let a:iso = a:dec + a:isos[arg[0]]

            let a:con = 1
            for rel in a:relevant
                if index(a:iso,rel) < 0 && index(a:lines,rel) < 0
                    let a:con = 0
                    break
                endif
            endfor
            if a:con == 0
                continue
            endif

            let a:next_args = s:getNewArgs(a:iso,a:vars,a:rels,arg)
            let a:fin = uniq(s:merge(a:fin,a:iso))

            call remove(a:fin_args,index(a:fin_args,arg))
            for narg in a:next_args
                if index(a:fin_args,narg) < 0 && narg[0] != a:var[0]
                    call add(a:fin_args,narg)
                endif
            endfor
        endif
        call cursor(a:orig[0],a:orig[1])
    endfor

    call cursor(a:orig[0],a:orig[1])
    return [a:fin,a:fin_args]
endfunction

" buildArgs {{{3
function! s:buildArgs(args)
    let a:defs = map(deepcopy(a:args),{n,arg -> arg[0]})
    return join(a:defs,',')
endfunction

" formatMethod {{{3
function! s:formatMethod(def,body,return,lines,spaces)
    let a:paren = stridx(a:def[0],'(')
    let a:def_space = repeat(' ',a:paren+1)
    call map(a:def,{n,line -> a:spaces[0] . (n > 0 ? a:def_space : '') . substitute(line,'^\s*\(.*\)','\1','')})

    let a:dspaces = join(a:spaces,'')
    let a:i = 0

    call map(a:body,{n,line -> substitute(line,'^\s*\(.*\)','\1','')})
    let a:next_closes = []
    while a:i < len(a:lines)
        if len(a:next_closes) > 0 && s:isBefore(a:next_closes[-1],[a:lines[a:i],1])
            call remove(a:next_closes,len(a:next_closes)-1)
        endif

        let a:tspaces = a:dspaces . repeat(a:spaces[1],len(a:next_closes))
        let a:body[a:i] = a:tspaces . a:body[a:i]

        if match(a:body[a:i],':\s*$') >= 0
            call add(a:next_closes,s:getClosingIndent(1,[a:lines[a:i],1]))
        endif

        let a:i += 1
    endwhile
    call add(a:body,a:dspaces . substitute(a:return,'^\s*\(.*\)','\1',''))
endfunction

" buildNewMethod {{{3
function! s:buildNewMethod(var,lines,args,ranges,vars,rels,tab,close)
    call cursor(a:lines[-1],1)
    let a:return = ''
    let a:call = ''

    let a:outer = s:getContainingBlock(a:lines[0],a:ranges,a:ranges[0])
    let a:include_dec = 1
    for var in a:vars
        if index(a:lines,var[1]) >= 0
            let a:outside = s:getNextUse(var[0])    
            if a:outside[1] != [0,0] && s:isBefore(a:outside[1],a:close) == 1
                let a:contain = s:getContainingBlock(var[1],a:ranges,a:ranges[0])
                if a:contain[0] <= a:outer[0] || a:contain[1] >= a:outer[1]
                    let a:type = var[1]
                    let a:return = 'return ' . var[0]
                    let a:call = var[0] . ' = '

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

                    let a:inner = s:getContainingBlock(a:lines[i+1],a:ranges,a:outer)
                    if a:inner[1] - a:inner[0] > 0
                        let a:removes = []
                        for j in range(i+1)
                            if match(getline(a:lines[j]),'\<' . var[0] . '\>') >= 0
                                call add(a:removes,j)
                            endif
                        endfor
                        for rem in reverse(a:removes)
                            call remove(a:lines,rem)
                        endfor
                        let a:include_dec = 0
                    endif
                    break
                endif
            endif
        endif
    endfor
    let a:body = map(copy(a:lines),{n,line -> getline(line)})

    let a:arg_string = s:buildArgs(a:args)
    let a:build_string = 'def ' .  g:factorus_method_name . '(' . a:arg_string . '):'
    let a:temp = join(reverse(split(a:build_string, '.\zs')), '')
    let a:def = []

    if g:factorus_split_lines == 1
        while len(a:temp) >= g:factorus_line_length
            let i = stridx(a:temp,'|',len(a:temp) - g:factorus_line_length)
            if i <= 0
                break
            endif
            let a:segment = strpart(a:temp,0,i)
            let a:segment = join(reverse(split(a:segment, '.\zs')), '')
            let a:segment = substitute(a:segment,'|',',','g')
            call add(a:def,a:segment)
            let a:temp = strpart(a:temp,i)
        endwhile
    endif

    let a:temp = join(reverse(split(a:temp, '.\zs')), '')
    let a:temp = substitute(a:temp,'|',',','g')
    call add(a:def,a:temp)
    call reverse(a:def)

    call s:formatMethod(a:def,a:body,a:return,a:lines,a:tab)
    let a:final = a:def + a:body + ['']

    let a:call_space = substitute(getline(s:getContainingBlock(a:lines[-1],a:ranges,a:ranges[0])[0]),'\(\s*\).*','\1','')
    let a:rep = [a:call_space . a:call . g:factorus_method_name . '(' . a:arg_string . ')']

    return [a:final,a:rep]
endfunction

" Rollback {{{2
" rollbackExtraction {{{3
function! s:rollbackExtraction()
    let a:open = search('def ' . g:factorus_method_name . '(')
    let a:close = s:getClosingIndent(1)[0] - 1

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
    let a:close = s:getClosingIndent(1)[0] - 1

    execute 'silent ' . a:open . ',' . a:close . 'delete'
    call append(line('.')-1,g:factorus_history['old'][1])
    call cursor(a:open,1)
    silent write
endfunction

" Global Functions {{{1
" addParam {{{2
function! python#factorus#addParam(param_name,...)
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

" renameSomething {{{2
function! python#factorus#renameSomething(new_name,type,...)
    let a:orig = [line('.'),col('.')]
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
    let a:project_dir = g:factorus_project_dir == '' ? system('git rev-parse --show-toplevel') : g:factorus_project_dir
    execute 'silent cd ' a:project_dir

    let a:res = ''
    try
        let Rename = function('s:rename' . a:type)
        let a:res = Rename(a:new_name)

        if a:0 > 0 && a:000[-1] == 'factorusRollback'
            let a:res = 'Rolled back renaming of ' . substitute(g:factorus_history['args'][-2],'\(.\)\(.*\)','\L\1\E\2','') . ' ' . g:factorus_history['old']
        else
            if g:factorus_show_changes > 0
                let a:ch = len(s:qf)
                let a:ch_i = a:ch == 1 ? ' instance ' : ' instances '
                let a:un = s:getUnchanged('\<' . a:res . '\>')
                let a:un_l = len(a:un)
                let a:un_i = a:un_l == 1 ? ' instance ' : ' instances '

                let a:first_line = a:ch . a:ch_i . 'modified, ' . a:un_l . a:un_i . 'left unmodified.'

                if g:factorus_show_changes > 1
                    let a:un = [{'pattern' : 'Unmodified'}] + a:un
                    if g:factorus_show_changes == 2
                        let s:qf = []
                    endif
                    let s:qf += a:un
                endif

                if g:factorus_show_changes % 2 == 1
                    let s:qf = [{'pattern' : 'Modified'}] + s:qf
                endif
                let s:qf = [{'text' : a:first_line,'pattern' : 'rename' . a:type}] + s:qf

                call s:setQuickFix(a:type)
            endif
        endif

        execute 'silent cd ' a:prev_dir
        if a:type != 'Class'
            let &switchbuf = 'useopen,usetab'
            execute 'silent sbuffer ' . a:curr_buf
            let &switchbuf = a:buf_setting
        endif
        call cursor(a:orig[0],a:orig[1])

        return a:res
    catch /.*/
        call system('rm -rf .Factorus*')
        execute 'silent cd ' a:prev_dir
        if a:type != 'Class'
            let &switchbuf = 'useopen,usetab'
            execute 'silent sbuffer ' . a:curr_buf
            let &switchbuf = a:buf_setting
        endif
        let a:err = match(v:exception,'^Factorus:') >= 0 ? v:exception : 'Factorus:' . v:exception
        throw a:err
    endtry
endfunction

" extractMethod {{{2
function! python#factorus#extractMethod(...)
    if a:0 > 0 && a:1 == 'factorusRollback'
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif
    echo 'Extracting new method...'
    call s:gotoTag(0)
    let a:tab = [substitute(getline('.'),'\(\s*\).*','\1',''),substitute(getline(line('.')+1),'\(\s*\).*','\1','')]
    let a:method_name = substitute(getline('.'),'^\s*def\s\+\<\(' . s:python_identifier . '\)\s*(.*','\1','')

    let [a:open,a:close] = [line('.'),s:getClosingIndent(1)]
    let a:old_lines = getline(a:open,a:close[0]-1)

    call searchpos(':','W')

    let a:method_length = (a:close[0] - (line('.') + 1)) * 1.0
    let a:vars = s:getLocalDecs(a:close)
    let a:names = map(deepcopy(a:vars),{n,var -> var[0]})
    let a:blocks = s:getAllBlocks(a:close)

    let a:best_var = ['','',0]
    let a:best_lines = []
    let [a:all,a:isos] = s:getAllRelevantLines(a:vars,a:names,a:close)

    redraw
    echo 'Finding best lines...'
    for var in a:vars
        let a:iso = s:getIsolatedLines(var,a:names,a:all,a:blocks,a:close)
        let a:isos[var[0]] = copy(a:iso)
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
    if index(a:best_lines,a:best_var[1]) < 0 && a:best_var[1] != a:open
        let a:best_lines = [a:best_var[1]] + a:best_lines
    endif

    let a:new_args = s:getNewArgs(a:best_lines,a:vars,a:all,a:best_var)
    let [a:wrapped,a:wrapped_args] = s:wrapDecs(a:best_var,a:best_lines,a:vars,a:all,a:isos,a:new_args,a:close)
    while a:wrapped != a:best_lines
        let [a:best_lines,a:new_args] = [a:wrapped,a:wrapped_args]
        let [a:wrapped,a:wrapped_args] = s:wrapDecs(a:best_var,a:best_lines,a:vars,a:all,a:isos,a:new_args,a:close)
    endwhile

    if a:best_var[1] == a:open && index(a:new_args,a:best_var) < 0
        call add(a:new_args,a:best_var)
    endif

    let a:new_args = s:getNewArgs(a:best_lines,a:vars,a:all,a:best_var)
    let [a:final,a:rep] = s:buildNewMethod(a:best_var,a:best_lines,a:new_args,a:blocks,a:vars,a:all,a:tab,a:close)

    call append(a:close[0]-1,a:final)
    call append(a:best_lines[-1],a:rep)

    let a:i = len(a:best_lines) - 1
    while a:i >= 0
        call cursor(a:best_lines[a:i],1)
        d 
        let a:i -= 1
    endwhile

    call search('def ' . g:factorus_method_name . '(')
    silent write
    redraw
    echo 'Extracted ' . len(a:best_lines) . ' lines from ' . a:method_name
    return [a:method_name,a:old_lines]
endfunction
