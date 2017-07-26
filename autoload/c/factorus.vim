" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" Search Constants {{{1

let s:start_chars = '_A-Za-z'
let s:search_chars = s:start_chars . '0-9#'
let s:c_identifier = '[' . s:start_chars . '][' . s:search_chars . ']*'
let s:c_type = '\(enum\_s*\|struct\_s*\|union\_s*\|long\_s*\|short\_s*\)\=\<' . s:c_identifier . '\>'
let s:collection_identifier = '\([\[\*&]\=[[\]\*' . s:search_chars . '[:space:]&]*[\*\]]\)\='

let s:c_keywords = '\<\(break\|case\|continue\|default\|do\|else\|for\|goto\|if\|return\|sizeof\|switch\|while\)\>'
let s:c_allow = 'auto,char,const,double,enum,extern,float,inline,int,long,register,restrict,short,signed,static,struct,union,unsigned,void,volatile'

let s:modifiers = '\(typedef\_s*\|extern\_s*\|static\_s*\|auto\_s*\|register\_s*\|const\_s*\|restrict\_s*\|volatile\_s*\|signed\_s*\|unsigned\_s*\)\='
let s:modifier_query = repeat(s:modifiers,3)

let s:struct = '\<\(enum\|struct\|union\)\>\_s*\(' . s:c_identifier . '\)\=\_s*\({\|\<' . s:c_identifier . '\>\_s*;\)'
let s:func = s:c_type . '\_s*' . s:collection_identifier . '\<' . s:c_identifier . '\>\_s*('
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

function! s:isAlone(...)
    let a:file = a:0 > 0 ? a:1 : expand('%:p')
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

function! s:safeClose(...)
    let a:prev = 0
    let a:file = a:0 > 0 ? a:1 : expand('%:p')
    if getbufinfo(a:file)[0]['loaded'] == 1 && winnr("$") == 1 && tabpagenr("$") > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr("$")
        let a:prev = 1
    endif

    if index(s:open_bufs,a:file) < 0 && s:isAlone(a:file) == 1
        execute 'bwipeout ' . a:file
    elseif a:file == expand('%:p')
        q
    endif

    if a:prev == 1
        tabprev
    endif
endfunction

function! s:findTags(temp_file,search_string,append)
    let a:fout = a:append == 'yes' ? ' >> ' : ' > '
    call system('cat ' . s:temp_file . ' | xargs grep -l "' . a:search_string . '"' .  a:fout . a:temp_file . ' 2> /dev/null')
endfunction

function! s:narrowTags(temp_file,search_string)
    let a:n_temp_file = a:temp_file . '.narrow'
    call system('cat ' . a:temp_file . ' | xargs grep -l "' . a:search_string . '" {} + > ' . a:n_temp_file)
    call system('mv ' . a:n_temp_file . ' ' . a:temp_file)
endfunction

function! s:updateQuickFix(temp_file,search_string)
    let a:res = split(system('cat ' . a:temp_file . ' | xargs grep -n "' . a:search_string . '"'),'\n')
    call map(a:res,{n,val -> split(val,':')})
    if len(split(system('cat ' . a:temp_file),'\n')) == 1
        call map(a:res,{n,val -> {'filename' : expand('%:p'), 'lnum' : val[0], 'text' : s:trim(join(val[1:],':'))}})
    else
        call map(a:res,{n,val -> {'filename' : val[0], 'lnum' : val[1], 'text' : s:trim(join(val[2:],':'))}})
    endif
    let g:factorus_qf += a:res
endfunction

function! s:setQuickFix(type,qf)
    let a:title = a:type . ' : '
    if g:factorus_show_changes == 1
        let a:title .= 'ChangedFiles'
    elseif g:factorus_show_changes == 2
        let a:title .= 'UnchangedFiles'
    else
        let a:title .= 'AllFiles'
    endif

    call setqflist(a:qf)
    call setqflist(a:qf,'r',{'title' : a:title})
endfunction

function! s:setChanges(res,un,func,...)
    let a:qf = copy(g:factorus_qf)
    let a:type = a:func == 'rename' ? a:1 : ''

    let a:ch = len(g:factorus_qf)
    let a:ch_i = a:ch == 1 ? ' instance ' : ' instances '
    let a:un_l = len(a:un)
    let a:un_i = a:un_l == 1 ? ' instance ' : ' instances '

    let a:first_line = a:ch . a:ch_i . 'modified'
    let a:first_line .= (a:type == 'Arg' || a:func == 'addParam') ? '.' : ', ' . a:un_l . a:un_i . 'left unmodified.'

    if g:factorus_show_changes > 1 && a:func != 'addParam' && a:type != 'Arg'
        let a:un = [{'pattern' : 'Unmodified'}] + a:un
        if g:factorus_show_changes == 2
            let a:qf = []
        endif
        let a:qf += a:un
    endif

    if g:factorus_show_changes % 2 == 1
        let a:qf = [{'pattern' : 'Modified'}] + a:qf
    endif
    let a:qf = [{'text' : a:first_line,'pattern' : a:func . a:type}] + a:qf

    call s:setQuickFix(a:func . a:type,a:qf)
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

function! s:setEnvironment()
    let s:open_bufs = []

    let a:prev_dir = getcwd()
    let a:buf_nrs = []
    for buf in getbufinfo()
        call add(s:open_bufs,buf['name'])
        call add(a:buf_nrs,buf['bufnr'])
    endfor
    let a:curr_buf = a:buf_nrs[index(s:open_bufs,expand('%:p'))]

    execute 'silent cd ' . expand('%:p:h')
    let a:project_dir = g:factorus_project_dir == '' ? system('git rev-parse --show-toplevel') : g:factorus_project_dir
    execute 'silent cd ' a:project_dir

    let s:temp_file = '.FactorusTemp'
    call system('find ' . getcwd() . g:factorus_ignore_string . ' > ' . s:temp_file)

    return [[line('.'),col('.')],a:prev_dir,a:curr_buf]
endfunction

function! s:resetEnvironment(orig,prev_dir,curr_buf,type)
    let a:buf_setting = &switchbuf
    call system('rm -rf .Factorus*')
    execute 'silent cd ' a:prev_dir
    if a:type != 'Class'
        let &switchbuf = 'useopen,usetab'
        execute 'silent sbuffer ' . a:curr_buf
        let &switchbuf = a:buf_setting
    endif
    call cursor(a:orig[0],a:orig[1])
endfunction

" Utilities {{{2

function! s:getClosingBracket(stack,...)
    let a:orig = [line('.'),col('.')]
    if a:0 > 0
        call cursor(a:1[0],a:1[1])
    endif
    if a:stack == 0
        call searchpair('{','','}','Wb')
    else
        call search('{','Wc')
    endif
    normal %
    let a:res = [line('.'),col('.')]
    call cursor(a:orig[0],a:orig[1])
    return a:res
endfunction

function! s:isQuoted(pat,state)
    let a:temp = a:state
    let a:mat = match(a:temp,a:pat)
    let a:res = 1
    while a:mat >= 0 && a:res == 1
        let a:begin = strpart(a:temp,0,a:mat)
        let a:quotes = len(a:begin) - len(substitute(a:begin,'"','','g'))
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

function! s:isWrapped(pat,state)
    let a:match = match(a:state,a:pat)
    let a:temp = a:state
    let a:res = 1
    while a:match >= 0
        let a:begin = split(strpart(a:temp,0,a:match),'\zs')
        if count(a:begin,'>') >= count(a:begin,'<')
            let a:res = 0
            break
        endif
        let a:temp = substitute(a:temp,a:pat,'','')
        let a:match = match(a:temp,a:pat)
    endwhile
    return a:res
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
    let a:orig = [line('.'),col('.')]
    call cursor(a:start[0],a:start[1])
    let a:fin = searchpos(a:search,'Wen')
    call cursor(a:orig[0],a:orig[1])
    return a:fin
endfunction

function! s:getStatement(line)
    let a:i = a:line
    while match(getline(a:i),'\({\|;$\)') < 0
        let a:i += 1
    endwhile
    return join(getline(a:line,a:i))
endfunction

" Tag Navigation {{{2
" isValidTag {{{3
function! s:isValidTag(line)
    let a:first_char = strpart(substitute(getline(a:line),'\s*','','g'),0,1)   
    if a:first_char == '*' || a:first_char == '/'
        return 0
    endif

    let a:has_keyword = match(getline(a:line),s:c_keywords)
    if a:has_keyword >= 0 && s:isQuoted(s:c_keywords,getline(a:line)) == 0
        return 0
    endif

    if match(getline(a:line),';') >= 0 && match(getline(a:line),'(') < 0 && match(getline(a:line),'\<typedef\>') < 0
        return 0
    endif

    return 1
endfunction

" getAdjacentTag {{{3
function! s:getAdjacentTag(dir)
    let [a:oline,a:ocol] = [line('.'),col('.')]
    call cursor(a:oline + 1,a:ocol)

    let a:func = searchpos(s:tag_query,'Wn' . a:dir)
    let a:is_valid = 0
    while a:func != [0,0]
        let a:is_valid = s:isValidTag(a:func[0])
        if a:is_valid == 1
            break
        endif

        call cursor(a:func[0],a:func[1])
        let a:func = searchpos(s:tag_query,'Wn' . a:dir)
    endwhile
    call cursor(a:oline,a:ocol)

    if a:is_valid == 1
        return a:func[0]
    endif
    return 0
endfunction

" getNextTag {{{3
function! s:getNextTag()
    return [s:getAdjacentTag(''),1]
endfunction

" getTypeTag {{{3
function! s:getTypeTag()
    let [a:line,a:col] = [line('.'),col('.')]
    call cursor(1,1)
    let a:class_tag = search(s:tag_query,'n')
    let a:tag_end = search(s:tag_query,'ne')
    call cursor(a:line,a:col)
    return [a:class_tag,a:tag_end]
endfunction

"isInType {{{3
function! s:isInType()
    let a:orig = [line('.'),col('.')]
    let a:close = s:getClosingBracket(0)
    let a:back = s:getAdjacentTag('b')
    call cursor(a:back,1)

    let a:res = 0
    if s:isBefore(searchpos('{','Wn'),searchpos('(','Wn')) && s:getClosingBracket(1,[a:back,1]) == a:close
        let a:res = 1
    endif
    call cursor(a:orig[0],a:orig[1])
    return a:res
endfunction

" gotoTag {{{3
function! s:gotoTag()
    let a:tag = s:getAdjacentTag('b')
    if a:tag != 0
        call cursor(a:tag,1)
    else
        echo 'No tag found'
    endif
endfunction

" Class Hierarchy {{{2
" getIncluded {{{3
function! s:getIncluded()
    let a:orig = [line('.'),col('.')]
    call cursor(1,1)

    let a:files = []
    let a:include = '^#\<include\>\s*"'
    let a:next = search(a:include,'Wc')
    while a:next > 0
        if match(getline(a:next),'<.*>$') < 0
            call add(a:files,substitute(getline(a:next),'^.*"\(.*\/\)\=\(.*\)".*$','\2',''))
        endif
        call cursor(line('.') + 1,1)
        let a:next = search(a:include,'Wc')
    endwhile
    if a:files == []
        return []
    endif

    call map(a:files,{n,val -> '\/' . substitute(val,'\(.*\/\)\=\(.*\)','\2','')})
    let a:or = substitute(' "\(' . join(a:files,'\|') . '\)" ','\.','\\.','g')
    let a:fin = split(system('grep' . a:or . s:temp_file . ' 2> /dev/null'),'\n')

    call cursor(a:orig[0],a:orig[1])
    return a:fin
endfunction

" getAllIncluded {{{3 
function! s:getAllIncluded()
    if exists('s:all_inc') && index(keys(s:all_inc),expand('%:p')) >= 0
        return s:all_inc[expand('%:p')]
    endif

    let a:fin = s:getIncluded()
    let a:files = copy(a:fin)

    for file in a:files
        execute 'silent tabedit! ' . file
        let a:fin += s:getAllIncluded()
        call s:safeClose()
    endfor

    let s:all_inc[expand('%:p')] = a:fin
    return a:fin
endfunction

" getInclusions {{{3
function! s:getInclusions(temp_file)
    let a:swap_file = '.FactorusIncSwap'
    call system('> ' . a:temp_file)

    let a:inc = [expand('%:p:t')]
    while a:inc != []
        let a:search = '^#include\s*\".*\(' . join(a:inc,'\|') . '\)\"'
        call s:findTags(a:swap_file,a:search,'no')
        call system('cat ' . a:swap_file . ' >> ' . a:temp_file)
        let a:inc = filter(readfile(a:swap_file),'index(a:inc,v:val) < 0')
        call map(a:inc,{n,val -> substitute(val,'\(.*\/\)\=\(.*\)','\2','')})
    endwhile

    call system('sort -u ' . a:temp_file . ' -o ' . a:temp_file)
    call system('rm -rf ' . a:swap_file)
endfunction

" Declarations {{{2
" getTypeDefs {{{3
function! s:getTypeDefs(name,...)
    let a:type = a:0 > 0 ? '\_s*' . a:1 . '\_s*' : '\_s*'

    let a:temp_file = '.FactorusInc'
    call s:getInclusions(a:temp_file)
    let a:files = readfile(a:temp_file) + [expand('%:p')]
    call system('rm -rf ' . a:temp_file)

    let a:search = '\<typedef\>' . a:type . a:name . '\_s*\<\(' . s:c_identifier . '\)\>'
    try
        execute 'silent lvimgrep /' . a:search . '/j ' . join(a:files)
        let a:res = []
        for grep in getloclist(0)
            let a:def = substitute(grep['text'],a:search,'\1','')
            if index(a:res,a:def) < 0
                call add(a:res,a:def)
            endif
        endfor
        return a:res
    catch /.*/
        return []
    endtry
endfunction

" getStructDef {{{3
function! s:getStructDef(type)
    if exists('s:all_structs') && index(keys(s:all_structs),expand('%:p') . '-' . a:type) >= 0
        return s:all_structs[expand('%:p') . '-' . a:type]
    endif

    let a:files = s:getAllIncluded() + [expand('%:p')]
    let [a:prev_file,a:res] = ['',[]]
    if match(a:type,'\<\(struct\|union\)\>') >= 0
        try
            execute 'silent lvimgrep! /' . a:type . '\_s*{/j ' . join(a:files)
            execute 'silent tabedit! ' . getbufinfo(getloclist(0)[0]['bufnr'])[0]['name']
            call cursor(1,1)
            let a:find = search(a:type . '\_s*{','W')
            if a:find != 0
                let a:prev_file = expand('%:p')
                call search('{')
                let a:start = line('.')
                normal %
                let a:end = line('.')
                let a:def = join(getline(a:start,a:end))
                let a:res = a:def

                let a:res = s:trim(substitute(a:res,'^[^{]*{\(.*\)}[^}]*$','\1',''))
                let a:res = s:trim(substitute(a:res,'\/\*.\{-\}\*\/','','g'))
                let a:res = split(a:res,';')
                call map(a:res,{n,val -> s:trim(substitute(val,'\(\*\|\[[^]]*\]\)',' ','g'))})
                call map(a:res,{n,val -> [join(split(val)[:-2]),split(val)[-1]]})
            endif
            call s:safeClose()
        catch /.*/
        endtry
    else
    endif

    let s:all_structs[expand('%:p') . '-' . a:type] = [a:prev_file,a:type,deepcopy(a:res)]
    return [a:prev_file,a:type,a:res]
endfunction

" getNextArg {{{3
function! s:getNextArg(...)
    let a:get_variable = '^[^/*].*(.*\<\(' . a:1 . '\)\>' . s:collection_identifier . '\=\s\+\(\<' . a:2 . '\).*).*'
    let a:index = '\3'

    let a:line = line('.')
    let a:col = col('.')

    let a:match = searchpos(a:get_variable,'Wn')
    let a:end_match = searchpos(a:get_variable,'Wnze')

    if s:isBefore([a:line,a:col],a:match) == 1
        let a:var = substitute(getline(a:match[0]),a:get_variable,a:index,'')
        return [a:var,a:match]
    endif

    return ['none',[0,0]]
endfunction

" getParams {{{3
function! s:getParams() abort
    let a:prev = [line('.'),col('.')]
    call s:gotoTag()
    let a:oparen = search('(','Wn')
    let a:cparen = search(')','Wn')
    
    let a:dec = join(getline(a:oparen,a:cparen))
    let a:dec = substitute(a:dec,'.*(\(.*\)).*','\1','')
    if a:dec == ''
        return []
    endif

    let a:args = split(a:dec,',')
    call map(a:args, {n,arg -> split(substitute(s:trim(arg),'\(.*\)\(\<' . s:c_identifier . '\>\)$','\1|\2',''),'|')})
    call map(a:args, {n,arg -> [s:trim(arg[1]),s:trim(arg[0]),line('.')]})
    "call map(a:args, {n,arg -> [split(arg)[-1],join(split(arg)[:-2]),line('.')]})

    call cursor(a:prev[0],a:prev[1])
    return a:args
endfunction

" getNextDec {{{3
function! s:getNextDec()
    let a:get_variable = '^\s*\(' . s:modifier_query . '\|for\s*(\)\s*\(' . s:c_type . '\_s*' . 
                \ s:collection_identifier . '\)\s*\(\<' . s:c_identifier . '\>[^=;]*\)[;=].*'
    
    let a:alt_get = '^\s*' . s:modifier_query . '\s*\(' . s:c_type . '\_s*' . 
                \ s:collection_identifier . '\)\s*\(\<' . s:c_identifier . '\>[^=;]*\)[=;].*'

    let [a:line,a:col] = [line('.'),col('.')]
    let a:match = searchpos(a:get_variable,'Wn')

    if a:0 == 0
        while a:match != [0,0] && match(getline(a:match[0]),'\<return\>') >= 0
            call cursor(a:match[0],a:match[1])
            let a:match = searchpos(a:get_variable,'Wn')
        endwhile
        call cursor(a:line,a:col)
    endif

    if s:isBefore([a:line,a:col],a:match) == 1
        if match(getline(a:match[0]),'\<for\>') >= 0
            let a:var = substitute(getline(a:match[0]),a:get_variable,'\5','')
            let a:fline = split(substitute(getline(a:match[0]),a:get_variable,'\8',''),',')
        else
            let a:var = s:trim(substitute(getline(a:match[0]),a:alt_get,'\1 \2 \3 \4',''))
            let a:var = substitute(a:var,'\s\+',' ','g')
            let a:fline = split(substitute(getline(a:match[0]),a:alt_get,'\7',''),',')
        endif
        call map(a:fline,{n,var -> s:trim(var)})
        call map(a:fline,{n,var -> substitute(var,'^\<\(' . s:c_identifier . '\)\>.*','\1','')})

        return [a:var,a:fline,a:match]
    endif

    return ['none',[],[0,0]]
endfunction

" getLocalDecs {{{3
function! s:getLocalDecs(close)
    let a:orig = [line('.'),col('.')]
    let a:here = [line('.'),col('.')]
    let a:next = s:getNextDec()

    let a:vars = s:getParams()
    while s:isBefore(a:next[2],a:close)
        if a:next[2] == [0,0]
            break
        endif
        
        let a:type = a:next[0]
        for name in a:next[1]
            call add(a:vars,[name,a:type,a:next[2][0]])
        endfor

        call cursor(a:next[2][0],a:next[2][1])
        let a:next = s:getNextDec()
    endwhile
    call cursor(a:orig[0],a:orig[1])

    return a:vars
endfunction

" getFunctionDecs {{{3
function! s:getFunctionDecs()
    let a:query = '^\s*' . s:modifier_query . '\s*\(' .  s:c_type . '\_s*' . s:collection_identifier . '\)\_s*\(' . s:c_identifier . '\)\_s*\([;(]\).*'
    let a:decs = {'types' : [], 'names' : []}
    try
        execute 'silent vimgrep /' . a:query . '/j %:p'
        let a:greps = getqflist()

        for g in a:greps
            let a:fname = substitute(g['text'],a:query,'\4|\7\8','')
            if match(a:fname,s:c_keywords) >= 0
                continue
            endif

            if a:fname[len(a:fname)-1] == '('
                let [a:type,a:name] = split(a:fname,'|')
            else
                let [a:type,a:name] = split(a:fname[:-2],'|')
                let a:name = substitute(a:name,';','(','')
            endif

            call add(a:decs['types'],a:type)
            call add(a:decs['names'],a:name)
        endfor

    catch /.*No match.*/
    endtry

    return a:decs
endfunction

" getAllFunctions {{{3
function! s:getAllFunctions()
    if index(keys(s:all_funcs),expand('%:p')) >= 0
        return s:all_funcs[expand('%:p')]
    endif

    let a:use = s:getAllIncluded()

    let a:defs = {'types' : [], 'names' : []}
    for class in a:use
        execute 'silent tabedit! ' . class
        let a:funcs = s:getFunctionDecs()
        let a:defs['types'] += a:funcs['types']
        let a:defs['names'] += a:funcs['names']
        call s:safeClose()
    endfor
    silent edit!

    let s:all_funcs[expand('%:p')] = a:defs
    return a:defs
endfunction

" getStructVars {{{3
function! s:getStructVars(var,dec,funcs)
    if match(a:dec,'>$') < 0
        return [a:dec]
    endif

        call add(a:funcs[0],old)
    endif

    let a:orig = substitute(a:dec,'^\([^<]*\)<.*','\1','')
    let a:res = substitute(a:dec,'^.*<','','')
    let a:res = substitute(a:res,'\(<\|>\|\s\)','','g')
    return [a:orig] + split(a:res,',')
endfunction

" getFuncDec {{{3
function! s:getFuncDec(func)
    let a:orig = [line('.'),col('.')]
    call cursor(1,1)
    let a:search = s:no_comment . s:modifier_query . '\(' . s:c_type . '\_s*' . s:collection_identifier . '\)\_s\+\<' . a:func . '\(\<\|\>\|)\|\s\).*'
    let a:find =  search(a:search)
    let a:next = ''
    if a:find > 0
        call cursor(line('.'),1)
        let a:next = substitute(getline('.'),a:search,'\4','')
    else
        let a:all_funcs = s:getAllFunctions()
        let a:ind = match(a:all_funcs['names'],a:func)
        if a:ind >= 0
            let a:next = a:all_funcs['types'][a:ind]
        endif
    endif
    call cursor(a:orig[0],a:orig[1])
    return a:next
endfunction

" getVarDec {{{3
function! s:getVarDec(var)
    let a:orig = [line('.'),col('.')]
    let a:search = s:no_comment  . '.\{-\}\(' . s:modifier_query . '\|for\s*(\)\s*\(' . s:c_type . '\_s*' .
                \ s:collection_identifier . '\)\s*\<' . a:var . '\>.*'
    let a:jump = '\<' . a:var . '\>'

    let a:pos = search(a:search,'Wb')
    call search(a:jump)
    let a:res = substitute(substitute(getline(a:pos),a:search,'\5',''),'\*','','g')
    while s:isQuoted(a:res,getline(a:pos)) == 1 || s:isCommented() == 1 || match(a:res,s:c_keywords) >= 0
        if a:pos == 0
            return ''
        endif
        call cursor(a:pos-1,a:pos)
        let a:pos = search(a:search,'Wb')
        call search(a:jump)
        let a:res = substitute(substitute(getline(a:pos),a:search,'\5',''),'\*','','g')
    endwhile

    call cursor(a:orig[0],a:orig[1])
    return a:res
endfunction

" getUsingVar {{{3
function! s:getUsingVar()
    let a:orig = [line('.'),col('.')]

    let a:search = '\(\.\|->\)'
    while 1 == 1
        let a:adj = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')
        if a:adj == ')' || a:adj == ']'
            call cursor(line('.'),col('.')-1)
            normal %
            if searchpos(a:search,'bn') == searchpos('[^[:space:]]\_s*\<' . s:c_identifier . '\>','bn')
                call search(a:search,'b')
            elseif s:isBefore(searchpos('\<' . s:c_identifier . '\>\((\|\[\)','bn'),searchpos('[^[:space:]' . s:search_chars . ']','bn'))
                call search('\<' . s:c_identifier . '\>','')
                let a:var = expand('<cword>')
                let a:dec = s:getVarDec(a:var)
            else
                let a:end = col('.')
                call search('\<' . s:c_identifier . '\>','b')
                let a:begin = col('.') - 1
                let a:var = strpart(getline('.'),a:begin,a:end - a:begin)
                let a:dec = s:getFuncDec(a:var)
                let a:var = substitute(a:var,'\(\[\|(\)','','')
                break
            endif
        else
            let a:end = col('.') - 1
            call search('\<' . s:c_identifier . '\>','b')
            let a:dot = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')
            if a:dot != '.' && a:dot != '>'
                let a:begin = col('.') - 1
                let a:var = strpart(getline('.'),a:begin,a:end - a:begin)
                let a:var = substitute(a:var,'-','','g')
                let a:dec = s:getVarDec(a:var)
                break
            endif
            call search(a:search,'b')
        endif 
    endwhile

    let a:funcs = []
    let a:search = a:search . '\<' . s:c_identifier . '\>[([]\='
    let a:next = searchpos(a:search,'W')
    let a:next_end = searchpos(a:search,'Wnez')

    while s:isBefore(a:next,a:orig)
        call cursor(a:next[0],a:next[1])

        let a:func = substitute(strpart(getline('.'),a:next[1], a:next_end[1] - a:next[1]),'^>','','')
        call add(a:funcs,a:func)
        if matchstr(getline('.'), '\%' . a:next_end[1] . 'c.') == '('
            call search('(')
            normal %
        elseif matchstr(getline('.'), '\%' . a:next_end[1] . 'c.') == '['
            call search('[')
            normal %
        endif
        let a:next = searchpos(a:search,'W')
        let a:next_end = searchpos(a:search,'Wnez')
    endwhile
    call cursor(a:orig[0],a:orig[1])

    let a:dec = [a:dec]
    return [a:var,a:dec,a:funcs]
endfunction

" followChain {{{3
function! s:followChain(types,funcs,type_name)
    let a:orig = [line('.'),col('.')]

    let a:func_search = '\(' . s:c_type . '\_s*' . s:collection_identifier . '\)\_s*\<' . a:funcs[0]
    let [a:prev_file,a:prev_struct,a:fields] = s:getStructDef('\(' . join(a:types,'\|') . '\)')

    while len(a:funcs) > 0
        if match(a:funcs[0],'(') >= 0
            try
                let a:included = s:getAllIncluded() + [expand('%:p')]
                execute 'silent lvimgrep /' . a:func_search . '/j ' . join(a:included)
            catch /.*/
            endtry
        else
            let a:ind = index(map(deepcopy(a:fields),{n,val -> val[1]}),a:funcs[0])
            if a:ind < 0
                break
            endif

            execute 'silent tabedit! ' . a:prev_file
            let a:new_struct = split(a:fields[a:ind][0],' ')
            if len(a:new_struct) == 1
                let a:type_defs = s:getTypeDefs(a:new_struct[0])
            else
                let a:type_defs = s:getTypeDefs(join(a:new_struct[1:],'\_s*'),a:new_struct[0])
            endif

            let a:struct_find = len(a:type_defs) == 0 ? a:fields[a:ind][0] : '\(' . a:fields[a:ind][0] . '\|' . join(a:type_defs,'\|') . '\)'
            let [a:prev_file,a:prev_struct,a:fields] = s:getStructDef(a:struct_find)
            call s:safeClose()
        endif
        if len(a:funcs) > 0
            call remove(a:funcs,0)
        endif
    endwhile
    call cursor(a:orig[0],a:orig[1])

    if a:ind >= 0
        let a:ind = match(a:prev_struct,a:type_name)
    endif

    return (a:ind >= 0)
endfunction

" References {{{2
" getNextReference {{{3
function! s:getNextReference(var,type,...)
    if a:type == 'right'
        let a:search = s:no_comment . s:modifier_query . '\s*\(' . s:c_type . '\_s*' . s:collection_identifier . 
                    \ '\)\=\s*\(' . s:c_identifier . '\)\s*[(.=]\_[^{;]*\<\(' . a:var . '\)\>\_.\{-\};$'
        let a:index = '\7'
        let a:alt_index = '\8'
    elseif a:type == 'left'
        let a:search = s:no_comment . '\<\(' . a:var . '\)\>\s*\(++\_s*;\|--\_s*;\|[-\^|&~+*/]\=[.=][^=]\).*'
        let a:index = '\1'
        let a:alt_index = '\1'
    elseif a:type == 'cond'
        let a:search = s:no_comment . '\<\(switch\|while\|for\|if\|else\s\+if\)\>\_s*(\_[^{;]*\<\(' . a:var . '\)\>\_[^{;]*).*'
        let a:index = '\1'
        let a:alt_index = '\2'
    elseif a:type == 'return'
        let a:search = s:no_comment . '\s*\<return\>\_[^;]*\<\(' . a:var . '\)\>.*'
        let a:index = '\1'
        let a:alt_index = '\1'
    endif

    let a:line = searchpos(a:search,'Wn')
    let a:endline = s:getEndLine(a:line,a:search)
    if a:type == 'right'
        let a:prev = [line('.'),col('.')]
        while s:isValidTag(a:line[0]) == 0
            if a:line == [0,0]
                break
            endif

            if match(getline(a:line[0]),';') >= 0
                break
            endif

            if match(getline(a:line[0]),'\<\(true\|false\)\>') >= 0 
                break
            endif

            call cursor(a:line[0],a:line[1])
            let a:line = searchpos(a:search,'Wn')
            let a:endline = s:getEndLine(a:line,a:search)
        endwhile
        call cursor(a:prev[0],a:prev[1])
    endif

    if a:line[0] > line('.')
        let a:state = join(getline(a:line[0],a:endline[0]))
"        if a:type == 'cond'
"            let a:for = match(a:state,'\<for\>')
"            let a:c = match(a:state,'\<\(switch\|while\|if\|else\s\+if\)\>')
"            if a:c == -1 || (a:for != -1 && a:for < a:c)
"                let a:index = '\4'
"                let a:alt_index = '\5'
"            endif
"        endif
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
" updateUsingFile {{{3
function! s:updateUsingFile(type_name,old_name,new_name,paren) abort
    call cursor(1,1)
    let a:here = [line('.'),col('.')]
    let a:types = '\<\(' . a:type_name . '\)\>'
    let a:search = '\(\.\|->\)\<' . a:old_name . '\>' . a:paren

    let a:next = searchpos(a:search,'Wn')
    while a:next != [0,0]
        call cursor(a:next[0],a:next[1])
        let [a:var,a:dec,a:funcs] = s:getUsingVar()
        if len(a:funcs) == 0
            let a:dec = join(a:dec,'|')
            if match(a:dec,a:types) >= 0
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                execute 'silent s/\(\.\|->\)\<' . a:old_name . '\>' . a:paren . '/\1' . a:new_name . a:paren . '/e'
            endif
        else
            let a:chain = '\(' . repeat('\<' . s:c_identifier . '\>\(\.\|->\)',len(a:funcs)+1) . '\)'
            if s:followChain(a:dec,a:funcs,a:type_name) == 1
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                execute 'silent s/' . a:chain . '\<' . a:old_name . '\>' . a:paren . '/\1' . a:new_name . a:paren . '/e'
            endif
        endif
        call cursor(a:next[0],a:next[1])
        let a:next = searchpos(a:search,'Wn')
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
    let a:prev = [line('.'),col('.')]
    if matchstr(getline('.'), '\%' . col('.') . 'c.') != '('
        call search('(')
    endif
    let a:start = strpart(getline('.'),0,col('.')-1)
    normal %
    let a:leftover = strpart(getline('.'),col('.'))
    let a:end = line('.')
    call cursor(a:prev[0],a:prev[1])

    let a:start = substitute(a:start,s:special_chars,'\\\1','g')
    let a:leftover = substitute(a:leftover,s:special_chars,'\\\1','g')

    let a:args = join(getline(a:prev[0],a:end))
    let a:args = substitute(a:args,a:start . '(\(.*\))' . a:leftover,'\1','')

    if a:args == ''
        return 0
    endif

    let a:car = 0
    let a:par = 0
    let a:count = 1
    let a:i = 0
    let a:prev = 0
    while a:i < len(a:args)
        let char = a:args[a:i]
        if char == ',' && a:car == 0 && a:par == 0
            let a:count += 1
        elseif char == '>'
            let a:car -= 1
        elseif char == '<'
            let a:car += 1
        elseif char == ')'
            let a:par -= 1
        elseif char == '('
            let a:par += 1
        endif
        let a:i += 1
    endwhile
    return a:count
endfunction

" updateParamFile {{{3
function! s:updateParamFile(method_name,commas,default,param_name,param_type) abort
    call cursor(1,1)
    let a:search = a:method_name . '('

    let a:next = searchpos(a:search,'Wn')
    let [a:param_search,a:insert] = ['',a:default . ')']
    let a:com = a:commas > 0 ? ', ' : ''
    if a:commas > 0
        let a:insert = ', ' . a:insert
        let a:param_search = '\_[^;]*'
        let a:param_search .= repeat(',' . '\_[^;]*',a:commas - 1)
    endif
    let a:param_search = '\((' . a:param_search . '\))'

    while a:next != [0,0]
        call cursor(a:next[0],a:next[1])
        let a:func = s:c_type . '\_s*' . s:collection_identifier . '\<' . a:method_name . '\>\_s*('
        if match(getline('.'),a:func) >= 0
            let a:end = searchpos(')','Wn')

            let a:line = substitute(getline(a:end[0]), ')', a:com . a:param_type . ' ' . a:param_name . ')', '')
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
            execute 'silent ' .  a:end[0] . 'd'
            call append(a:end[0] - 1,a:line)
        else
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
            call search('(')
            normal %
            let a:end = line('.')
            let a:leftover = strpart(getline('.'),col('.'))
            call cursor(a:next[0],a:next[1])
            execute 'silent ' . line('.') . ',' . a:end . 's/\<' .a:method_name . '\>' . a:param_search . '\(' . a:leftover . '\)/' . 
                        \ a:method_name . '\1' . a:insert . '\2/e'
        endif

        call cursor(a:next[0],a:next[1])
        let a:next = searchpos(a:search,'Wn')
    endwhile

    silent write!
endfunction

" updateFile {{{3
function! s:updateFile(old_name,new_name,is_method,is_local)
    let a:orig = [line('.'),col('.')]

    if a:is_local == 1
        let a:query = '\(^\|[^.]\)\<' . a:old_name . '\>'
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent s/' . a:query . '/\1' . a:new_name . '/g'

        call s:gotoTag()
        let a:closing = s:getClosingBracket(1)

        let a:next = searchpos(a:query,'Wn')
        while s:isBefore(a:next,a:closing)
            if a:next == [0,0]
                break
            endif
            call cursor(a:next[0],a:next[1])
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
            execute 'silent s/' . a:query . '/\1' . a:new_name . '/g'

            let a:next = searchpos(a:query,'Wn')
        endwhile
    else
        let a:paren = a:is_method == 1 ? '(' : ''
        try
            execute 'silent lvimgrep /\(^\|[^.]\)\<' . a:old_name . '\>' . a:paren . '/j %:p'
            let g:factorus_qf += map(getloclist(0),{n,val -> {'filename' : expand('%:p'), 'lnum' : val['lnum'], 'text' : s:trim(val['text'])}})
        catch /.*/
        endtry
        call setloclist(0,[])

        execute 'silent %s/\(^\|[^.]\)\<' . a:old_name . '\>' . a:paren . '/\1' . a:new_name . a:paren . '/ge'
    endif

    call cursor(a:orig[0],a:orig[1])
    silent write!
endfunction

" Renaming {{{2
" renameArg {{{3
function! s:renameArg(new_name,...) abort
    let a:var = expand('<cword>')
    let g:factorus_history['old'] = a:var
    call s:updateFile(a:var,a:new_name,0,1)

    if !factorus#isRollback(a:000)
        redraw
        echo 'Re-named ' . a:var . ' to ' . a:new_name
    endif
    return [a:var,[]]
endfunction

" renameField {{{3
function! s:renameField(new_name,...) abort
    let a:search = '^\s*' . s:modifier_query . '\(' . s:c_type . s:collection_identifier . '\)\=\s*\(' . s:c_identifier . '\)\s*[;=].*'

    let a:line = getline('.')
    let a:is_static = match(a:line,'\<static\>') >= 0 ? 1 : 0
    let a:is_local = !s:isInType()
    let a:type = substitute(a:line,a:search,'\4','')
    let a:var = s:trim(substitute(a:line,a:search,'\7',''))
    if a:var == '' || a:type == '' || match(a:var,'[^' . s:search_chars . ']') >= 0
        if a:is_local == 1 || match(getline(s:getAdjacentTag('b')),'\<enum\>') < 0
            throw 'Factorus:Invalid'
        endif
        let a:var = expand('<cword>')
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent s/\<' . a:var . '\>/' . a:new_name . '/e'
        silent write!

        let a:temp_file = '.FactorusEnum'
        
        echo 'Updating enum...'
        call s:findTags(a:temp_file,'\<' . a:var . '\>','no')
        call s:updateQuickFix(a:temp_file,'\<' . a:var . '\>')
        call system('cat ' . a:temp_file . ' | xargs sed -i "s/\<' . a:var . '\>/' . a:new_name . '/g"')
        call system('rm -rf ' . a:temp_file)

        let a:unchanged = s:getUnchanged('\<' . a:var . '\>')
        redraw
        echo 'Renamed enum field ' . a:var . ' to ' . a:new_name . '.'
        return [a:var,a:unchanged]
    elseif a:var == a:new_name
        throw 'Factorus:Duplicate'
    endif
    let g:factorus_history['old'] = a:var

    let a:unchanged = []
    if a:is_local == 1
        call s:updateFile(a:var,a:new_name,0,a:is_local)
    elseif a:is_static == 0
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent s/\<' . a:var . '\>/' . a:new_name . '/e'

        call s:gotoTag()
        let a:search = '^\s*\(\<typedef\>\)\=\_s*\<\(struct\|union\)\>\_s*\(' . s:c_identifier . '\)\=\_s*{\=.*'
        let a:type_type = substitute(getline('.'),a:search,'\2','')
        if a:type_type == ''
            throw 'Factorus:Invalid'
        endif

        let a:type_defs = []
        let a:type_name = ''
        if substitute(getline('.'),a:search,'\3','') != ''
            let a:type_name = substitute(getline('.'),a:search,'\3','')
        endif

        if match(getline('.'),'\<typedef\>') >= 0
            let a:prev = [line('.'),col('.')]
            call search('{')
            normal %
            if match(getline('.'),'\<\(' . s:c_identifier . '\)\>') >= 0
                call add(a:type_defs,substitute(getline('.'),'.*\<\(' . s:c_identifier . '\)\>.*','\1',''))
            endif
            call cursor(a:prev[0],a:prev[1])
        endif

        let a:includes = s:getAllIncluded()

        try
            execute 'silent lvimgrep /\<' . a:method_name . '\>(/j ' . join(a:includes)
            execute 'silent tabedit! ' . getbufinfo(getloclist(0)[0]['bufnr'])[0]['name']
            call setloclist(0,[])
            let a:swap = 1
        catch /.*/
            let a:swap = 0
        endtry

        redraw
        echo 'Updating references...'

        let a:temp_file = '.FactorusInc'
        call s:getInclusions(a:temp_file)
        call s:narrowTags(a:temp_file,'\(\.\|->\)' . a:var)

        let a:files = readfile(a:temp_file) + [expand('%:p')]
        if a:type_name != ''
            let a:type_defs += s:getTypeDefs(a:type_name,a:type_type)
            let a:find_name = a:type_type . '\_s*' . a:type_name
            call add(a:type_defs,a:find_name)
        endif

        let a:def_find = join(a:type_defs,'\|')
        call s:updateUsingFiles(a:files,a:def_find,a:var,a:new_name,'')
        call system('rm -rf ' . a:temp_file)
        let a:unchanged = s:getUnchanged('\(\.\|->\)\<' . a:var . '\>')
    endif

    redraw
    echo 'Re-named ' . a:var . ' to ' . a:new_name
    return [a:var,a:unchanged]
endfunction

" renameMacro {{{3
function! s:renameMacro(new_name,...) abort
    let a:search = '^#define \<\(' . s:c_identifier . '\)\>.*'
    let a:macro = substitute(getline('.'),a:search,'\1','')
    if a:macro == '' || a:macro == getline('.')
        throw 'Factorus:Invalid'
    endif
    call s:updateFile(a:macro,a:new_name,0,0)

    let a:temp_file = '.FactorusMacro'
    call s:getInclusions(a:temp_file)
    call s:updateQuickFix(a:temp_file,'\<' . a:macro . '\>')

    call system('cat ' . a:temp_file . ' | xargs sed -i "s/\<' . a:macro . '\>/' . a:new_name . '/g"')
    call system('rm -rf ' . a:temp_file)
    let a:unchanged = s:getUnchanged('\<' . a:macro . '\>')

    silent edit!
    redraw
    echo 'Renamed macro ' . a:macro . ' to ' . a:new_name . '.'

    return [a:macro,a:unchanged]
endfunction

" renameMethod {{{3
function! s:renameMethod(new_name,...) abort
    call s:gotoTag()

    let a:unchanged = []
    let a:method_name = matchstr(getline('.'),'\<' . s:c_identifier . '\>\s*(')
    let a:method_name = matchstr(a:method_name,'[^[:space:](]\+')
    if a:method_name == a:new_name
        throw 'Factorus:Duplicate'
    endif
    let g:factorus_history['old'] = a:method_name

    let a:is_static = match(getline('.'),'\<static\>[^)]\+(') >= 0 ? 1 : 0

    let a:includes = s:getAllIncluded()
    try
        execute 'silent lvimgrep /\<' . a:method_name . '\>(/j ' . join(a:includes)
        execute 'silent tabedit! ' . getbufinfo(getloclist(0)[0]['bufnr'])[0]['name']
        call setloclist(0,[])
        let a:swap = 1
    catch /.*/
        let a:swap = 0
    endtry

    call s:updateFile(a:method_name,a:new_name,1,0)
    if a:is_static == 0
        let a:search = '\([^.]\)\<' . a:method_name . '\>('
        let a:temp_file = '.FactorusInc'

        call s:getInclusions(a:temp_file)
        call s:updateQuickFix(a:temp_file,a:search)

        call system('cat ' . a:temp_file . ' | xargs sed -i "s/' . a:search . '/\1' . a:new_name . '(/g"')
        call system('rm -rf ' . a:temp_file)
        let a:unchanged = s:getUnchanged('\<' . a:method_name . '\>')
    endif

    if a:swap == 1
        call s:safeClose()
    endif
    silent edit!

    redraw
    let a:keyword = a:is_static == 1 ? ' static' : ''
    echo 'Re-named' . a:keyword . ' method ' . a:method_name . ' to ' . a:new_name

    return [a:method_name,a:unchanged]
endfunction

" renameType {{{3
function! s:renameType(new_name,...) abort
    call s:gotoTag()

    let a:unchanged = []
    let a:search = '^.*\<\(enum\|struct\|union\)\>\s*\(\<' . s:c_identifier . '\>\)\s*\({\|\<' . s:c_identifier . '\>\_s*;\).*'
    if match(getline('.'),a:search) < 0
        throw 'Factorus:Invalid'
    endif

    let [a:type,a:type_name] = split(substitute(getline('.'),a:search,'\1|\2',''),'|')
    let a:is_static = match(getline('.'),'\<static\>[^)]\+(') >= 0 ? 1 : 0
    let a:rep = '\<' . a:type . '\>\_s*\<' . a:type_name . '\>'
    let a:new_rep = a:type . ' ' . a:new_name
    let g:factorus_history['old'] = a:type . ' ' . a:type_name

    let a:includes = s:getAllIncluded()
    try
        execute 'silent lvimgrep /' . a:rep . '/j ' . join(a:includes)
        execute 'silent tabedit! ' . getbufinfo(getloclist(0)[0]['bufnr'])[0]['name']
        call setloclist(0,[])
        let a:swap = 1
    catch /.*/
        let a:swap = 0
    endtry

    call s:updateFile(a:rep,a:new_rep,0,0)
    if a:is_static == 0
        let a:search = '\<' . a:type . '\>[[:space:]]*\<' . a:type_name . '\>'
        let a:temp_file = '.FactorusInc'

        call s:getInclusions(a:temp_file)
        call s:updateQuickFix(a:temp_file,a:search)

        call system('cat ' . a:temp_file . ' | xargs sed -i "s/' . a:search . '/' . a:new_rep . '/g"')
        call system('rm -rf ' . a:temp_file)
        let a:unchanged = s:getUnchanged(a:search)
    endif

    if a:swap == 1
        call s:safeClose()
    endif
    silent edit!

    if !factorus#isRollback(a:000)
        redraw
        let a:keyword = a:is_static == 1 ? ' static' : ''
        echo 'Re-named' . a:keyword . ' ' . a:type . ' ' . a:type_name . ' to ' . a:new_name
    endif
    return [a:type . ' ' . a:type_name,a:unchanged]
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
    let a:if = '\<if\>\_s*(\_[^{;]*)\_s*{\='
    let a:for = '\<for\>\_s*(\_[^{;]*;\_[^{;]*;\_[^{;]*)\_s*{\='
    let a:while = '\<while\>\_s*(\_[^{;]*)'
    let a:do = '\<do\>\_s*{'
    let a:switch = '\<switch\>\_s*(\_[^{]*)\_s*{'
    let a:search = '\(' . a:if . '\|' . a:for . '\|' . a:while . '\|' . a:do . '\|' . a:switch . '\)'

    let a:orig = [line('.'),col('.')]
    call s:gotoTag()
    let a:blocks = [[line('.'),a:close[0]]]

    let a:open = searchpos('{','Wn')
    let a:next = searchpos(a:search,'Wn')
    while a:next[0] <= a:close[0]
        if a:next == [0,0]
            break
        endif
        call cursor(a:next[0],a:next[1])

        if match(getline('.'),'\<else\>') >= 0 || match(getline('.'),'}\s*\<while\>') >= 0
            let a:next = searchpos(a:search,'Wn')
            continue
        endif

        if match(getline('.'),'\<\(if\|for\|while\)\>') >= 0
            let a:open = [line('.'),col('.')]
            call search('(')
            normal %

            let a:ret =  searchpos('{','Wn')
            let a:semi = searchpos(';','Wn')

            let a:o = line('.')
            if s:isBefore(a:semi,a:ret) == 1
                call cursor(a:semi[0],a:semi[1])
                call add(a:blocks,[a:open[0],line('.')])
            elseif match(getline('.'),'\<if\>') >= 0
                call cursor(a:ret[0],a:ret[1])
                normal %

                let a:continue = '}\_s*else\_s*\(\<if\>\_[^{]*)\)\={'
                let a:next = searchpos(a:continue,'Wnc')
                while a:next == [line('.'),col('.')]
                    if a:next == [0,0]
                        let a:next = a:ret
                        break
                    endif
                    call add(a:blocks,[a:o,line('.')])
                    call search('{','W')
                    let a:o = line('.')
                    normal %

                    let a:next = searchpos(a:continue,'Wnc')
                endwhile
                call add(a:blocks,[a:o,line('.')])
                if a:o != a:open[0]
                    call add(a:blocks,[a:open[0],line('.')])
                endif
            else
                call search('{','W')
                let a:prev = [line('.'),col('.')]
                normal %
                call add(a:blocks,[a:next[0],line('.')])
                call cursor(a:prev[0],a:prev[1])
            endif

            call cursor(a:open[0],a:open[1])
        elseif match(getline('.'),'\<switch\>') >= 0
            let a:open = [line('.'),col('.')]
            call searchpos('{','W')

            normal %
            let a:sclose = [line('.'),col('.')]
            normal %

            let a:continue = '\<\(case\|default\)\>[^:]*:'
            let a:next = searchpos(a:continue,'Wn')

            while s:isBefore(a:next,a:sclose) == 1 && a:next != [0,0]
                call cursor(a:next[0],a:next[1])
                let a:next = searchpos(a:continue,'Wn')
                if s:isBefore(a:close,a:next) == 1 || a:next == [0,0]
                    call add(a:blocks,[line('.'),a:close[0]])
                    break
                endif
                call add(a:blocks,[line('.'),a:next[0]-1])
            endwhile
            call add(a:blocks,[a:open[0],a:sclose[0]])
        else
            call search('{','W')
            let a:prev = [line('.'),col('.')]
            normal %
            call add(a:blocks,[a:next[0],line('.')])
            call cursor(a:prev[0],a:prev[1])
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
        call cursor(var[2],1)
        let a:local_close = var[2] == a:begin ? s:getClosingBracket(1) : s:getClosingBracket(0)
        let a:closes[var[0]] = copy(a:local_close)
        call cursor(a:orig[0],a:orig[1])
        if index(keys(a:lines),var[0]) < 0
            let a:lines[var[0]] = {var[2] : [var[2]]}
        else
            let a:lines[var[0]][var[2]] = [var[2]]
        endif
        let a:isos[var[0]] = {}
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

            let a:ldec = s:getLatestDec(a:lines,a:name,a:next[1])

            let a:quoted = s:isQuoted('\<' . a:name . '\>',s:getStatement(a:next[1][0]))
            if s:isBefore(a:next[1],a:closes[a:name]) == 1 && a:quoted == 0 && a:ldec > 0
                if index(a:lines[a:name][a:ldec],a:next[1][0]) < 0
                    call add(a:lines[a:name][a:ldec],a:next[1][0])
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
    elseif s:contains(a:block,a:continue)
        call cursor(a:continue,1)
        let a:loop = searchpair('\<\(for\|while\)\>','','}','Wbn')
        if a:loop != 0 && a:loop < a:block[0]
            let a:res = 0
        endif
    else
        while a:ref[1] != [0,0] && s:isBefore(a:ref[1],[a:block[1]+1,1]) == 1
            let a:i = s:getLatestDec(a:rels,a:ref[2],a:ref[1])
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
function! s:getIsolatedLines(var,compact,rels,blocks,close)
    let a:refs = a:rels[a:var[0]][a:var[2]]
    let [a:names,a:decs] = a:compact

    if len(a:refs) == 1
        return []
    endif

    let a:orig = [line('.'),col('.')]
    let [a:name,a:type,a:dec] = a:var

    let a:wraps = []
    if match(getline(a:var[2]),'\<for\>') >= 0
        let a:for = s:getContainingBlock(a:var[2],a:blocks,a:blocks[0])
        if s:isIsolatedBlock(a:for,a:var,a:rels,a:close) == 0
            return []
        endif
    endif
    let a:dec_block = s:getContainingBlock(a:var[2],a:blocks,a:blocks[0])
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

            if a:block[1] - a:block[0] == 0 && match(getline(a:block[0]),'\<\(try\|for\|if\|while\)\>') < 0
                let a:stop = a:block[0]
                while match(getline(a:stop),';') < 0
                    let a:stop += 1
                endwhile
                let a:block[1] = a:stop
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
" getLatestDec {{{3
function! s:getLatestDec(rels,name,loc)
    let a:min = 0
    for dec in keys(a:rels[a:name])
        if a:min <= dec && dec <= a:loc[0]
            let a:min = dec
        endif
    endfor
    return a:min
endfunction

" findVar {{{3
function! s:findVar(vars,names,name,dec)
    let a:i = index(a:names,a:name)
    let a:var = a:vars[a:i]
    while a:var[2] != a:dec
        let a:i = index(a:names,a:name,a:i + 1)
        let a:var = a:vars[a:i]
    endwhile
    return a:var
endfunction

" getNewArgs {{{3
function! s:getNewArgs(lines,vars,rels,...)

    let a:names = map(deepcopy(a:vars),{n,var -> var[0]})
    let a:search = '\(' . join(a:names,'\|') . '\)'
    let a:search = s:no_comment . '.*\<' . a:search . '\>.*'
    let a:args = []

    for line in a:lines
        let a:this = getline(line)
        if match(a:this,'^\s*\(\/\/\|*\)') >= 0
            continue
        endif
        let a:new = substitute(a:this,a:search,'\1','')
        while a:new != a:this
            let a:spot = str2nr(s:getLatestDec(a:rels,a:new,[line,1]))
            if a:spot == 0
                break
            endif
            let a:next_var = s:findVar(a:vars,a:names,a:new,a:spot)

            if index(a:args,a:next_var) < 0 && index(a:lines,a:spot) < 0 && (a:0 == 0 || a:next_var[0] != a:1[0] || a:next_var[2] == a:1[2]) 
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

        if arg[2] == a:head
            continue
        endif

        let a:wrap = 1
        let a:name = arg[0]
        let a:next = s:getNextUse(a:name)

        while a:next[1] != [0,0] && s:isBefore(a:next[1],a:close) == 1
            if a:next[2] != 'left' && a:next[2] != 'return' && index(a:lines,a:next[1][0]) < 0
                let a:wrap = 0    
                break
            endif
            call cursor(a:next[1][0],a:next[1][1])
            let a:next = s:getNextUse(a:name)
        endwhile

        if a:wrap == 1
            let a:relevant = a:rels[arg[0]][arg[2]]
            let a:stop = arg[2]
            let a:dec = [a:stop]
            while match(getline(a:stop),';') < 0
                let a:stop += 1
                call add(a:dec,a:stop)
            endwhile
            let a:iso = a:dec + a:isos[arg[0]][arg[2]]

            let a:con = 1
            for rel in a:relevant
                if index(a:iso,rel) < 0 && index(a:lines,rel) < 0 && match(getline(rel),'\<return\>') < 0
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

" wrapAnnotations {{{3
function! s:wrapAnnotations(lines)
    for line in a:lines
        let a:prev = line - 1
        if match(getline(a:prev),'^\s*@') >= 0
            call add(a:lines,a:prev)
        endif
    endfor
    return uniq(sort(a:lines,'N'))
endfunction

" buildArgs {{{3
function! s:buildArgs(args,is_call)
    if a:is_call == 0
        let a:defs = map(deepcopy(a:args),{n,arg -> arg[1] . ' ' . arg[0]})
        let a:sep = '| '
    else
        let a:defs = map(deepcopy(a:args),{n,arg -> arg[0]})
        let a:sep = ', '
    endif
    return join(a:defs,a:sep)
endfunction

" formatMethod {{{3
function! s:formatMethod(def,body,spaces)
    let a:paren = stridx(a:def[0],'(')
    let a:def_space = repeat(' ',a:paren+1)
    call map(a:def,{n,line -> a:spaces . (n > 0 ? a:def_space : '') . substitute(line,'\s*\(.*\)','\1','')})

    let a:fspaces = a:spaces == '' ? repeat(' ',&tabstop) : a:spaces
    let a:dspaces = a:spaces == '' ? a:fspaces : repeat(a:spaces,2)
    let a:i = 0

    call map(a:body,{n,line -> substitute(line,'\s*\(.*\)','\1','')})
    while a:i < len(a:body)
        if match(a:body[a:i],'}') >= 0
            let a:dspaces = strpart(a:dspaces,len(a:fspaces))
        endif
        let a:body[a:i] = a:dspaces . a:body[a:i]

        if match(a:body[a:i],'{') >= 0
            let a:dspaces .= a:fspaces
        endif

        let a:i += 1
    endwhile
endfunction

" buildNewMethod {{{3
function! s:buildNewMethod(lines,args,ranges,vars,rels,tab,close,...)
    let a:body = map(copy(a:lines),{n,line -> getline(line)})

    call cursor(a:lines[-1],1)
    let a:type = 'void'
    let a:return = ['}'] 
    let a:call = ''

    let a:outer = s:getContainingBlock(a:lines[0],a:ranges,a:ranges[0])
    let a:include_dec = 1
    for var in a:vars
        if index(a:lines,var[2]) >= 0
            let a:outside = s:getNextUse(var[0])    
            if a:outside[1] != [0,0] && s:isBefore(a:outside[1],a:close) == 1 && s:getLatestDec(a:rels,var[0],a:outside[1]) == var[2]
                let a:contain = s:getContainingBlock(var[2],a:ranges,a:ranges[0])
                if a:contain[0] <= a:outer[0] || a:contain[1] >= a:outer[1]
                    let a:type = var[1]
                    let a:return = ['return ' . var[0] . ';','}']
                    let a:call = a:type . ' ' . var[0] . ' = '

                    let i = 0
                    while i < len(a:lines)
                        let line = getline(a:lines[i])
                        if match(line,';') >= 0 && match(line,'\<' . var[0] . '\>') >= 0
                            break
                        endif
                        let i += 1
                    endwhile

                    if i == len(a:lines)
                        break
                    endif

                    let a:inner = s:getContainingBlock(a:lines[i+1],a:ranges,a:outer)
                    if a:inner[1] - a:inner[0] > 0 && match(getline(a:inner[0]),'\<\(if\|else\)\>') >= 0
                        let a:removes = []
                        for j in range(i+1)
                            if match(getline(a:lines[j]),'\<' . var[0] . '\>') >= 0
                                call add(a:removes,j)
                            endif
                        endfor
                        for rem in reverse(a:removes)
                            call remove(a:lines,rem)
                        endfor
                        let a:call = var[0] . ' = '
                        let a:include_dec = 0
                    endif
                    break
                endif
            endif
        endif
    endfor

    let a:name = a:0 == 0 ? g:factorus_method_name : a:1
    let a:build = s:buildArgs(a:args,0)
    let a:build_string = a:type . ' ' .  a:name . '(' . a:build . ') {'
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

    let a:body += a:return
    call s:formatMethod(a:def,a:body,a:tab)
    let a:final = [''] + a:def + a:body + ['']

    let a:arg_string = s:buildArgs(a:args,1)
    let a:call_space = substitute(getline(a:lines[-1]),'\(\s*\).*','\1','')
    let a:rep = [a:call_space . a:call . a:name . '(' . a:arg_string . ');']

    return [a:final,a:rep]
endfunction

" Rollback {{{2
" rollbackAddParam {{{3
function! s:rollbackAddParam()
    let a:files = {}
    let [a:method_name,a:param_name,a:count] = g:factorus_history['old']

    for line in g:factorus_qf
        if index(keys(line),'filename') < 0
            if line['pattern'] == 'Unmodified'
                break
            endif
            continue
        endif

        if index(keys(a:files),line['filename']) < 0
            let a:files[line['filename']] = [line['lnum']]
        else
            call add(a:files[line['filename']],line['lnum'])
        endif
    endfor

    for file in keys(a:files)
        execute 'silent tabedit! ' . file
        for line in a:files[file]
            call cursor(line,1)
            let a:nline = search(a:method_name . '(','We')
            let a:call_count = 0
            while a:nline == line
                if s:getArgs() == a:count
                    let a:calls = repeat('.\{-\}' . a:method_name . '(.\{-\}',a:call_count)
                    let col = col('.')
                    normal %
                    let end = line('.')
                    let a:leftover = substitute(strpart(getline('.'),col('.')),s:special_chars,'\\\1','g')

                    call cursor(line,1)
                    execute line . ',' . end . 's/\(' . a:calls . '\)\<\(' . a:method_name . '\>(\_.\{-\}\)\(,\=[^,)]*)\)\(' . a:leftover . '\)/\1\2)\4/e'
                    call cursor(line,col)
                endif
                let a:call_count += 1
                let a:nline = search(a:method_name . '(','We')
            endwhile
        endfor
        silent write!
        call s:safeClose()
    endfor

    return 'Rolled back adding of param ' . a:param_name . '.'
endfunction

" rollbackRename {{{3
function! s:rollbackRename()
    let a:files = {}

    for line in g:factorus_qf
        if index(keys(line),'filename') < 0
            if line['pattern'] == 'Unmodified'
                break
            endif
            continue
        endif

        if index(keys(a:files),line['filename']) < 0
            let a:files[line['filename']] = [line['lnum']]
        else
            call add(a:files[line['filename']],line['lnum'])
        endif
    endfor

    let a:old = g:factorus_history['old']
    let a:new = g:factorus_history['args'][-1] == 'Type' ? split(a:old)[0] . ' ' . g:factorus_history['args'][0] : g:factorus_history['args'][0]

    for file in keys(a:files)
        execute 'silent tabedit! ' . file
        for line in a:files[file]
            call cursor(line,1)
            execute 's/\<' . a:new . '\>/' . a:old . '/ge'
        endfor
        silent write!
        call s:safeClose()
    endfor

    return 'Rolled back renaming of ' . substitute(g:factorus_history['args'][-1],'\(.\)\(.*\)','\L\1\E\2','') . ' ' . a:old
endfunction

" rollbackExtraction {{{3
function! s:rollbackExtraction()
    let a:open = search(g:factorus_method_name . '(\_[^;]*{')
    let a:close = s:getClosingBracket(1)[0]

    if match(getline(a:open - 1),'^\s*$') >= 0
        let a:open -= 1
    endif
    if match(getline(a:close + 1),'^\s*$') >= 0
        let a:close += 1
    endif

    execute 'silent ' . a:open . ',' . a:close . 'delete'

    call search('\<' . g:factorus_method_name . '\>(')
    call s:gotoTag()
    let a:open = line('.')
    let a:close = s:getClosingBracket(1)[0]

    execute 'silent ' . a:open . ',' . a:close . 'delete'
    call append(line('.')-1,g:factorus_history['old'][1])
    call cursor(a:open,1)
    silent write!
endfunction

" Global Functions {{{1
" addParam {{{2
function! c#factorus#addParam(param_name,param_type,...) abort
    if factorus#isRollback(a:000)
        call s:rollbackAddParam()
        let g:factorus_qf = []
        return 'Removed new parameter ' . a:param_name
    endif
    let g:factorus_qf = []

    let [s:all_inc,s:all_funcs] = [{},{}]
    let [a:orig,a:prev_dir,a:curr_buf] = s:setEnvironment()

    try
        call s:gotoTag()
        let a:tag = line('.')
        let a:next = searchpos(')','Wn')
        let [a:type,a:name,a:params] = split(substitute(join(getline(line('.'),a:next[0])),'^.*\<\(' . s:c_type . 
                    \ s:collection_identifier . '\)\s*\<\(' . s:c_identifier . '\)\>\s*(\(.*\)).*','\1 | \4 | \5',''),'|')
        let [a:type,a:name] = [s:trim(a:type),s:trim(a:name)]
        let g:factorus_history['old'] = [a:name,a:param_name]

        let a:includes = s:getAllIncluded()
        try
            execute 'silent lvimgrep /\<' . a:name . '\>(/j ' . join(a:includes)
            execute 'silent tabedit! ' . getbufinfo(getloclist(0)[0]['bufnr'])[0]['name']
            call cursor(getloclist(0)[0]['lnum'],1)
            call setloclist(0,[])
            let a:swap = 1
        catch /.*/
            call cursor(a:tag,1)
            let a:swap = 0
        endtry

        let a:count = len(split(a:params,','))
        let a:com = a:count > 0 ? ', ' : ''

        let a:next = searchpos(')','Wn')
        let a:line = substitute(getline(a:next[0]), ')', a:com . a:param_type . ' ' . a:param_name . ')', '')
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent ' .  a:next[0] . 'd'
        call append(a:next[0] - 1,a:line)
        silent write!

        if g:factorus_add_default == 1
    "        redraw
    "        echo 'Updating hierarchy...'
    "        let a:classes = s:updateSubClassFiles(expand('%:t:r'),a:method_name,a:new_name,'(',a:is_static)

            redraw
            echo 'Updating references...'

            let a:default = a:0 > 0 ? a:1 : 'null'

            let a:temp_file = '.FactorusParam'
            call s:getInclusions(a:temp_file)
            call s:narrowTags(a:temp_file,a:name)
            for file in readfile(a:temp_file)
                execute 'silent tabedit! ' . file
                call s:updateParamFile(a:name,a:count,a:default,a:param_name,a:param_type)
                call s:safeClose()
            endfor
            call system('rm -rf ' . a:temp_file)

            if g:factorus_show_changes > 0
                call s:setChanges(a:name,[],'addParam')
            endif

        endif
        redraw
        echo 'Added parameter ' . a:param_name . ' to method ' . a:name . '.'

        if a:swap == 1
            call s:safeClose()
        endif

        call s:resetEnvironment(a:orig,a:prev_dir,a:curr_buf,'addParam')
        return [a:name,a:param_name,a:count+1]
    catch /.*/
        call s:resetEnvironment(a:orig,a:prev_dir,a:curr_buf,'addParam')
        let a:err = match(v:exception,'^Factorus:') >= 0 ? v:exception : 'Factorus:' . v:exception
        throw a:err . ', at ' . v:throwpoint
    endtry

    if factorus#isRollback(a:000)
        call s:gotoTag()
        execute 'silent s/,\=[^,]\{-\})/)/e'
        silent write!
        return 'Removed new parameter ' . a:param_name
    endif
    let g:factorus_history['old'] = a:param_name

    let a:orig = [line('.'),col('.')]
    call s:gotoTag()

    let a:next = searchpos(')','Wn')
    let a:line = substitute(getline(a:next[0]), ')', ', ' . a:param_type . ' ' . a:param_name . ')', '')
    execute 'silent ' .  a:next[0] . 'd'
    call append(a:next[0] - 1,a:line)

    silent write!
    silent edit!
    call cursor(a:orig[0],a:orig[1])

    echo 'Added parameter ' . a:param_name . ' to method'
    return a:param_name
endfunction

" renameSomething {{{2
function! c#factorus#renameSomething(new_name,type,...)
    let [s:all_structs,s:all_inc,s:all_funcs] = [{},{},{}]
    let [a:orig,a:prev_dir,a:curr_buf] = s:setEnvironment()

    let a:res = ''
    try
        if factorus#isRollback(a:000)
            let a:res = s:rollbackRename()
            let g:factorus_qf = []
        else
            let g:factorus_qf = []
            let Rename = function('s:rename' . a:type)
            let [a:res,a:un] = Rename(a:new_name)

            if g:factorus_show_changes > 0
                call s:setChanges(a:res,a:un,'rename',a:type)
            endif
        endif
        call s:resetEnvironment(a:orig,a:prev_dir,a:curr_buf,a:type)
        return a:res
    catch /.*/
        call s:resetEnvironment(a:orig,a:prev_dir,a:curr_buf,a:type)
        let a:err = match(v:exception,'^Factorus:') >= 0 ? v:exception : 'Factorus:' . v:exception
        throw a:err . ', at ' . v:throwpoint
    endtry
endfunction

" extractMethod {{{2
function! c#factorus#extractMethod(...)
    if factorus#isRollback(a:000)
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif
    echo 'Extracting new method...'
    call s:gotoTag()
    let a:tab = substitute(getline('.'),'\(\s*\).*','\1','')
    let a:method_name = substitute(getline('.'),'.*\s\+\(' . s:c_identifier . '\)\s*(.*','\1','')

    let [a:open,a:close] = [line('.'),s:getClosingBracket(1)]
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
            if len(a:iso) > len(a:best_lines) && index(a:iso,a:open) < 0 "&& a:ratio < g:factorus_method_threshold
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
        throw 'Factorus:NoLines' 
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
    let [a:final,a:rep] = s:buildNewMethod(a:best_lines,a:new_args,a:blocks,a:vars,a:all,a:tab,a:close)

    call append(a:close[0],a:final)
    call append(a:best_lines[-1],a:rep)

    let a:i = len(a:best_lines) - 1
    while a:i >= 0
        call cursor(a:best_lines[a:i],1)
        d 
        let a:i -= 1
    endwhile

    call search(g:factorus_method_name . '(\_[^;]*{')
    silent write!
    redraw
    echo 'Extracted ' . len(a:best_lines) . ' lines from ' . a:method_name
    return [a:method_name,a:old_lines]
endfunction

" manualExtract {{{2
function! c#factorus#manualExtract(...)
    if factorus#isRollback(a:000)
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif

    let a:name = a:0 <= 2 ? g:factorus_method_name : a:3

    echo 'Extracting new method...'
    call s:gotoTag()
    let [a:open,a:close] = [line('.'),s:getClosingBracket(1)]
    let a:tab = substitute(getline('.'),'\(\s*\).*','\1','')
    let a:method_name = substitute(getline('.'),'.*\s\+\(' . s:c_identifier . '\)\s*(.*','\1','')

    let a:extract_lines = range(a:1,a:2)
    let a:old_lines = getline(a:open,a:close[0])

    let a:vars = s:getLocalDecs(a:close)
    let a:names = map(deepcopy(a:vars),{n,var -> var[0]})
    let a:decs = map(deepcopy(a:vars),{n,var -> var[2]})
    let a:blocks = s:getAllBlocks(a:close)

    let [a:all,a:isos] = s:getAllRelevantLines(a:vars,a:names,a:close)

    let a:new_args = s:getNewArgs(a:extract_lines,a:vars,a:all)
    let [a:final,a:rep] = s:buildNewMethod(a:extract_lines,a:new_args,a:blocks,a:vars,a:all,a:tab,a:close,a:name)

    call append(a:close[0],a:final)
    call append(a:extract_lines[-1],a:rep)

    let a:i = len(a:extract_lines) - 1
    while a:i >= 0
        call cursor(a:extract_lines[a:i],1)
        d 
        let a:i -= 1
    endwhile

    call search('\<' . a:name . '\>(\_[^;]*{')
    silent write!
    redraw
    echo 'Extracted ' . len(a:extract_lines) . ' lines from ' . a:method_name

    return [a:name,a:old_lines]
endfunction
