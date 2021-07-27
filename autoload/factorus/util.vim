" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" General {{{1 

function! factorus#util#is_before(x, y)
    if a:x[0] < a:y[0] || (a:x[0] == a:y[0] && a:x[1] < a:y[1])
        return 1
    endif
    return 0
endfunction

function! factorus#util#contains(outer, inner)
    if a:outer[0] <= a:inner[0]
        if len(a:inner) == 1
            let end = a:inner
        else
            let end = a:inner[1]
        endif

        if a:outer[1] >= end
            return 1
        endif
    endif

    return 0
endfunction

function! factorus#util#is_smaller_range(x, y)
    if (a:x[1] - a:x[0]) < (a:y[1] - a:y[0])
        return 1
    endif
    return 0
endfunction

function! factorus#util#trim(string)
    return substitute(a:string, '\(^\s*\|\s*$\)', '', 'g')
endfunction

function! factorus#util#merge(a, b)
    let l:i = 0
    let l:j = 0
    let l:c = []

    while l:i < len(a:a) || l:j < len(a:b)
        if l:j >= len(a:b)
            call add(l:c, a:a[l:i])
            let l:i += 1
        elseif l:i >= len(a:a)
            call add(l:c, a:b[l:j])
            let l:j += 1
        elseif l:j >= len(a:b) || a:a[l:i] < a:b[l:j]
            call add(l:c, a:a[l:i])
            let l:i += 1
        elseif l:i >= len(a:a) || a:b[l:j] < a:a[l:i]
            call add(l:c, a:b[l:j])
            let l:j += 1
        else
            call add(l:c, a:a[l:i])
            let l:i += 1
            let l:j += 1
        endif
    endwhile
    return l:c
endfunction

function! factorus#util#compare_blocks(x, y)
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

" File Navigation {{{1

function! factorus#util#is_alone(...)
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

function! factorus#util#safe_close(...)
    let l:prev = 0
    let l:file = a:0 > 0 ? a:1 : expand('%:p')
    if getbufinfo(l:file)[0]['loaded'] == 1 && winnr("$") == 1 && tabpagenr("$") > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr("$")
        let l:prev = 1
    endif

    if index(s:open_bufs, l:file) < 0 && factorus#util#is_alone(l:file)
        execute 'bwipeout ' l:file
    elseif l:file == expand('%:p')
        q
    endif

    if l:prev == 1
        tabprev
    endif
endfunction

" Find all files containing search_string, and write them to temp_file. If
" append is 'yes', appends to file; otherwise, overwrites file.
function! factorus#util#find_tags(temp_file, search_string, append)
    let l:fout = a:append == 'yes' ? '>>' : '>'
    call system('cat ' . s:all_files . ' | xargs grep -l "' . a:search_string . '"' .  l:fout . a:temp_file . ' 2> /dev/null')
endfunction

" Narrows files in temp_file to those containing search_string.
function! factorus#util#narrow_tags(temp_file, search_string)
    let l:n_temp_file = a:temp_file . '.narrow'
    call system('cat ' . a:temp_file . ' | xargs grep -l "' . a:search_string . '" {} + > ' . l:n_temp_file)
    call system('mv ' . l:n_temp_file . ' ' . a:temp_file)
endfunction

" Updates the factorus quickfix variable with files from temp_file that match the
" search_string.
function! factorus#util#update_quick_fix(temp_file, search_string)
    let l:res = split(system('cat ' . a:temp_file . ' | xargs grep -n -H "' . a:search_string . '"'), '\n')
    call filter(l:res, 'v:val[0:4] != "grep:"')
    call map(l:res, {n, val -> split(val, ':')})
    call map(l:res, {n, val -> {'filename' : val[0], 'lnum' : val[1], 'text' : factorus#util#trim(join(val[2:], ':'))}})
    let g:factorus_qf += l:res
endfunction

" Updates the quickfix menu with the values of qf, of a certain type.
function! factorus#util#set_quick_fix(type, qf)
    let l:title = a:type . ' : '
    if g:factorus_show_changes == 1
        let l:title .= 'ChangedFiles'
    elseif g:factorus_show_changes == 2
        let l:title .= 'UnchangedFiles'
    else
        let l:title .= 'AllFiles'
    endif

    call setqflist([], 'r', {'title' : l:title})
    call setqflist(a:qf, 'a')
endfunction

" Gets the instances that were changed by the command, in case user wants to
" check accuracy.
function! factorus#util#set_changes(res, func, ...)
    let l:qf = copy(g:factorus_qf)
    let l:type = a:func == 'rename' ? a:1 : ''

    let l:ch = len(g:factorus_qf)
    let l:ch_i = l:ch == 1 ? ' instance ' : ' instances '
    let l:un = factorus#util#get_unchanged('\<' . a:res . '\>')
    let l:un_l = len(l:un)
    let l:un_i = l:un_l == 1 ? ' instance ' : ' instances '

    let l:first_line = l:ch . l:ch_i . 'modified'
    let l:first_line .= (l:type == 'arg' || a:func == 'addParam') ? '.' : ', ' . l:un_l . l:un_i . 'left unmodified.'

    if g:factorus_show_changes > 1 && a:func != 'addParam' && l:type != 'arg'
        let l:un = [{'pattern' : 'Unmodified'}] + l:un
        if g:factorus_show_changes == 2
            let l:qf = []
        endif
        let l:qf += l:un
    endif

    if g:factorus_show_changes % 2 == 1
        let l:qf = [{'pattern' : 'Modified'}] + l:qf
    endif
    let l:qf = [{'text' : l:first_line, 'pattern' : a:func . l:type}] + l:qf

    call factorus#util#set_quick_fix(a:func . l:type, l:qf)
endfunction

" Gets the instances that were left unchanged by the command, in case user wants to
" check accuracy.
function! factorus#util#get_unchanged(search)
    let l:qf = []

    let l:temp_file = '.FactorusUnchanged'
    call factorus#util#find_tags(l:temp_file, a:search, 'no')

    let l:count = 0
    for file in readfile(l:temp_file)
        let l:lines = split(system('grep -n "' . a:search . '" ' . file), '\n')  

        let l:count += len(l:lines)
        for line in l:lines
            let l:un = split(line, ':')
            call add(l:qf, {'lnum' : l:un[0], 'filename' : file, 'text' : factorus#util#trim(join(l:un[1:], ''))})
        endfor
    endfor

    call system('rm -rf ' . l:temp_file)
    return l:qf
endfunction

" Set the working environment for the command by getting all currently open
" buffers, moving to the highest-level directory (if possible), and putting
" all filenames into a temp file.
function! factorus#util#set_environment()
    let s:open_bufs = []

    let l:prev_dir = getcwd()
    let l:buf_nrs = []
    for buf in getbufinfo()
        call add(s:open_bufs, buf['name'])
        call add(l:buf_nrs, buf['bufnr'])
    endfor
    let l:curr_buf = l:buf_nrs[index(s:open_bufs, expand('%:p'))]

    execute 'silent cd ' . expand('%:p:h')
    let l:project_dir = factorus#project_dir()
    execute 'silent cd ' l:project_dir

    let s:all_files = '.FactorusTemp'
    call system('find ' . getcwd() . g:factorus_ignore_string . ' > ' . s:all_files)

    return [[line('.'), col('.')], l:prev_dir, l:curr_buf]
endfunction

" Reset the working environment to how it was before the command was run.
function! factorus#util#reset_environment(orig, prev_dir, curr_buf, type)
    let l:buf_setting = &switchbuf
    call system('rm -rf .Factorus*')
    execute 'silent cd ' a:prev_dir
    if a:type != 'class'
        let &switchbuf = 'useopen, usetab'
        execute 'silent sbuffer ' . a:curr_buf
        let &switchbuf = l:buf_setting
    endif
    call cursor(a:orig)
endfunction

" Gets all lines in the changelog that were marked 'Modified' and returns them
" as a dictionary.
function! factorus#util#get_modified_lines()
    let l:files = {}

    for line in g:factorus_qf
        if index(keys(line), 'filename') < 0
            if line['pattern'] == 'Unmodified'
                break
            endif
            continue
        endif

        if index(keys(l:files), line['filename']) < 0
            let l:files[line['filename']] = [line['lnum']]
        else
            call add(l:files[line['filename']],line['lnum'])
        endif
    endfor

    return l:files
endfunction

" Helper function to check if a command is a rollback command or not.
function! factorus#util#is_rollback(command)
    return (len(a:command) > 0 && a:command[-1] == 'factorus_rollback')
endfunction
