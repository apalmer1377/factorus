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
" Utilities {{{2

function! s:is_quoted(pat,state)
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
" get_adjacent_tag {{{3
function! s:get_adjacent_tag(dir)
    return searchpos(s:function_def,'Wnc' . a:dir)
endfunction

" getClosingIndent {{{3

" Ideally, would get the last line of the block; currently, returns the first
" line outside of the block.
function! s:getClosingIndent(stack,...)
    let l:orig = [line('.'),col('.')]
    if a:0 > 0
        call cursor(a:1)
    endif
    let l:indent = substitute(getline('.'),'^\(\s*\)[^[:space:]].*','\1','')
    let l:l = a:stack == 1 ? len(l:indent) : len(l:indent) - 1
    if l:l < 0
        return [0,0]
    endif
    let l:indent = '^\s\{,' . l:l . '\}'

    let l:res = searchpos(l:indent . '[^[:space:]]','Wn')
    call cursor(l:orig)
    return l:res
endfunction

function! s:getIndentSpaces()
    let l:orig = [line('.'),col('.')]
    call cursor(1,1)
    let l:spaces = 1
    let l:search = search('^\s\{1,' . l:spaces . '\}[^[:space:]]','Wn')
    while l:search == 0
        let l:spaces += 1
        let l:search = search('^\s\{1,' . l:spaces . '\}[^[:space:]]','Wn')
    endwhile
    return substitute(getline(l:search),'^\(\s*\)[^[:space:]].*','\1','')
endfunction

function! s:getLastLine(at_start,...)
    let l:orig = [line('.'),col('.')]
    if a:0 > 0
        call cursor(a:1)
    endif
    let l:indent = substitute(getline('.'),'^\(\s*\)[^[:space:]].*','\1','')
    let l:l = a:at_start == 1 ? len(l:indent) : len(l:indent) - 1
    if l:l < 0
        return [0,0]
    endif
    let l:indent = '^\s\{,' . l:l . '\}'

    let l:res = search(l:indent . '[^[:space:]]','Wn') - 1
    if l:res == -1
        let l:res = line('$')
    endif
    call cursor(l:orig)
    return l:res
endfunction

" get_class_tag {{{3
function! s:get_class_tag()
    let l:res = searchpos(s:class_def,'Wnbc')
    if l:res == [0,0]
        return l:res
    endif
    let l:close = s:getLastLine(0)
    let l:orig = [line('.'),col('.')]
    call cursor(l:res)
    let l:class_close = s:getLastLine(1)
    if l:class_close < l:close
        let l:res = [0,0]
    endif
    call cursor(l:orig)
    return l:res
endfunction

" go_to_tag {{{3

" Jumps to a 'tag' previous to the cursor's current position. If head is 0,
" jumps to the closest tag; otherwsie, jumps to the class tag.
function! s:go_to_tag(head)
    let l:tag = a:head == 1 ? s:get_class_tag() : s:get_adjacent_tag('b') 
    if l:tag[0] <= line('.') && l:tag != [0,0]
        call cursor(l:tag)
    else
        echo 'No tag found'
    endif
endfunction

" Class Hierarchy {{{2
" get_module {{{3
function! s:get_module(file)
    let l:project_dir = factorus#project_dir()
    let l:module = strpart(a:file,len(l:project_dir))
    let l:module = substitute(substitute(l:module,'\.py$','',''),'\/','.','g')
    return l:module
endfunction

" Declarations {{{2
" getArgs {{{3
function! s:getArgs() abort
    let l:prev = [line('.'),col('.')]
    call s:go_to_tag(0)
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

    call cursor(l:prev)
    return l:args
endfunction

" getLocalDecs {{{3

" Returns a list of all local declarations within a method, including
" parameters.
"
" Return value: vars. vars is a list of doubles of the form [name,dec], where
" name is the variable name, and dec is the line on which it is declared.
function! s:getLocalDecs(close)
    let l:orig = [line('.'),col('.')]
    let l:here = [line('.'),col('.')]
    let l:search = '.*\<\(' . s:python_identifier . '\)\>\s*=.*'
    let l:next = searchpos(l:search,'Wn')

    let l:vars = s:getArgs()
    let l:names = map(deepcopy(l:vars),{n,val -> val[0]})

    while l:next[0] <= a:close
        if l:next == [0,0]
            break
        endif
        
        let l:name = substitute(getline(l:next[0]),l:search,'\1','')
        call add(l:vars,[l:name,l:next[0]])
        call add(l:names,l:name)

        call cursor(l:next)
        let l:next = searchpos(l:search,'Wn')
    endwhile
    call cursor(l:orig)

    let i = len(l:names) - 1
    while i >= 0
        let l:ind = index(l:names,l:names[i])
        if l:ind < i
            call remove(l:names,i)
            call remove(l:vars,i)
        endif
        let i -= 1
    endwhile

    return l:vars
endfunction

" References {{{2
" getNextReference {{{3

" Returns the next reference to var, of type type. Type can be 'right',
" 'left', 'cond', or 'return', which refers to whether var is on the
" right-hand side of an assignment, the left-hand side of an assignment, in a
" condition (or for loop, etc.), or in a return statement.
"
" Return value: [l:loc, l:line, l:name]
function! s:getNextReference(var,type)
    if a:type == 'right'
        let l:search = '^\s*\(' . s:python_identifier . '\)\s*[(.=].*\<\(' . a:var . '\)\>.*$'
        let l:index = '\1'
        let l:alt_index = '\2'
    elseif a:type == 'left'
        let l:search = '^\s*\<\(' . a:var . '\)\>\s*[-+*/]\=[.=][^=].*$'
        let l:index = '\1'
        let l:alt_index = '\1'
    elseif a:type == 'cond'
        let l:search = '^\s*\(for\|while\|if\|elif\).*\<\(' . a:var . '\)\>.*:.*$'
        let l:index = '\1'
        let l:alt_index = '\2'
    elseif a:type == 'return'
        let l:search = '^\s*\<return\>.*\<\(' . a:var . '\)\>.*$'
        let l:index = '\1'
        let l:alt_index = '\1'
    endif

    let l:line = searchpos(l:search,'Wn')

    if l:line[0] > line('.')
        let l:state = getline(l:line[0])
        let l:loc = substitute(l:state,l:search,l:index,'')
        let l:name = substitute(l:state,l:search,l:alt_index,'')
        return [l:loc,l:line,l:name]
        return [l:loc,l:line]
    endif
        
    return ['none', [0,0], 'none']
endfunction

" getNextUse {{{3

" Returns the next use of var in the method.
"
" Return value: [loc, pos, type, name], where loc is the relvant thing
" referencing var, pos is the position of the reference, type is the type of
" use of var, and name is just the name of var.
function! s:getNextUse(var)
    let l:right = s:getNextReference(a:var,'right')
    let l:left = s:getNextReference(a:var,'left')
    let l:cond = s:getNextReference(a:var,'cond')
    let l:return = s:getNextReference(a:var,'return')

    let l:min = [l:right[0],copy(l:right[1]), 'right']
    let l:min_name = l:right[2]

    let l:poss = [l:right,l:left,l:cond,l:return]
    let l:idents = ['right', 'left', 'cond', 'return']
    for i in range(4)
        let temp = l:poss[i]
        if temp[1] != [0,0] && (factorus#util#is_before(temp[1],l:min[1]) || l:min[1] == [0,0])
            let l:min = [temp[0],copy(temp[1]),l:idents[i]]
            let l:min_name = temp[2]
        endif
    endfor

    call add(l:min,l:min_name)
    return l:min
endfunction

" File-Updating {{{2
" updateFile {{{3
function! s:updateFile(old_name,new_name,is_method,is_local,is_global)
    let l:orig = line('.')

    if a:is_local == 1
        let l:query = '\([^.]\)\<' . a:old_name . '\>'
        call add(s:qf,{'filename' : expand('%:p'), 'lnum' : line('.'), 'text' : factorus#util#trim(getline('.'))})
        execute 'silent s/' . l:query . '/\1' . a:new_name . '/g'

        call s:go_to_tag(0)
        let l:closing = s:getLastLine(1)

        let l:next = search(l:query,'Wn')
        while l:next <= l:closing
            if l:next == 0
                break
            endif
            call cursor(l:next,1)
            execute 'silent s/' . l:query . '/\1' . a:new_name . '/g'

            let l:next = search(l:query,'Wn')
        endwhile
    else
        let l:paren = a:is_method == 1 ? '(' : ''
        let l:period = a:is_global == 1 ? '\([^.]\)\{0,1\}' : '\(\.\)'
        let l:search = l:period . '\<' . a:old_name . '\>' . l:paren
        try
            execute 'silent lvimgrep /' . l:search . '/j %:p'
            let s:qf += map(getloclist(0),{n,val -> {'filename' : expand('%:p'), 'lnum' : val['lnum'], 'text' : factorus#util#trim(val['text'])}})
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
    let l:class_line = s:get_class_tag()[0]
    let l:class_name = substitute(getline(l:class_line),s:class_def,'\1','')
    if l:class_name == a:new_name
        throw 'Factorus:Duplicate'
    endif    
    let g:factorus_history['old'] = l:class_name

    let l:module_name = s:get_module(expand('%:p'))

    let l:temp_file = '.Factorus' . l:class_name
    let l:module_name = substitute(l:module_name,'\.','\\.','g')
    let l:module_name = substitute(l:module_name,'\(.*\)\(\\\..*\)','\\(\1\\)\\{0,1\\}\2','')
    call factorus#util#find_tags(l:temp_file,'\<' . l:class_name . '\>','no')
    call factorus#util#update_quick_fix(l:temp_file,'\<' . l:class_name . '\>')

    try
        call system('cat ' . l:temp_file . ' | xargs sed -i "s/\<' . l:class_name . '\>/' . a:new_name . '/g"') 
        call system('rm -rf ' . l:temp_file)
    catch /.*/
        call system('cat ' . l:temp_file . ' | xargs sed -i "s/' . l:period . '\<' . l:method_name . '\>/\1' . a:new_name . '/g"')
        call system('rm -rf ' . l:temp_file)
        throw 'Factorus: ' . v:exception . ', at ' . v:throwpoint
    endtry

    silent edit!

    if !factorus#is_rollback(a:000)
        redraw
        echo 'Re-named class ' . l:class_name . ' to ' . a:new_name
    endif
    return l:class_name
endfunction

" renameMethod {{{3
function! s:renameMethod(new_name,...) abort
    call s:go_to_tag(0)
    let l:class = s:get_class_tag()

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
    call factorus#util#find_tags(l:temp_file,l:period . '\<' . l:method_name . '\>','no')
    call factorus#util#update_quick_fix(l:temp_file,l:period . '\<' . l:method_name . '\>')
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
function! s:getContainingBlock(line,blocks,exclude)
    for block in a:blocks
        if block[0] > a:line
            return [a:line,a:line]
        endif

        if block[1] >= a:line && block[0] > a:exclude[0]
            return block
        endif
    endfor
    return [a:line,a:line]
endfunction

" getAllBlocks {{{3

" Gets all blocks of code within a method. A block is an if/else statement,
" for loop, etc.
function! s:getAllBlocks(close)

    " Define search sequences for all different blocks.
    let l:if = '\<if\>.*:'
    let l:for = '\<for\>.*:'
    let l:while = '\<while\>.*:'
    let l:try = '\<try\>.*:'
    let l:search = '\(' . l:if . '\|' . l:for . '\|' . l:while . '\|' . l:try . '\)'

    let l:orig = [line('.'),col('.')]
    call s:go_to_tag(0)
    let l:blocks = [[line('.'),a:close]]

    let l:next = searchpos(l:search,'Wn')
    while l:next[0] <= a:close
        if l:next == [0,0]
            break
        endif
        call cursor(l:next)

        if match(getline('.'),'\<else\>') >= 0
            let l:next = searchpos(l:search,'Wn')
            continue
        endif

        if match(getline('.'),'\<\(if\|try\|for\|while\)\>') >= 0
            let l:open = [line('.'),col('.')]
            let l:loc_close = s:getLastLine(1)

            let l:o = line('.')
            while match(getline(l:loc_close + 1),'\<\(else\|elif\|except\|finally\)\>.*') >= 0
                if len(substitute(getline(l:loc_close + 1),'^\(\s*\)[[:space:]].*','\1','')) < len(substitute(getline('.'),'^\(\s*\)[[:space:]].*','\1',''))
                    break
                endif
                call cursor(l:loc_close + 1,1)
                call add(l:blocks,[l:o,l:loc_close])
                let l:o = line('.')
                let l:loc_close = s:getLastLine(1)
            endwhile

            call add(l:blocks,[l:o,l:loc_close])
            call add(l:blocks,[l:open[0],l:loc_close])
            call cursor(l:open)
        else
            let l:loc_close = s:getLastLine(1)
            call add(l:blocks,[line('.'),l:loc_close])
        endif

        let l:next = searchpos(l:search,'Wn')
    endwhile

    call cursor(l:orig)
    return uniq(sort(l:blocks,'factorus#util#compare_blocks'))
endfunction

" getAllRelevantLines {{{3
"
" Returns all lines that reference any variables in vars (essentially, all
" lines except commented lines and lines exclusively representing outside
" functions or variables), referenced by which variables they reference.
"
" Return value: [lines, isos], where lines and isos are both dictionaries. The
" key values for both are the names of the variables; lines contains all lines
" that reference that variable, whereas isos is empty, and is added to in the
" next step of extractMethod.
function! s:getAllRelevantLines(vars,names,close)
    let l:orig = [line('.'),col('.')]
    let l:begin = s:get_adjacent_tag('b')

    let l:lines = {}
    let l:closes = {}
    let l:isos = {}
    for [name,dec] in a:vars
        call cursor(dec,1)
        let l:local_close = dec == l:begin[0] ? s:getLastLine(1) : s:getLastLine(0)
        let l:closes[name] = l:local_close
        call cursor(l:orig)
        if index(keys(l:lines),name) < 0
            let l:lines[name] = [dec]
        else
            call add(l:lines,dec)
        endif
        let l:isos[name] = []
    endfor

    let l:search = join(a:names,'\|')
    let l:next = s:getNextUse(l:search)

    while l:next[1][0] <= a:close
        if l:next[1] == [0,0]
            break
        endif

        let l:pause = deepcopy(l:next)
        let l:new_search = l:search
        while l:pause[1] == l:next[1]
            let l:name = l:next[3]

            let l:ldec = l:lines[l:name][0]

            let l:quoted = s:is_quoted('\<' . l:name . '\>',getline(l:next[1][0]))
            if !l:quoted
                if index(l:lines[l:name],l:next[1][0]) < 0
                    call add(l:lines[l:name],l:next[1][0])
                endif
            endif

            if match(l:new_search,'\\|') < 0
                break
            endif

            let l:new_search = substitute(l:new_search,'\\|\<' . l:name . '\>','','')
            let l:new_search = substitute(l:new_search,'\<' . l:name . '\>\\|','','')

            let l:next = s:getNextUse(l:new_search)
        endwhile
        let l:next = deepcopy(l:pause)

        call cursor(l:next[1])
        let l:next = s:getNextUse(l:search)
    endwhile
    
    call cursor(l:orig)
    return [l:lines,l:isos]
endfunction

" isIsolatedBlock {{{3

" Checks whether block is isolated relative to var.
"
" Return value: 1 if block doesn't contain any return values, continue/breaks,
" or references to variables that aren't declarations of those variables, and
" 0 otherwise.
function! s:isIsolatedBlock(block,var,rels,close)
    let l:orig = [line('.'),col('.')]
    call cursor(a:block[0],1)
    if a:block[1] == a:block[0] 
        call cursor(line('.')-1,1)
    endif

    let l:search = join(keys(a:rels),'\|')
    let l:search = substitute(l:search,'\\|\<' . a:var[0] . '\>','','')
    let l:search = substitute(l:search,'\<' . a:var[0] . '\>\\|','','')
    let l:ref = s:getNextReference(l:search,'left')
    let l:return = search('\<\(return\)\>','Wn')
    let l:continue = search('\<\(continue\|break\)\>','Wn')

    let l:res = 1
    if factorus#util#contains(a:block,l:return)
        let l:res = 0
    elseif factorus#util#contains(a:block,l:continue) && match(getline(a:block[0]),'\<\(for\|while\)\>') < 0
        let l:res = 0
    else
        while l:ref[1] != [0,0] && l:ref[1][0] <= a:block[1]
            let l:i = a:rels[l:ref[2]][0]
            if !factorus#util#contains(a:block,l:i)
                let l:res = 0
                break
            endif
            call cursor(l:ref[1])
            let l:ref = s:getNextReference(l:search,'left')
        endwhile
    endif

    call cursor(l:orig)
    return l:res
endfunction

" getIsolatedLines {{{3
"
" Returns all isolated lines related to a variable.
"
function! s:getIsolatedLines(var,names,rels,blocks,close)
    let l:refs = a:rels[a:var[0]]

    " If the only relevant line for var is its declaration, return an empty
    " array.
    if len(l:refs) == 1
        return []
    endif

    let l:orig = [line('.'),col('.')]
    let [l:name,l:dec] = a:var
    let l:wraps = []

    let l:dec_block = s:getContainingBlock(l:dec,a:blocks,a:blocks[0])

    if match(getline(l:dec),'\<for\>') >= 0
        if !s:isIsolatedBlock(l:dec_block,a:var,a:rels,a:close)
            return []
        endif
    endif

    if l:dec_block[1] == l:dec_block[0] 
        call add(l:wraps,copy(a:blocks[0]))
    endif
    call add(l:wraps,s:getContainingBlock(l:refs[1],a:blocks,a:blocks[0]))

    let l:usable = []
    for i in range(len(l:wraps))
        let twrap = l:wraps[i]
        let l:temp = []

        let l:next_use = s:getNextReference(l:name,'right')
        call cursor(l:next_use[1])

        " Starting from i avoids a possible issue where var is declared in a
        " block, but its next reference is in a different block. In that case,
        " we need to make sure that var's declaration is in an isolated block,
        " so we start from the declaration. If var is not declared in a block,
        " however, we don't need to check the isolation of its declaration, as
        " we can just use it as a parameter; so, we start from the reference
        " after the declaration.
        let l:block = [0,0]
        for line in l:refs[i:]
            
            " If this reference is our next_use, we check to see if that use
            " contains any reference to another variable; if it does, these
            " lines can't be isolated, so we break.
            if line == l:next_use[1][0]
                if index(a:names,l:next_use[0]) >= 0
                    break
                endif
                call cursor(l:next_use[1])
                let l:next_use = s:getNextReference(l:name,'right')
            endif

            " If the line is contained in the current block, we already added
            " it, so move on.
            if factorus#util#contains(l:block,line)
                continue
            endif

            " Get the next containing block (not including the wrapper we're
            " in); if that block is outside the wrapper we're in, these lines
            " can't be extracted, so we break.
            let l:block = s:getContainingBlock(line,a:blocks,twrap)
            if l:block[0] < twrap[0] || l:block[1] > twrap[1]
                break
            endif

            if !s:isIsolatedBlock(l:block,a:var,a:rels,a:close)
                break
            endif

            " Add all lines in block to temp.
            for k in range(l:block[0],l:block[1])
                if index(l:temp,k) < 0
                    call add(l:temp,k)
                endif
            endfor
        endfor

        " If temp has more lines than our current list of usable lines, set
        " the usable lines to temp.
        if len(l:temp) > len(l:usable)
            let l:usable = copy(l:temp)
        endif

        call cursor(l:orig)
    endfor

    return l:usable
endfunction

" initExtraction {{{3

" Gets all necessary variables for extractMethod.
"
" Return values:
"   orig: Original position of cursor.
"   indent: The indent level of the current method.
"   method_name: Name of the current method.
"   open: First line of the current method.
"   close: Last line of the current method.
"   old_lines: All lines of the current method.
"   vars: All variables defined in the current method.
"   names: Names of all variables defined in the current method.
function! s:initExtraction()
    let l:orig = [line('.'),col('.')]
    call s:go_to_tag(0)
    let l:indent = substitute(getline('.'),'^\(\s*\)[^[:space:]].*','\1','')
    let l:method_name = substitute(getline('.'),'^\s*def\s\+\<\(' . s:python_identifier . '\)\s*(.*','\1','')

    let [l:open,l:close] = [line('.'),s:getLastLine(1)]
    let l:old_lines = getline(l:open,l:close)

    call searchpos(':','W')

    " Get all locally declared variables and all blocks of code within current
    " method, then get the relevant lines for each variable.
    let l:vars = s:getLocalDecs(l:close)
    let l:names = map(deepcopy(l:vars),{n,var -> var[0]})
    let l:blocks = s:getAllBlocks(l:close)
    let [l:all,l:isos] = s:getAllRelevantLines(l:vars,l:names,l:close)

    return [l:orig, l:indent, l:method_name, l:open, l:close, l:old_lines, l:vars, l:names, l:blocks, l:all, l:isos]
endfunction

" Method-Building {{{2

" getBestVar {{{3

" Gets the best variable to extract the method around, according to the
" desired heuristic.
function! s:getBestVar(vars,names,isos,all,blocks,open,close)
    let l:best_var = ['','',0]
    let l:best_lines = []
    let l:method_length = (a:close - line('.')) * 1.0

    for var in a:vars
        let l:iso = s:getIsolatedLines(var,a:names,a:all,a:blocks,a:close)
        let a:isos[var[0]] = copy(l:iso)
        let l:ratio = (len(l:iso) / l:method_length)

        " If the extraction heuristic is 'longest', take the largest block of
        " isolated lines. Otherwise, take the first block that is longer than
        " min_extracted_lines and shorter than method_threshold.
        if g:factorus_extract_heuristic == 'longest'
            if len(l:iso) > len(l:best_lines) && index(l:iso,a:open) < 0 && l:ratio < g:factorus_method_threshold
                let l:best_var = var
                let l:best_lines = copy(l:iso)
            endif 
        elseif g:factorus_extract_heuristic == 'greedy'
            if l:best_var[0] != ''
                continue
            elseif len(l:iso) >= g:factorus_min_extracted_lines && l:ratio < g:factorus_method_threshold
                let l:best_var = var
                let l:best_lines = copy(l:iso)
            endif
        endif
    endfor

    return [l:best_var,l:best_lines]
endfunction

" getNewArgs {{{3

" Returns the arguments required for the method being built. If the optional
" argument is given, does not return that as an argument.
"
" Return value: args. args is an array of variables, each of which will become
" an argument in the method being built.
function! s:getNewArgs(lines,vars,rels,...)
    let l:names = map(deepcopy(a:vars),{n,var -> var[0]})
    "let l:search = '\(' . join(l:names,'\|') . '\)'
    "let l:search = '^.*\<' . l:search . '\>.*'
    let l:search = '^.*\<\(' . join(l:names,'\|') . '\)\>.*'
    let l:args = []
    let l:var = a:0 > 0 ? a:1 : ['',0]

    " Go through all the lines in our new method and look for references to
    " other variables.
    for line in a:lines
        let l:this = getline(line)

        " If the line is commented, skip it.
        if match(l:this,'^\s*\(#\|"\)') >= 0
            continue
        endif

        " Each line may reference multiple variables, so add each one that
        " isn't the given variable (if variable is given), and remove it from
        " the line so we don't double-count.
        let l:new = substitute(l:this,l:search,'\1','')
        while l:new != l:this
            let l:spot = a:rels[l:new][0]
            let l:next_var = filter(deepcopy(a:vars),'v:val[0] == l:new')[0]

            if index(l:args,l:next_var) < 0 && index(a:lines,l:spot) < 0 && (l:next_var[0] != l:var[0] || l:next_var[1] == l:var[1]) 
                call add(l:args,l:next_var)
            endif
            let l:this = substitute(l:this,'\<' . l:new . '\>','','g')
            let l:new = substitute(l:this,l:search,'\1','')
        endwhile
    endfor
    return l:args
endfunction

" wrapDecs {{{3

" Wraps any declarations into the method we're about to build; that is, if a
" variable is used only for the lines of our new function, we can just wrap
" that variable into the new function.
"
" Return value: [fin, fin_args]. fin is the finalized lines we'll be
" extracting, and fin_args are the finalized arguments for the new method.
function! s:wrapDecs(var,lines,vars,rels,isos,args,close)
    let l:head = s:get_adjacent_tag('b')
    let l:orig = [line('.'),col('.')]
    let l:fin = copy(a:lines)
    let l:fin_args = deepcopy(a:args)

    " Loop through our arguments and see if we can just wrap them into the new
    " method.
    for arg in a:args
        if arg[1] == l:head[0]
            continue
        endif

        let l:wrap = 1
        let l:name = arg[0]
        let l:next = s:getNextUse(l:name)

        " If we use this variable for something other than our new method, we
        " shouldn't wrap it, just to be safe.
        while l:next[1] != [0,0] && l:next[1][0] <= a:close
            if l:next[2] != 'left' && index(a:lines,l:next[1][0]) < 0
                let l:wrap = 0    
                break
            endif
            call cursor(l:next[1])
            let l:next = s:getNextUse(l:name)
        endwhile

        " If we only use this variable in the context of our new method, make
        " sure we can wrap it.
        if l:wrap == 1
            let l:relevant = a:rels[arg[0]]
            let l:stop = arg[1]
            let l:dec = [arg[1]]
            let l:iso = l:dec + a:isos[arg[0]]

            " If we missed it before, and a relevant line to var is not
            " isolated or is not already part of our new method, move to the
            " next var.
            let l:continue = 1
            for rel in l:relevant
                if index(l:iso,rel) < 0 && index(a:lines,rel) < 0
                    let l:continue = 0
                    break
                endif
            endfor

            " If we're really very sure that the variable is isolated, get any
            " new arguments for it and add its lines to our new method.
            if l:continue
                let l:next_args = s:getNewArgs(l:iso,a:vars,a:rels,arg)
                let l:fin = uniq(factorus#util#merge(l:fin,l:iso))

                call remove(l:fin_args,index(l:fin_args,arg))
                for narg in l:next_args
                    if index(l:fin_args,narg) < 0 && narg[0] != a:var[0]
                        call add(l:fin_args,narg)
                    endif
                endfor
            endif
        endif
        call cursor(l:orig)
    endfor

    call cursor(l:orig)
    return [l:fin,l:fin_args]
endfunction

" wrapAllDecs {{{3

" Returns the lines of the new method and all arguments required for it, after
" 'wrapping in' any possible variables.
function! s:wrapAllDecs(vars, all, isos, open, close, best_lines, best_var)
    let l:best_lines = deepcopy(a:best_lines)
    let l:new_args = s:getNewArgs(l:best_lines,a:vars,a:all,a:best_var)

    let [l:wrapped,l:wrapped_args] = s:wrapDecs(a:best_var,l:best_lines,a:vars,a:all,a:isos,l:new_args,a:close)
    while l:wrapped != l:best_lines
        let [l:best_lines,l:new_args] = [l:wrapped,l:wrapped_args]
        let [l:wrapped,l:wrapped_args] = s:wrapDecs(a:best_var,l:best_lines,a:vars,a:all,a:isos,a:new_args,a:close)
    endwhile
    let l:new_args = s:getNewArgs(l:best_lines,a:vars,a:all,a:best_var)

    if a:best_var[1] == a:open && index(l:new_args,a:best_var) < 0
        call add(l:new_args,a:best_var)
    endif

    return [l:best_lines, l:new_args]
endfunction

" buildArgs {{{3

" Builds the arguments for an extracted method.
" 
" Return value: str. str is a string comprising all arguments, separated by
" commas.
function! s:buildArgs(args)
    let l:defs = map(deepcopy(a:args),{n,arg -> arg[0]})
    return join(l:defs,',')
endfunction

" formatMethod {{{3
function! s:formatMethod(def,body,return,lines,indent)
    
    " Indents multiple lines of function definition similarly. Not necessary
    " right now, since we aren't splitting lines in Python.
    "let l:paren = stridx(a:def[0],'(')
    "let l:def_space = repeat(' ',l:paren+1)
    "call map(a:def,{n,line -> a:spaces[0] . (n > 0 ? l:def_space : '') . substitute(line,'^\s*\(.*\)','\1','')})

    "let l:dspaces = join(a:spaces,'')
    
    "let l:indent = substitute(getline('.'),'^\(\s*\)[^[:space:]].*','\1','')
    let l:tab = s:getIndentSpaces()

    let l:i = 0

    call map(a:def, {n,line -> a:indent . line})
    call map(a:body,{n,line -> substitute(line,'^\s*\([^[:space:]].*\)','\1','')})
    let l:next_closes = []
    while l:i < len(a:lines)
        if len(l:next_closes) > 0 && l:next_closes[-1] < a:lines[l:i]
            call remove(l:next_closes,-1)
        endif

        " let l:tspaces = l:dspaces . repeat(a:spaces[1],len(l:next_closes))
        " let a:body[l:i] = l:tspaces . a:body[l:i]
        let a:body[l:i] = a:indent . repeat(l:tab, len(l:next_closes) + 1) . a:body[l:i]

        if match(a:body[l:i],':\s*$') >= 0
            call add(l:next_closes,s:getLastLine(1,[a:lines[l:i],1]))
        endif

        let l:i += 1
    endwhile
    call add(a:body,a:indent . l:tab . substitute(a:return,'^\s*\([^[:space:]].*\)','\1',''))
endfunction

" buildNewMethod {{{3

" Builds the method we just extracted.
function! s:buildNewMethod(lines,args,blocks,vars,rels,indent,close,...)
    " Jump to the last line so we can look for lines outside what we're
    " extracting.
    call cursor(a:lines[-1],1)
    let l:return = ''
    let l:call = ''

    let l:outer = s:getContainingBlock(a:lines[0],a:blocks,a:blocks[0])

    " We need to check if the current method will require any variable used
    " within our extracted method. If so, we need to make sure to return that
    " variable.
    
    " For every variable contained in our extracted lines, check that
    " variable's first reference outside of our extracted lines. Then, if that
    " line is within a block that is not contained within the same block as
    " the first line of our extracted method, that's the variable we need to
    " return.

    for var in a:vars
        if index(a:lines,var[1]) >= 0
            let l:outside = s:getNextUse(var[0])    
            if l:outside[1] != [0,0] && l:outside[1][0] <= a:close
                let l:contain = s:getContainingBlock(var[1],a:blocks,a:blocks[0])
                if l:contain[0] <= l:outer[0] || l:contain[1] >= l:outer[1]
                    let l:type = var[1]
                    let l:return = 'return ' . var[0]
                    let l:call = var[0] . ' = '

"                     If our return variable is referenced in a line other than
"                     an if or loop, we may need to get rid of some lines.
"                    let i = 0
"                    while i < len(a:lines)
"                        let line = getline(a:lines[i])
"                        if match(line,'\<\(if\|elif\|while\|for\)\>') < 0 && match(line,'\<' . var[0] . '\>') >= 0
"                            break
"                        endif
"                        let i += 1
"                    endwhile
"
"                    if i == len(a:lines)
"                        break
"                    endif
"
"                    let l:inner = s:getContainingBlock(a:lines[i+1],a:blocks,l:outer)
"                    if l:inner[1] - l:inner[0] > 0
"                        let l:removes = []
"                        for j in range(i+1)
"                            if match(getline(a:lines[j]),'\<' . var[0] . '\>') >= 0
"                                call add(l:removes,j)
"                            endif
"                        endfor
"                        for rem in reverse(l:removes)
"                            call remove(a:lines,rem)
"                        endfor
"                    endif
                    break
                endif
            endif
        endif
    endfor

    " Get the actual lines we're extracting from the current method, and
    " create the function name,
    let l:body = map(copy(a:lines),{n,line -> getline(line)})

    let l:name = a:0 == 0 ? g:factorus_method_name : a:1
    let l:arg_string = s:buildArgs(a:args)
    let l:build_string = 'def ' . l:name . '(' . l:arg_string . '):'

    let l:def = [l:build_string]
"    let l:temp = join(reverse(split(l:build_string, '.\zs')), '')

"    Currently, we don't split lines of the new function, since that could
"    impact the indentation level of the file.
"    if g:factorus_split_lines == 1
"        while len(l:temp) >= g:factorus_line_length
"            let i = stridx(l:temp,'|',len(l:temp) - g:factorus_line_length)
"            if i <= 0
"                break
"            endif
"            let l:segment = strpart(l:temp,0,i)
"            let l:segment = join(reverse(split(l:segment, '.\zs')), '')
"            let l:segment = substitute(l:segment,'|',',','g')
"            call add(l:def,l:segment)
"            let l:temp = strpart(l:temp,i)
"        endwhile
"    endif

"    let l:temp = join(reverse(split(l:temp, '.\zs')), '')
"    let l:temp = substitute(l:temp,'|',',','g')
"    call add(l:def,l:temp)
"    call reverse(l:def)

    call s:formatMethod(l:def,l:body,l:return,a:lines,a:indent)
    let l:final = l:def + l:body + ['']

    let l:call_space = substitute(getline(s:getContainingBlock(a:lines[-1],a:blocks,a:blocks[0])[0]),'\(\s*\).*','\1','')
    let l:rep = [l:call_space . l:call . l:name . '(' . l:arg_string . ')']

    return [l:final,l:rep]
endfunction

" Rollback {{{2
" rollback_add_param {{{3

function! s:rollback_add_param()
    let l:files = factorus#util#get_modified_lines()

    for file in keys(l:files)
        execute 'silent tabedit! ' . file
        for line in l:files[file]
            call cursor(line, 1)
                execute 'silent s/,\=\s\=\<' . a:param_name . '\>[^)]*)/)/e'
                execute 'silent s/(\<' . a:param_name . '\>,\=\s\=/(/e'
        endfor

        silent write!
        call factorus#util#safe_close()
    endfor
endfunction

" rollbackExtraction {{{3
function! s:rollbackExtraction()
    let l:open = search('def ' . g:factorus_method_name . '(')
    let l:close = s:getLastLine(1)

    if match(getline(l:open - 1),'^\s*$') >= 0
        let l:open -= 1
    endif
    if match(getline(l:close + 1),'^\s*$') >= 0
        let l:close += 1
    endif

    execute 'silent ' . l:open . ',' . l:close . 'delete'

    call search('\<' . g:factorus_method_name . '\>(')
    call s:go_to_tag(0)
    let l:open = line('.')
    let l:close = s:getLastLine(1)

    execute 'silent ' . l:open . ',' . l:close . 'delete'
    call append(line('.')-1,g:factorus_history['old'][1])
    call cursor(l:open,1)
    silent write!
endfunction

" Global Functions {{{1
" add_param {{{2
function! factorus#python#add_param(param_name,...)
    if factorus#util#is_rollback(a:000)
        call s:rollback_add_param()
        let g:factorus_qf = []
        return 'Removed new parameter ' . a:param_name . '.'
    endif

    let l:orig = [line('.'), col('.')]
    call s:go_to_tag(0)

    " If there is a default argument, add the parameter at the end; otherwise,
    " add it at the beginning.
    " TODO: This is straight-up weaksauce. It doesn't update the method
    " anywhere else, or even tell the user which methods might need to be
    " updated. There isn't too much to be done without context-sensitive code,
    " but can at least try to find method calls that could be changed.
    if a:0 == 0
        let l:next = searchpos('(','Wn')
        let l:line = substitute(getline(l:next[0]), '(', '(' . a:param_name . ', ', '')
    else
        let l:next = searchpos(')','Wn')
        let l:line = substitute(getline(l:next[0]), ')', ', ' . a:param_name . '=' . a:1 . ')', '')
    endif

    execute 'silent ' .  l:next[0] . 'd'
    call append(l:next[0] - 1, l:line)

    silent write!
    silent edit!
    call cursor(l:orig)

    redraw
    echo 'Added parameter ' . a:param_name . ' to method.'
    return a:param_name
endfunction

" rename_something {{{2
function! factorus#python#rename_something(new_name,type,...)
    try
        if factorus#util#is_rollback(a:000)
            " Roll back previous rename command.
            let l:res = s:rollback_rename(a:new_name, a:type)
            let g:factorus_qf = []
        else
            let [l:orig, l:prev_dir, l:curr_buf] = factorus#util#set_environment()

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
        call factorus#util#reset_environment(l:orig, l:prev_dir, l:curr_buf, a:type)
        let l:err = match(v:exception, '^Factorus:') >= 0 ? v:exception : 'Factorus:' . v:exception
        throw l:err . ', at ' . v:throwpoint
    endtry


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
    let l:project_dir = factorus#project_dir()
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
                let l:un = factorus#util#get_unchanged('\<' . l:res . '\>')
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

                call factorus#util#set_quick_fix(a:type)
            endif
        endif
        call system('rm -rf ' . s:temp_file)

        execute 'silent cd ' l:prev_dir
        if a:type != 'Class'
            let &switchbuf = 'useopen,usetab'
            execute 'silent sbuffer ' . l:curr_buf
            let &switchbuf = l:buf_setting
        endif
        call cursor(l:orig)

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
"
" Extracts lines from the current method into a brand new method; if lines are
" selected visually, simply extracts those into a brand new method. 
function! python#factorus#extractMethod(...)

    " If this is a rollback command, just roll the previous extraction back.
    if factorus#isRollback(a:000)
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif

    echo 'Extracting new method...'

    " If lines were visually selected, this is a manual extraction, so use
    " that method.
    if a:1 != 1 || a:2 != line('$')
        return s:manualExtract(a:000)
    endif

    let [l:orig, l:indent, l:method_name, l:open, l:close, l:old_lines, l:vars, l:names, l:blocks, l:all, l:isos] = s:initExtraction()

    " For each variable, get the isolated lines for that variable (lines that
    " can be extracted without ruining the rest of the code), and find the
    " 'best' variable to extract around.
    
    redraw
    echo 'Finding best lines...'

    let [l:best_var, l:best_lines] = s:getBestVar(l:vars,l:names,l:isos,l:all,l:blocks,l:open,l:close)

    if len(l:best_lines) < g:factorus_min_extracted_lines
        call cursor(l:orig)
        redraw
        echo 'Nothing to extract'
        return
    endif

    redraw
    echo 'Almost done...'
    if index(l:best_lines,l:best_var[1]) < 0 && l:best_var[1] != l:open
        let l:best_lines = [l:best_var[1]] + l:best_lines
    endif

    " Get our arguments for the new method, then wrap any isolated variables
    " into our new method until no more remain.
    let [l:best_lines, l:new_args] = s:wrapAllDecs(l:vars, l:all, l:isos, l:open, l:close, l:best_lines, l:best_var)

    " Finally, build the method using the lines we wish to extract and the
    " arguments we'll be needing.
    let [l:final,l:rep] = s:buildNewMethod(l:best_lines,l:new_args,l:blocks,l:vars,l:all,l:indent,l:close)

    call append(l:close,l:final)
    call append(l:best_lines[-1],l:rep)

    for i in range(len(l:best_lines) - 1, 0, -1)
        call cursor(l:best_lines[i],1)
        d 
    endfor

    call search('def ' . g:factorus_method_name . '(')
    silent write!
    redraw
    echo 'Extracted ' . len(l:best_lines) . ' lines from ' . l:method_name . ' into ' . g:factorus_method_name
    return [l:method_name,l:old_lines]
endfunction

"manualExtract {{{2
function! s:manualExtract(args)
    if factorus#isRollback(a:args)
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif

    let l:new_name = len(a:args) <= 2 ? g:factorus_method_name : a:args[2]
    let l:extract_lines = range(a:args[0],a:args[1])

    let [l:orig, l:indent, l:method_name, l:open, l:close, l:old_lines, l:vars, l:names, l:blocks, l:all, l:isos] = s:initExtraction()

    let l:new_args = s:getNewArgs(l:extract_lines,l:vars,l:all)
    let [l:final,l:rep] = s:buildNewMethod(l:extract_lines,l:new_args,l:blocks,l:vars,l:all,l:indent,l:close,l:new_name)

    call append(l:close,l:final)
    call append(l:extract_lines[-1],l:rep)

    let l:i = len(l:extract_lines) - 1
    while l:i >= 0
        call cursor(l:extract_lines[l:i],1)
        d 
        let l:i -= 1
    endwhile

    call search('def\s*\<' . l:new_name . '\>(')
    silent write!
    redraw
    echo 'Extracted ' . len(l:extract_lines) . ' lines from ' . l:method_name . ' into ' . l:new_name

    return [l:new_name,l:old_lines]
endfunction
