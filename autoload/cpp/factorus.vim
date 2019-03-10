" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" Search Constants {{{1

let s:start_chars = '_A-Za-z'
let s:search_chars = s:start_chars . '0-9#'
let s:cpp_identifier = '[' . s:start_chars . '][' . s:search_chars . ']*'
let s:cpp_type = '\(enum\_s*\|struct\_s*\|union\_s*\|long\_s*\|short\_s*\)\=\<' . s:cpp_identifier . '\>'
let s:collection_identifier = '\([\[\*&]\=[[\]\*' . s:search_chars . '[:space:]&]*[\*\]]\)\='

let s:cpp_keywords = '\<\(break\|case\|continue\|default\|do\|else\|for\|goto\|if\|return\|sizeof\|switch\|while\)\>'

let s:modifiers = '\(inline\_s*\|typedef\_s*\|extern\_s*\|static\_s*\|auto\_s*\|register\_s*\|const\_s*\|restrict\_s*\|volatile\_s*\|signed\_s*\|unsigned\_s*\)\='
let s:modifier_query = repeat(s:modifiers,3)

let s:struct = '\<\(enum\|struct\|union\)\>\_s*\(' . s:cpp_identifier . '\)\=\_s*\({\|\<' . s:cpp_identifier . '\>\_s*;\)'
let s:func = s:cpp_type . '\_s*' . s:collection_identifier . '\<' . s:cpp_identifier . '\>\_s*('
let s:tag_query = '^\s*' . s:modifier_query . '\(' . s:struct . '\|' . s:func . '\)'
let s:no_comment = '^\s*'
let s:special_chars = '\([*\/[\]]\)'

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

function! s:isAlone(...)
    let l:file = a:0 > 0 ? a:1 : expand('%:p')
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

function! s:safeClose(...)
    let l:prev = 0
    let l:file = a:0 > 0 ? a:1 : expand('%:p')
    if getbufinfo(l:file)[0]['loaded'] == 1 && winnr("$") == 1 && tabpagenr("$") > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr("$")
        let l:prev = 1
    endif

    if index(s:open_bufs,l:file) < 0 && s:isAlone(l:file) == 1
        execute 'bwipeout ' . l:file
    elseif l:file == expand('%:p')
        q
    endif

    if l:prev == 1
        tabprev
    endif
endfunction

function! s:findTags(temp_file,search_string,append)
    let l:fout = a:append == 'yes' ? ' >> ' : ' > '
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

function! s:setQuickFix(type,qf)
    let l:title = a:type . ' : '
    if g:factorus_show_changes == 1
        let l:title .= 'ChangedFiles'
    elseif g:factorus_show_changes == 2
        let l:title .= 'UnchangedFiles'
    else
        let l:title .= 'AllFiles'
    endif

    call setqflist(a:qf)
    call setqflist(a:qf,'r',{'title' : l:title})
endfunction

function! s:setChanges(res,eun,func,...)
    let l:qf = copy(g:factorus_qf)
    let l:type = a:func == 'rename' ? a:1 : ''

    let l:un = deepcopy(a:eun)
    let l:ch = len(g:factorus_qf)
    let l:ch_i = l:ch == 1 ? ' instance ' : ' instances '
    let l:un_l = len(l:un)
    let l:un_i = l:un_l == 1 ? ' instance ' : ' instances '

    let l:first_line = l:ch . l:ch_i . 'modified'
    let l:first_line .= (l:type == 'Arg' || a:func == 'addParam') ? '.' : ', ' . l:un_l . l:un_i . 'left unmodified.'

    if g:factorus_show_changes > 1 && a:func != 'addParam' && l:type != 'Arg'
        let l:un = [{'pattern' : 'Unmodified'}] + l:un
        if g:factorus_show_changes == 2
            let l:qf = []
        endif
        let l:qf += l:un
    endif

    if g:factorus_show_changes % 2 == 1
        let l:qf = [{'pattern' : 'Modified'}] + l:qf
    endif
    let l:qf = [{'text' : l:first_line,'pattern' : a:func . l:type}] + l:qf

    call s:setQuickFix(a:func . l:type,l:qf)
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

function! s:setEnvironment()
    let s:open_bufs = []

    let l:prev_dir = getcwd()
    let l:buf_nrs = []
    for buf in getbufinfo()
        call add(s:open_bufs,buf['name'])
        call add(l:buf_nrs,buf['bufnr'])
    endfor
    let l:curr_buf = l:buf_nrs[index(s:open_bufs,expand('%:p'))]

    execute 'silent cd ' . expand('%:p:h')
    let l:project_dir = factorus#projectDir()
    execute 'silent cd ' l:project_dir

    let s:temp_file = '.FactorusTemp'
    call system('find ' . getcwd() . g:factorus_ignore_string . ' > ' . s:temp_file)

    return [[line('.'),col('.')],l:prev_dir,l:curr_buf]
endfunction

function! s:resetEnvironment(orig,prev_dir,curr_buf,type)
    let l:buf_setting = &switchbuf
    call system('rm -rf .Factorus*')
    execute 'silent cd ' a:prev_dir
    if a:type != 'Class'
        let &switchbuf = 'useopen,usetab'
        execute 'silent sbuffer ' . a:curr_buf
        let &switchbuf = l:buf_setting
    endif
    call cursor(a:orig[0],a:orig[1])
endfunction

" Utilities {{{2

function! s:getClosingBracket(stack,...)
    let l:orig = [line('.'),col('.')]
    if a:0 > 0
        call cursor(a:1[0],a:1[1])
    endif
    if a:stack == 0
        call searchpair('{','','}','Wb')
    else
        call search('{','Wc')
    endif
    normal %
    let l:res = [line('.'),col('.')]
    call cursor(l:orig[0],l:orig[1])
    return l:res
endfunction

function! s:isQuoted(pat,state)
    let l:temp = a:state
    let l:mat = match(l:temp,a:pat)
    let l:res = 1
    while l:mat >= 0 && l:res == 1
        let l:begin = strpart(l:temp,0,l:mat)
        let l:quotes = len(l:begin) - len(substitute(l:begin,'"','','g'))
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

function! s:isWrapped(pat,state)
    let l:match = match(a:state,a:pat)
    let l:temp = a:state
    let l:res = 1
    while l:match >= 0
        let l:begin = split(strpart(l:temp,0,l:match),'\zs')
        if count(l:begin,'>') >= count(l:begin,'<')
            let l:res = 0
            break
        endif
        let l:temp = substitute(l:temp,a:pat,'','')
        let l:match = match(l:temp,a:pat)
    endwhile
    return l:res
endfunction

function! s:isCommented()
    if match(getline('.'),'//') >= 0 && match(getline('.'),'//') < col('.')
        return 1
    endif
    if searchpairpos('[^/]\/\*','','\*\/','Wbn') != [0,0]
        return 1
    endif
    return 0
endfunction

function! s:getEndLine(start,search)
    let l:orig = [line('.'),col('.')]
    call cursor(a:start[0],a:start[1])
    let l:fin = searchpos(a:search,'Wen')
    call cursor(l:orig[0],l:orig[1])
    return l:fin
endfunction

function! s:getStatement(line)
    let l:i = a:line
    while match(getline(l:i),'\({\|;$\)') < 0
        let l:i += 1
    endwhile
    return join(getline(a:line,l:i))
endfunction

" Tag Navigation {{{2
" isValidTag {{{3
function! s:isValidTag(line)
    let l:first_char = strpart(substitute(getline(a:line),'\s*','','g'),0,1)   
    if l:first_char == '*' || l:first_char == '/'
        return 0
    endif

    let l:has_keyword = match(getline(a:line),s:cpp_keywords)
    if l:has_keyword >= 0 && s:isQuoted(s:cpp_keywords,getline(a:line)) == 0
        return 0
    endif

    let l:gline = getline(a:line)
    if match(l:gline,'\<typedef\>') < 0
        if (match(l:gline,';') >= 0 && match(l:gline,'(') < 0) || (match(l:gline,'\<\(struct\|enum\|union\)\>\s*{') >= 0)
            return 0
        endif
    endif
    
    return 1
endfunction

" getAdjacentTag {{{3
function! s:getAdjacentTag(dir)
    let [l:oline,l:ocol] = [line('.'),col('.')]
    call cursor(l:oline + 1,l:ocol)

    let l:func = searchpos(s:tag_query,'Wn' . a:dir)
    let l:is_valid = 0
    while l:func != [0,0]
        let l:is_valid = s:isValidTag(l:func[0])
        if l:is_valid == 1
            break
        endif

        call cursor(l:func[0],l:func[1])
        let l:func = searchpos(s:tag_query,'Wn' . a:dir)
    endwhile
    call cursor(l:oline,l:ocol)

    if l:is_valid == 1
        return l:func[0]
    endif
    return 0
endfunction

" getNextTag {{{3
function! s:getNextTag()
    return [s:getAdjacentTag(''),1]
endfunction

" getTypeTag {{{3
function! s:getTypeTag()
    let [l:line,l:col] = [line('.'),col('.')]
    call cursor(1,1)
    let l:class_tag = search(s:tag_query,'n')
    let l:tag_end = search(s:tag_query,'ne')
    call cursor(l:line,l:col)
    return [l:class_tag,l:tag_end]
endfunction

"isInType {{{3
function! s:isInType()
    let l:orig = [line('.'),col('.')]
    let l:close = s:getClosingBracket(0)
    call s:gotoTag()

    let l:res = 0
    if s:isBefore(searchpos('{','Wn'),searchpos('(','Wn')) && s:getClosingBracket(1)[0] >= l:close[0]
        let l:res = 1
    endif
    call cursor(l:orig[0],l:orig[1])
    return l:res
endfunction

" gotoTag {{{3
function! s:gotoTag()
    let l:tag = s:getAdjacentTag('b')
    if l:tag != 0
        call cursor(l:tag,1)
    else
        echo 'No tag found'
    endif
endfunction

" Class Hierarchy {{{2
" getIncluded {{{3
function! s:getIncluded()
    let l:orig = [line('.'),col('.')]
    call cursor(1,1)

    let l:files = []
    let l:include = '^#\<include\>\s*"'
    let l:next = search(l:include,'Wc')
    while l:next > 0
        if match(getline(l:next),'<.*>$') < 0
            call add(l:files,substitute(getline(l:next),'^.*"\(.*\/\)\=\(.*\)".*$','\2',''))
        endif
        call cursor(line('.') + 1,1)
        let l:next = search(l:include,'Wc')
    endwhile
    if l:files == []
        return []
    endif

    call map(l:files,{n,val -> '\/' . substitute(val,'\(.*\/\)\=\(.*\)','\2','')})
    let l:or = substitute(' "\(' . join(l:files,'\|') . '\)" ','\.','\\.','g')
    let l:fin = split(system('grep' . l:or . s:temp_file . ' 2> /dev/null'),'\n')

    call cursor(l:orig[0],l:orig[1])
    return l:fin
endfunction

" getAllIncluded {{{3 
function! s:getAllIncluded()
    if exists('s:all_inc') && index(keys(s:all_inc),expand('%:p')) >= 0
        return s:all_inc[expand('%:p')]
    endif

    let l:fin = s:getIncluded()
    let l:files = copy(l:fin)

    for file in l:files
        execute 'silent tabedit! ' . file
        let l:fin += s:getAllIncluded()
        call s:safeClose()
    endfor

    let s:all_inc[expand('%:p')] = l:fin
    return l:fin
endfunction

" getInclusions {{{3
function! s:getInclusions(temp_file,is_static)
    let l:swap_file = '.FactorusIncSwap'
    call system('> ' . l:swap_file)

    let l:inc = [expand('%:p:t')]
    while l:inc != []
        let l:search = '^#include\s*\".*\(' . join(l:inc,'\|') . '\)\"'
        call s:findTags(l:swap_file,l:search,'no')
        call system('cat ' . l:swap_file . ' >> ' . a:temp_file)
        let l:inc = filter(readfile(l:swap_file),'index(l:inc,v:val) < 0')
        call map(l:inc,{n,val -> substitute(val,'\(.*\/\)\=\(.*\)','\2','')})
    endwhile

    if !a:is_static
        call system('find ' . getcwd() . ' -name "*.h" >> ' . a:temp_file)
    endif

    call system('sort -u ' . a:temp_file . ' -o ' . a:temp_file)
    call system('rm -rf ' . l:swap_file)
endfunction

" Declarations {{{2
" getTypeDefs {{{3
function! s:getTypeDefs(name,...)
    let l:type = a:0 > 0 ? '\_s*' . a:1 . '\_s*' : '\_s*'

    let l:temp_file = '.FactorusInc'
    call s:getInclusions(l:temp_file,0)
    let l:files = readfile(l:temp_file) + [expand('%:p')]
    call system('rm -rf ' . l:temp_file)

    let l:search = '\<typedef\>' . l:type . a:name . '\_s*\<\(' . s:cpp_identifier . '\)\>'
    try
        execute 'silent lvimgrep /' . l:search . '/j ' . join(l:files)
        let l:res = []
        for grep in getloclist(0)
            let l:def = substitute(grep['text'],l:search,'\1','')
            if index(l:res,l:def) < 0
                call add(l:res,l:def)
            endif
        endfor
        return l:res
    catch /.*/
        return []
    endtry
endfunction

" parseStruct {{{3
function! cpp#factorus#parseStruct(struct)
    if match(a:struct,'{') < 0
        let l:res = substitute(a:struct,'\[.*\]','','g')
        let l:res = substitute(l:res,'\*','','g')
        let l:res = split(l:res)
        return [join(l:res[:-2]),l:res[-1]]
    elseif match(a:struct,'^enum') >= 0
        let l:res = s:trim(substitute(a:struct,'^\([^{]*\){\(.*\)}\([^}]*\)$','\1 \3',''))
        return split(l:res)
    endif

    let l:res = s:trim(substitute(a:struct,'^[^{]*{\(.*\)}[^}]*$','\1',''))
    let l:res = s:trim(substitute(l:res,'\/\*.\{-\}\*\/','','g'))
    let l:name = s:trim(substitute(a:struct,'^[^{]*{\(.*\)}\([^}]*\)$','\2',''))

    let l:items = []
    let l:brack = 0
    let l:count = 1
    let l:i = 0
    let l:prev = 0
    while l:i < len(l:res)
        let char = l:res[l:i]
        if char == ';' && l:brack == 0
            call add(l:items,s:trim(strpart(l:res,l:prev,l:i - l:prev)))
            let l:prev = l:i + 1
        elseif char == '}'
            let l:brack -= 1
        elseif char == '{'
            let l:brack += 1
        endif
        let l:i += 1
    endwhile

    for i in range(len(l:items))
        let l:items[i] = cpp#factorus#parseStruct(l:items[i])
    endfor

    return [l:items,l:name]
endfunction

" getStructDef {{{3
function! s:getStructDef(type)
    if exists('s:all_structs') && index(keys(s:all_structs),expand('%:p') . '-' . a:type) >= 0
        return s:all_structs[expand('%:p') . '-' . a:type]
    endif

    let l:files = s:getAllIncluded() + [expand('%:p')]
    let [l:prev_file,l:res] = ['',[]]
    if match(a:type,'\<\(struct\|union\)\>') >= 0
        try
            execute 'silent lvimgrep! /' . a:type . '\_s*{/j ' . join(l:files)
            execute 'silent tabedit! ' . getbufinfo(getloclist(0)[0]['bufnr'])[0]['name']
            call cursor(1,1)
            let l:find = search(a:type . '\_s*{','W')
            if l:find != 0
                let l:prev_file = expand('%:p')
                call search('{')
                let l:start = line('.')
                normal %
                let l:end = line('.')
                let l:def = join(getline(l:start,l:end))
                let l:res = cpp#factorus#parseStruct(l:def)[0]
            endif
            call s:safeClose()
        catch /.*/
        endtry
    else
    endif

    let s:all_structs[expand('%:p') . '-' . a:type] = [l:prev_file,a:type,deepcopy(l:res)]
    return [l:prev_file,a:type,l:res]
endfunction

" getNextArg {{{3
function! s:getNextArg(...)
    let l:get_variable = '^[^/*].*(.*\<\(' . a:1 . '\)\>' . s:collection_identifier . '\=\s\+\(\<' . a:2 . '\).*).*'
    let l:index = '\3'

    let l:line = line('.')
    let l:col = col('.')

    let l:match = searchpos(l:get_variable,'Wn')
    let l:end_match = searchpos(l:get_variable,'Wnze')

    if s:isBefore([l:line,l:col],l:match) == 1
        let l:var = substitute(getline(l:match[0]),l:get_variable,l:index,'')
        return [l:var,l:match]
    endif

    return ['none',[0,0]]
endfunction

" getParams {{{3
function! s:getParams() abort
    let l:prev = [line('.'),col('.')]
    call s:gotoTag()
    let l:oparen = search('(','Wn')
    let l:cparen = search(')','Wn')
    
    let l:dec = join(getline(l:oparen,l:cparen))
    let l:dec = substitute(l:dec,'.*(\(.*\)).*','\1','')
    if l:dec == ''
        return []
    endif

    let l:args = split(l:dec,',')
    call map(l:args, {n,arg -> split(substitute(s:trim(arg),'\(.*\)\(\<' . s:cpp_identifier . '\>\)$','\1|\2',''),'|')})
    call map(l:args, {n,arg -> [s:trim(arg[1]),s:trim(arg[0]),line('.')]})

    call cursor(l:prev[0],l:prev[1])
    return l:args
endfunction

" getNextDec {{{3
function! s:getNextDec()
    let l:get_variable = '^\s*\(' . s:modifier_query . '\|for\s*(\)\s*\(' . s:cpp_type . '\_s*' . 
                \ s:collection_identifier . '\)\s*\(\<' . s:cpp_identifier . '\>[^=;]*\)[;=].*'
    
    let l:alt_get = '^\s*' . s:modifier_query . '\s*\(' . s:cpp_type . '\_s*' . 
                \ s:collection_identifier . '\)\s*\(\<' . s:cpp_identifier . '\>[^=;]*\)[=;].*'

    let [l:line,l:col] = [line('.'),col('.')]
    let l:match = searchpos(l:get_variable,'Wn')

    if a:0 == 0
        while l:match != [0,0] && match(getline(l:match[0]),'\<return\>') >= 0
            call cursor(l:match[0],l:match[1])
            let l:match = searchpos(l:get_variable,'Wn')
        endwhile
        call cursor(l:line,l:col)
    endif

    if s:isBefore([l:line,l:col],l:match) == 1
        if match(getline(l:match[0]),'\<for\>') >= 0
            let l:var = substitute(getline(l:match[0]),l:get_variable,'\5','')
            let l:fline = split(substitute(getline(l:match[0]),l:get_variable,'\8',''),',')
        else
            let l:var = s:trim(substitute(getline(l:match[0]),l:alt_get,'\1 \2 \3 \4',''))
            let l:var = substitute(l:var,'\s\+',' ','g')
            let l:fline = split(substitute(getline(l:match[0]),l:alt_get,'\7',''),',')
        endif
        call map(l:fline,{n,var -> s:trim(var)})
        call map(l:fline,{n,var -> substitute(var,'^\<\(' . s:cpp_identifier . '\)\>.*','\1','')})

        return [l:var,l:fline,l:match]
    endif

    return ['none',[],[0,0]]
endfunction

" getLocalDecs {{{3
function! s:getLocalDecs(close)
    let l:orig = [line('.'),col('.')]
    let l:here = [line('.'),col('.')]
    let l:next = s:getNextDec()

    let l:vars = s:getParams()
    while s:isBefore(l:next[2],a:close)
        if l:next[2] == [0,0]
            break
        endif
        
        let l:type = l:next[0]
        for name in l:next[1]
            call add(l:vars,[name,l:type,l:next[2][0]])
        endfor

        call cursor(l:next[2][0],l:next[2][1])
        let l:next = s:getNextDec()
    endwhile
    call cursor(l:orig[0],l:orig[1])

    return l:vars
endfunction

" getFunctionDecs {{{3
function! s:getFunctionDecs()
    let l:query = '^\s*' . s:modifier_query . '\s*\(' .  s:cpp_type . '\_s*' . s:collection_identifier . '\)\_s*\(' . s:cpp_identifier . '\)\_s*\([;(]\).*'
    let l:decs = {'types' : [], 'names' : []}
    try
        execute 'silent vimgrep /' . l:query . '/j %:p'
        let l:greps = getqflist()

        for g in l:greps
            let l:fname = substitute(g['text'],l:query,'\4|\7\8','')
            if match(l:fname,s:cpp_keywords) >= 0
                continue
            endif

            if l:fname[len(l:fname)-1] == '('
                let [l:type,l:name] = split(l:fname,'|')
            else
                let [l:type,l:name] = split(l:fname[:-2],'|')
                let l:name = substitute(l:name,';','(','')
            endif

            call add(l:decs['types'],l:type)
            call add(l:decs['names'],l:name)
        endfor

    catch /.*No match.*/
    endtry

    return l:decs
endfunction

" getAllFunctions {{{3
function! s:getAllFunctions()
    if index(keys(s:all_funcs),expand('%:p')) >= 0
        return s:all_funcs[expand('%:p')]
    endif

    let l:use = s:getAllIncluded()

    let l:defs = {'types' : [], 'names' : []}
    for class in l:use
        execute 'silent tabedit! ' . class
        let l:funcs = s:getFunctionDecs()
        let l:defs['types'] += l:funcs['types']
        let l:defs['names'] += l:funcs['names']
        call s:safeClose()
    endfor
    silent edit!

    let s:all_funcs[expand('%:p')] = l:defs
    return l:defs
endfunction

" getStructVars {{{3
function! s:getStructVars(var,dec,funcs)
    if match(a:dec,'>$') < 0
        return [a:dec]
    endif

        call add(a:funcs[0],old)
    endif

    let l:orig = substitute(a:dec,'^\([^<]*\)<.*','\1','')
    let l:res = substitute(a:dec,'^.*<','','')
    let l:res = substitute(l:res,'\(<\|>\|\s\)','','g')
    return [l:orig] + split(l:res,',')
endfunction

" getFuncDec {{{3
function! s:getFuncDec(func)
    let l:orig = [line('.'),col('.')]
    call cursor(1,1)
    let l:search = s:no_comment . s:modifier_query . '\(' . s:cpp_type . '\_s*' . s:collection_identifier . '\)\_s\+\<' . a:func . '\(\<\|\>\|)\|\s\).*'
    let l:find =  search(l:search)
    let l:next = ''
    if l:find > 0
        call cursor(line('.'),1)
        let l:next = substitute(getline('.'),l:search,'\4','')
    else
        let l:all_funcs = s:getAllFunctions()
        let l:ind = match(l:all_funcs['names'],a:func)
        if l:ind >= 0
            let l:next = l:all_funcs['types'][l:ind]
        endif
    endif
    call cursor(l:orig[0],l:orig[1])
    return l:next
endfunction

" getVarDec {{{3
function! s:getVarDec(var)
    let l:orig = [line('.'),col('.')]
    let l:search = s:no_comment  . '.\{-\}\(' . s:modifier_query . '\|for\s*(\)\s*\(' . s:cpp_type . '\_s*' .
                \ s:collection_identifier . '\)\s*\<' . a:var . '\>.*'
    let l:jump = '\<' . a:var . '\>'

    let l:pos = search(l:search,'Wb')
    call search(l:jump)
    let l:res = substitute(substitute(getline(l:pos),l:search,'\5',''),'\*','','g')
    while s:isQuoted(l:res,getline(l:pos)) == 1 || s:isCommented() == 1 || match(l:res,s:cpp_keywords) >= 0
        if l:pos == 0
            return ''
        endif
        call cursor(l:pos-1,l:pos)
        let l:pos = search(l:search,'Wb')
        call search(l:jump)
        let l:res = substitute(substitute(getline(l:pos),l:search,'\5',''),'\*','','g')
    endwhile

    call cursor(l:orig[0],l:orig[1])
    return l:res
endfunction

" getUsingVar {{{3
function! s:getUsingVar()
    let l:orig = [line('.'),col('.')]

    let l:search = '\(\.\|->\)'
    while 1 == 1
        let l:adj = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')
        if l:adj == ')' || l:adj == ']'
            call cursor(line('.'),col('.')-1)
            normal %
            if searchpos(l:search,'bn') == searchpos('[^[:space:]]\_s*\<' . s:cpp_identifier . '\>','bn')
                call search(l:search,'b')
            elseif s:isBefore(searchpos('\<' . s:cpp_identifier . '\>\((\|\[\)','bn'),searchpos('[^[:space:]' . s:search_chars . ']','bn'))
                call search('\<' . s:cpp_identifier . '\>','')
                let l:var = expand('<cword>')
                let l:dec = s:getVarDec(l:var)
            else
                let l:end = col('.')
                call search('\<' . s:cpp_identifier . '\>','b')
                let l:begin = col('.') - 1
                let l:var = strpart(getline('.'),l:begin,l:end - l:begin)
                let l:dec = s:getFuncDec(l:var)
                let l:var = substitute(l:var,'\(\[\|(\)','','')
                break
            endif
        else
            let l:end = col('.') - 1
            call search('\<' . s:cpp_identifier . '\>','b')
            let l:dot = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')
            if l:dot != '.' && l:dot != '>'
                let l:begin = col('.') - 1
                let l:var = strpart(getline('.'),l:begin,l:end - l:begin)
                let l:var = substitute(l:var,'-','','g')
                let l:dec = s:getVarDec(l:var)
                break
            endif
            call search(l:search,'b')
        endif 
    endwhile

    let l:funcs = []
    let l:search = l:search . '\<' . s:cpp_identifier . '\>[([]\='
    let l:next = searchpos(l:search,'W')
    let l:next_end = searchpos(l:search,'Wnez')

    while s:isBefore(l:next,l:orig)
        call cursor(l:next[0],l:next[1])

        let l:func = substitute(strpart(getline('.'),l:next[1], l:next_end[1] - l:next[1]),'^>','','')
        call add(l:funcs,l:func)
        if matchstr(getline('.'), '\%' . l:next_end[1] . 'c.') == '('
            call search('(')
            normal %
        elseif matchstr(getline('.'), '\%' . l:next_end[1] . 'c.') == '['
            call search('[')
            normal %
        endif
        let l:next = searchpos(l:search,'W')
        let l:next_end = searchpos(l:search,'Wnez')
    endwhile
    call cursor(l:orig[0],l:orig[1])

    let l:dec = [l:dec]
    return [l:var,l:dec,l:funcs]
endfunction

" followChain {{{3
function! s:followChain(types,funcs,type_name)
    let s:open_bufs = []
    let s:all_incs = {}
    let s:all_structs = {}
    let s:all_funcs = {}

    let l:orig = [line('.'),col('.')]

    let l:func_search = '\(' . s:cpp_type . '\_s*' . s:collection_identifier . '\)\_s*\<' . a:funcs[0]
    let [l:prev_file,l:prev_struct,l:fields] = s:getStructDef('\(' . join(a:types,'\|') . '\)')

    while len(a:funcs) > 0
        if match(a:funcs[0],'(') >= 0
            try
                let l:included = s:getAllIncluded() + [expand('%:p')]
                execute 'silent lvimgrep /' . l:func_search . '/j ' . join(l:included)
            catch /.*/
            endtry
        else
            let l:ind = index(map(deepcopy(l:fields),{n,val -> val[1]}),a:funcs[0])
            if l:ind < 0
                break
            endif

            execute 'silent tabedit! ' . l:prev_file
            try
                let l:new_struct = split(l:fields[l:ind][0],' ')
                if len(l:new_struct) == 1
                    let l:type_defs = s:getTypeDefs(l:new_struct[0])
                else
                    let l:type_defs = s:getTypeDefs(join(l:new_struct[1:],'\_s*'),l:new_struct[0])
                endif

                let l:struct_find = len(l:type_defs) == 0 ? l:fields[l:ind][0] : '\(' . l:fields[l:ind][0] . '\|' . join(l:type_defs,'\|') . '\)'
                let [l:prev_file,l:prev_struct,l:fields] = s:getStructDef(l:struct_find)
            catch /^Vim\((\a\+)\)\=:E730.*/
                let [l:prev_file,l:prev_struct,l:fields] = [l:prev_file,l:fields[l:ind][1],l:fields[l:ind][0]]
            endtry
            call s:safeClose()
        endif
        if len(a:funcs) > 0
            call remove(a:funcs,0)
        endif
    endwhile
    call cursor(l:orig[0],l:orig[1])

    if l:ind >= 0
        let l:ind = match(map(l:fields,{n,val -> val[1]}),'\<' . a:type_name . '\>')
    endif

    return (l:ind >= 0)
endfunction

" References {{{2
" getNextReference {{{3
function! s:getNextReference(var,type,...)
    if a:type == 'right'
        let l:search = s:no_comment . s:modifier_query . '\s*\(' . s:cpp_type . '\_s*' . s:collection_identifier . 
                    \ '\)\=\s*\(' . s:cpp_identifier . '\)\s*[(.=]\_[^{;]*\<\(' . a:var . '\)\>\_.\{-\};$'
        let l:index = '\7'
        let l:alt_index = '\8'
    elseif a:type == 'left'
        let l:search = s:no_comment . '\(.\{-\}\[[^]]\{-\}\<\(' . a:var . '\)\>.\{-\}]\|\<\(' . a:var . '\)\>\)\s*\(++\_s*;\|--\_s*;\|[-\^|&~+*/]\=[.=][^=]\).*'
        let l:index = '\1'
        let l:alt_index = '\1'
    elseif a:type == 'cond'
        let l:search = s:no_comment . '\<\(switch\|while\|for\|if\|else\s\+if\)\>\_s*(\_[^{;]*\<\(' . a:var . '\)\>\_[^{;]*).*'
        let l:index = '\1'
        let l:alt_index = '\2'
    elseif a:type == 'return'
        let l:search = s:no_comment . '\s*\<return\>\_[^;]*\<\(' . a:var . '\)\>.*'
        let l:index = '\1'
        let l:alt_index = '\1'
    endif

    let l:line = searchpos(l:search,'Wn')
    let l:endline = s:getEndLine(l:line,l:search)
    if a:type == 'right'
        let l:prev = [line('.'),col('.')]
        while s:isValidTag(l:line[0]) == 0
            if l:line == [0,0]
                break
            endif

            if match(getline(l:line[0]),';') >= 0
                break
            endif

            if match(getline(l:line[0]),'\<\(true\|false\)\>') >= 0 
                break
            endif

            call cursor(l:line[0],l:line[1])
            let l:line = searchpos(l:search,'Wn')
            let l:endline = s:getEndLine(l:line,l:search)
        endwhile
        call cursor(l:prev[0],l:prev[1])
    endif

    if l:line[0] > line('.')
        let l:state = join(getline(l:line[0],l:endline[0]))
        let l:loc = substitute(l:state,l:search,l:index,'')
        if a:type == 'left'
            let l:loc = substitute(l:loc,'.*\<\(' . a:var . '\)\>.*','\1','')
        endif
        if a:0 > 0 && a:1 == 1
            let l:name = substitute(l:state,l:search,l:alt_index,'')
            if a:type == 'left'
                let l:name = l:loc
            endif
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
" updateUsingFile {{{3
function! s:updateUsingFile(type_name,old_name,new_name,paren) abort
    call cursor(1,1)
    let l:here = [line('.'),col('.')]
    let l:types = '\<\(' . a:type_name . '\)\>'
    let l:search = '\(\.\|->\)\<' . a:old_name . '\>' . a:paren

    let l:next = searchpos(l:search,'Wn')
    while l:next != [0,0]
        call cursor(l:next[0],l:next[1])
        let [l:var,l:dec,l:funcs] = s:getUsingVar()
        if len(l:funcs) == 0
            let l:dec = join(l:dec,'|')
            if match(l:dec,l:types) >= 0
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                execute 'silent s/\(\.\|->\)\<' . a:old_name . '\>' . a:paren . '/\1' . a:new_name . a:paren . '/e'
            endif
        else
            let l:chain = '\(' . join([l:var] + l:funcs,'\(\.\|->\)') . '\(\.\|->\)\)' . '\<' . a:old_name . '\>' . a:paren
            if s:followChain(l:dec,l:funcs,a:new_name) == 1 && match(getline('.'),l:chain) >= 0
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                execute 'silent s/' . l:chain . '/\1' . a:new_name . a:paren . '/e'
            endif
        endif
        call cursor(l:next[0],l:next[1])
        let l:next = searchpos(l:search,'Wn')
    endwhile

    silent write!
endfunction

" updateUsingFiles {{{3
function! s:updateUsingFiles(files,type_name,old_name,new_name,paren) abort
    for file in a:files
        execute 'silent tabedit! ' . file
        call s:updateUsingFile(a:type_name,a:old_name,a:new_name,a:paren)
        call s:safeClose()
    endfor
    silent edit!
endfunction 

" getArgs {{{3
function! s:getArgs() abort
    let l:prev = [line('.'),col('.')]
    if matchstr(getline('.'), '\%' . col('.') . 'c.') != '('
        call search('(')
    endif
    let l:start = strpart(getline('.'),0,col('.')-1)
    normal %
    let l:leftover = strpart(getline('.'),col('.'))
    let l:end = line('.')
    call cursor(l:prev[0],l:prev[1])

    let l:start = substitute(l:start,s:special_chars,'\\\1','g')
    let l:leftover = substitute(l:leftover,s:special_chars,'\\\1','g')

    let l:args = join(getline(l:prev[0],l:end))
    let l:args = substitute(l:args,l:start . '(\(.*\))' . l:leftover,'\1','')

    if l:args == ''
        return 0
    endif

    let l:car = 0
    let l:par = 0
    let l:count = 1
    let l:i = 0
    let l:prev = 0
    while l:i < len(l:args)
        let char = l:args[l:i]
        if char == ',' && l:car == 0 && l:par == 0
            let l:count += 1
        elseif char == '>'
            let l:car -= 1
        elseif char == '<'
            let l:car += 1
        elseif char == ')'
            let l:par -= 1
        elseif char == '('
            let l:par += 1
        endif
        let l:i += 1
    endwhile
    return l:count
endfunction

" updateParamFile {{{3
function! s:updateParamFile(method_name,commas,default,param_name,param_type) abort
    call cursor(1,1)
    let l:search = a:method_name . '('

    let l:next = searchpos(l:search,'Wn')
    let [l:param_search,l:insert] = ['',a:default . ')']
    let l:com = a:commas > 0 ? ', ' : ''
    if a:commas > 0
        let l:insert = ', ' . l:insert
        let l:param_search = '\_[^;]\{-\}'
        let l:param_search .= repeat(',' . '\_[^;]\{-\}',a:commas - 1)
    endif
    let l:param_search = '\((' . l:param_search . '\))'

    while l:next != [0,0]
        call cursor(l:next[0],l:next[1])
        if s:getArgs() == a:commas
            let l:func = s:cpp_type . '\_s*' . s:collection_identifier . '\<' . a:method_name . '\>\_s*('
            if match(getline('.'),l:func) >= 0
                let l:end = searchpos(')','Wn')

                let l:line = substitute(getline(l:end[0]), ')', l:com . a:param_type . ' ' . a:param_name . ')', '')
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                execute 'silent ' .  l:end[0] . 'd'
                call append(l:end[0] - 1,l:line)
            else
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                call search('(')
                normal %
                let l:end = line('.')
                let l:leftover = strpart(getline('.'),col('.'))
                call cursor(l:next[0],l:next[1])
                execute 'silent ' . line('.') . ',' . l:end . 's/\<' .a:method_name . '\>' . l:param_search . '\(' . l:leftover . '\)/' . 
                            \ a:method_name . '\1' . l:insert . '\2/e'
            endif

            call cursor(l:next[0],l:next[1])
        endif
        let l:next = searchpos(l:search,'Wn')
    endwhile

    silent write!
endfunction

" updateFile {{{3
function! s:updateFile(old_name,new_name,is_method,is_local)
    let l:orig = [line('.'),col('.')]

    if a:is_local == 1
        let l:query = '\(^\|[^.]\)\<' . a:old_name . '\>'
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent s/' . l:query . '/\1' . a:new_name . '/g'

        call s:gotoTag()
        let l:closing = s:getClosingBracket(1)

        let l:next = searchpos(l:query,'Wn')
        while s:isBefore(l:next,l:closing)
            if l:next == [0,0]
                break
            endif
            call cursor(l:next[0],l:next[1])
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
            execute 'silent s/' . l:query . '/\1' . a:new_name . '/g'

            let l:next = searchpos(l:query,'Wn')
        endwhile
    else
        let l:paren = a:is_method == 1 ? '(' : ''
        try
            execute 'silent lvimgrep /\(^\|[^.]\)\<' . a:old_name . '\>' . l:paren . '/j %:p'
            let g:factorus_qf += map(getloclist(0),{n,val -> {'filename' : expand('%:p'), 'lnum' : val['lnum'], 'text' : s:trim(val['text'])}})
        catch /.*/
        endtry
        call setloclist(0,[])

        execute 'silent %s/\(^\|[^.]\)\<' . a:old_name . '\>' . l:paren . '/\1' . a:new_name . l:paren . '/ge'
    endif

    call cursor(l:orig[0],l:orig[1])
    silent write!
endfunction

" Renaming {{{2
" renameArg {{{3
function! s:renameArg(new_name,...) abort
    let l:var = expand('<cword>')
    let g:factorus_history['old'] = l:var
    call s:updateFile(l:var,a:new_name,0,1)

    if !factorus#isRollback(a:000)
        redraw
        echo 'Re-named ' . l:var . ' to ' . a:new_name
    endif
    return [l:var,[]]
endfunction

" renameField {{{3
function! s:renameField(new_name,...) abort
    let l:search = '^\s*' . s:modifier_query . '\(' . s:cpp_type . s:collection_identifier . '\)\=\s*\(' . s:cpp_identifier . '\)\s*[;=].*'

    let l:line = getline('.')
    let l:is_static = match(l:line,'\<static\>') >= 0 ? 1 : 0
    let l:is_local = !s:isInType()
    let l:type = substitute(l:line,l:search,'\4','')
    let l:var = s:trim(substitute(l:line,l:search,'\7',''))
    if l:var == '' || l:type == '' || match(l:var,'[^' . s:search_chars . ']') >= 0
        if l:is_local == 1 || match(getline(s:getAdjacentTag('b')),'\<enum\>') < 0
            throw 'Factorus:Invalid'
        endif
        let l:var = expand('<cword>')
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent s/\<' . l:var . '\>/' . a:new_name . '/e'
        silent write!

        let l:temp_file = '.FactorusEnum'
        
        echo 'Updating enum...'
        call s:findTags(l:temp_file,'\<' . l:var . '\>','no')
        call s:updateQuickFix(l:temp_file,'\<' . l:var . '\>')
        call system('cat ' . l:temp_file . ' | xargs sed -i "s/\<' . l:var . '\>/' . a:new_name . '/g"')
        call system('rm -rf ' . l:temp_file)

        let l:unchanged = s:getUnchanged('\<' . l:var . '\>')
        redraw
        echo 'Renamed enum field ' . l:var . ' to ' . a:new_name . '.'
        return [l:var,l:unchanged]
    elseif l:var == a:new_name
        throw 'Factorus:Duplicate'
    endif
    let g:factorus_history['old'] = l:var

    let l:unchanged = []
    if l:is_local == 1
        call s:updateFile(l:var,a:new_name,0,l:is_local)
    else
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent s/\<' . l:var . '\>/' . a:new_name . '/e'

        call s:gotoTag()

        let l:search = '^\s*\(\<typedef\>\)\=\_s*\<\(struct\|union\)\>\_s*\(' . s:cpp_identifier . '\)\=\_s*{\=.*'
        let l:type_type = substitute(getline('.'),l:search,'\2','')
        if l:type_type == ''
            throw 'Factorus:Invalid'
        endif

        let l:type_defs = []
        let l:type_name = ''
        if substitute(getline('.'),l:search,'\3','') != ''
            let l:type_name = substitute(getline('.'),l:search,'\3','')
        endif

        if match(getline('.'),'\<typedef\>') >= 0
            let l:prev = [line('.'),col('.')]
            call search('{')
            normal %
            if match(getline('.'),'\<\(' . s:cpp_identifier . '\)\>') >= 0
                call add(l:type_defs,substitute(getline('.'),'.*\<\(' . s:cpp_identifier . '\)\>.*','\1',''))
            endif
            call cursor(l:prev[0],l:prev[1])
        endif

        let l:includes = s:getAllIncluded()

        try
            execute 'silent lvimgrep /\<' . l:method_name . '\>(/j ' . join(l:includes)
            execute 'silent tabedit! ' . getbufinfo(getloclist(0)[0]['bufnr'])[0]['name']
            call setloclist(0,[])
            let l:swap = 1
        catch /.*/
            let l:swap = 0
        endtry

        redraw
        echo 'Updating references...'

        let l:temp_file = '.FactorusInc'
        call s:getInclusions(l:temp_file,l:is_static)
        call s:narrowTags(l:temp_file,'\(\.\|->\)' . l:var)

        let l:files = readfile(l:temp_file) + [expand('%:p')]
        if l:type_name != ''
            let l:type_defs += s:getTypeDefs(l:type_name,l:type_type)
            let l:find_name = l:type_type . '\_s*' . l:type_name
            call add(l:type_defs,l:find_name)
        endif

        let l:def_find = join(l:type_defs,'\|')
        call s:updateUsingFiles(l:files,l:def_find,l:var,a:new_name,'')
        call system('rm -rf ' . l:temp_file)
        let l:unchanged = s:getUnchanged('\(\.\|->\)\<' . l:var . '\>')
    endif

    redraw
    echo 'Re-named ' . l:var . ' to ' . a:new_name
    return [l:var,l:unchanged]
endfunction

" renameMacro {{{3
function! s:renameMacro(new_name,...) abort
    let l:search = '^#define \<\(' . s:cpp_identifier . '\)\>.*'
    let l:macro = substitute(getline('.'),l:search,'\1','')
    if l:macro == '' || l:macro == getline('.')
        throw 'Factorus:Invalid'
    endif
    call s:updateFile(l:macro,a:new_name,0,0)

    let l:temp_file = '.FactorusMacro'
    call s:getInclusions(l:temp_file,0)
    call s:updateQuickFix(l:temp_file,'\<' . l:macro . '\>')

    call system('cat ' . l:temp_file . ' | xargs sed -i "s/\<' . l:macro . '\>/' . a:new_name . '/g"')
    call system('rm -rf ' . l:temp_file)
    let l:unchanged = s:getUnchanged('\<' . l:macro . '\>')

    silent edit!
    redraw
    echo 'Renamed macro ' . l:macro . ' to ' . a:new_name . '.'

    return [l:macro,l:unchanged]
endfunction

" renameMethod {{{3
function! s:renameMethod(new_name,...) abort
    call s:gotoTag()

    let l:unchanged = []
    let l:method_name = matchstr(getline('.'),'\<' . s:cpp_identifier . '\>\s*(')
    let l:method_name = matchstr(l:method_name,'[^[:space:](]\+')
    if l:method_name == a:new_name
        throw 'Factorus:Duplicate'
    endif
    let g:factorus_history['old'] = l:method_name

    let l:is_static = match(getline('.'),'\<static\>[^)]\+(') >= 0 ? 1 : 0

    let l:includes = s:getAllIncluded()
    try
        execute 'silent lvimgrep /\<' . l:method_name . '\>(/j ' . join(l:includes)
        execute 'silent tabedit! ' . getbufinfo(getloclist(0)[0]['bufnr'])[0]['name']
        call setloclist(0,[])
        let l:swap = 1
    catch /.*/
        let l:swap = 0
    endtry

    call s:updateFile(l:method_name,a:new_name,1,0)

    redraw
    echo 'Updating references...'
    let l:search = '\([^.]\)\<' . l:method_name . '\>('
    let l:temp_file = '.FactorusInc'

    call s:getInclusions(l:temp_file,l:is_static)
    call s:updateQuickFix(l:temp_file,l:search)

    call system('cat ' . l:temp_file . ' | xargs sed -i "s/' . l:search . '/\1' . a:new_name . '(/g"')
    call system('rm -rf ' . l:temp_file)
    let l:unchanged = s:getUnchanged('\<' . l:method_name . '\>')

    if l:swap == 1
        call s:safeClose()
    endif
    silent edit!

    redraw
    let l:keyword = l:is_static == 1 ? ' static' : ''
    echo 'Re-named' . l:keyword . ' method ' . l:method_name . ' to ' . a:new_name

    return [l:method_name,l:unchanged]
endfunction

" renameType {{{3
function! s:renameType(new_name,...) abort
    call s:gotoTag()

    let l:unchanged = []
    let l:search = '^.*\<\(enum\|struct\|union\)\>\s*\(\<' . s:cpp_identifier . '\>\)\s*\({\|\<' . s:cpp_identifier . '\>\_s*;\).*'
    if match(getline('.'),l:search) < 0
        throw 'Factorus:Invalid'
    endif

    let [l:type,l:type_name] = split(substitute(getline('.'),l:search,'\1|\2',''),'|')
    let l:is_static = match(getline('.'),'\<static\>[^)]\+(') >= 0 ? 1 : 0
    let l:rep = '\<' . l:type . '\>\_s*\<' . l:type_name . '\>'
    let l:new_rep = l:type . ' ' . a:new_name
    let g:factorus_history['old'] = l:type . ' ' . l:type_name

    let l:includes = s:getAllIncluded()
    try
        execute 'silent lvimgrep /' . l:rep . '/j ' . join(l:includes)
        execute 'silent tabedit! ' . getbufinfo(getloclist(0)[0]['bufnr'])[0]['name']
        call setloclist(0,[])
        let l:swap = 1
    catch /.*/
        let l:swap = 0
    endtry

    call s:updateFile(l:rep,l:new_rep,0,0)

    redraw
    echo 'Updating references...'

    let l:search = '\<' . l:type . '\>[[:space:]]*\<' . l:type_name . '\>'
    let l:temp_file = '.FactorusInc'

    call s:getInclusions(l:temp_file,l:is_static)
    call s:updateQuickFix(l:temp_file,l:search)

    call system('cat ' . l:temp_file . ' | xargs sed -i "s/' . l:search . '/' . l:new_rep . '/g"')
    call system('rm -rf ' . l:temp_file)
    let l:unchanged = s:getUnchanged(l:search)

    if l:swap == 1
        call s:safeClose()
    endif
    silent edit!

    if !factorus#isRollback(a:000)
        redraw
        let l:keyword = l:is_static == 1 ? ' static' : ''
        echo 'Re-named' . l:keyword . ' ' . l:type . ' ' . l:type_name . ' to ' . a:new_name
    endif
    return [l:type . ' ' . l:type_name,l:unchanged]
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
    let l:if = '\<if\>\_s*(\_[^{;]*)\_s*{\='
    let l:for = '\<for\>\_s*(\_[^{;]*;\_[^{;]*;\_[^{;]*)\_s*{\='
    let l:while = '\<while\>\_s*(\_[^{;]*)'
    let l:do = '\<do\>\_s*{'
    let l:switch = '\<switch\>\_s*(\_[^{]*)\_s*{'
    let l:search = '\(' . l:if . '\|' . l:for . '\|' . l:while . '\|' . l:do . '\|' . l:switch . '\)'

    let l:orig = [line('.'),col('.')]
    call s:gotoTag()
    let l:blocks = [[line('.'),a:close[0]]]

    let l:open = searchpos('{','Wn')
    let l:next = searchpos(l:search,'Wn')
    while l:next[0] <= a:close[0]
        if l:next == [0,0]
            break
        endif
        call cursor(l:next[0],l:next[1])

        if match(getline('.'),'\<else\>') >= 0 || match(getline('.'),'}\s*\<while\>') >= 0
            let l:next = searchpos(l:search,'Wn')
            continue
        endif

        if match(getline('.'),'\<\(if\|for\|while\)\>') >= 0
            let l:open = [line('.'),col('.')]
            call search('(')
            normal %

            let l:ret =  searchpos('{','Wn')
            let l:semi = searchpos(';','Wn')

            let l:o = line('.')
            if s:isBefore(l:semi,l:ret) == 1
                call cursor(l:semi[0],l:semi[1])
                call add(l:blocks,[l:open[0],line('.')])
            elseif match(getline('.'),'\<if\>') >= 0
                call cursor(l:ret[0],l:ret[1])
                normal %

                let l:continue = '}\_s*else\_s*\(\<if\>\_[^{]*)\)\={'
                let l:next = searchpos(l:continue,'Wnc')
                while l:next == [line('.'),col('.')]
                    if l:next == [0,0]
                        let l:next = l:ret
                        break
                    endif
                    call add(l:blocks,[l:o,line('.')])
                    call search('{','W')
                    let l:o = line('.')
                    normal %

                    let l:next = searchpos(l:continue,'Wnc')
                endwhile
                call add(l:blocks,[l:o,line('.')])
                if l:o != l:open[0]
                    call add(l:blocks,[l:open[0],line('.')])
                endif
            else
                call search('{','W')
                let l:prev = [line('.'),col('.')]
                normal %
                call add(l:blocks,[l:next[0],line('.')])
                call cursor(l:prev[0],l:prev[1])
            endif

            call cursor(l:open[0],l:open[1])
        elseif match(getline('.'),'\<switch\>') >= 0
            let l:open = [line('.'),col('.')]
            call searchpos('{','W')

            normal %
            let l:sclose = [line('.'),col('.')]
            normal %

            let l:continue = '\<\(case\|default\)\>[^:]*:'
            let l:next = searchpos(l:continue,'Wn')

            while s:isBefore(l:next,l:sclose) == 1 && l:next != [0,0]
                call cursor(l:next[0],l:next[1])
                let l:next = searchpos(l:continue,'Wn')
                if s:isBefore(a:close,l:next) == 1 || l:next == [0,0]
                    call add(l:blocks,[line('.'),a:close[0]])
                    break
                endif
                call add(l:blocks,[line('.'),l:next[0]-1])
            endwhile
            call add(l:blocks,[l:open[0],l:sclose[0]])
        else
            call search('{','W')
            let l:prev = [line('.'),col('.')]
            normal %
            call add(l:blocks,[l:next[0],line('.')])
            call cursor(l:prev[0],l:prev[1])
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
        call cursor(var[2],1)
        if match(getline('.'),'\<for\>') >= 0
            call search('(')
            normal %
            if s:isBefore(searchpos(';','Wn'),searchpos('{','Wn'))
                let l:start_lines = range(var[2],search(';','Wn'))
            else
                call search('{')
                normal %
                let l:start_lines = range(var[2],line('.'))
            endif
            call cursor(var[2],1)
        else
            let l:start_lines = [var[2]]
        endif
        let l:local_close = var[2] == l:begin ? s:getClosingBracket(1) : s:getClosingBracket(0)
        let a:closes[var[0]] = copy(l:local_close)
        call cursor(l:orig[0],l:orig[1])
        if index(keys(l:lines),var[0]) < 0
            let l:lines[var[0]] = {var[2] : l:start_lines}
        else
            let l:lines[var[0]][var[2]] = l:start_lines
        endif
        let l:isos[var[0]] = {}
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

            let l:ldec = s:getLatestDec(l:lines,l:name,l:next[1])

            let l:quoted = s:isQuoted('\<' . l:name . '\>',s:getStatement(l:next[1][0]))
            if s:isBefore(l:next[1],a:closes[l:name]) == 1 && l:quoted == 0 && l:ldec > 0
                if index(l:lines[l:name][l:ldec],l:next[1][0]) < 0
                    call add(l:lines[l:name][l:ldec],l:next[1][0])
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
    elseif s:contains(a:block,l:continue)
        call cursor(l:continue,1)
        let l:loop = searchpair('\<\(for\|while\)\>','','}','Wbn')
        if l:loop != 0 && l:loop < a:block[0]
            let l:res = 0
        endif
    else
        while l:ref[1] != [0,0] && s:isBefore(l:ref[1],[a:block[1]+1,1]) == 1
            let l:i = s:getLatestDec(a:rels,l:ref[2],l:ref[1])
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
function! s:getIsolatedLines(var,compact,rels,blocks,close)
    let l:refs = a:rels[a:var[0]][a:var[2]]
    let [l:names,l:decs] = a:compact

    if len(l:refs) == 1
        return []
    endif

    let l:orig = [line('.'),col('.')]
    let [l:name,l:type,l:dec] = a:var

    let l:wraps = []
    if match(getline(a:var[2]),'\<for\>') >= 0
        let l:for = s:getContainingBlock(a:var[2],a:blocks,a:blocks[0])
        if s:isIsolatedBlock(l:for,a:var,a:rels,a:close) == 0
            return []
        endif
    endif
    let l:dec_block = s:getContainingBlock(a:var[2],a:blocks,a:blocks[0])
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
                if index(l:names,l:next_use[0]) >= 0
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

            if l:block[1] - l:block[0] == 0 && match(getline(l:block[0]),'\<\(try\|for\|if\|while\)\>') < 0
                let l:stop = l:block[0]
                while match(getline(l:stop),';') < 0
                    let l:stop += 1
                endwhile
                let l:block[1] = l:stop
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
" getLatestDec {{{3
function! s:getLatestDec(rels,name,loc)
    let l:min = 0
    for dec in keys(a:rels[a:name])
        if l:min <= dec && dec <= a:loc[0]
            let l:min = dec
        endif
    endfor
    return l:min
endfunction

" findVar {{{3
function! s:findVar(vars,names,name,dec)
    let l:i = index(a:names,a:name)
    let l:var = a:vars[l:i]
    while l:var[2] != a:dec
        let l:i = index(a:names,a:name,l:i + 1)
        let l:var = a:vars[l:i]
    endwhile
    return l:var
endfunction

" getNewArgs {{{3
function! s:getNewArgs(lines,vars,rels,...)

    let l:names = map(deepcopy(a:vars),{n,var -> var[0]})
    let l:search = '\(' . join(l:names,'\|') . '\)'
    let l:search = s:no_comment . '.*\<' . l:search . '\>.*'
    let l:args = []

    for line in a:lines
        let l:this = getline(line)
        if match(l:this,'^\s*\(\/\/\|*\)') >= 0
            continue
        endif
        let l:new = substitute(l:this,l:search,'\1','')
        while l:new != l:this
            let l:spot = str2nr(s:getLatestDec(a:rels,l:new,[line,1]))
            if l:spot == 0
                break
            endif
            let l:next_var = s:findVar(a:vars,l:names,l:new,l:spot)

            if index(l:args,l:next_var) < 0 && index(a:lines,l:spot) < 0 && (a:0 == 0 || l:next_var[0] != a:1[0] || l:next_var[2] == a:1[2]) 
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

        if arg[2] == l:head
            continue
        endif

        let l:wrap = 1
        let l:name = arg[0]
        let l:next = s:getNextUse(l:name)

        while l:next[1] != [0,0] && s:isBefore(l:next[1],a:close) == 1
            if l:next[2] != 'left' && l:next[2] != 'return' && index(a:lines,l:next[1][0]) < 0
                let l:wrap = 0    
                break
            endif
            call cursor(l:next[1][0],l:next[1][1])
            let l:next = s:getNextUse(l:name)
        endwhile

        if l:wrap == 1
            let l:relevant = a:rels[arg[0]][arg[2]]
            let l:stop = arg[2]
            let l:dec = [l:stop]
            while match(getline(l:stop),';') < 0
                let l:stop += 1
                call add(l:dec,l:stop)
            endwhile
            let l:iso = l:dec + a:isos[arg[0]][arg[2]]

            let l:con = 1
            for rel in l:relevant
                if index(l:iso,rel) < 0 && index(a:lines,rel) < 0 && match(getline(rel),'\<return\>') < 0
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

" wrapAnnotations {{{3
function! s:wrapAnnotations(lines)
    for line in a:lines
        let l:prev = line - 1
        if match(getline(l:prev),'^\s*@') >= 0
            call add(a:lines,l:prev)
        endif
    endfor
    return uniq(sort(a:lines,'N'))
endfunction

" buildArgs {{{3
function! s:buildArgs(args,is_call)
    if a:is_call == 0
        let l:defs = map(deepcopy(a:args),{n,arg -> arg[1] . ' ' . arg[0]})
        let l:sep = '| '
    else
        let l:defs = map(deepcopy(a:args),{n,arg -> arg[0]})
        let l:sep = ', '
    endif
    return join(l:defs,l:sep)
endfunction

" formatMethod {{{3
function! s:formatMethod(def,body,spaces)
    let l:paren = stridx(a:def[0],'(')
    let a:def_space = repeat(' ',l:paren+1)
    call map(a:def,{n,line -> a:spaces . (n > 0 ? a:def_space : '') . substitute(line,'\s*\(.*\)','\1','')})

    let l:fspaces = a:spaces == '' ? repeat(' ',&tabstop) : a:spaces
    let l:dspaces = a:spaces == '' ? l:fspaces : repeat(a:spaces,2)
    let l:i = 0

    call map(a:body,{n,line -> substitute(line,'\s*\(.*\)','\1','')})
    while l:i < len(a:body)
        if match(a:body[l:i],'}') >= 0
            let l:dspaces = strpart(l:dspaces,len(l:fspaces))
        endif
        let a:body[l:i] = l:dspaces . a:body[l:i]

        if match(a:body[l:i],'{') >= 0
            let l:dspaces .= l:fspaces
        endif

        let l:i += 1
    endwhile
endfunction

" buildNewMethod {{{3
function! s:buildNewMethod(lines,args,ranges,vars,rels,tab,close,...)
    let l:body = map(copy(a:lines),{n,line -> getline(line)})

    call cursor(a:lines[-1],1)
    let l:type = 'void'
    let l:return = ['}'] 
    let l:call = ''

    let l:outer = s:getContainingBlock(a:lines[0],a:ranges,a:ranges[0])
    let l:include_dec = 1
    for var in a:vars
        if index(a:lines,var[2]) >= 0

            let l:outside = s:getNextUse(var[0])    
            if l:outside[1] != [0,0] && s:isBefore(l:outside[1],a:close) == 1 && s:getLatestDec(a:rels,var[0],l:outside[1]) == var[2]

                let l:contain = s:getContainingBlock(var[2],a:ranges,a:ranges[0])
                if l:contain[0] <= l:outer[0] || l:contain[1] >= l:outer[1]
                    let l:type = var[1]
                    let l:return = ['return ' . var[0] . ';','}']
                    let l:call = l:type . ' ' . var[0] . ' = '

                    let i = 0
                    while i < len(a:lines)
                        let line = getline(a:lines[i])
                        if match(line,';') >= 0 && match(line,'[^.]\<' . var[0] . '\>[^.]') >= 0
                            break
                        endif
                        let i += 1
                    endwhile

                    if i == len(a:lines)
                        break
                    endif

                    let l:inner = s:getContainingBlock(a:lines[i+1],a:ranges,l:outer)
                    if l:inner[1] - l:inner[0] > 0 && match(getline(l:inner[0]),'\<\(if\|else\)\>') >= 0
                        let l:removes = []
                        for j in range(i+1)
                            if match(getline(a:lines[j]),'[^.]\<' . var[0] . '\>[^.][^=]*=') >= 0
                                call add(l:removes,j)
                                let k = j
                                while match(getline(a:lines[k]),';') < 0
                                    let k += 1
                                    call add(l:removes,k)
                                endwhile
                            endif
                        endfor
                        for rem in reverse(l:removes)
                            call remove(a:lines,rem)
                        endfor
                        let l:call = var[0] . ' = '
                        let l:include_dec = 0
                    endif
                    break
                endif

            endif

        endif
    endfor

    let l:name = a:0 == 0 ? g:factorus_method_name : a:1
    let l:build = s:buildArgs(a:args,0)
    let l:build_string = l:type . ' ' .  l:name . '(' . l:build . ') {'
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

    let l:body += l:return
    call s:formatMethod(l:def,l:body,a:tab)
    let l:final = [''] + l:def + l:body + ['']

    let l:arg_string = s:buildArgs(a:args,1)
    let l:call_space = substitute(getline(a:lines[-1]),'\(\s*\).*','\1','')
    let l:rep = [l:call_space . l:call . l:name . '(' . l:arg_string . ');']

    return [l:final,l:rep]
endfunction

" Rollback {{{2
" rollbackAddParam {{{3
function! s:rollbackAddParam()
    let l:files = {}
    let [l:method_name,l:param_name,l:count] = g:factorus_history['old']

    for line in g:factorus_qf
        if index(keys(line),'filename') < 0
            if line['pattern'] == 'Unmodified'
                break
            endif
            continue
        endif

        if index(keys(l:files),line['filename']) < 0
            let l:files[line['filename']] = [line['lnum']]
        else
            call add(l:files[line['filename']],line['lnum'])
        endif
    endfor

    for file in keys(l:files)
        execute 'silent tabedit! ' . file
        for line in l:files[file]
            call cursor(line,1)
            let l:nline = search(l:method_name . '(','We')
            let l:call_count = 0
            while l:nline == line
                if s:getArgs() == l:count
                    let l:calls = repeat('.\{-\}' . l:method_name . '(.\{-\}',l:call_count)
                    let col = col('.')
                    normal %
                    let end = line('.')
                    let l:leftover = substitute(strpart(getline('.'),col('.')),s:special_chars,'\\\1','g')

                    call cursor(line,1)
                    execute line . ',' . end . 's/\(' . l:calls . '\)\<\(' . l:method_name . '\>(\_.\{-\}\)\(,\=[^,)]*)\)\(' . l:leftover . '\)/\1\2)\4/e'
                    call cursor(line,col)
                endif
                let l:call_count += 1
                let l:nline = search(l:method_name . '(','We')
            endwhile
        endfor
        silent write!
        call s:safeClose()
    endfor

    return 'Rolled back adding of param ' . l:param_name . '.'
endfunction

" rollbackRename {{{3
function! s:rollbackRename()
    let l:files = {}

    for line in g:factorus_qf
        if index(keys(line),'filename') < 0
            if line['pattern'] == 'Unmodified'
                break
            endif
            continue
        endif

        if index(keys(l:files),line['filename']) < 0
            let l:files[line['filename']] = [line['lnum']]
        else
            call add(l:files[line['filename']],line['lnum'])
        endif
    endfor

    let l:old = g:factorus_history['old']
    let l:new = g:factorus_history['args'][-1] == 'Type' ? split(l:old)[0] . ' ' . g:factorus_history['args'][0] : g:factorus_history['args'][0]

    for file in keys(l:files)
        execute 'silent tabedit! ' . file
        for line in l:files[file]
            call cursor(line,1)
            execute 'silent! s/\<' . l:new . '\>/' . l:old . '/ge'
        endfor
        silent write!
        call s:safeClose()
    endfor

    return 'Rolled back renaming of ' . substitute(g:factorus_history['args'][-1],'\(.\)\(.*\)','\L\1\E\2','') . ' ' . l:old
endfunction

" rollbackExtraction {{{3
function! s:rollbackExtraction()
    let l:open = search(g:factorus_method_name . '(\_[^;]*{')
    let l:close = s:getClosingBracket(1)[0]

    if match(getline(l:open - 1),'^\s*$') >= 0
        let l:open -= 1
    endif
    if match(getline(l:close + 1),'^\s*$') >= 0
        let l:close += 1
    endif

    execute 'silent ' . l:open . ',' . l:close . 'delete'

    call search('\<' . g:factorus_method_name . '\>(')
    call s:gotoTag()
    let l:open = line('.')
    let l:close = s:getClosingBracket(1)[0]

    execute 'silent ' . l:open . ',' . l:close . 'delete'
    call append(line('.')-1,g:factorus_history['old'][1])
    call cursor(l:open,1)
    silent write!
endfunction

" Global Functions {{{1
" addParam {{{2
function! cpp#factorus#addParam(param_name,param_type,...) abort
    if factorus#isRollback(a:000)
        call s:rollbackAddParam()
        let g:factorus_qf = []
        return 'Removed new parameter ' . a:param_name . '.'
    endif
    let g:factorus_qf = []

    let [s:all_inc,s:all_funcs] = [{},{}]
    let [l:orig,l:prev_dir,l:curr_buf] = s:setEnvironment()

    try
        call s:gotoTag()
        let l:tag = line('.')
        let l:next = searchpos(')','Wn')
        let [l:type,l:name,l:params] = split(substitute(join(getline(line('.'),l:next[0])),'^.*\<\(' . s:cpp_type . 
                    \ s:collection_identifier . '\)\s*\<\(' . s:cpp_identifier . '\)\>\s*(\(.*\)).*','\1 | \4 | \5',''),'|')
        let [l:type,l:name] = [s:trim(l:type),s:trim(l:name)]
        let g:factorus_history['old'] = [l:name,a:param_name]

        let l:includes = s:getAllIncluded()
        try
            execute 'silent lvimgrep /\<' . l:name . '\>(/j ' . join(l:includes)
            execute 'silent tabedit! ' . getbufinfo(getloclist(0)[0]['bufnr'])[0]['name']
            call cursor(getloclist(0)[0]['lnum'],1)
            call setloclist(0,[])
            let l:swap = 1
        catch /.*/
            call cursor(l:tag,1)
            let l:swap = 0
        endtry

        let l:count = len(split(l:params,','))
        let l:com = l:count > 0 ? ', ' : ''

        let l:next = searchpos(')','Wn')
        let l:is_static = match(getline(l:next[0]),'\<static\>[^)]\+(') >= 0 ? 1 : 0
        let l:line = substitute(getline(l:next[0]), ')', l:com . a:param_type . ' ' . a:param_name . ')', '')
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent ' .  l:next[0] . 'd'
        call append(l:next[0] - 1,l:line)
        silent write!

        if g:factorus_add_default == 1
            redraw
            echo 'Updating references...'

            let l:default = a:0 > 0 ? a:1 : 'null'

            let l:temp_file = '.FactorusParam'
            call s:getInclusions(l:temp_file,l:is_static)
            call s:narrowTags(l:temp_file,l:name)
            for file in readfile(l:temp_file)
                execute 'silent tabedit! ' . file
                call s:updateParamFile(l:name,l:count,l:default,a:param_name,a:param_type)
                call s:safeClose()
            endfor
            call system('rm -rf ' . l:temp_file)

            if g:factorus_show_changes > 0
                call s:setChanges(l:name,[],'addParam')
            endif

        endif
        redraw
        echo 'Added parameter ' . a:param_name . ' to method ' . l:name . '.'

        if l:swap == 1
            call s:safeClose()
        endif

        call s:resetEnvironment(l:orig,l:prev_dir,l:curr_buf,'addParam')
        return [l:name,a:param_name,l:count+1]
    catch /.*/
        call s:resetEnvironment(l:orig,l:prev_dir,l:curr_buf,'addParam')
        let l:err = match(v:exception,'^Factorus:') >= 0 ? v:exception : 'Factorus:' . v:exception
        throw l:err . ', at ' . v:throwpoint
    endtry

    if factorus#isRollback(a:000)
        call s:gotoTag()
        execute 'silent s/,\=[^,]\{-\})/)/e'
        silent write!
        return 'Removed new parameter ' . a:param_name
    endif
    let g:factorus_history['old'] = a:param_name

    let l:orig = [line('.'),col('.')]
    call s:gotoTag()

    let l:next = searchpos(')','Wn')
    let l:line = substitute(getline(l:next[0]), ')', ', ' . a:param_type . ' ' . a:param_name . ')', '')
    execute 'silent ' .  l:next[0] . 'd'
    call append(l:next[0] - 1,l:line)

    silent write!
    silent edit!
    call cursor(l:orig[0],l:orig[1])

    echo 'Added parameter ' . a:param_name . ' to method'
    return a:param_name
endfunction

" renameSomething {{{2
function! cpp#factorus#renameSomething(new_name,type,...)
    let [s:all_structs,s:all_inc,s:all_funcs] = [{},{},{}]
    let [l:orig,l:prev_dir,l:curr_buf] = s:setEnvironment()

    let l:res = ''
    try
        if factorus#isRollback(a:000)
            let l:res = s:rollbackRename()
            let g:factorus_qf = []
        else
            let g:factorus_qf = []
            let Rename = function('s:rename' . a:type)
            let [l:res,l:un] = Rename(a:new_name)

            if g:factorus_show_changes > 0
                call s:setChanges(l:res,l:un,'rename',a:type)
            endif
        endif
        call s:resetEnvironment(l:orig,l:prev_dir,l:curr_buf,a:type)
        return l:res
    catch /.*/
        call s:resetEnvironment(l:orig,l:prev_dir,l:curr_buf,a:type)
        let l:err = match(v:exception,'^Factorus:') >= 0 ? v:exception : 'Factorus:' . v:exception
        throw l:err . ', at ' . v:throwpoint
    endtry
endfunction

" extractMethod {{{2
function! cpp#factorus#extractMethod(...)
    if factorus#isRollback(a:000)
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif

    if a:1 != 1 || a:2 != line('$')
        return s:manualExtract(a:000)
    endif

    echo 'Extracting new method...'
    call s:gotoTag()
    let l:tab = substitute(getline('.'),'\(\s*\).*','\1','')
    let l:method_name = substitute(getline('.'),'.*\s\+\(' . s:cpp_identifier . '\)\s*(.*','\1','')

    let [l:open,l:close] = [line('.'),s:getClosingBracket(1)]
    let l:old_lines = getline(l:open,l:close[0])

    call searchpos('{','W')

    let l:method_length = (l:close[0] - (line('.') + 1)) * 1.0
    let l:vars = s:getLocalDecs(l:close)
    let l:names = map(deepcopy(l:vars),{n,var -> var[0]})
    let l:decs = map(deepcopy(l:vars),{n,var -> var[2]})
    let l:compact = [l:names,l:decs]
    let l:blocks = s:getAllBlocks(l:close)

    let l:best_var = ['','',0]
    let l:best_lines = []
    let [l:all,l:isos] = s:getAllRelevantLines(l:vars,l:names,l:close)

    redraw
    echo 'Finding best lines...'
    for var in l:vars
        let l:iso = s:getIsolatedLines(var,l:compact,l:all,l:blocks,l:close)
        let l:isos[var[0]][var[2]] = copy(l:iso)

        let l:ratio = (len(l:iso) / l:method_length)
        if g:factorus_extract_heuristic == 'longest'
            if len(l:iso) > len(l:best_lines) && index(l:iso,l:open) < 0 "&& l:ratio < g:factorus_method_threshold
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
        throw 'Factorus:NoLines' 
    endif

    redraw
    echo 'Almost done...'
    if index(l:best_lines,l:best_var[2]) < 0 && l:best_var[2] != l:open
        let l:stop = l:best_var[2]
        let l:dec_lines = [l:stop]
        while match(getline(l:stop),';') < 0
            let l:stop += 1
            call add(l:dec_lines,l:stop)
        endwhile

        let l:best_lines = l:dec_lines + l:best_lines
    endif

    let l:new_args = s:getNewArgs(l:best_lines,l:vars,l:all,l:best_var)
    let [l:wrapped,l:wrapped_args] = s:wrapDecs(l:best_var,l:best_lines,l:vars,l:all,l:isos,l:new_args,l:close)
    while l:wrapped != l:best_lines
        let [l:best_lines,l:new_args] = [l:wrapped,l:wrapped_args]
        let [l:wrapped,l:wrapped_args] = s:wrapDecs(l:best_var,l:best_lines,l:vars,l:all,l:isos,l:new_args,l:close)
    endwhile

    if l:best_var[2] == l:open && index(l:new_args,l:best_var) < 0
        call add(l:new_args,l:best_var)
    endif

    let l:best_lines = s:wrapAnnotations(l:best_lines)

    let l:new_args = s:getNewArgs(l:best_lines,l:vars,l:all,l:best_var)
    let [l:final,l:rep] = s:buildNewMethod(l:best_lines,l:new_args,l:blocks,l:vars,l:all,l:tab,l:close)

    call append(l:close[0],l:final)
    call append(l:best_lines[-1],l:rep)

    let l:i = len(l:best_lines) - 1
    while l:i >= 0
        call cursor(l:best_lines[l:i],1)
        d 
        let l:i -= 1
    endwhile

    call search(g:factorus_method_name . '(\_[^;]*{')
    silent write!
    redraw
    echo 'Extracted ' . len(l:best_lines) . ' lines from ' . l:method_name
    return [l:method_name,l:old_lines]
endfunction

" manualExtract {{{2
function! s;manualExtract(args)
    if factorus#isRollback(a:args)
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif

    let l:name = len(a:args) <= 2 ? g:factorus_method_name : a:args[2]

    echo 'Extracting new method...'
    call s:gotoTag()
    let [l:open,l:close] = [line('.'),s:getClosingBracket(1)]
    let l:tab = substitute(getline('.'),'\(\s*\).*','\1','')
    let l:method_name = substitute(getline('.'),'.*\s\+\(' . s:cpp_identifier . '\)\s*(.*','\1','')

    let l:extract_lines = range(a:args[0],a:args[1])
    let l:old_lines = getline(l:open,l:close[0])

    let l:vars = s:getLocalDecs(l:close)
    let l:names = map(deepcopy(l:vars),{n,var -> var[0]})
    let l:decs = map(deepcopy(l:vars),{n,var -> var[2]})
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

    call search('\<' . l:name . '\>(\_[^;]*{')
    silent write!
    redraw
    echo 'Extracted ' . len(l:extract_lines) . ' lines from ' . l:method_name

    return [l:name,l:old_lines]
endfunction
