" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" Search Constants {{{1

" Regex patterns are used to identify clauses in cpp (variables, for loops,
" structs, etc.)
"
" TODO: Add support for try/catch blocks.

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

" Closes current window safely.
function! s:safeClose(...)
    let l:prev = 0
    let l:file = a:0 > 0 ? a:1 : expand('%:p')
    if getbufinfo(l:file)[0]['loaded'] == 1 && winnr("$") == 1 && tabpagenr("$") > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr("$")
        let l:prev = 1
    endif

    if index(s:open_bufs,l:file) < 0 && s:isAlone(l:file)
        execute 'bwipeout ' . l:file
    elseif l:file == expand('%:p')
        q
    endif

    if l:prev == 1
        tabprev
    endif
endfunction

" Find all files containing search_string, and write them to temp_file. If
" append is 'yes', appends to file; otherwise, overwrites file.
function! s:findTags(temp_file,search_string,append)
    let l:fout = a:append == 'yes' ? ' >> ' : ' > '
    call system('cat ' . s:temp_file . ' | xargs grep -l "' . a:search_string . '"' .  l:fout . a:temp_file . ' 2> /dev/null')
endfunction

" Narrows files in temp_file to those containing search_string.
function! s:narrowTags(temp_file,search_string)
    let l:n_temp_file = a:temp_file . '.narrow'
    call system('cat ' . a:temp_file . ' | xargs grep -l "' . a:search_string . '" {} + > ' . l:n_temp_file)
    call system('mv ' . l:n_temp_file . ' ' . a:temp_file)
endfunction

" Updates the factorus quickfix variable with files from temp_file that match the
" search_string.
function! s:updateQuickFix(temp_file,search_string)
    let l:res = split(system('cat ' . a:temp_file . ' | xargs grep -n -H "' . a:search_string . '"'),'\n')
    call map(l:res,{n,val -> split(val,':')})
    call map(l:res,{n,val -> {'filename' : val[0], 'lnum' : val[1], 'text' : s:trim(join(val[2:],':'))}})
    let g:factorus_qf += l:res
endfunction

" Updates the quickfix menu with the values of qf, of a certain type.
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

" Gets the instances that were changed by the command, in case user wants to
" check accuracy.
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

" Gets the instances that were left unchanged by the command, in case user wants to
" check accuracy.
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

" Set the working environment for the command by getting all currently open
" buffers, moving to the highest-level directory (if possible), and putting
" all filenames into a temp file.
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

" Reset the working environment to how it was before the command was run.
function! s:resetEnvironment(orig,prev_dir,curr_buf,type)
    let l:buf_setting = &switchbuf
    call system('rm -rf .Factorus*')
    execute 'silent cd ' a:prev_dir
    if a:type != 'Class'
        let &switchbuf = 'useopen,usetab'
        execute 'silent sbuffer ' . a:curr_buf
        let &switchbuf = l:buf_setting
    endif
    call cursor(a:orig)
endfunction

" Utilities {{{2

function! s:getClosingBracket(stack,...)
    let l:orig = [line('.'),col('.')]
    if a:0 > 0
        call cursor(a:1)
    endif
    if a:stack == 0
        call searchpair('{','','}','Wb')
    else
        call search('{','Wc')
    endif
    normal %
    let l:res = [line('.'),col('.')]
    call cursor(l:orig)
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
    call cursor(a:start)
    let l:fin = searchpos(a:search,'Wen')
    call cursor(l:orig)
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

" Checks if line is a valid tag in cpp.
function! s:isValidTag(line)
    let l:first_char = strpart(substitute(getline(a:line),'\s*','','g'),0,1)   
    if l:first_char == '*' || l:first_char == '/'
        return 0
    endif

    let l:has_keyword = match(getline(a:line),s:cpp_keywords)
    if l:has_keyword >= 0 && !s:isQuoted(s:cpp_keywords,getline(a:line))
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
"
" Gets the nearest adjacent tag; if dir is 'b', searches backwards, and
" otherwise searches forwards. Returns just the line.
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

        call cursor(l:func)
        let l:func = searchpos(s:tag_query,'Wn' . a:dir)
    endwhile
    call cursor(l:oline,l:ocol)

    if l:is_valid == 1
        return l:func[0]
    endif
    return 0
endfunction

" getNextTag {{{3
"
" Shortcut for getting the next forward tag. Returns the line and the first
" character in the line.
function! s:getNextTag()
    return [s:getAdjacentTag(''),1]
endfunction

" gotoTag {{{3
"
" Jumps to the nearest backwards tag, if possible.
function! s:gotoTag()
    let l:tag = s:getAdjacentTag('b')
    if l:tag != 0
        call cursor(l:tag,1)
    else
        echo 'No tag found'
    endif
endfunction

"isInType {{{3
"
" Checks if cursor is within a typedef or struct.
function! s:isInType()
    let l:orig = [line('.'),col('.')]
    let l:close = s:getClosingBracket(0)
    call s:gotoTag()

    let l:res = 0
    if s:isBefore(searchpos('{','Wn'),searchpos('(','Wn')) && s:getClosingBracket(1)[0] >= l:close[0]
        let l:res = 1
    endif
    call cursor(l:orig)
    return l:res
endfunction


" Class Hierarchy {{{2
" getIncluded {{{3
"
" Returns all files included by a:file.
function! s:getIncluded(file)

    let l:files = []
    try
        execute 'silent lvimgrep /^#include\s*".*.h"/j ' . a:file
        for grep in getloclist(0)
            call add(l:files, substitute(grep['text'], '^.*"\(.*\/\)\=\(.*\.h\)".*$','\1\2',''))
        endfor
    catch /.*/
        return []
    endtry

    call map(l:files,{n,val -> substitute(val,'/','\\/','g')})
    call map(l:files,{n,val -> '\/' . substitute(val,'\(.*\/\)\=\(.*\)','\1\2','')})

    try
        execute 'silent lvimgrep /' . join(l:files,'\|') . '/j ' . s:temp_file
        let l:res = []
        for grep in getloclist(0)
            call add(l:res, grep['text'])
        endfor
    catch /.*/
        return []
    endtry

    return l:res
endfunction

" getAllIncluded {{{3
"
" Returns the upward hierarchy of inclusions starting with a:inc_file.
function! s:getAllIncluded(inc_file)
    if exists('s:all_inc') && index(keys(s:all_inc),a:inc_file) >= 0
        return s:all_inc[a:inc_file]
    endif

    let l:exclude = []
    let l:fin = s:getIncluded(a:inc_file)
    let l:files = copy(l:fin)

    let l:n = 0
    let l:step = 10
    let l:thresh = 1
    while len(l:files) > 0
        let l:temp_files = copy(l:files)
        let l:files = []
        for file in l:temp_files
            if index(l:exclude,file) < 0
                let l:n += 1
                if l:n >= l:thresh * l:step
                    echo 'Getting file hierarchy (' . l:thresh * l:step . ')...'
                    let l:thresh += 1
                endif

                call add(l:exclude, file)
                let l:files += s:getIncluded(file)
            endif
        endfor
        let l:fin += copy(l:files)
    endwhile

    let s:all_inc[a:inc_file] = l:fin
    return l:fin
endfunction

" getInclusions {{{3
"
" Returns downwards inclusion hierarchy of the current file, including the
" current file.
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
" 
" Gets all typedefs renaming the name a:name.
" TODO: This gets all typedefs renaming a:name, but shouldn't it also get
" whatever a:name is typedef-ing? (if any)
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
"
" Recursively parses the struct a:struct, returning the struct's name and all
" items.
function! s:parseStruct(struct)
    " If we're at a leaf of the struct tree (no more recursion), we just split
    " it into its type and name;
    if match(a:struct,'{') < 0
        let l:res = substitute(a:struct,'\[.*\]','','g')
        let l:res = substitute(l:res,'\*','','g')
        let l:res = split(l:res)
        return [join(l:res[:-2]),l:res[-1]]
    elseif match(a:struct,'^enum') >= 0
        let l:res = split(substitute(a:struct,'^\([^{]*\){\(.*\)}\([^}]*\)$','\1 \3',''),' ')
        return [s:trim(join(l:res[:-2])),s:trim(l:res[-1])]
    endif

    " Otherwise, we need to get each element within the brackets, and parse
    " them separately.
    let l:res = s:trim(substitute(a:struct,'^[^{]*{\(.*\)}[^}]*$','\1',''))
    let l:res = s:trim(substitute(l:res,'\/\*.\{-\}\*\/','','g'))
    let l:name = s:trim(substitute(a:struct,'^[^{]*{\(.*\)}\([^}]*\)$','\2',''))

    " Go through the struct character by character, stopping only when we hit
    " a bracket or a semi-colon. In the former situation, we change the level
    " of recursion, and in the latter we cut off that part and add it to the
    " list of struct attributes.
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

    " For each item in the struct, we parse that item recursively as well.
    for i in range(len(l:items))
        let l:items[i] = substitute(l:items[i],':[^:]*$','','')
        let l:items[i] = s:parseStruct(l:items[i])
    endfor

    " Return the list of items in the struct, and the name of the struct (if
    " it has one). If the struct doesn't have the name, l:name will be ';'.
    return [l:items,l:name]
endfunction

" getStructDef {{{3
"
" Gets the definition of the struct a:type. a:type could actually be multiple
" names, but all those names are typedefs of each other, so the definition for
" one is the definition for all the others. getStructDef also records this
" definition in a script-local dictionary, since it can be a time-consuming
" process.
function! s:getStructDef(type)
    " If a:type already exists in the dictionary, we just return that.
    if exists('s:all_structs') && index(keys(s:all_structs),expand('%:p') . '-' . a:type) >= 0
        return s:all_structs[expand('%:p') . '-' . a:type]
    endif

    " Otherwise, we get the upward hierarchy of the current file, and search
    " for the definition of the struct.
    let l:files = s:getAllIncluded(expand('%:p')) + [expand('%:p')]
    let [l:prev_file,l:res] = ['',[]]

    " NOTE: This if statement doesn't seem to serve any purpose. If we're
    " getting the struct definition, that would imply we're definitely looking
    " at a struct/union, which means we don't need to check again.
    if match(a:type,'\<\(struct\|union\)\>') >= 0
        try
            " Get the highest-level mention of a:type, and jump into that file
            " to find the declaration.
            execute 'silent lvimgrep! /' . a:type . '\_s*{/j ' . join(l:files)
            execute 'silent tabedit! ' . getbufinfo(getloclist(0)[0]['bufnr'])[0]['name']
            call cursor(1,1)

            " Search for the struct declaration, and parse its structure
            " recursively.
            " TODO: This will probably need to be made more robust, to deal
            " with classes.
            let l:find = search(a:type . '\_s*{','W')
            if l:find != 0
                let l:prev_file = expand('%:p')
                call search('{')
                let l:start = line('.')
                normal %
                let l:end = line('.')
                let l:def = join(getline(l:start,l:end))
                let l:res = s:parseStruct(l:def)[0]
            endif
            call s:safeClose()
        catch /.*/
        endtry
    else
    endif

    " Now that we have the struct's definition, we can add it to the
    " dictionary.
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
"
" Gets the parameters of the current method.
function! s:getParams() abort
    " Remember the current line, and get the parentheses that contain the
    " method parameters.
    let l:orig = [line('.'),col('.')]

    let l:oparen = search('(','Wn')
    let l:cparen = search(')','Wn')
    
    " TODO: Need to allow for multi-line method declarations.
    let l:dec = join(getline(l:oparen,l:cparen))
    let l:dec = substitute(l:dec,'.*(\(\_[^)]*\)).*','\1','')
    if l:dec == ''
        return []
    endif

    let l:args = split(l:dec,',')
    call map(l:args, {n,arg -> split(substitute(s:trim(arg),'\(.*\)\(\<' . s:cpp_identifier . '\>\)$','\1|\2',''),'|')})
    call map(l:args, {n,arg -> [s:trim(arg[1]),s:trim(arg[0]),line('.')]})

    call cursor(l:orig)
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
            call cursor(l:match)
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
"
" Gets all local declarations of the current method, including the method
" parameters.
function! s:getLocalDecs(close)

    " Get the parameters of the method.
    let l:vars = s:getParams()

    " Remember our current position, then get the next local declaration.
    let l:orig = [line('.'),col('.')]
    let l:next = s:getNextDec()

    " Until there are no more declarations in the current method, parse the
    " declaration and add it to l:vars.
    while s:isBefore(l:next[2],a:close) && l:next[2] != [0,0]
        
        " Parse the declaration and add it to l:vars.
        let l:type = l:next[0]
        for name in l:next[1]
            call add(l:vars,[name,l:type,l:next[2][0]])
        endfor

        " Get the next local declaration.
        call cursor(l:next[2])
        let l:next = s:getNextDec()
    endwhile

    " Return back to our original position.
    call cursor(l:orig)

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

    let l:use = s:getAllIncluded(expand('%:p'))

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
"
" Gets the definition of a:func in order to determine its return type. 
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
    call cursor(l:orig)
    return l:next
endfunction

" getVarDec {{{3
"
" Jumps back to the declaration of a:var to get its type.
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

    call cursor(l:orig)
    return l:res
endfunction

" getUsingVar {{{3
"
" Gets the struct/union that is referring to an instance of a field (used for
" s:renameField).
function! s:getUsingVar()
    let l:orig = [line('.'),col('.')]

    " Jump backwards through the chain of structs/functions until we get to
    " the front of the chain.
    let l:search = '\(\.\|->\)'
    while 1 == 1
        " Get the character right before the '.' or '->'.
        let l:adj = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')

        " If the character before '.'/'->' is a ')' or ']', we need to jump to
        " the opening bracket and keep going.
        if l:adj == ')' || l:adj == ']'
            call cursor(line('.'),col('.')-1)
            normal %

            " If we haven't reached the front of the chain, keep going.
            if searchpos(l:search,'bne') == searchpos('[^[:space:]]\_s*\<' . s:cpp_identifier . '\>','bn')
                call search(l:search,'b')
            " If the front of the chain is a variable, we get its name and
            " declaration.
            elseif s:isBefore(searchpos('\<' . s:cpp_identifier . '\>\((\|\[\)','bn'),searchpos('[^[:space:]' . s:search_chars . ']','bn'))
                call search('\<' . s:cpp_identifier . '\>','b')
                let l:var = expand('<cword>')
                let l:dec = s:getVarDec(l:var)
                break
            " Otherwise, if the front of the chain is a function, we get the
            " function's name and declaration.
            else
                let l:end = col('.')
                call search('\<' . s:cpp_identifier . '\>','b')
                let l:begin = col('.') - 1
                let l:var = strpart(getline('.'),l:begin,l:end - l:begin)
                let l:dec = s:getFuncDec(l:var)
                let l:var = substitute(l:var,'\(\[\|(\)','','')
                break
            endif
        " If the character before '.'/'->' isn't a ')' or ']', we need to
        " parse the relevant variable (if it's the front), or just keep
        " following the chain backwards. 
        else
            let l:end = col('.') - 1
            call search('\<' . s:cpp_identifier . '\>','b')
            let l:dot = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')

            " If we're at the front of the chain, get the variable's name and
            " declaration.
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

    " Now that we're at the front of the chain, we go back through it and add
    " the other elements to a list. (We don't need their definitions yet,
    " we'll be finding them during s:followChain).
    let l:funcs = []
    let l:search = l:search . '\<' . s:cpp_identifier . '\>[([]\='
    let l:next = searchpos(l:search,'W')
    let l:next_end = searchpos(l:search,'Wnez')

    while s:isBefore(l:next,l:orig)
        call cursor(l:next)

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
    call cursor(l:orig)

    let l:dec = [l:dec]
    return [l:var,l:dec,l:funcs]
endfunction

" followChain {{{3
"
" Checks to see if a referring chain of functions or structs is of type 
" a:types (used for s:renameField). a:types can be multiple types, since cpp/c
" has typedefs.
function! s:followChain(types,funcs,type_name)
    " let s:open_bufs = []
    " let s:all_inc = {}
    " let s:all_structs = {}
    " let s:all_funcs = {}

    let l:orig = [line('.'),col('.')]

    " Get the definition and structure of a:types. l:prev_struct will contain
    " the most recent struct in the chain, so we only need to keep track of
    " one variable at a time.
    let l:func_search = '\(' . s:cpp_type . '\_s*' . s:collection_identifier . '\)\_s*\<' . a:funcs[0]
    let [l:prev_file,l:prev_struct,l:fields] = s:getStructDef('\(' . join(a:types,'\|') . '\)')

    while len(a:funcs) > 0
        " If the next item in the chain is a function, we need to get the
        " function definition.
        " TODO: This doesn't actually happen, because in C there are no class
        " methods. Functionality will need to be added for C++.
        if match(a:funcs[0],'(') >= 0
            try
                let l:included = s:getAllIncluded(expand('%:p')) + [expand('%:p')]
                execute 'silent lvimgrep /' . l:func_search . '/j ' . join(l:included)
            catch /.*/
            endtry
        " If the next item in the chain is just a variable, we need to figure
        " out the type of that variable, then get its definition.
        else
            " If the next item isn't a valid attribute of the previous struct,
            " something went wrong, so we'll just return false.
            let l:ind = index(map(deepcopy(l:fields),{n,val -> val[1]}),a:funcs[0])
            if l:ind < 0
                break
            endif

            " Otherwise, we jump into l:prev_file, and parse the type of that
            " attribute.
            execute 'silent tabedit! ' . l:prev_file
            try
                " Get the type and name of the struct, and find its
                " definition.
                " TODO: s:getTypeDefs needs to go upwards as well as downards;
                " if new_struct is itself a typedef, this won't work.
                let l:new_struct = split(l:fields[l:ind][0],' ')
                if len(l:new_struct) == 1
                    let l:type_defs = s:getTypeDefs(l:new_struct[0])
                else
                    let l:type_defs = s:getTypeDefs(l:new_struct[-1],l:new_struct[-2])
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
    call cursor(l:orig)

    if l:ind >= 0
        let l:ind = match(map(l:fields,{n,val -> val[1]}),'\<' . a:type_name . '\>')
    endif

    return (l:ind >= 0)
endfunction

" References {{{2
" getNextReference {{{3
"
" Gets the next reference to a:var; the type of reference depends on a:type.
" If type is 'right', gets the next reference where a:var is being used for a
" value or function. If type is 'left', gets the next reference where a:var is
" being updated or is doing something (e.g. a:var is a struct and code is
" referring to an attribute). If type is 'cond', gets the next reference where
" a:var is part of a conditional statement (if, while, etc.). Lastly, if type
" is 'return' gets the next reference where a:var is part of a return
" statement.
function! s:getNextReference(var,type)
    " Set our regex based on a:type, as well as the index we'll be using to
    " isolate part of the result.
    if a:type == 'right'
        let l:search = s:no_comment . s:modifier_query . '\s*\(' . s:cpp_type . '\_s*' . s:collection_identifier . 
                    \ '\)\=\s*\(' . s:cpp_identifier . '\)\s*[(.=]\_[^{;]*\<\(' . a:var . '\)\>\_.\{-\};$'
        let l:ref_index = '\7'
        let l:name_index = '\8'
    elseif a:type == 'left'
        let l:search = s:no_comment . '\(.\{-\}\[[^]]\{-\}\<\(' . a:var . '\)\>.\{-\}]\|\<\(' . a:var . '\)\>\)\s*\(++\_s*;\|--\_s*;\|[-\^|&~+*/]\=[.=][^=]\).*'
        let l:ref_index = '\1'
        let l:name_index = '\1'
    elseif a:type == 'cond'
        let l:search = s:no_comment . '\<\(switch\|while\|for\|if\|else\s\+if\)\>\_s*(\_[^{;]*\<\(' . a:var . '\)\>\_[^{;]*).*'
        let l:ref_index = '\1'
        let l:name_index = '\2'
    elseif a:type == 'return'
        let l:search = s:no_comment . '\s*\<return\>\_[^;]*\<\(' . a:var . '\)\>.*'
        let l:ref_index = '\1'
        let l:name_index = '\1'
    endif

    " Get the next reference of the relevant type.
    let l:line = searchpos(l:search,'Wn')
    let l:endline = s:getEndLine(l:line,l:search)

    " If type is 'right', there are some potential issues with the reference
    " regex that need to be cleared up.
    if a:type == 'right'
        let l:prev = [line('.'),col('.')]
        while !s:isValidTag(l:line[0])
            if l:line == [0,0]
                break
            endif

            if match(getline(l:line[0]),';') >= 0
                break
            endif

            if match(getline(l:line[0]),'\<\(true\|false\)\>') >= 0 
                break
            endif

            call cursor(l:line)
            let l:line = searchpos(l:search,'Wn')
            let l:endline = s:getEndLine(l:line,l:search)
        endwhile
        call cursor(l:prev)
    endif

    " If the reference we found is valid, we isolate the relevant parts and
    " return them; otherwise, we return a 'blank' value.
    if l:line[0] > line('.')
        let l:state = join(getline(l:line[0],l:endline[0]))

        let l:ref = substitute(l:state,l:search,l:ref_index,'')
        let l:name = substitute(l:state,l:search,l:name_index,'')

        if a:type == 'left'
            let l:ref = substitute(l:ref,'.*\<\(' . a:var . '\)\>.*','\1','')
            let l:name = l:ref
        endif

        return [l:ref, l:line, l:name]
    endif
        
    return ['none', [0,0], 'none']
endfunction

" getNextUse {{{3
"
" Gets the next mention of a:var. Returns the reference point, the type of
" reference, and the variable name.
function! s:getNextUse(var)

    " Get the next reference of each type.
    let l:right = s:getNextReference(a:var,'right')
    let l:left = s:getNextReference(a:var,'left')
    let l:cond = s:getNextReference(a:var,'cond')
    let l:return = s:getNextReference(a:var,'return')

    let l:min = [l:right[0], copy(l:right[1]), 'right', l:right[2]]

    " Find which reference is nearest to the cursor, and return that. If there
    " are no more references, the return value will be
    " ['none',[0,0],'right','none'].
    let l:poss = [l:right,l:left,l:cond,l:return]
    let l:idents = ['right', 'left', 'cond', 'return']
    for i in range(4)
        let temp = l:poss[i]
        if temp[1] != [0,0] && (s:isBefore(temp[1],l:min[1]) || l:min[1] == [0,0])
            let l:min = [temp[0],copy(temp[1]),l:idents[i], temp[2]]
        endif
    endfor

    return l:min
endfunction

" File-Updating {{{2
" updateUsingFile {{{3
"
" Updates the current file, renaming a:old_name to a:new_name. The only
" instances to be renamed should be when a variable is of the proper struct
" type, so we need a:type_name to differentiate.
"
" TODO: This function will eventually need to be modified to deal with things
" like class methods and fields.
function! s:updateUsingFile(type_name,old_name,new_name,paren) abort
    call cursor(1,1)
    let l:here = [line('.'),col('.')]
    let l:types = '\<\(' . a:type_name . '\)\>'
    let l:search = '\(\.\|->\)\<' . a:old_name . '\>' . a:paren

    " Go through all uses of a:old_name, and rename them to a:new_name if it's
    " a valid use of a:old_name.
    let l:next = searchpos(l:search,'Wn')
    while l:next != [0,0]
        call cursor(l:next)

        " Get the variable referring to the field a:old_name.
        let [l:var,l:dec,l:funcs] = s:getUsingVar()

        " If the referring variable is just a variable, we can check to see
        " if it's the proper type. Otherwise, the referring variable is
        " actually a function (or chain of functions), so we need to follow
        " the chain to see if the resulting return value is the proper type.
        if len(l:funcs) == 0
            let l:dec = join(l:dec,'|')
            if match(l:dec,l:types) >= 0
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                execute 'silent s/\(\.\|->\)\<' . a:old_name . '\>' . a:paren . '/\1' . a:new_name . a:paren . '/e'
            endif
        " Otherwise, the referring variable is a chain, so we need to follow
        " the chain to see if the resulting value is the proper type.
        else
            let l:chain = '\(' . join([l:var] + l:funcs,'\(\.\|->\)') . '\(\.\|->\)\)' . '\<' . a:old_name . '\>' . a:paren
            if s:followChain(l:dec,l:funcs,a:new_name) == 1 && match(getline('.'),l:chain) >= 0
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                execute 'silent s/' . l:chain . '/\1' . a:new_name . a:paren . '/e'
            endif
        endif
        call cursor(l:next)
        let l:next = searchpos(l:search,'Wn')
    endwhile

    silent write!
endfunction

" updateUsingFiles {{{3
"
" Updates all files in a:files, renaming the field a:old_name to a:new_name.
" a:files contains all files in the downard hierarchy of the current file,
" that have some reference to a:old_name.
function! s:updateUsingFiles(files,type_name,old_name,new_name,paren) abort
    for file in a:files
        execute 'silent tabedit! ' . file
        call s:updateUsingFile(a:type_name,a:old_name,a:new_name,a:paren)
        call s:safeClose()
    endfor
    silent edit!
endfunction 

" getArgs {{{3
"
" Returns the number of arguments to the current function.
function! s:getArgs() abort
    let l:prev = [line('.'),col('.')]
    if matchstr(getline('.'), '\%' . col('.') . 'c.') != '('
        call search('(')
    endif
    let l:start = strpart(getline('.'),0,col('.')-1)
    normal %
    let l:leftover = strpart(getline('.'),col('.'))
    let l:end = line('.')
    call cursor(l:prev)

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
"
" Updates a:method_name with a new parameter in the current file.
function! s:updateParamFile(method_name,num_args,default,param_name,param_type) abort
    call cursor(1,1)

    " Set the regex expression for replacing old method call with new method
    " call.
    let [l:param_search,l:insert] = ['',a:default . ')']
    let l:com = a:num_args > 0 ? ', ' : ''

    " If there are any parameters in the old method call, we need to modify
    " the insertion and regex to deal with that.
    if a:num_args > 0
        let l:insert = ', ' . l:insert
        let l:param_search = '\_[^;]\{-\}' . repeat(',' . '\_[^;]\{-\}',a:num_args - 1)
    endif
    let l:param_search = '\((' . l:param_search . '\))'

    " For every call to the old method, replace the old call with the new
    " call.
    let l:search = a:method_name . '('
    let l:next = searchpos(l:search,'Wn')
    while l:next != [0,0]
        call cursor(l:next)
        " If the method call we found doesn't have enough arguments, we add
        " the default argument to it.
        if s:getArgs() == a:num_args
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
                call cursor(l:next)
                execute 'silent ' . line('.') . ',' . l:end . 's/\<' .a:method_name . '\>' . l:param_search . '\(' . l:leftover . '\)/' . 
                            \ a:method_name . '\1' . l:insert . '\2/e'
            endif

            call cursor(l:next)
        endif
        let l:next = searchpos(l:search,'Wn')
    endwhile

    silent write!
endfunction

" updateFile {{{3
"
" Updates all references of a:new_name to a:old_name in the current file. If
" a:is_method == 1, the function adds a parenthesis, and if a:local == 1, the
" function only updates the current method.
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
            call cursor(l:next)
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

    call cursor(l:orig)
    silent write!
endfunction

" Renaming {{{2
" renameArg {{{3
"
" Renames the argument of a method to a:new_name.
function! s:renameArg(new_name) abort
    let l:var = expand('<cword>')
    let g:factorus_history['old'] = l:var
    call s:updateFile(l:var,a:new_name,0,1)

    "if !factorus#isRollback(a:000)
    redraw
    echo 'Re-named ' . l:var . ' to ' . a:new_name
    "endif
    return [l:var,[]]
endfunction

" renameField {{{3
"
" Renames the field under cursor to a:new_name. If the field is defined within
" a function, we just rename all instances in that function; otherwise, we
" attempt to find all references to that field, and rename them. 
function! s:renameField(new_name) abort

    let l:line = getline('.')

    " Find out if the field is static, or if it's defined in some type.
    let l:is_static = match(l:line,'\<static\>') >= 0 ? 1 : 0
    let l:is_local = !s:isInType()

    " Get the type and name of the variable.
    let l:search = '^\s*\(enum[^{]*{\)\=\s*' . s:modifier_query . '\(' . s:cpp_type . s:collection_identifier . '\)\=\s*\(' . s:cpp_identifier . '\)\s*[,;=].*'

    let l:enum = substitute(l:line,l:search,'\1','')
    let l:type = substitute(l:line,l:search,'\5','')
    let l:var = s:trim(substitute(l:line,l:search,'\8',''))

    " If the name or type didn't match, we're renaming an enum field.
    " TODO: Currently, renaming an enum just seems to be a global
    " find-and-replace, which is likely to be inaccurate.
    if l:var == '' || l:type == '' || match(l:var,'[^' . s:search_chars . ']') >= 0
        " That said, if we're not actually renaming an enum field, something's
        " gone wrong.
        if l:is_local && l:enum == ''
            throw 'Factorus:Invalid'
        endif

        " Rename the definition of the field, and save the change to the quickfix
        " list.
        let l:var = expand('<cword>')
        let g:factorus_history['old'] = l:var

        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent s/\<' . l:var . '\>/' . a:new_name . '/e'
        silent write!

        let l:temp_file = '.FactorusEnum'
        
        " Find all files that have l:var in them, and do a global
        " find-and-replace to a:new_name. 
        echo 'Updating enum...'
        call s:findTags(l:temp_file,'\<' . l:var . '\>','no')
        call s:updateQuickFix(l:temp_file,'\<' . l:var . '\>')
        call system('cat ' . l:temp_file . ' | xargs sed -i "s/\<' . l:var . '\>/' . a:new_name . '/g"')
        call system('rm -rf ' . l:temp_file)

        " Get the instances of l:var that were unchanged, and return the old
        " field and unchanged instances.
        let l:unchanged = s:getUnchanged('\<' . l:var . '\>')
        redraw
        echo 'Renamed enum field ' . l:var . ' to ' . a:new_name . '.'
        return [l:var,l:unchanged]
    elseif l:var == a:new_name
        throw 'Factorus:Duplicate'
    endif

    " If we're not renaming an enum field, we have to be more careful about
    " renaming.
    let g:factorus_history['old'] = l:var
    let l:unchanged = []

    " If the field is local, we just rename it within its method. Otherwise,
    " we're renaming a field within a struct/union. 
    if l:is_local == 1
        call s:updateFile(l:var,a:new_name,0,1)
    else
        " Replace field under the cursor and add it to the quickfix list.
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent s/\<' . l:var . '\>/' . a:new_name . '/e'

        "redraw
        "echo 'Updating references...'

        call s:gotoTag()

        " If the struct is typedefd to a different name, we need to also
        " recognize that name in files.
        let l:type_defs = []
        if match(getline('.'),'\<typedef\>') >= 0
            let l:prev = [line('.'),col('.')]
            call search('{')
            normal %
            if match(getline('.'),'\<\(' . s:cpp_identifier . '\)\>') >= 0
                call add(l:type_defs,substitute(getline('.'),'.*\<\(' . s:cpp_identifier . '\)\>.*','\1',''))
            endif
            call cursor(l:prev)
        endif

        " Get the name of the group, as well as whether it's a struct or a
        " union.
        let l:search = '^\s*\(\<typedef\>\)\=\_s*\<\(struct\|union\)\>\_s*\(' . s:cpp_identifier . '\)\=\_s*{\=.*'

        let l:type_name = ''
        if substitute(getline('.'),l:search,'\3','') != ''
            let l:type_name = substitute(getline('.'),l:search,'\3','')
        endif

        let l:struct_or_union = substitute(getline('.'),l:search,'\2','')
        if l:struct_or_union == ''
            throw 'Factorus:Invalid'
        endif

        " Get all files that include this one, and find any more typedefs that
        " we need to recognize when replacing.
        let l:temp_file = '.FactorusInc'
        call s:getInclusions(l:temp_file,l:is_static)
        call s:narrowTags(l:temp_file,'\(\.\|->\)' . l:var)

        let l:files = readfile(l:temp_file) + [expand('%:p')]
        if l:type_name != ''
            let l:type_defs += s:getTypeDefs(l:type_name,l:struct_or_union)
            let l:find_name = l:struct_or_union . '\_s*' . l:type_name
            call add(l:type_defs,l:find_name)
        endif

        " Update all files in the hierarchy that might reference this field,
        " and set our list of unchanged instances.
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
"
" Renames the macro under cursor to a:new_name.
function! s:renameMacro(new_name) abort
    " Check to see the line under the cursor actually defines a macro, and
    " throw an exception if it doesn't.
    let l:search = '^#define\s\+\<\(' . s:cpp_identifier . '\)\>.*'
    let l:macro = substitute(getline('.'),l:search,'\1','')
    if l:macro == '' || l:macro == getline('.')
        throw 'Factorus:Invalid'
    endif

    " Get the downward hierarchy of the current file, and do a global
    " find-replace of the old macro name to the new one, then update quickfix
    " and get unchanged..
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
"
" Renames the current method to a:new_name.
function! s:renameMethod(new_name) abort
    call s:gotoTag()

    " Get the name of the current method, and make sure we aren't renaming to
    " the same name.
    let l:method_name = matchstr(getline('.'),'\<' . s:cpp_identifier . '\>\s*(')
    let l:method_name = matchstr(l:method_name,'[^[:space:](]\+')
    if l:method_name == a:new_name
        throw 'Factorus:Duplicate'
    endif
    let g:factorus_history['old'] = l:method_name

    let l:is_static = match(getline('.'),'\<static\>[^)]\+(') >= 0 ? 1 : 0

    " Get the upward hierarchy of the current file, and edit the highest-level
    " file that mentions this function (probably where it's defined, then). If
    " we're already at the highest-level file, we don't need to change files.
    echo 'Getting file hierarchy...'
    let l:includes = s:getAllIncluded(expand('%:p'))

    try
        execute 'silent lvimgrep /\<' . l:method_name . '\>(/j ' . join(l:includes)
        execute 'silent tabedit! ' . getbufinfo(getloclist(0)[0]['bufnr'])[0]['name']
        call setloclist(0,[])
        let l:swap = 1
    catch /.*/
        let l:swap = 0
    endtry

    " Update the file where the method is defined.
    call s:updateFile(l:method_name,a:new_name,1,0)

    redraw
    echo 'Updating references...'
    let l:search = '\([^.]\)\<' . l:method_name . '\>('
    let l:temp_file = '.FactorusInc'

    " Get the downard hierarchy of the top-level file, and update all
    " instances of the old name to the new name.
    " TODO: A global find-and-replace works okay for C, since there are no
    " class methods, but this needs to be improved for C++.
    call s:getInclusions(l:temp_file,l:is_static)
    call s:updateQuickFix(l:temp_file,l:search)

    call system('cat ' . l:temp_file . ' | xargs sed -i "s/' . l:search . '/\1' . a:new_name . '(/g"')
    call system('rm -rf ' . l:temp_file)
    let l:unchanged = s:getUnchanged('\<' . l:method_name . '\>')

    " If we had to change files during execution, make sure we end up back in
    " the original file.
    silent edit!
    if l:swap == 1
        call s:safeClose()
        silent edit!
    endif

    redraw
    let l:keyword = l:is_static == 1 ? ' static' : ''
    echo 'Re-named' . l:keyword . ' method ' . l:method_name . ' to ' . a:new_name

    return [l:method_name,l:unchanged]
endfunction

" renameType {{{3
"
" Renames the current enum, struct, or union to a:new_name.
function! s:renameType(new_name) abort
    call s:gotoTag()

    " Check to make sure the thing we're in is actually valid for renaming.
    let l:search = '^.*\<\(enum\|struct\|union\)\>\s*\(\<' . s:cpp_identifier . '\>\)\s*\({\|\<' . s:cpp_identifier . '\>\_s*;\).*'
    if match(getline('.'),l:search) < 0
        throw 'Factorus:Invalid'
    endif

    " Get all the relevant information from the object (name, type, etc.)
    " TODO: In C the struct/union keyword is required, but it's optional in
    " C++.
    let [l:type,l:type_name] = split(substitute(getline('.'),l:search,'\1|\2',''),'|')
    let l:is_static = match(getline('.'),'\<static\>[^)]\+(') >= 0 ? 1 : 0
    let l:rep = '\<' . l:type . '\>\_s*\<' . l:type_name . '\>'
    let l:new_rep = l:type . ' ' . a:new_name
    let g:factorus_history['old'] = l:type . ' ' . l:type_name

    " Get the upward hierarchy of the current file, and edit the highest-level
    " file that mentions this function (probably where it's defined, then). If
    " we're already at the highest-level file, we don't need to change files.
    echo 'Getting file hierarchy...'
    let l:includes = s:getAllIncluded(expand('%:p'))

    try
        execute 'silent lvimgrep /' . l:rep . '/j ' . join(l:includes)
        execute 'silent tabedit! ' . getbufinfo(getloclist(0)[0]['bufnr'])[0]['name']
        call setloclist(0,[])
        let l:swap = 1
    catch /.*/
        let l:swap = 0
    endtry

    " Update the file where the method is defined.
    call s:updateFile(l:rep,l:new_rep,0,0)

    redraw
    echo 'Updating references...'

    " Get the downard hierarchy of the top-level file, and update all
    " instances of the old name to the new name.
    let l:search = '\<' . l:type . '\>[[:space:]]*\<' . l:type_name . '\>'
    let l:temp_file = '.FactorusInc'

    call s:getInclusions(l:temp_file,l:is_static)
    call s:updateQuickFix(l:temp_file,l:search)

    call system('cat ' . l:temp_file . ' | xargs sed -i "s/' . l:search . '/' . l:new_rep . '/g"')
    call system('rm -rf ' . l:temp_file)
    let l:unchanged = s:getUnchanged(l:search)

    " If we had to change files during execution, make sure we end up back in
    " the original file.
    silent edit!
    if l:swap == 1
        call s:safeClose()
        silent edit!
    endif

    "if !factorus#isRollback(a:000)
    redraw
    let l:keyword = l:is_static == 1 ? ' static' : ''
    echo 'Re-named' . l:keyword . ' ' . l:type . ' ' . l:type_name . ' to ' . a:new_name
    "endif
    
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
"
" Gets all 'blocks' of code within the current method. A block is a segment of
" code that is its own unit (an if statement, for loop, etc.)
function! s:getAllBlocks(close)

    " Remember current location, jump to method declaration, and define the
    " entire method as the first block.
    let l:orig = [line('.'),col('.')]
    call s:gotoTag()
    let l:blocks = [[line('.'),a:close[0]]]

    " Define all the regex patterns for the different blocks (if, for, while,
    " do, switch).
    let l:if = '\<if\>\_s*(\_[^{;]*)\_s*{\='
    let l:for = '\<for\>\_s*(\_[^{;]*;\_[^{;]*;\_[^{;]*)\_s*{\='
    let l:while = '\<while\>\_s*(\_[^{;]*)'
    let l:do = '\<do\>\_s*{'
    let l:switch = '\<switch\>\_s*(\_[^{]*)\_s*{'

    " While there's another block within the method, parse that block and get
    " the next one.
    let l:search = '\(' . l:if . '\|' . l:for . '\|' . l:while . '\|' . l:do . '\|' . l:switch . '\)'
    let l:open = searchpos('{','Wn')
    let l:next = searchpos(l:search,'Wn')
    while l:next[0] <= a:close[0] && l:next != [0,0]
        call cursor(l:next)

        " Searching may end up revealing the end of an if block or a
        " do...while loop, so ignore those.
        if match(getline('.'),'\<else\>') >= 0 || match(getline('.'),'}\s*\<while\>') >= 0
            let l:next = searchpos(l:search,'Wn')
            continue
        endif

        " If the block is an if, for, or while, we parse it by just jumping to
        " the end of the block (or dealing with else/elseifs). We separately
        " deal with switch blocks because these can be single-line 
        " without brackets.
        if match(getline('.'),'\<\(if\|for\|while\)\>') >= 0
            " Jump past the conditionals in the block.
            let l:open = [line('.'),col('.')]
            call search('(')
            normal %

            let l:ret =  searchpos('{','Wn')
            let l:semi = searchpos(';','Wn')
            let l:o = line('.')

            "If we find a semi-colon before a bracket, the block doesn't have
            "any brackets, so we just add the lines between the beginning and
            "the semi-colon.
            if s:isBefore(l:semi,l:ret)
                call cursor(l:semi)
                call add(l:blocks,[l:open[0],line('.')])
            " Otherwise, if we're in an 'if' block, deal with that.
            elseif match(getline('.'),'\<if\>') >= 0
                call cursor(l:ret)
                normal %

                " Get any else/elseif parts of the if statement and add them
                " to the list of blocks.
                " TODO: Re-examine how this works. Currently, pieces of an
                " if/else/elseif statement are added as blocks, but not sure
                " if that makes sense.
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
            " Get the rest of the loop if we're looking at a for/while.
            else
                call search('{','W')
                let l:prev = [line('.'),col('.')]
                normal %
                call add(l:blocks,[l:next[0],line('.')])
                call cursor(l:prev)
            endif

            call cursor(l:open)
        " We deal with switch blocks separately, since they have required
        " brackets.
        " TODO: It looks like we assume the switch block doesn't contain for
        " or while loops, and just jump to the end. This is problematic.
        elseif match(getline('.'),'\<switch\>') >= 0
            let l:open = [line('.'),col('.')]
            call searchpos('{','W')

            normal %
            let l:sclose = [line('.'),col('.')]
            normal %

            let l:continue = '\<\(case\|default\)\>[^:]*:'
            let l:next = searchpos(l:continue,'Wn')

            " Jump to each case and add it to the list of blocks.
            while s:isBefore(l:next,l:sclose) && l:next != [0,0]
                call cursor(l:next)
                let l:next = searchpos(l:continue,'Wn')
                if s:isBefore(a:close,l:next) || l:next == [0,0]
                    call add(l:blocks,[line('.'),a:close[0]])
                    break
                endif
                call add(l:blocks,[line('.'),l:next[0]-1])
            endwhile
            call add(l:blocks,[l:open[0],l:sclose[0]])
        " We also deal with do...while blocks separately.
        else
            call search('{','W')
            let l:prev = [line('.'),col('.')]
            normal %
            call add(l:blocks,[l:next[0],line('.')])
            call cursor(l:prev)
        endif

        " Get the next block declaration.
        let l:next = searchpos(l:search,'Wn')
    endwhile

    " Return the sorted list of blocks.
    call cursor(l:orig)
    return uniq(sort(l:blocks,'s:compare'))
endfunction

" getAllRelevantLines {{{3
"
" For all variables in a:vars, gets the lines in the method that reference
" that variable.
function! s:getAllRelevantLines(vars,names,close)

    let l:orig = [line('.'),col('.')]
    let l:begin = s:getAdjacentTag('b')

    let l:lines = {}
    let l:closes = {}
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
        let l:closes[var[0]] = copy(l:local_close)
        call cursor(l:orig)
        if index(keys(l:lines),var[0]) < 0
            let l:lines[var[0]] = {var[2] : l:start_lines}
        else
            let l:lines[var[0]][var[2]] = l:start_lines
        endif
        let l:isos[var[0]] = {}
    endfor

    let l:search = join(a:names,'\|')
    let l:next = s:getNextUse(l:search)

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
            if s:isBefore(l:next[1],l:closes[l:name]) && l:quoted == 0 && l:ldec > 0
                if index(l:lines[l:name][l:ldec],l:next[1][0]) < 0
                    call add(l:lines[l:name][l:ldec],l:next[1][0])
                endif
            endif

            if match(l:new_search,'\\|') < 0
                break
            endif

            let l:new_search = substitute(l:new_search,'\\|\<' . l:name . '\>','','')
            let l:new_search = substitute(l:new_search,'\<' . l:name . '\>\\|','','')

            let l:next = s:getNextUse(l:new_search)
        endwhile
        let l:next = copy(l:pause)

        call cursor(l:next[1])
        let l:next = s:getNextUse(l:search)
    endwhile
    
    call cursor(l:orig)
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
    let l:ref = s:getNextReference(l:search,'left')
    let l:return = search('\<\(return\)\>','Wn')
    let l:continue = search('\<\(continue\|break\)\>','Wn')

    let l:res = 1
    if s:contains(a:block,l:return)
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
            if s:contains(a:block,l:i)
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
        if !s:isIsolatedBlock(l:for,a:var,a:rels,a:close)
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
        call cursor(l:next_use[1])

        let l:block = [0,0]
        for j in range(i,len(l:refs)-1)
            let line = l:refs[j]

            if line == l:next_use[1][0]
                if index(l:names,l:next_use[0]) >= 0
                    break
                endif
                call cursor(l:next_use[1])
                let l:next_use = s:getNextReference(a:var[0],'right')
            endif
            if line >= l:block[0] && line <= l:block[1]
                continue
            endif

            let l:block = s:getContainingBlock(line,a:blocks,twrap)
            if l:block[0] < twrap[0] || l:block[1] > twrap[1]
                break
            endif

            if !s:isIsolatedBlock(l:block,a:var,a:rels,a:close)
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

        call cursor(l:orig)
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
            call cursor(l:next[1])
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
        call cursor(l:orig)
    endfor

    call cursor(l:orig)
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
    let l:def_space = repeat(' ',l:paren+1)
    call map(a:def,{n,line -> a:spaces . (n > 0 ? l:def_space : '') . substitute(line,'\s*\(.*\)','\1','')})

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
            if l:outside[1] != [0,0] && s:isBefore(l:outside[1],a:close) && s:getLatestDec(a:rels,var[0],l:outside[1]) == var[2]

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
" manualExtract {{{2
"
" Manually extracts a block of code to a new function.
function! s:manualExtract(args)
    " If we're rolling back a command, undo the changes and let the user know.
    if factorus#isRollback(a:args)
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif

    " If new function name is given, use that; otherwise, use the default
    " method name.
    let l:name = len(a:args) <= 2 ? g:factorus_method_name : a:args[2]

    echo 'Extracting new method...'

    " Go to the beginning of the method, get its open and close lines, how
    " many spaces it's indented, and the method name.
    call s:gotoTag()
    let [l:open,l:close] = [line('.'),s:getClosingBracket(1)]
    let l:tab = substitute(getline('.'),'\(\s*\).*','\1','')
    let l:method_name = substitute(getline('.'),'.*\s\+\(' . s:cpp_identifier . '\)\s*(.*','\1','')

    " Get the lines we want to extract, and remember the original function.
    let l:extract_lines = range(a:args[0],a:args[1])
    let l:old_lines = getline(l:open,l:close[0])

    " Get all local declarations within the method, as well as the blocks of
    " code.
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

" addParam {{{2
"
" Adds a new parameter of type a:param_type and name a:param_name to the
" current function.
function! cpp#factorus#addParam(param_name,param_type,...) abort
    " If we're just rolling back, undo the changes that were made.
    if factorus#isRollback(a:000)
        call s:rollbackAddParam()
        let g:factorus_qf = []
        return 'Removed new parameter ' . a:param_name . '.'
    endif
    let g:factorus_qf = []

    let [s:all_inc,s:all_funcs] = [{},{}]
    let [l:orig,l:prev_dir,l:curr_buf] = s:setEnvironment()

    try
        " Go to the beginning of the method,and find the last parameter.
        call s:gotoTag()
        let l:tag = line('.')
        let l:next = searchpos(')','Wn')
        let [l:type,l:name,l:params] = split(substitute(join(getline(line('.'),l:next[0])),'^.*\<\(' . s:cpp_type . 
                    \ s:collection_identifier . '\)\s*\<\(' . s:cpp_identifier . '\)\>\s*(\(.*\)).*','\1 | \4 | \5',''),'|')
        let [l:type,l:name] = [s:trim(l:type),s:trim(l:name)]
        let g:factorus_history['old'] = [l:name,a:param_name]

        " Get the top-level file that defines this method, so we can work from
        " there.
        let l:includes = s:getAllIncluded(expand('%:p'))
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

        " Add the new parameter to the end of the method definition.
        let l:count = len(split(l:params,','))
        let l:com = l:count > 0 ? ', ' : ''

        let l:next = searchpos(')','Wn')
        let l:is_static = match(getline(l:next[0]),'\<static\>[^)]\+(') >= 0 ? 1 : 0
        let l:line = substitute(getline(l:next[0]), ')', l:com . a:param_type . ' ' . a:param_name . ')', '')
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent ' .  l:next[0] . 'd'
        call append(l:next[0] - 1,l:line)
        silent write!

        " If we are adding a default parameter, update all calls to the new
        " method.
        if g:factorus_add_default == 1
            redraw
            echo 'Updating references...'

            let l:default = a:0 > 0 ? a:1 : 'null'

            " For every file that includes this one and references this
            " method, update the method with the default parameter.
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
    call cursor(l:orig)

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
            let [l:res,l:unchanged] = Rename(a:new_name)

            if g:factorus_show_changes > 0
                call s:setChanges(l:res,l:unchanged,'rename',a:type)
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


