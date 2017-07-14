" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" Search Constants {{{1

let s:start_chars = '_A-Za-z'
let s:search_chars = s:start_chars . '0-9#'
let s:c_identifier = '[' . s:start_chars . '][' . s:search_chars . ']*'
let s:c_type = '\(struct\_s*\|union\_s*\|long\_s*\|short\_s*\)\=\<' . s:c_identifier . '\>'
let s:collection_identifier = '\([\[\*&]\=[[\]\*' . s:search_chars . '[:space:]&]*[\*\]]\)\='

let s:c_keywords = '\<\(break\|case\|continue\|default\|do\|else\|for\|goto\|if\|return\|sizeof\|switch\|typedef\|while\)\>'
let s:c_allow = 'auto,char,const,double,enum,extern,float,inline,int,long,register,restrict,short,signed,static,struct,union,unsigned,void,volatile'

let s:modifiers = '\(typedef\_s*\|extern\_s*\|static\_s*\|auto\_s*\|register\_s*\|const\_s*\|restrict\_s*\|volatile\_s*\|signed\_s*\|unsigned\_s*\)\='
let s:modifier_query = repeat(s:modifiers,3)

let s:struct = '\<\(enum\|struct\|union\)\>\_s*\(' . s:c_identifier . '\)\=\_s*{'
let s:func = s:c_type . '\_s*' . s:collection_identifier . '\<' . s:c_identifier . '\>\_s*('
let s:tag_query = '^\s*' . s:modifier_query . '\(' . s:struct . '\|' . s:func . '\)'

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
        execute 'bwipeout ' a:file
    elseif a:file == expand('%:p')
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
    let g:factorus_qf += a:res
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
    execute 'normal %'
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
    let a:include = '^#\<include\>'
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

    call map(a:files,{n,val -> ' -name "' . substitute(val,'\(.*\/\)\=\(.*\)','\2','') . '"'})
    let a:or = join(a:files,' -or')
    let a:fin = split(system('find ' . getcwd() . a:or),'\n')

    call cursor(a:orig[0],a:orig[1])
    return a:fin
endfunction

" getAllIncluded {{{3 
function! s:getAllIncluded()
    let a:fin = s:getIncluded()
    let a:files = copy(a:fin)

    while a:files != []
        let a:temp = []
        for file in a:files
            execute 'silent tabedit! ' . file
            let a:temp += filter(s:getIncluded(),'index(a:temp,v:val) < 0')
            call s:safeClose()
        endfor
        call filter(a:temp,'index(a:fin,v:val) < 0')
        let a:files = copy(a:temp)
        let a:fin += a:files
    endwhile

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

" References {{{2

" File-Updating {{{2
" updateFile {{{3
function! s:updateFile(old_name,new_name,is_method,is_local)
    let a:orig = [line('.'),col('.')]

    if a:is_local == 1
        let a:query = '\([^.]\)\<' . a:old_name . '\>'
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
            execute 'silent lvimgrep /\([^.]\)\<' . a:old_name . '\>' . a:paren . '/j %:p'
            let g:factorus_qf += map(getloclist(0),{n,val -> {'filename' : expand('%:p'), 'lnum' : val['lnum'], 'text' : s:trim(val['text'])}})
        catch /.*/
        endtry
        call setloclist(0,[])

        execute 'silent %s/\([^.]\)\<' . a:old_name . '\>' . a:paren . '/\1' . a:new_name . a:paren . '/ge'
    endif

    call cursor(a:orig[0],a:orig[1])
    silent write
endfunction

" Renaming {{{2
" renameArg {{{3
function! s:renameArg(new_name,...) abort
    let a:var = expand('<cword>')
    let g:factorus_history['old'] = a:var
    call s:updateFile(a:var,a:new_name,0,1)

    if a:0 == 0 || a:000[-1] != 'factorusRollback'
        redraw
        echo 'Re-named ' . a:var . ' to ' . a:new_name
    endif
    return a:var
endfunction

" renameMethod {{{3
function! s:renameMethod(new_name,...) abort
    call s:gotoTag()

    let a:method_name = matchstr(getline('.'),'\<' . s:c_identifier . '\>\s*(')
    let a:method_name = matchstr(a:method_name,'[^[:space:](]\+')
    if a:method_name == a:new_name
        throw 'Factorus:Duplicate'
    endif
    let g:factorus_history['old'] = a:method_name

    let s:all_funcs = {}
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
    endif

    if a:swap == 1
        call s:safeClose()
    endif
    silent edit!

    if a:0 == 0 || a:000[-1] != 'factorusRollback'
        redraw
        let a:keyword = a:is_static == 1 ? ' static' : ''
        echo 'Re-named' . a:keyword . ' method ' . a:method_name . ' to ' . a:new_name
    endif
    return a:method_name
endfunction

" Extraction {{{2

" Method-Building {{{2

" Rollback {{{2
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
    let a:new = g:factorus_history['args'][0]

    for file in keys(a:files)
        execute 'silent tabedit! ' . file
        for line in a:files[file]
            call cursor(line,1)
            execute 's/\<' . a:new . '\>/' . a:old . '/ge'
        endfor
        silent write
        call s:safeClose()
    endfor

    return 'Rolled back renaming of ' . substitute(g:factorus_history['args'][-1],'\(.\)\(.*\)','\L\1\E\2','') . ' ' . a:old
endfunction

" Global Functions {{{1
" addParam {{{2

" renameSomething {{{2
function! c#factorus#renameSomething(new_name,type,...)
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
        if a:0 > 0 && a:000[-1] == 'factorusRollback'
            let a:res = s:rollbackRename()
            let g:factorus_qf = []
        else
            let g:factorus_qf = []
            let Rename = function('s:rename' . a:type)
            let a:res = Rename(a:new_name)

            if g:factorus_show_changes > 0
                let s:qf = copy(g:factorus_qf)

                let a:ch = len(g:factorus_qf)
                let a:ch_i = a:ch == 1 ? ' instance ' : ' instances '
                let a:un = s:getUnchanged('\<' . a:res . '\>')
                let a:un_l = len(a:un)
                let a:un_i = a:un_l == 1 ? ' instance ' : ' instances '

                let a:first_line = a:ch . a:ch_i . 'modified'
                let a:first_line .= a:type == 'Arg' ? '.' : ', ' . a:un_l . a:un_i . 'left unmodified.'

                if g:factorus_show_changes > 1 && a:type != 'Arg'
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
        throw a:err . ', at ' . v:throwpoint
    endtry
endfunction

" extractMethod {{{2

