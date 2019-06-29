" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

scriptencoding utf-8

" Search Constants {{{1

"Java allows for more than just alpha_numeric characters as variable names, so
"a long string of unicode characters is used to allow for unusual names.

let s:start_chars = '\u0024\u0041-\u005a\u005f\u0061-\u007a\u00a2-\u00a5\u00aa\u00b5\u00ba\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u02c1\u02c6-\u02d1\u02e0-\u02e4\u02ec\u02ee\u0370-\u0374\u0376-\u0377\u037a-\u037d\u0386\u0388-\u038a\u038c\u038e-\u03a1\u03a3-\u03f5\u03f7-\u0481\u048a-\u0527\u0531-\u0556\u0559\u0561-\u0587\u058f\u05d0-\u05ea\u05f0-\u05f2\u060b\u0620-\u064a\u066e-\u066f\u0671-\u06d3\u06d5\u06e5-\u06e6\u06ee-\u06ef\u06fa-\u06fc\u06ff\u0710\u0712-\u072f\u074d-\u07a5\u07b1\u07ca-\u07ea\u07f4-\u07f5\u07fa\u0800-\u0815\u081a\u0824\u0828\u0840-\u0858\u08a0\u08a2-\u08ac\u0904-\u0939\u093d\u0950\u0958-\u0961\u0971-\u0977\u0979-\u097f\u0985-\u098c\u098f-\u0990\u0993-\u09a8\u09aa-\u09b0\u09b2\u09b6-\u09b9\u09bd\u09ce\u09dc-\u09dd\u09df-\u09e1\u09f0-\u09f3\u09fb\u0a05-\u0a0a\u0a0f-\u0a10\u0a13-\u0a28\u0a2a-\u0a30\u0a32-\u0a33\u0a35-\u0a36\u0a38-\u0a39\u0a59-\u0a5c\u0a5e\u0a72-\u0a74\u0a85-\u0a8d\u0a8f-\u0a91\u0a93-\u0aa8\u0aaa-\u0ab0\u0ab2-\u0ab3\u0ab5-\u0ab9\u0abd\u0ad0\u0ae0-\u0ae1\u0af1\u0b05-\u0b0c\u0b0f-\u0b10\u0b13-\u0b28\u0b2a-\u0b30\u0b32-\u0b33\u0b35-\u0b39\u0b3d\u0b5c-\u0b5d\u0b5f-\u0b61\u0b71\u0b83\u0b85-\u0b8a\u0b8e-\u0b90\u0b92-\u0b95\u0b99-\u0b9a\u0b9c\u0b9e-\u0b9f\u0ba3-\u0ba4\u0ba8-\u0baa\u0bae-\u0bb9\u0bd0\u0bf9\u0c05-\u0c0c\u0c0e-\u0c10\u0c12-\u0c28\u0c2a-\u0c33\u0c35-\u0c39\u0c3d\u0c58-\u0c59\u0c60-\u0c61\u0c85-\u0c8c\u0c8e-\u0c90\u0c92-\u0ca8\u0caa-\u0cb3\u0cb5-\u0cb9\u0cbd\u0cde\u0ce0-\u0ce1\u0cf1-\u0cf2\u0d05-\u0d0c\u0d0e-\u0d10\u0d12-\u0d3a\u0d3d\u0d4e\u0d60-\u0d61\u0d7a-\u0d7f\u0d85-\u0d96\u0d9a-\u0db1\u0db3-\u0dbb\u0dbd\u0dc0-\u0dc6\u0e01-\u0e30\u0e32-\u0e33\u0e3f-\u0e46\u0e81-\u0e82\u0e84\u0e87-\u0e88\u0e8a\u0e8d\u0e94-\u0e97\u0e99-\u0e9f\u0ea1-\u0ea3\u0ea5\u0ea7\u0eaa-\u0eab\u0ead-\u0eb0\u0eb2-\u0eb3\u0ebd\u0ec0-\u0ec4\u0ec6\u0edc-\u0edf\u0f00\u0f40-\u0f47\u0f49-\u0f6c\u0f88-\u0f8c\u1000-\u102a\u103f\u1050-\u1055\u105a-\u105d\u1061\u1065-\u1066\u106e-\u1070\u1075-\u1081\u108e\u10a0-\u10c5\u10c7\u10cd\u10d0-\u10fa\u10fc-\u1248\u124a-\u124d\u1250-\u1256\u1258\u125a-\u125d\u1260-\u1288\u128a-\u128d\u1290-\u12b0\u12b2-\u12b5\u12b8-\u12be\u12c0\u12c2-\u12c5\u12c8-\u12d6\u12d8-\u1310\u1312-\u1315\u1318-\u135a\u1380-\u138f\u13a0-\u13f4\u1401-\u166c\u166f-\u167f\u1681-\u169a\u16a0-\u16ea\u16ee-\u16f0\u1700-\u170c\u170e-\u1711\u1720-\u1731\u1740-\u1751\u1760-\u176c\u176e-\u1770\u1780-\u17b3\u17d7\u17db-\u17dc\u1820-\u1877\u1880-\u18a8\u18aa\u18b0-\u18f5\u1900-\u191c\u1950-\u196d\u1970-\u1974\u1980-\u19ab\u19c1-\u19c7\u1a00-\u1a16\u1a20-\u1a54\u1aa7\u1b05-\u1b33\u1b45-\u1b4b\u1b83-\u1ba0\u1bae-\u1baf\u1bba-\u1be5\u1c00-\u1c23\u1c4d-\u1c4f\u1c5a-\u1c7d\u1ce9-\u1cec\u1cee-\u1cf1\u1cf5-\u1cf6\u1d00-\u1dbf\u1e00-\u1f15\u1f18-\u1f1d\u1f20-\u1f45\u1f48-\u1f4d\u1f50-\u1f57\u1f59\u1f5b\u1f5d\u1f5f-\u1f7d\u1f80-\u1fb4\u1fb6-\u1fbc\u1fbe\u1fc2-\u1fc4\u1fc6-\u1fcc\u1fd0-\u1fd3\u1fd6-\u1fdb\u1fe0-\u1fec\u1ff2-\u1ff4\u1ff6-\u1ffc\u203f-\u2040\u2054\u2071\u207f\u2090-\u209c\u20a0-\u20ba\u2102\u2107\u210a-\u2113\u2115\u2119-\u211d\u2124\u2126\u2128\u212a-\u212d\u212f-\u2139\u213c-\u213f\u2145-\u2149\u214e\u2160-\u2188\u2c00-\u2c2e\u2c30-\u2c5e\u2c60-\u2ce4\u2ceb-\u2cee\u2cf2-\u2cf3\u2d00-\u2d25\u2d27\u2d2d\u2d30-\u2d67\u2d6f\u2d80-\u2d96\u2da0-\u2da6\u2da8-\u2dae\u2db0-\u2db6\u2db8-\u2dbe\u2dc0-\u2dc6\u2dc8-\u2dce\u2dd0-\u2dd6\u2dd8-\u2dde\u2e2f\u3005-\u3007\u3021-\u3029\u3031-\u3035\u3038-\u303c\u3041-\u3096\u309d-\u309f\u30a1-\u30fa\u30fc-\u30ff\u3105-\u312d\u3131-\u318e\u31a0-\u31ba\u31f0-\u31ff\u3400-\u4db5\u4e00-\u9fcc\ua000-\ua48c\ua4d0-\ua4fd\ua500-\ua60c\ua610-\ua61f\ua62a-\ua62b\ua640-\ua66e\ua67f-\ua697\ua6a0-\ua6ef\ua717-\ua71f\ua722-\ua788\ua78b-\ua78e\ua790-\ua793\ua7a0-\ua7aa\ua7f8-\ua801\ua803-\ua805\ua807-\ua80a\ua80c-\ua822\ua838\ua840-\ua873\ua882-\ua8b3\ua8f2-\ua8f7\ua8fb\ua90a-\ua925\ua930-\ua946\ua960-\ua97c\ua984-\ua9b2\ua9cf\uaa00-\uaa28\uaa40-\uaa42\uaa44-\uaa4b\uaa60-\uaa76\uaa7a\uaa80-\uaaaf\uaab1\uaab5-\uaab6\uaab9-\uaabd\uaac0\uaac2\uaadb-\uaadd\uaae0-\uaaea\uaaf2-\uaaf4\uab01-\uab06\uab09-\uab0e\uab11-\uab16\uab20-\uab26\uab28-\uab2e\uabc0-\uabe2\uac00-\ud7a3\ud7b0-\ud7c6\ud7cb-\ud7fb\uf900-\ufa6d\ufa70-\ufad9\ufb00-\ufb06\ufb13-\ufb17\ufb1d\ufb1f-\ufb28\ufb2a-\ufb36\ufb38-\ufb3c\ufb3e\ufb40-\ufb41\ufb43-\ufb44\ufb46-\ufbb1\ufbd3-\ufd3d\ufd50-\ufd8f\ufd92-\ufdc7\ufdf0-\ufdfc\ufe33-\ufe34\ufe4d-\ufe4f\ufe69\ufe70-\ufe74\ufe76-\ufefc\uff04\uff21-\uff3a\uff3f\uff41-\uff5a\uff66-\uffbe\uffc2-\uffc7\uffca-\uffcf\uffd2-\uffd7\uffda-\uffdc\uffe0-\uffe1\uffe5-\uffe6'

let s:search_chars = s:start_chars . '\u0030-\u0039\u007f-\u009f\u00ad\u0300-\u036f\u0483-\u0487\u0591-\u05bd\u05bf\u05c1-\u05c2\u05c4-\u05c5\u05c7\u0600-\u0604\u0610-\u061a\u064b-\u0669\u0670\u06d6-\u06dd\u06df-\u06e4\u06e7-\u06e8\u06ea-\u06ed\u06f0-\u06f9\u070f\u0711\u0730-\u074a\u07a6-\u07b0\u07c0-\u07c9\u07eb-\u07f3\u0816-\u0819\u081b-\u0823\u0825-\u0827\u0829-\u082d\u0859-\u085b\u08e4-\u08fe\u0900-\u0903\u093a-\u093c\u093e-\u094f\u0951-\u0957\u0962-\u0963\u0966-\u096f\u0981-\u0983\u09bc\u09be-\u09c4\u09c7-\u09c8\u09cb-\u09cd\u09d7\u09e2-\u09e3\u09e6-\u09ef\u0a01-\u0a03\u0a3c\u0a3e-\u0a42\u0a47-\u0a48\u0a4b-\u0a4d\u0a51\u0a66-\u0a71\u0a75\u0a81-\u0a83\u0abc\u0abe-\u0ac5\u0ac7-\u0ac9\u0acb-\u0acd\u0ae2-\u0ae3\u0ae6-\u0aef\u0b01-\u0b03\u0b3c\u0b3e-\u0b44\u0b47-\u0b48\u0b4b-\u0b4d\u0b56-\u0b57\u0b62-\u0b63\u0b66-\u0b6f\u0b82\u0bbe-\u0bc2\u0bc6-\u0bc8\u0bca-\u0bcd\u0bd7\u0be6-\u0bef\u0c01-\u0c03\u0c3e-\u0c44\u0c46-\u0c48\u0c4a-\u0c4d\u0c55-\u0c56\u0c62-\u0c63\u0c66-\u0c6f\u0c82-\u0c83\u0cbc\u0cbe-\u0cc4\u0cc6-\u0cc8\u0cca-\u0ccd\u0cd5-\u0cd6\u0ce2-\u0ce3\u0ce6-\u0cef\u0d02-\u0d03\u0d3e-\u0d44\u0d46-\u0d48\u0d4a-\u0d4d\u0d57\u0d62-\u0d63\u0d66-\u0d6f\u0d82-\u0d83\u0dca\u0dcf-\u0dd4\u0dd6\u0dd8-\u0ddf\u0df2-\u0df3\u0e31\u0e34-\u0e3a\u0e47-\u0e4e\u0e50-\u0e59\u0eb1\u0eb4-\u0eb9\u0ebb-\u0ebc\u0ec8-\u0ecd\u0ed0-\u0ed9\u0f18-\u0f19\u0f20-\u0f29\u0f35\u0f37\u0f39\u0f3e-\u0f3f\u0f71-\u0f84\u0f86-\u0f87\u0f8d-\u0f97\u0f99-\u0fbc\u0fc6\u102b-\u103e\u1040-\u1049\u1056-\u1059\u105e-\u1060\u1062-\u1064\u1067-\u106d\u1071-\u1074\u1082-\u108d\u108f-\u109d\u135d-\u135f\u1712-\u1714\u1732-\u1734\u1752-\u1753\u1772-\u1773\u17b4-\u17d3\u17dd\u17e0-\u17e9\u180b-\u180d\u1810-\u1819\u18a9\u1920-\u192b\u1930-\u193b\u1946-\u194f\u19b0-\u19c0\u19c8-\u19c9\u19d0-\u19d9\u1a17-\u1a1b\u1a55-\u1a5e\u1a60-\u1a7c\u1a7f-\u1a89\u1a90-\u1a99\u1b00-\u1b04\u1b34-\u1b44\u1b50-\u1b59\u1b6b-\u1b73\u1b80-\u1b82\u1ba1-\u1bad\u1bb0-\u1bb9\u1be6-\u1bf3\u1c24-\u1c37\u1c40-\u1c49\u1c50-\u1c59\u1cd0-\u1cd2\u1cd4-\u1ce8\u1ced\u1cf2-\u1cf4\u1dc0-\u1de6\u1dfc-\u1dff\u200b-\u200f\u202a-\u202e\u2060-\u2064\u206a-\u206f\u20d0-\u20dc\u20e1\u20e5-\u20f0\u2cef-\u2cf1\u2d7f\u2de0-\u2dff\u302a-\u302f\u3099-\u309a\ua620-\ua629\ua66f\ua674-\ua67d\ua69f\ua6f0-\ua6f1\ua802\ua806\ua80b\ua823-\ua827\ua880-\ua881\ua8b4-\ua8c4\ua8d0-\ua8d9\ua8e0-\ua8f1\ua900-\ua909\ua926-\ua92d\ua947-\ua953\ua980-\ua983\ua9b3-\ua9c0\ua9d0-\ua9d9\uaa29-\uaa36\uaa43\uaa4c-\uaa4d\uaa50-\uaa59\uaa7b\uaab0\uaab2-\uaab4\uaab7-\uaab8\uaabe-\uaabf\uaac1\uaaeb-\uaaef\uaaf5-\uaaf6\uabe3-\uabea\uabec-\uabed\uabf0-\uabf9\ufb1e\ufe00-\ufe0f\ufe20-\ufe26\ufeff\uff10-\uff19\ufff9-\ufffb'

let s:java_identifier = '[' . s:start_chars . '][' . s:search_chars . ']*'
let s:java_keywords = '\<\(assert\|break\|case\|catch\|const\|continue\|default\|do\|else\|false\|finally\|for\|goto\|if\|import\|instanceof\|new\|package\|return\|super\|switch\|this\|throw\|true\|try\|while\)\>'
let s:modifiers = '\(public\_s*\|private\_s*\|protected\_s*\|static\_s*\|abstract\_s*\|final\_s*\|synchronized\_s*\|native\_s*\|strictfp\_s*\|transient\_s*\|volatile\_s*\)\='
let s:access_query = repeat(s:modifiers,3)

"Regex patterns used to identify Java constructs (classes, variables, etc.)

let s:special_chars = '\([*\/[\]]\)'
let s:strip_dir = '\(.*\/\)\=\(.*\)'
let s:no_comment = '^\s*'
let s:class = '\<\(class\|enum\|interface\)\>'
let s:sub_class = '\(implements\|extends\)'
let s:collection_identifier = '\(\[\]\|<[<>?,.[:space:]' . s:search_chars . ']*>\)'

let s:struct = s:class . '\_s\+' . s:java_identifier . '[^;{]\_[^;{]\{-\}' . s:sub_class . '\=\_[^{]\{-\}{'
let s:common = s:java_identifier . s:collection_identifier . '\=\_s\+' . s:java_identifier . '\_s*('
let s:reflect = s:collection_identifier . '\_s\+' . s:java_identifier . '\_s\+' . s:java_identifier . '\_s*('

let s:tag_query = '^\s*' . s:access_query . '\(' . s:struct . '\|' . s:common . '\|' . s:reflect . '\)'

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

    if index(s:open_bufs,l:file) < 0 && s:isAlone(l:file) == 1
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
function! s:findTags(temp_file,search_string,append)
    let l:fout = a:append == 'yes' ? '>>' : '>'
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
function! s:setChanges(res,func,...)
    let l:qf = copy(g:factorus_qf)
    let l:type = a:func == 'rename' ? a:1 : ''

    let l:ch = len(g:factorus_qf)
    let l:ch_i = l:ch == 1 ? ' instance ' : ' instances '
    let l:un = s:getUnchanged('\<' . a:res . '\>')
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

" Return line and column of the closing bracket of a block of code.
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
function! s:isValidTag(line)
    let l:first_char = strpart(substitute(getline(a:line),'\s*','','g'),0,1)   
    if l:first_char == '*' || l:first_char == '/'
        return 0
    endif

    let l:has_keyword = match(getline(a:line),s:java_keywords)
    if l:has_keyword >= 0 && s:isQuoted(s:java_keywords,getline(a:line)) == 0
        return 0
    endif

    if match(getline(a:line-1),'\<new\>.*{') >= 0
        return 0   
    endif

    return 1
endfunction

" getAdjacentTag {{{3
function! s:getAdjacentTag(dir)
    let [l:oline,l:ocol] = [line('.'),col('.')]
    let [l:line,l:col] = [line('.') + 1,col('.')]
    call cursor(l:line,l:col)

    let l:func = searchpos(s:tag_query,'Wn' . a:dir)
    let l:is_valid = 0
    while l:func != [0,0]
        let l:is_valid = s:isValidTag(l:func[0])
        if l:is_valid == 1
            break
        endif

        call cursor(l:func)
        let [l:line,l:col] = [line('.'),col('.')]
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

" getClassTag {{{3
"
" Gets the start and end of the class.
function! s:getClassTag()
    let [l:line,l:col] = [line('.'),col('.')]
    call cursor(1,1)
    let l:class_tag = search(s:tag_query,'cn')
    let l:tag_end = search(s:tag_query,'ne')
    call cursor(l:line,l:col)
    return [l:class_tag,l:tag_end]
endfunction

" gotoTag {{{3
function! s:gotoTag(head)
    let l:tag = a:head == 1 ? s:getClassTag()[0] : s:getAdjacentTag('b') 
    if l:tag != 0
        call cursor(l:tag,1)
    elseif a:head == 1
        call cursor(1,1)
    else
        echo 'No tag found'
    endif
endfunction

" Class Hierarchy {{{2
" getPackage {{{3

" Gets the package that file belongs to, and returns '' if it doesn't belong
" to a package.
function! s:getPackage(file)
    let l:i = 1
    let l:head = system('head -n ' . l:i . ' ' . a:file)
    while match(l:head,'^package') < 0
        let l:i += 1
        if l:i > 100
            return ''
        endif
        let l:head = system('head -n ' . l:i . ' ' . a:file . ' | tail -n 1')
    endwhile

    let l:head = substitute(l:head,'^\s*package\s*\(.*\);.*','\1','')
    let l:head = substitute(l:head,'\.','\\.','g')
    return l:head
endfunction

" getPackageFiles {{{3

" Gets all files associated with current file's package (in the same directory
" or in subdirectories).
function! s:getPackageFiles(file)
    let l:package_dir = expand('%:p:h')
    call system('find ' . l:package_dir . ' -name  "*.java" >> ' . a:file)
endfunction

" getSubClasses {{{3

" Gets all subclasses of class_name (including the base class itself).
function! s:getSubClasses(class_name)
    let l:temp_file = '.Factorus' . a:class_name . 'E'
    call system('> ' . l:temp_file)

    let l:sub = [expand('%:p')]
    let l:subc = [expand('%:t:r')]
    let l:all = [expand('%:p')]

    while l:sub != []
        let l:sub_classes = '\<\(' . join(l:subc) . '\)\>'
        let l:exclude = '[^\;}()=+\-\*/|&~!''\"]*'
        let l:fsearch = '^' . l:exclude . l:sub_classes . l:exclude . '$'
        let l:search = '^.\{-\}' . s:class . '\_[^{;]\{-\}' . s:sub_class . '\_[^;{]\{-\}' . l:sub_classes . '\_[^;{]\{-\}{'
        call s:findTags(l:temp_file,l:fsearch,'no')

        let l:sub = []
        for file in readfile(l:temp_file)
            if index(l:all,file) < 0
                execute 'silent tabedit! ' . file
                call cursor(1,1)
                let l:found = search(l:search,'W')
                if l:found > 0
                    call add(l:sub,file)
                    let l:new_sub = expand('%:t:r')
                    if l:found != s:getClassTag()[0]
                        let l:new_sub .= '\.' . substitute(getline('.'),'^.\{-\}' . s:class . '\s*\<\(' . s:java_identifier . '\)\>.*','\2','')
                    endif
                    call add(l:subc,l:new_sub)
                endif
                call s:safeClose()
            endif
        endfor
        let l:all += l:sub
    endwhile

    call system('rm -rf ' . l:temp_file)
    return [l:all,l:subc]
endfunction

" getSuperClasses {{{3

" Gets all superclasses of the current file. The search is recursive, and the
" current class is considered a superclass of itself, so if A is a subclass of B,  
" and B is a subclass of C, then getSuperClasses() will return A, B and C.
function! s:getSuperClasses()
    let l:class_tag = s:getClassTag()
    let l:class_name = expand('%:t:r')
    let l:super_search = '.*' . s:class . '\_s\+\<' . l:class_name . '\>[^{]\_[^{]\{-\}' . s:sub_class . '\_s\+\<\(' . s:java_identifier . '\)\>\_[^{]*{.*'
    let l:sups = [expand('%:p')]

    let l:class_line = join(getline(l:class_tag[0],l:class_tag[1]))
    let l:class_line = substitute(l:class_line,',',' ','g')
    let l:inherits = []

    while match(l:class_line,l:super_search) >= 0
        let l:super = substitute(l:class_line,l:super_search,'\3','')
        if s:isWrapped(l:super,l:class_line) == 1
            let l:class_line = substitute(l:class_line,s:sub_class,'','')
        elseif match(l:super,s:sub_class) < 0
            call add(l:inherits,l:super)
        endif
        let l:class_line = substitute(l:class_line,l:super,'','')
    endwhile

    if l:inherits == []
        return l:sups
    endif

    let l:names = join(map(l:inherits,{n,val -> ' -name "' . val . '.java"'}),' -or')
    let l:search = 'find ' . getcwd() . l:names
    let l:possibles = system(l:search)
    let l:possibles = split(l:possibles,'\n')
    for poss in l:possibles
        execute 'silent tabedit! ' . poss
        let l:sups += s:getSuperClasses()
        call s:safeClose()
    endfor

    return l:sups
endfunction

" Declarations {{{2
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
" Returns all parameters of the current function.
"
" Return value: args. args is a list of triplets of the form
" [name, type, line].
function! s:getParams() abort
    let l:prev = [line('.'),col('.')]
    call s:gotoTag(0)
    let l:oparen = search('(','Wn')
    let l:cparen = search(')','Wn')
    
    " Get the string of declarations; if it's empty, there are no
    " declarations.
    let l:dec = join(getline(l:oparen,l:cparen))
    let l:dec = substitute(l:dec,'.*(\(.*\)).*','\1','')
    if l:dec == ''
        return []
    endif

    let l:car = 0
    let l:args = []
    let l:i = 0
    let l:prev = 0

    " Because declarations can contain commas, can't just split by commas; so,
    " need to go character by character.
    " TODO: Might be able to make this less finicky.
    while l:i < len(l:dec)
        let char = l:dec[l:i]
        if char == ',' && l:car == 0
            call add(l:args,strpart(l:dec,l:prev,(l:i - l:prev)))
            let l:prev = l:i + 1
        elseif char == '>'
            let l:car -= 1
        elseif char == '<'
            let l:car += 1
        endif
        let l:i += 1
    endwhile
    call add(l:args,strpart(l:dec,l:prev,len(l:dec)-l:prev))
    call map(l:args, {n,arg -> [split(arg)[-1],join(split(arg)[:-2]),line('.')]})

    call cursor(l:prev)
    return l:args
endfunction

" getNextDec {{{3
"
" Gets the next variable declaration, starting from current line.
" Return value: [var, fline, match]. var is the variable type, fline is a list
" of all variable names defined on that line, and match is the position of the
" match.
function! s:getNextDec()
    " Define our regex searches; l:get_variable is our general search, which
    " includes for loop declarations, while l_alt_get is for specifically
    " finding declarations that aren't part of the for loop.
    let l:get_variable = '^\s*\(' . s:access_query . '\|for\s*(\)\s*\(' . s:java_identifier . 
                \ s:collection_identifier . '\=\)\s\+\(\<' . s:java_identifier . '\>[^:=;]*\)[;=:].*'
    
    let l:alt_get = '^\s*' . s:access_query . '\s*\(' . s:java_identifier . 
                \ s:collection_identifier . '\=\)\s\+\(\<' . s:java_identifier . '\>[^=;]*\)[=;].*'

    let [l:line,l:col] = [line('.'),col('.')]

    " Find the first match that isn't a return statement.
    let l:match = searchpos(l:get_variable,'Wn')
    while l:match != [0,0] && match(getline(l:match[0]),'\<return\>') >= 0
        call cursor(l:match)
        let l:match = searchpos(l:get_variable,'Wn')
    endwhile
    call cursor(l:line,l:col)

    " If the declaration is in the for loop, use l:get_variable to grab the
    " declaration. Otherwise, use l:alt_get.
    "
    if s:isBefore([l:line,l:col],l:match) == 1
        if match(getline(l:match[0]),'\<for\>') >= 0
            let l:var = substitute(getline(l:match[0]),l:get_variable,'\5','')
            let l:fline = split(substitute(getline(l:match[0]),l:get_variable,'\7',''),',')
        else
            let l:var = substitute(getline(l:match[0]),l:alt_get,'\4','')
            let l:fline = split(substitute(getline(l:match[0]),l:alt_get,'\6',''),',')
        endif
        call map(l:fline,{n,var -> s:trim(var)})
        call map(l:fline,{n,var -> substitute(var,'^\<\(' . s:java_identifier . '\)\>.*','\1','')})

        return [l:var,l:fline,l:match]
    endif

    return ['none',[],[0,0]]
endfunction

" getLocalDecs {{{3
"
" Returns all declarations until close, including function arguments,
" variables declared within functions, and variables declared within for loops
" within function.
"
" Return value: vars. vars is an array of triplets, of the form
" [name, type, line].
function! s:getLocalDecs(close)
    let l:vars = s:getParams()

    let l:orig = [line('.'),col('.')]
    let l:next = s:getNextDec()

    " As long as the next declaration is before a:close, add the next
    " declaration to l:vars.
    while s:isBefore(l:next[2],a:close)
        if l:next[2] == [0,0]
            break
        endif
        
        let l:type = l:next[0]
        for name in l:next[1]
            call add(l:vars,[name,l:type,l:next[2][0]])
        endfor

        call cursor(l:next[2])
        let l:next = s:getNextDec()
    endwhile
    call cursor(l:orig)

    return l:vars
endfunction

" getFunctionDecs {{{3
function! s:getFunctionDecs()
    let l:access = '\<\(void\|public\|private\|protected\|static\|abstract\|final\|synchronized\)\>'
    let l:query = '^\s*' . s:access_query . '\s*\(' .  s:java_identifier . s:collection_identifier . '\=\)\_s\+\(' . s:java_identifier . '\)\_s*\([;=(]\).*'
    let l:decs = {'types' : [], 'names' : []}
    try
        let l:class_tag = s:getClassTag()
        let l:close = s:getClosingBracket(1,[l:class_tag[0],1])
        execute 'silent vimgrep /' . l:query . '/j %:p'
        let l:greps = getqflist()

        for g in l:greps
            let l:fname = substitute(g['text'],l:query,'\4|\6\7','')
            if match(l:fname,s:java_keywords) >= 0 || match(l:fname,l:access) >= 0
                continue
            endif

            if l:fname[len(l:fname)-1] == '('
                let [l:type,l:name] = split(l:fname,'|')
            else
                call cursor(g['lnum'],g['col'])
                if searchpair('{','','}','Wnb') == l:class_tag[0]
                    let [l:type,l:name] = split(l:fname[:-2],'|')
                else
                    continue
                endif
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

    let l:hier = s:getSuperClasses()

    let l:defs = {'types' : [], 'names' : []}
    for class in l:hier
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

    if len(a:funcs) > 1
        let old = a:funcs[0]
        call remove(a:funcs,0)
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
    let l:search = s:no_comment . s:access_query . '\(' . s:java_identifier . s:collection_identifier . '\=\)\_s\+\<' . a:func . '\(\<\|\>\|)\|\s\).*'
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
function! s:getVarDec(var)
    let l:orig = [line('.'),col('.')]
    let l:search = s:no_comment  . '.\{-\}\(' . s:access_query . '\|for\s*(\)\s*\(' . s:java_identifier .
                \ s:collection_identifier . '\=\)\s\+\<' . a:var . '\>.*'
    let l:jump = '\<' . a:var . '\>'

    let l:pos = search(l:search,'Wb')
    call search(l:jump)
    let l:res = substitute(getline(l:pos),l:search,'\5','')
    while s:isQuoted(l:res,getline(l:pos)) == 1 || s:isCommented() == 1 || match(l:res,s:java_keywords) >= 0
        if l:pos == 0
            return ''
        endif
        call cursor(l:pos-1,l:pos)
        let l:pos = search(l:search,'Wb')
        call search(l:jump)
        let l:res = substitute(getline(l:pos),l:search,'\5','')
    endwhile

    call cursor(l:orig)
    return l:res
endfunction

" getClassVarDec {{{3
function! s:getClassVarDec(var)
    let l:orig = [line('.'),col('.')]
    call s:gotoTag(1)
    let l:search = '.*\<\(' . s:java_identifier . s:collection_identifier . '\=\)\_s\+\<' . a:var . '\>.*'
    let l:find = search(l:search,'Wn')
    let l:res = substitute(getline(l:find),l:search,'\1','') 
    call cursor(l:orig)
    return l:res
endfunction

" getUsingVar {{{3
function! s:getUsingVar()
    let l:orig = [line('.'),col('.')]

    while 1 == 1
        let l:adj = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')
        if l:adj == ')'
            call cursor(line('.'),col('.')-1)
            normal %
            if searchpos('\.','bn') == searchpos('[^[:space:]]\_\s*\<' . s:java_identifier . '\>','bn')
                call search('\.','b')
            else
                let l:end = col('.')
                call search('\<' . s:java_identifier . '\>','b')
                let l:begin = col('.') - 1
                let l:var = strpart(getline('.'),l:begin,l:end - l:begin)
                let l:dec = s:getFuncDec(l:var)
                break
            endif
        else
            let l:end = col('.') - 1
            call search('\<' . s:java_identifier . '\>','b')
            let l:dot = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')
            if l:dot != '.'
                let l:begin = col('.') - 1
                let l:var = strpart(getline('.'),l:begin,l:end - l:begin)
                let l:dec = s:getVarDec(l:var)
                break
            else
                let l:this = searchpos('\<this\>\.','Wbne')
                if l:this[1] == col('.') - 1
                    let l:begin = col('.') - 1
                    let l:var = strpart(getline('.'),l:begin,l:end - l:begin)
                    let l:dec = s:getClassVarDec(l:var)
                    break
                endif
            endif
            call search('\.','b')
        endif 
    endwhile

    let l:funcs = []
    let l:search = '\.\<' . s:java_identifier . '\>[([]\='
    let l:next = searchpos(l:search,'Wn')
    let l:next_end = searchpos(l:search,'Wnez')
    while s:isBefore(l:next,l:orig) == 1
        call cursor(l:next)
        call add(l:funcs,[strpart(getline('.'),l:next[1], l:next_end[1] - l:next[1])])
        if matchstr(getline('.'), '\%' . l:next_end[1] . 'c.') == '('
            call search('(')
            normal %
        elseif matchstr(getline('.'), '\%' . l:next_end[1] . 'c.') == '['
            call search('[')
            normal %
        endif
        let l:next = searchpos(l:search,'Wn')
        let l:next_end = searchpos(l:search,'Wnez')
    endwhile
    call cursor(l:orig)

    let l:dec = s:getStructVars(l:var,l:dec,l:funcs)
    return [l:var,l:dec,l:funcs]
endfunction

" followChain {{{3
function! s:followChain(classes,funcs,new_method)
    let l:chain_file = '.Factorus' . a:new_method . 'Chain'
    let l:names_list = []
    for class in a:classes
        call add(l:names_list,' -name "' . class . '.java" ') 
    endfor
    let l:names = join(l:names_list,'-or')
    call system('find ' . getcwd() . l:names . '> ' . l:chain_file)
    
    let l:vars = copy(a:classes)
    let l:chain_files = readfile(l:chain_file)
    while len(a:funcs) > 0
        let func = '\(' . join(a:funcs[0],'\|') . '\)'
        let l:temp_list = []
        for file in l:chain_files
            let l:next = ''
            execute 'silent tabedit! ' . file
            call cursor(1,1)
            let l:search = s:no_comment . s:access_query . '\(' . s:java_identifier . s:collection_identifier . '\=\)\_s\+\<' . func . '\(\<\|\>\|)\|\s\).*'
            let l:find =  search(l:search)
            if l:find > 0
                call cursor(line('.'),1)
                let l:next = substitute(getline('.'),l:search,'\4','')
            else
                let l:all_funcs = s:getAllFunctions()
                let l:ind = match(l:all_funcs['names'],func)
                if l:ind >= 0
                    let l:next = l:all_funcs['types'][l:ind]
                endif
            endif

            if l:next != ''
                let l:vars = s:getStructVars(func,l:next,a:funcs)
            endif
            let l:next_list = []
            for var in l:vars
                call add(l:next_list,' -name "' . var . '.java" ') 
            endfor
            let l:nexts = join(l:next_list,'-or')

            call system('find ' . getcwd() . l:nexts . '> ' . l:chain_file)
            let l:temp_list += readfile(l:chain_file)

            call s:safeClose()
        endfor
        let l:chain_files = copy(l:temp_list)
        if len(a:funcs) > 0
            call remove(a:funcs,0)
        endif
    endwhile

    let l:res = 0
    for file in l:chain_files
        execute 'silent tabedit! ' . file
        let l:search = s:no_comment . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+\<' . a:new_method . '\>\_s*('
        let l:find =  search(l:search)
        call s:safeClose()

        if l:find > 0
            let l:res = 1
            break
        endif
    endfor
    call system('rm -rf ' . l:chain_file)

    return l:res
endfunction

" References {{{2
" getNextReference {{{3
function! s:getNextReference(var,type,...)
    if a:type == 'right'
        let l:search = s:no_comment . s:access_query . '\s*\(' . s:java_identifier . s:collection_identifier . 
                    \ '\=\s\)\=\s*\(' . s:java_identifier . '\)\s*[(.=]\_[^{;]*\<\(' . a:var . '\)\>\_.\{-\};$'
        let l:index = '\6'
        let l:alt_index = '\7'
    elseif a:type == 'left'
        let l:search = s:no_comment . '\(.\{-\}\[[^]]\{-\}\<\(' . a:var . '\)\>.\{-\}]\|\<\(' . a:var . '\)\>\)\s*\(++\_s*;\|--\_s*;\|[-\^|&~+*/]\=[.=][^=]\).*'
        let l:index = '\1'
        let l:alt_index = '\1'
    elseif a:type == 'cond'
        let l:search = s:no_comment . '\<\(\(switch\|while\|if\|else\s\+if\)\>\_s*(\_[^{;]*\<\(' . a:var . '\)\>\_[^{;]*).*\|' .
                    \ '\<\(for\)\>\_s*(\_[^{]*\<\(' . a:var . '\)\>\_[^{]*).*\)'
        let l:index = '\2'
        let l:alt_index = '\3'
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

            if match(getline(l:line[0]),'\<\(new\|true\|false\)\>') >= 0 
                break
            endif

            call cursor(l:line)
            let l:line = searchpos(l:search,'Wn')
            let l:endline = s:getEndLine(l:line,l:search)
        endwhile
        call cursor(l:prev)
    endif

    if l:line[0] > line('.')
        let l:state = join(getline(l:line[0],l:endline[0]))
        if a:type == 'cond'
            let l:for = match(l:state,'\<for\>')
            let l:c = match(l:state,'\<\(switch\|while\|if\|else\s\+if\)\>')
            if l:c == -1 || (l:for != -1 && l:for < l:c)
                let l:index = '\4'
                let l:alt_index = '\5'
            endif
        endif
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

" File Updating {{{2
" updateFile {{{3
function! s:updateFile(old_name,new_name,is_method,is_local,is_static)
    let l:orig = [line('.'),col('.')]

    if a:is_local == 1
        let l:query = '\([^.]\)\<' . a:old_name . '\>'
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent s/' . l:query . '/\1' . a:new_name . '/g'

        call s:gotoTag(0)
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
            execute 'silent lvimgrep /\(\<super\>\.\|\<this\>\.\|[^.]\)\<' . a:old_name . '\>' . l:paren . '/j %:p'
            let g:factorus_qf += map(getloclist(0),{n,val -> {'filename' : expand('%:p'), 'lnum' : val['lnum'], 'text' : s:trim(val['text'])}})
        catch /.*/
        endtry
        call setloclist(0,[])

        execute 'silent %s/\(\<super\>\.\|\<this\>\.\|[^.]\)\<' . a:old_name . '\>' . l:paren . '/\1' . a:new_name . l:paren . '/ge'
    endif

    call cursor(l:orig)
    silent write!
endfunction

" updateClassFile {{{3
function! s:updateClassFile(class_name,old_name,new_name) abort
    let l:prev = [line('.'),col('.')]
    call cursor(1,1)
    let l:restricted = 0
    let l:here = line('.')

    let l:search = ['\([^.]\|\<this\>\.\)\<\(' . a:old_name . '\)\>' , '\(\<this\>\.\)\<\(' . a:old_name . '\)\>']

    let [l:dec,l:next] = s:getNextArg(a:class_name,a:old_name)
    if l:next[0] == 0
        let l:next = line('$')
    endif

    let l:rep = searchpos(l:search[l:restricted],'Wn')
    while l:rep != [0,0]

        if l:rep[0] >= l:next[0]
            call cursor(l:next[0],1)
            let l:restricted = 1 - l:restricted
            if l:restricted == 1
                let l:next = s:getNextTag()
            else
                let [l:dec,l:next] = s:getNextArg(a:class_name,a:old_name)
                if l:next[0] == 0
                    let l:next = [line('$'),1]
                endif
            endif
        else
            call cursor(l:rep[0],1)
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
            execute 'silent s/' . l:search[l:restricted] . '/\1' . a:new_name . '/g'
        endif

        let l:here = line('.')
        let l:rep = searchpos(l:search[l:restricted],'Wn')
        if l:rep == [0,0]
            call cursor(l:next[0],1)
            let l:rep = searchpos(l:search[1-l:restricted],'Wn')
        endif

    endwhile
    call cursor(l:prev)

    silent write!
endfunction

" updateDeclaration {{{3
function! s:updateDeclaration(method_name,new_name)
    let l:orig = [line('.'),col('.')]
    call cursor(1,1)

    let l:prev = [line('.'),col('.')]
    let l:next = searchpos('^\s*' . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+' . a:method_name . '\_s*(','Wn')

    while l:next[0] != l:prev[0] && l:next[0] != 0
        call cursor(l:next)

        if s:isValidTag(l:next[0])
            let l:prev = [line('.'),col('.')]
            let l:next = s:getNextTag()
            let l:match = match(getline('.'),'\<' . a:method_name . '\>')
            if l:match >= 0
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                execute 'silent s/\<' . a:method_name . '\>/' . a:new_name . '/e'
            endif
        endif

        let l:prev = [line('.'),col('.')]
        let l:next = searchpos('^\s*' . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+' . a:method_name . '\_s*(','Wn')
    endwhile
    silent write!

    call cursor(l:orig)
endfunction

" updateSubClassFiles {{{3
function! s:updateSubClassFiles(class_name,old_name,new_name,paren,is_static)
    let [l:sub_files,l:sub_classes] = s:getSubClasses(a:class_name)
    let l:is_method = a:paren == '(' ? 1 : 0

    try
        execute 'silent lvimgrep /\(\<super\>\.\|\<this\>\.\|[^.]\)\<' . a:old_name . '\>' . a:paren . '/j ' . join(l:sub_files)
    catch /.*/
        return [a:class_name]
    endtry

    let l:use_subs = map(getloclist(0),{key,val -> getbufinfo(val['bufnr'])[0]['name']})
    for file in l:use_subs
        execute 'silent tabedit! ' . file
        call cursor(1,1)
        if a:is_static == 1 || a:paren == '('
            if a:paren == '('
                call s:updateDeclaration(a:old_name,a:new_name)
            endif

            call s:updateFile(a:old_name,a:new_name,l:is_method,0,a:is_static)
        else
            call s:updateClassFile(expand('%:t:r'),a:old_name,a:new_name)
        endif

        call s:safeClose()
    endfor
    silent edit!

    call add(l:sub_classes,a:class_name)
    return l:sub_classes
endfunction

" updateMethodFile {{{3
function! s:updateMethodFile(class_name,method_name,new_name,paren) abort
    call s:gotoTag(1)
    call cursor(line('.')+1,1)
    let l:here = [line('.'),col('.')]
    let l:classes = '\<\(' . a:class_name . '\)\>'
    let l:search = '\.' . a:method_name . a:paren

    let l:next = searchpos(l:search,'Wn')
    while l:next != [0,0]
        call cursor(l:next)
        let [l:var,l:dec,l:funcs] = s:getUsingVar()
        if len(l:funcs) == 0 
            let l:dec = join(l:dec,'|')
            if match(l:dec,l:classes) >= 0
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                execute 'silent s/\<' .a:method_name . '\>' . a:paren . '/' . a:new_name . a:paren . '/e'
            endif
        else
            if s:followChain(l:dec,l:funcs,a:new_name) == 1
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                execute 'silent s/\<' . a:method_name . '\>' . a:paren . '/' . a:new_name . a:paren . '/e'
            endif
        endif
        let l:next = searchpos(l:search,'Wn')
    endwhile

    silent write!
endfunction

" updateMethodFiles {{{3
function! s:updateMethodFiles(files,class_name,method_name,new_name,paren) abort
    for file in a:files
        execute 'silent tabedit! ' . file
        call s:updateMethodFile(a:class_name,a:method_name,a:new_name,a:paren)
        call s:safeClose()
    endfor
    silent edit!
endfunction 

" updateReferences {{{3
function! s:updateReferences(classes,old_name,new_name,paren,is_static)
    let l:temp_file = '.Factorus' . a:new_name . 'References'
    let l:class_names = join(a:classes,'\|')
    if a:is_static == 1
        let l:search = '\<\(' . l:class_names . '\)\>\.\<' . a:old_name . '\>' . a:paren
        call s:findTags(l:temp_file,l:search,'no')
        call s:updateQuickFix(l:temp_file,l:search)
        call system('cat ' . l:temp_file . ' | xargs sed -i "s/' . l:search . '/\1\.' . a:new_name . a:paren . '/g"')  
    else
        call s:findTags(l:temp_file,'\.' . a:old_name . a:paren,'no')
        call s:narrowTags(l:temp_file,'\(' . l:class_names . '\)')
        let l:files = readfile(l:temp_file)
        call s:updateMethodFiles(l:files,l:class_names,a:old_name,a:new_name,a:paren)
    endif
    call system('rm -rf ' . l:temp_file)
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
function! s:updateParamFile(method_name,commas,default,is_static)
    let l:orig = [line('.'),col('.')]
    let l:rep = a:is_static ? ['\2','\3'] : ['\1','\2']
    let l:meth = a:is_static ? '\1.' . substitute(a:method_name,'.*)\\>\\\.\(.*\)','\1','') : a:method_name
    call cursor(1,1)

    let [l:param_search,l:insert] = ['',a:default . ')']
    if a:commas > 0
        let l:insert = ', ' . l:insert
        let l:param_search = '\_[^;]\{-\}'
        let l:param_search .= repeat(',' . '\_[^;]\{-\}',a:commas - 1)
    endif
    let l:param_search = '\((' . l:param_search . '\))'

    let l:func_search = a:is_static ? '\<' . a:method_name . '\>(' : '\(\<super\>\.\|\<this\>\.\|[^.]\)\<' . a:method_name . '\>('
    let l:next = searchpos(l:func_search,'Wn')
    while l:next != [0,0]
        call cursor(l:next[0],l:next[1]+1)
        if l:next[0] != s:getAdjacentTag('b') && s:getArgs() == a:commas
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
            call search('(')
            normal %
            let l:end = line('.')
            let l:leftover = substitute(strpart(getline('.'),col('.')),s:special_chars,'\\\1','g')
            call cursor(l:next)
            execute 'silent ' . line('.') . ',' . l:end . 's/\<' . a:method_name . '\>' . l:param_search . '\(' . l:leftover . '\)/' . 
                        \ l:meth . l:rep[0] . l:insert . l:rep[1] . '/e'
            call cursor(l:next)
        endif
        let l:next = searchpos(l:func_search,'Wn')
    endwhile

    call cursor(l:orig)
    silent write!
endfunction

" updateParamDeclaration {{{3
function! s:updateParamDeclaration(method_name,commas,param_name,param_type)
    let l:orig = [line('.'),col('.')]
    call cursor(1,1)

    let [l:param_search,l:insert] = ['',a:param_type . ' ' . a:param_name . ')']
    if a:commas > 0
        let l:insert = ', ' . l:insert
        let l:param_search = '\_[^;]\{-\}'
        let l:param_search .= repeat(',' . '\_[^;]\{-\}',a:commas - 1)
    endif
    let l:param_search = '\((' . l:param_search . '\))'

    let l:search = '^\s*' . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+' . a:method_name . '\_s*('
    let l:next = searchpos(l:search,'Wn')

    while l:next[0] != 0
        call cursor(l:next)

        if s:isValidTag(l:next[0]) && s:getArgs() == a:commas
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
            call search('(')
            normal %
            let l:end = line('.')
            let l:leftover = substitute(strpart(getline('.'),col('.')),s:special_chars,'\\\1','g')
            call cursor(l:next)
            execute 'silent ' . line('.') . ',' . l:end . 's/\<' . a:method_name . '\>' . l:param_search . '\(' . l:leftover . '\)/' . 
                        \ a:method_name . '\1' . l:insert . '\2/e'
            call cursor(l:next)
        endif

        let l:next = searchpos(l:search,'Wn')
    endwhile
    silent write!

    call cursor(l:orig)
endfunction

" updateParamSubClassFiles {{{3
function! s:updateParamSubClassFiles(old_name,commas,default,param_name,param_type,is_static)
    let l:class_name = expand('%:t:r')
    let [l:sub_files,l:sub_classes] = s:getSubClasses(l:class_name)

    try
        execute 'silent lvimgrep /\(\<super\>\.\|\<this\>\.\|[^.]\)\<' . a:old_name . '\>(' . '/j ' . join(l:sub_files)
    catch /.*/
        return [l:class_name]
    endtry

    let l:rep_name = a:is_static == 0 ? a:old_name : '\(' . join(copy(l:sub_classes),'\|') . '\)\>\.' . a:old_name
    let l:use_subs = map(getloclist(0),{key,val -> getbufinfo(val['bufnr'])[0]['name']})
    for file in l:use_subs
        execute 'silent tabedit! ' . file
        call cursor(1,1)
        call s:updateParamFile(l:rep_name,a:commas,a:default,a:is_static)
        if a:is_static == 0
            call s:updateParamDeclaration(l:rep_name,a:commas,a:param_name,a:param_type)
        endif
        call s:safeClose()
    endfor
    silent edit!

    call add(l:sub_classes,l:class_name)
    return l:sub_classes
endfunction

" updateParamUsingFile {{{3
function! s:updateParamUsingFile(class_name,method_name,commas,default,is_static) abort
    call s:gotoTag(1)
    call cursor(line('.')+1,1)
    let l:here = [line('.'),col('.')]
    let l:classes = '\<\(' . a:class_name . '\)\>'
    let l:search = a:is_static ? l:classes . '\.' . a:method_name . '(' : '\.' . a:method_name . '('

    let l:next = searchpos(l:search,'Wn')
    let [l:param_search,l:insert] = ['',a:default . ')']
    if a:commas > 0
        let l:insert = ', ' . l:insert
        let l:param_search = '\_[^;]\{-\}'
        let l:param_search .= repeat(',' . '\_[^;]\{-\}',a:commas - 1)
    endif
    let l:param_search = '\((' . l:param_search . '\))'
    while l:next != [0,0]
        call cursor(l:next)
        if s:getArgs() == a:commas
            if a:is_static
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                call search('(')
                normal %
                let l:end = line('.')
                let l:leftover = substitute(strpart(getline('.'),col('.')),s:special_chars,'\\\1','g')
                let l:leftover = strpart(getline('.'),col('.'))
                call cursor(l:next)
                let l:meth = l:classes . '\.\<' . a:method_name . '\>' . l:param_search . '\(' . l:leftover . '\)'
                execute 'silent ' . line('.') . ',' . l:end . 's/' . l:meth . '/\1.' . a:method_name . '\2' . l:insert . '\3/e'
            else
                let [l:var,l:dec,l:funcs] = s:getUsingVar()
                if len(l:funcs) == 0 
                    let l:dec = join(l:dec,'|')
                    if match(l:dec,l:classes) >= 0
                        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                        call search('(')
                        normal %
                        let l:end = line('.')
                        let l:leftover = substitute(strpart(getline('.'),col('.')),s:special_chars,'\\\1','g')
                        let l:leftover = strpart(getline('.'),col('.'))
                        call cursor(l:next)
                        execute 'silent ' . line('.') . ',' . l:end . 's/\<' .a:method_name . '\>' . l:param_search . '\(' . l:leftover . '\)/' . 
                                    \ a:method_name . '\1' . l:insert . '\2/e'

                    endif
                else
                    if s:followChain(l:dec,l:funcs,a:method_name) == 1
                        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                        call cursor(l:next)
                        call search('(')
                        normal %
                        let l:end = line('.')
                        let l:leftover = substitute(strpart(getline('.'),col('.')),s:special_chars,'\\\1','g')
                        let l:leftover = strpart(getline('.'),col('.'))
                        call cursor(l:next)
                        execute 'silent ' . line('.') . ',' . l:end . 's/\<' .a:method_name . '\>' . l:param_search . '\(' . l:leftover . '\)/' . 
                                    \ a:method_name . '\1' . l:insert . '\2/e'
                    endif
                endif
                call cursor(l:next)
            endif
        endif
        let l:next = searchpos(l:search,'Wn')
    endwhile

    silent write!
endfunction

" updateParamUsingFiles {{{3
function! s:updateParamUsingFiles(files,class_name,method_name,commas,default,is_static) abort
    for file in a:files
        execute 'silent tabedit! ' . file
        call s:updateParamUsingFile(a:class_name,a:method_name,a:commas,a:default,a:is_static)
        call s:safeClose()
    endfor
    silent edit!
endfunction 

" updateParamReferences {{{3
function! s:updateParamReferences(classes,name,commas,default,is_static)
    let l:temp_file = '.FactorusParam'
    let l:class_names = join(a:classes,'\|')

    call s:findTags(l:temp_file,'\.' . a:name . '(','no')
    call s:narrowTags(l:temp_file,'\(' . l:class_names . '\)')
    let l:files = readfile(l:temp_file)
    call s:updateParamUsingFiles(l:files,l:class_names,a:name,a:commas,a:default,a:is_static)

    call system('rm -rf ' . l:temp_file)
endfunction

" Renaming {{{2

" renameArg {{{3

" Renames the argument of a function to `new_name`. The argument has to be
" under the cursor.
function! s:renameArg(new_name,...) abort
    let l:var = expand('<cword>')
    let g:factorus_history['old'] = l:var
    call s:updateFile(l:var,a:new_name,0,1,0)

    redraw
    echo 'Re-named ' . l:var . ' to ' . a:new_name
    return l:var
endfunction

" renameClass {{{3

" Renames the class of the current file to `new_name`.
function! s:renameClass(new_name) abort
    let l:class_name = expand('%:t:r')
    let g:factorus_history['old'] = l:class_name
    let l:class_tag = s:getClassTag()

    if l:class_name == a:new_name
        throw 'Factorus:Duplicate'
    endif

    let l:old_file = expand('%:p')
    let l:new_file = expand('%:p:h') . '/' . a:new_name . '.java'
    call add(g:factorus_qf,{'filename' : l:new_file, 'lnum' : l:class_tag[0], 'text' : s:trim(join(getline(l:class_tag[0],l:class_tag[1])))})

    let l:package_name = s:getPackage(l:old_file)
    let l:temp_file = '.Factorus' . l:class_name
    call s:getPackageFiles(l:temp_file)

    if l:package_name != ''
        call s:findTags(l:temp_file,l:package_name,'yes')
        call s:narrowTags(l:temp_file,'\<' . l:class_name . '\>')
    endif

    call s:updateQuickFix(l:temp_file,'\<' . l:class_name . '\>')

    call system('cat ' . l:temp_file . ' | xargs sed -i "s/\<' . l:class_name . '\>/' . a:new_name . '/g"') 
    call system('mv ' . l:old_file . ' ' . l:new_file)
    call system('rm -rf ' . l:temp_file)

    let l:bufnr = bufnr('%')
    execute 'silent edit! ' . l:new_file
    execute 'silent! bwipeout ' . l:bufnr

    redraw
    echo 'Re-named class ' . l:class_name . ' to ' . a:new_name
    return l:class_name
endfunction

" renameField {{{3

" Renames the field on the current line to `new_name`.
function! s:renameField(new_name) abort
    let l:search = '^\s*' . s:access_query . '\(' . s:java_identifier . s:collection_identifier . '\=\)\=\s*\(' . s:java_identifier . '\)\s*[;=].*'

    let l:line = getline('.')
    let l:is_static = match(l:line,'\<static\>') >= 0 ? 1 : 0
    let l:is_local = s:getAdjacentTag('b') != s:getClassTag()[0]
    let l:type = substitute(l:line,l:search,'\4','')
    let l:var = substitute(l:line,l:search,'\6','')
    if l:var == '' || l:type == '' || match(l:var,'[^' . s:search_chars . ']') >= 0
        if l:is_local == 1 || match(getline(s:getClassTag()[0]),'\<enum\>') < 0
            throw 'Factorus:Invalid'
        endif
        let l:var = expand('<cword>')
        let l:enum_name = expand('%:t:r')
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent s/\<' . l:var . '\>/' . a:new_name . '/e'
        silent write!

        let l:temp_file = '.FactorusEnum'
        
        echo 'Updating enum...'
        call s:findTags(l:temp_file,l:enum_name . '\.' . l:var,'no')
        call s:updateQuickFix(l:temp_file,l:enum_name . '\.' . l:var)
        call system('cat ' . l:temp_file . ' | xargs sed -i "s/' . l:enum_name . '\.' . l:var . '/' . l:enum_name . '.' . a:new_name . '/g"')
        call system('rm -rf ' . l:temp_file)

        redraw
        echo 'Renamed enum ' . l:var . ' to ' . a:new_name . '.'
        return l:var
    elseif l:var == a:new_name
        throw 'Factorus:Duplicate'
    endif
    let g:factorus_history['old'] = l:var

    let l:file_name = expand('%:p')
    let l:supers = s:getSuperClasses()
    let l:top = len(l:supers) - 1
    let l:var_search = s:no_comment . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+\<' . l:var . '\>\_s*[;=]'
    while l:top >= 1
        if l:supers[l:top] != l:file_name
            execute 'silent tabedit! ' . l:supers[l:top]
            call cursor(1,1)
            if search(l:var_search) != 0
                break
            endif
            call s:safeClose()
        endif
        let l:top -= 1
    endwhile

    if l:is_local == 1
        call s:updateFile(l:var,a:new_name,0,l:is_local,l:is_static)
    else
        if l:is_static == 0
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
            execute 'silent s/\<' . l:var . '\>/' . a:new_name . '/e'
            call s:updateClassFile(l:type,l:var,a:new_name)
        endif

        redraw
        echo 'Updating sub-classes...'
        let l:classes = s:updateSubClassFiles(expand('%:t:r'),l:var,a:new_name,'',l:is_static)

        redraw
        echo 'Updating references...'
        call s:updateReferences(l:classes,l:var,a:new_name,'',l:is_static)
    endif

    if l:top > 0
        call s:safeClose()
    endif

    redraw
    echo 'Re-named ' . l:var . ' to ' . a:new_name
    return l:var
endfunction

" renameMethod {{{3

" Renames the current method to `new_name`. The current method is considered
" to be whatever method the cursor is in, so the user could be within the
" function, not necessarily right on the function.
function! s:renameMethod(new_name) abort
    call s:gotoTag(0)

    let l:method_name = matchstr(getline('.'),'\s\+' . s:java_identifier . '\s*(')
    let l:method_name = matchstr(l:method_name,'[^[:space:](]\+')
    if l:method_name == a:new_name
        throw 'Factorus:Duplicate'
    endif
    let g:factorus_history['old'] = l:method_name

    let l:file_name = expand('%:p')
    let l:supers = s:getSuperClasses()
    let l:top = len(l:supers) - 1
    let l:func_search = s:no_comment . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+\<' . l:method_name . '\>\_s*('
    while l:top >= 1
        if l:supers[l:top] != l:file_name
            execute 'silent tabedit! ' . l:supers[l:top]
            call cursor(1,1)
            if search(l:func_search) != 0
                break
            endif
            call s:safeClose()
        endif
        let l:top -= 1
    endwhile

    let s:all_funcs = {}
    let l:is_static = match(getline('.'),'\s*\<static\>\s*[^)]\+(') >= 0 ? 1 : 0

    redraw
    echo 'Updating hierarchy...'
    let l:classes = s:updateSubClassFiles(expand('%:t:r'),l:method_name,a:new_name,'(',l:is_static)

    redraw
    echo 'Updating references...'
    call s:updateReferences(l:classes,l:method_name,a:new_name,'(',l:is_static)

    if l:top > 0
        call s:safeClose()
    endif

    redraw
    let l:keyword = l:is_static == 1 ? ' static' : ''
    echo 'Re-named' . l:keyword . ' method ' . l:method_name . ' to ' . a:new_name
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
"
" Get all blocks of a function. A block is a segment of code like an if
" statement, loop, etc.
"
" Return value: A sorted array of pairs of the form [start, end], where start and
" end are the start and end of each block.
function! s:getAllBlocks(close)

    " Define all of our search sequences for various blocks.
    let l:if = '\<if\>\_s*(\_[^{;]*)\_s*{\='
    let l:for = '\<for\>\_s*(\(\_[^{;]*;\_[^{;]*;\_[^{;]*\|\_[^{;]*:\_[^{;]*\))\_s*{\='
    let l:while = '\<while\>\_s*(\_[^{;]*)'
    let l:try = '\<try\>\_s*{'
    let l:do = '\<do\>\_s*{'
    let l:switch = '\<switch\>\_s*(\_[^{]*)\_s*{'
    let l:search = '\(' . l:if . '\|' . l:for . '\|' . l:while . '\|' . l:try . '\|' . l:do . '\|' . l:switch . '\)'

    let l:orig = [line('.'),col('.')]
    call s:gotoTag(0)
    let l:blocks = [[line('.'),a:close[0]]]

    let l:open = searchpos('{','Wn')
    let l:next = searchpos(l:search,'Wn')
    while l:next[0] <= a:close[0]
        if l:next == [0,0]
            break
        endif
        call cursor(l:next)

        if match(getline('.'),'\<else\>') >= 0 || match(getline('.'),'}\s*\<while\>') >= 0
            let l:next = searchpos(l:search,'Wn')
            continue
        endif

        if match(getline('.'),'\<\(if\|try\|for\|while\)\>') >= 0
            let l:open = [line('.'),col('.')]
            call search('(')
            normal %

            let l:ret =  searchpos('{','Wn')
            let l:semi = searchpos(';','Wn')

            let l:o = line('.')
            if s:isBefore(l:semi,l:ret) == 1
                call cursor(l:semi)
                call add(l:blocks,[l:open[0],line('.')])
            elseif match(getline('.'),'\<\(if\|try\)\>') >= 0
                call cursor(l:ret)
                normal %

                let l:continue = '}\_s*\(else\_s*\(\<if\>\_[^{]*)\)\=\|\<catch\>\_[^{]*\|\<finally\>\_[^{]*\){'
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
                call cursor(l:prev)
            endif

            call cursor(l:open)
        elseif match(getline('.'),'\<switch\>') >= 0
            let l:open = [line('.'),col('.')]
            call searchpos('{','W')

            normal %
            let l:sclose = [line('.'),col('.')]
            normal %

            let l:continue = '\<\(case\|default\)\>[^:]*:'
            let l:next = searchpos(l:continue,'Wn')

            while s:isBefore(l:next,l:sclose) == 1 && l:next != [0,0]
                call cursor(l:next)
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
            call cursor(l:prev)
        endif

        let l:next = searchpos(l:search,'Wn')
    endwhile

    call cursor(l:orig)
    return uniq(sort(l:blocks,'s:compare'))
endfunction

" getAllRelevantLines {{{3
"
" Gets all relevant lines for each var in vars.
"
" Return value: [lines, isos]. lines is a dictionary 
function! s:getAllRelevantLines(vars,names,close)

    " Get original position and previous tag.
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
            if s:isBefore(l:next[1],l:closes[l:name]) == 1 && l:quoted == 0 && l:ldec > 0
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

        call cursor(l:next[1])
        let l:next = s:getNextUse(l:search,1)
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
            call cursor(l:ref[1])
            let l:ref = s:getNextReference(l:search,'left',1)
        endwhile
    endif

    call cursor(l:orig)
    return l:res
endfunction

" getIsolatedLines {{{3
"
" Gets lines that are 'isolated' relative to var. Isolated means lines that
" can be taken out of the function without affecting the other lines of code.
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
    call s:gotoTag(0)

    let l:tab = substitute(getline('.'),'\(\s*\).*','\1','')
    let l:method_name = substitute(getline('.'),'.*\s\+\(' . s:java_identifier . '\)\s*(.*','\1','')

    " Get the opening and closing lines, and copy those lines of code in case
    " we need to roll back.
    let [l:open,l:close] = [line('.'),s:getClosingBracket(1)]
    let l:old_lines = getline(l:open,l:close[0])

    " Jump to opening bracket of function
    call searchpos('{','W')

    " Get number of lines in method.

    " Get all variables defined in method, not referenced.
    let l:vars = s:getLocalDecs(l:close)
    let l:names = map(deepcopy(l:vars),{n,var -> var[0]})
    let l:decs = map(deepcopy(l:vars),{n,var -> var[2]})
    let l:compact = [l:names,l:decs]

    " Get all blocks of code (if statements, loops, etc.)
    let l:blocks = s:getAllBlocks(l:close)

    let [l:all,l:isos] = s:getAllRelevantLines(l:vars,l:names,l:close)

    return [l:orig, l:tab, l:method_name, l:open, l:close, l:old_lines, l:vars, l:compact, l:blocks, l:all, l:isos]
endfunction

" getBestVar {{{3

" Gets the best variable to extract the method around, according to the
" desired heuristic.
function! s:getBestVar(vars,compact,isos,all,blocks,open,close)
    let l:best_var = ['','',0]
    let l:best_lines = []
    let l:method_length = (a:close - line('.')) * 1.0

    " Go through all declared variables and try to extract 'isolated' lines.
    " Isolated means lines that can be extracted from the function without
    " breaking the rest of the function.
    for var in a:vars
        let l:iso = s:getIsolatedLines(var,a:compact,a:all,a:blocks,a:close)
        let a:isos[var[0]][var[2]] = copy(l:iso)

        let l:ratio = (len(l:iso) / l:method_length)
        if g:factorus_extract_heuristic == 'longest'
            if len(l:iso) > len(l:best_lines) && index(l:iso,a:open) < 0 "&& l:ratio < g:factorus_method_threshold
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
    if index(l:best_lines,l:best_var[2]) < 0 && l:best_var[2] != a:open
        let l:stop = l:best_var[2]
        let l:dec_lines = [l:stop]
        while match(getline(l:stop),';') < 0
            let l:stop += 1
            call add(l:dec_lines,l:stop)
        endwhile

        let l:best_lines = l:dec_lines + l:best_lines
    endif

    return [l:best_var, l:best_lines]
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
    let l:search = '[^.]\<\(' . join(l:names,'\|') . '\)\>'
    let l:search = s:no_comment . '.\{-\}' . l:search . '.*'
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

    let l:dspaces = repeat(a:spaces,2)
    let l:i = 0

    call map(a:body,{n,line -> substitute(line,'\s*\(.*\)','\1','')})
    while l:i < len(a:body)
        if match(a:body[l:i],'}') >= 0
            let l:dspaces = strpart(l:dspaces,len(a:spaces))
        endif
        let a:body[l:i] = l:dspaces . a:body[l:i]

        if match(a:body[l:i],'{') >= 0
            let l:dspaces .= a:spaces
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

    let l:build = s:buildArgs(a:args,0)
    let l:name = a:0 == 0 ? g:factorus_method_name : a:1
    let l:build_string = 'public ' . l:type . ' ' . l:name  . '(' . l:build . ') {'
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

" rollbackEncapsulation {{{3
function! s:rollbackEncapsulation()
        let l:orig = [line('.'),col('.')]
        let [l:var,l:type,l:is_pub] = g:factorus_history['old']
        let l:cap = substitute(l:var,'\(.\)\(.*\)','\U\1\E\2','')

        if l:is_pub == 1
            execute 'silent s/\<private\>/public/e'
        endif
       
        let l:open = search('public ' . l:type . ' get' . l:cap . '() {','n')
        if match(getline(l:open-1),'^\s*$') >= 0
            let l:open -= 1
        endif

        let l:close = s:getClosingBracket(1,[l:open,1])[0]
        if match(getline(l:close+1),'^\s*$') >= 0
            let l:close += 1
        endif
        execute 'silent ' . l:open . ',' . l:close . 'delete'

        let l:open = search('public void set' . l:cap . '(','n')
        let l:close = s:getClosingBracket(1,[l:open,1])[0]
        if match(getline(l:close+1),'^\s*$') >= 0
            let l:close += 1
        endif
        execute 'silent ' . l:open . ',' . l:close . 'delete'
        call cursor(l:orig)
        silent write!
endfunction

" rollbackRename {{{3
function! s:rollbackRename(new_name,type)
    let l:files = {}
    let l:old = g:factorus_history['old']
    let l:new = g:factorus_history['args'][0]

    if a:type == 'Class'
        call s:renameClass(a:new_name)
    else
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
                execute 'silent! s/\<' . l:new . '\>/' . l:old . '/ge'
            endfor
            silent write!
            call s:safeClose()
        endfor
    endif

    return 'Rolled back renaming of ' . substitute(g:factorus_history['args'][-1],'\(.\)\(.*\)','\L\1\E\2','') . ' ' . l:old
endfunction

" rollbackExtraction {{{3
function! s:rollbackExtraction()
    let l:method_name = g:factorus_history['old'][0]
    let l:open = search('public .*' . l:method_name . '(')
    let l:close = s:getClosingBracket(1)[0]

    if match(getline(l:open - 1),'^\s*$') >= 0
        let l:open -= 1
    endif
    if match(getline(l:close + 1),'^\s*$') >= 0
        let l:close += 1
    endif

    execute 'silent ' . l:open . ',' . l:close . 'delete'

    call search('\<' . l:method_name . '\>(')
    call s:gotoTag(0)
    let l:open = line('.')
    let l:close = s:getClosingBracket(1)[0]

    execute 'silent ' . l:open . ',' . l:close . 'delete'
    call append(line('.')-1,g:factorus_history['old'][1])
    call cursor(l:open,1)
    silent write!
endfunction

" Global Functions {{{1

" encapsulateField {{{2

" Encapsulates the field on the current line.
function! java#factorus#encapsulateField(...) abort

    " Check if we're rolling back something, and if so run the rollback
    " function.
    if factorus#isRollback(a:000)
        call s:rollbackEncapsulation() 
        return 'Rolled back encapsulation for ' . g:factorus_history['old'][0]
    endif

    " If we're trying to encapsulate a local variable, don't allow it.
    " TODO: Possibility of a class defined in a class, which current
    " implementation wouldn't allow.
    let l:is_local = s:getClassTag()[0] == s:getAdjacentTag('b') ? 0 : 1
    if l:is_local == 1
        throw 'Factorus:EncapLocal'
    endif


    " Get the current line and the things we need to encapsulate the variable.
    let l:line = getline('.')
    let l:search = '\s*' . s:access_query . '\(' . s:java_identifier . s:collection_identifier . '\=\)\_s*\(' . s:java_identifier . '\)\_s*[;=].*'

    " If the variable is static, don't let them encapsulate it.
    let l:is_static = substitute(l:line,l:search,'\2','')
    if l:is_static == 1
        throw 'Factorus:EncapStatic'
    endif

    " Get type and name of variable, and capitalize variable name for getters
    " and setters.
    let l:type = substitute(l:line,l:search,'\4','')
    let l:var = substitute(l:line,l:search,'\6','')
    let l:cap = a:0 > 0 ? substitute(a:1,'\(.\)\(.*\)','\U\1\E\2','') : substitute(l:var,'\(.\)\(.*\)','\U\1\E\2','')

    " If we're encapsulating a non-private variable, make it private.
    let l:is_pub = 0
    if match(getline('.'),'\<\(public\|protected\)\>') >= 0
        let l:is_pub = 1
        execute 'silent! s/\<public\>/private/e'
    elseif match(getline('.'),'\<private\>') < 0
        execute 'silent! s/^\(\s*\)/\1private /e'
    endif


    " Create our getters and setters for the encapsulated variable.
    let l:get = ["\tpublic " . l:type . " get" . l:cap . "() {" , "\t\treturn " . l:var . ";" , "\t}"]
    let l:set = ["\tpublic void set" . l:cap . "(" . l:type . ' ' . l:var . ") {" , "\t\tthis." . l:var . " = " . l:var . ";" , "\t}"]
    let l:encap = [""] + l:get + [""] + l:set + [""]

    let l:end = s:getClosingBracket(1,s:getClassTag())
    call append(l:end[0] - 1,l:encap)
    call cursor(l:end[0] + 1,1)
    silent write!

    " Let the user know it's done, and return important info for
    " g:factorus_history.
    redraw
    echo 'Created getters and setters for ' . l:var
    return [l:var, l:type, l:is_pub]

endfunction

" addParam {{{2
function! java#factorus#addParam(param_name,param_type,...) abort
    if factorus#isRollback(a:000)
        call s:rollbackAddParam()
        let g:factorus_qf = []
        return 'Removed new parameter ' . a:param_name . '.'
    endif
    let g:factorus_qf = []

    let s:all_funcs = {}
    let [l:orig,l:prev_dir,l:curr_buf] = s:setEnvironment()

    try
        call s:gotoTag(0)
        let l:is_static = (match(getline('.'),'\<static\>') >= 0)
        let l:next = searchpos(')','Wn')
        let [l:type,l:name,l:params] = split(substitute(join(getline(line('.'),l:next[0])),'^.*\<\(' . s:java_identifier . 
                    \ s:collection_identifier . '\=\)\s*\<\(' . s:java_identifier . '\)\>\s*(\(.*\)).*','\1 | \3 | \4',''),'|')
        let [l:type,l:name] = [s:trim(l:type),s:trim(l:name)]
        let g:factorus_history['old'] = [l:name,a:param_name]

        let l:file_name = expand('%:p')
        let l:supers = s:getSuperClasses()
        let l:top = len(l:supers) - 1
        let l:func_search = s:no_comment . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+\<' . l:name . '\>\_s*('
        while l:top >= 1
            if l:supers[l:top] != l:file_name
                execute 'silent tabedit! ' . l:supers[l:top]
                call cursor(1,1)
                if search(l:func_search) != 0
                    break
                endif
                call s:safeClose()
            endif
            let l:top -= 1
        endwhile

        let l:count = 0
        while 1 == 1
            let l:cut_params = substitute(l:params,'\(' . s:java_identifier . s:collection_identifier . '\=\s*\<' . s:java_identifier . '\>\)\(.*\)','\3','')
            if l:cut_params == l:params
                break
            endif
            let l:count += 1
            let l:params = l:cut_params
        endwhile
        let l:com = l:count > 0 ? ', ' : ''

        let l:next = searchpos(')','Wn')
        let l:line = substitute(getline(l:next[0]), ')', l:com . a:param_type . ' ' . a:param_name . ')', '')
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent ' .  l:next[0] . 'd'
        call append(l:next[0] - 1,l:line)
        silent write!

        if g:factorus_add_default == 1
            let l:default = a:0 > 0 ? a:1 : 'null'

            redraw
            echo 'Updating hierarchy...'
            let l:classes = s:updateParamSubClassFiles(l:name,l:count,l:default,a:param_name,a:param_type,l:is_static)

            redraw
            echo 'Updating references...'
            call s:updateParamReferences(l:classes,l:name,l:count,l:default,l:is_static)

        endif
        redraw
        echo 'Added parameter ' . a:param_name . ' to method ' . l:name . '.'

        if l:top > 0
            call s:safeClose()
        endif

        if g:factorus_show_changes > 0
            call s:setChanges(l:name,'addParam')
        endif

        call s:resetEnvironment(l:orig,l:prev_dir,l:curr_buf,'addParam')

        return [l:name,a:param_name,l:count+1]
    catch /.*/
        call s:resetEnvironment(l:orig,l:prev_dir,l:curr_buf,'addParam')
        let l:err = match(v:exception,'^Factorus:') >= 0 ? v:exception : 'Factorus:' . v:exception
        throw l:err . ', at ' . v:throwpoint
    endtry
endfunction

" renameSomething {{{2
function! java#factorus#renameSomething(new_name,type,...)
    let [l:orig,l:prev_dir,l:curr_buf] = s:setEnvironment()

    let l:res = ''
    try
        if factorus#isRollback(a:000)
            let l:res = s:rollbackRename(a:new_name,a:type)
            let g:factorus_qf = []
        else
            let g:factorus_qf = []
            let Rename = function('s:rename' . a:type)
            let l:res = Rename(a:new_name)

            if g:factorus_show_changes > 0
                call s:setChanges(l:res,'rename',a:type)
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
"
" Extracts sub-method from current method by finding 'blocks' of code that are
" isolated from the rest of the method. Not guaranteed to be useful, but can
" sometimes speed up the refactoring process.
function! java#factorus#extractMethod(...)

    " If the command is to roll back previous extraction, do so.
    if factorus#isRollback(a:000)
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif

    " If the user selected a range of lines, use manualExtract instead.
    if a:1 != 1 || a:2 != line('$')
        return s:manualExtract(a:000)
    endif

    echo 'Extracting new method...'

    let [l:orig, l:tab, l:method_name, l:open, l:close, l:old_lines, l:vars, l:compact, l:blocks, l:all, l:isos] = s:initExtraction()

    redraw
    echo 'Finding best lines...'

    let [l:best_var, l:best_lines] = s:getBestVar()

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

    call search('public.*\<' . g:factorus_method_name . '\>(')
    silent write!
    redraw
    echo 'Extracted ' . len(l:best_lines) . ' lines from ' . l:method_name
    return [l:method_name,l:old_lines]
endfunction

" manualExtract {{{2

" Manually extracts the code selected by cursor.
function! s:manualExtract(args)
    if factorus#isRollback(a:args)
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif

    let l:name = len(a:args) <= 2 ? g:factorus_method_name : a:args[2]

    echo 'Extracting new method...'
    call s:gotoTag(0)
    let l:tab = substitute(getline('.'),'\(\s*\).*','\1','')
    let l:method_name = substitute(getline('.'),'.*\s\+\(' . s:java_identifier . '\)\s*(.*','\1','')

    let l:extract_lines = range(a:args[0],a:args[1])
    let l:old_lines = getline(l:open,l:close[0])

    let [l:orig, l:tab, l:method_name, l:open, l:close, l:old_lines, l:vars, l:compact, l:blocks, l:all, l:isos] = s:initExtraction()

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

    call search('public.*\<' . l:name . '\>(')
    silent write!
    redraw
    echo 'Extracted ' . len(l:extract_lines) . ' lines from ' . l:method_name

    return [l:name,l:old_lines]
endfunction
