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

function! s:setChanges(res,func,...)
    let a:qf = copy(g:factorus_qf)
    let a:type = a:func == 'rename' ? a:1 : ''

    let a:ch = len(g:factorus_qf)
    let a:ch_i = a:ch == 1 ? ' instance ' : ' instances '
    let a:un = s:getUnchanged('\<' . a:res . '\>')
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

    let a:has_keyword = match(getline(a:line),s:java_keywords)
    if a:has_keyword >= 0 && s:isQuoted(s:java_keywords,getline(a:line)) == 0
        return 0
    endif

    if match(getline(a:line-1),'\<new\>.*{') >= 0
        return 0   
    endif

    return 1
endfunction

" getAdjacentTag {{{3
function! s:getAdjacentTag(dir)
    let [a:oline,a:ocol] = [line('.'),col('.')]
    let [a:line,a:col] = [line('.') + 1,col('.')]
    call cursor(a:line,a:col)

    let a:func = searchpos(s:tag_query,'Wn' . a:dir)
    let a:is_valid = 0
    while a:func != [0,0]
        let a:is_valid = s:isValidTag(a:func[0])
        if a:is_valid == 1
            break
        endif

        call cursor(a:func[0],a:func[1])
        let [a:line,a:col] = [line('.'),col('.')]
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

" getClassTag {{{3
function! s:getClassTag()
    let [a:line,a:col] = [line('.'),col('.')]
    call cursor(1,1)
    let a:class_tag = search(s:tag_query,'n')
    let a:tag_end = search(s:tag_query,'ne')
    call cursor(a:line,a:col)
    return [a:class_tag,a:tag_end]
endfunction

" gotoTag {{{3
function! s:gotoTag(head)
    let a:tag = a:head == 1 ? s:getClassTag()[0] : s:getAdjacentTag('b') 
    if a:tag != 0
        call cursor(a:tag,1)
    elseif a:head == 1
        call cursor(1,1)
    else
        echo 'No tag found'
    endif
endfunction

" Class Hierarchy {{{2
" getPackage {{{3
function! s:getPackage(file)
    let a:i = 1
    let a:head = system('head -n ' . a:i . ' ' . a:file)
    while match(a:head,'^package') < 0
        let a:i += 1
        if a:i > 100
            return 'NONE'
        endif
        let a:head = system('head -n ' . a:i . ' ' . a:file . ' | tail -n 1')
    endwhile

    let a:head = substitute(a:head,'^\s*package\s*\(.*\);.*','\1','')
    let a:head = substitute(a:head,'\.','\\.','g')
    return a:head
endfunction

function! s:getPackageClasses(class_name,package_name)
    let a:temp_file = '.FactorusPackage'
    call system('find ' . getcwd() . ' -name "' . a:class_name . '.java" -exec grep -l "\<' . a:package_name . '\>" {} + > ' . a:temp_file)
    let a:res = readfile(a:temp_file)
    call system('rm -rf ' . a:temp_file)
    return a:res
endfunction

" getSubClasses {{{3
function! s:getSubClasses(class_name)
    let a:temp_file = '.Factorus' . a:class_name . 'E'
    call system('> ' . a:temp_file)

    let a:sub = [expand('%:p')]
    let a:subc = [expand('%:t:r')]
    let a:all = [expand('%:p')]

    while a:sub != []
        let a:sub_classes = '\<\(' . join(a:subc) . '\)\>'
        let a:exclude = '[^\;}()=+\-\*/|&~!''\"]*'
        let a:fsearch = '^' . a:exclude . a:sub_classes . a:exclude . '$'
        let a:search = '^.\{-\}' . s:class . '\_[^{;]\{-\}' . s:sub_class . '\_[^;{]\{-\}' . a:sub_classes . '\_[^;{]\{-\}{'
        call s:findTags(a:temp_file,a:fsearch,'no')

        let a:sub = []
        for file in readfile(a:temp_file)
            if index(a:all,file) < 0
                execute 'silent tabedit! ' . file
                call cursor(1,1)
                let a:found = search(a:search,'W')
                if a:found > 0
                    call add(a:sub,file)
                    let a:new_sub = expand('%:t:r')
                    if a:found != s:getClassTag()[0]
                        let a:new_sub .= '\.' . substitute(getline('.'),'^.\{-\}' . s:class . '\s*\<\(' . s:java_identifier . '\)\>.*','\2','')
                    endif
                    call add(a:subc,a:new_sub)
                endif
                call s:safeClose()
            endif
        endfor
        let a:all += a:sub
    endwhile

    call system('rm -rf ' . a:temp_file)
    return [a:all,a:subc]
endfunction

" getSuperClasses {{{3
function! s:getSuperClasses()
    let a:class_tag = s:getClassTag()
    let a:class_name = expand('%:t:r')
    let a:super_search = '.*' . s:class . '\_s\+\<' . a:class_name . '\>[^{]\_[^{]\{-\}' . s:sub_class . '\_s\+\<\(' . s:java_identifier . '\)\>\_[^{]*{.*'
    let a:sups = [expand('%:p')]

    let a:class_line = join(getline(a:class_tag[0],a:class_tag[1]))
    let a:class_line = substitute(a:class_line,',',' ','g')
    let a:inherits = []

    while match(a:class_line,a:super_search) >= 0
        let a:super = substitute(a:class_line,a:super_search,'\3','')
        if s:isWrapped(a:super,a:class_line) == 1
            let a:class_line = substitute(a:class_line,s:sub_class,'','')
        elseif match(a:super,s:sub_class) < 0
            call add(a:inherits,a:super)
        endif
        let a:class_line = substitute(a:class_line,a:super,'','')
    endwhile

    if a:inherits == []
        return a:sups
    endif

    let a:names = join(map(a:inherits,{n,val -> ' -name "' . val . '.java"'}),' -or')
    let a:search = 'find ' . getcwd() . a:names
    let a:possibles = system(a:search)
    let a:possibles = split(a:possibles,'\n')
    for poss in a:possibles
        execute 'silent tabedit! ' . poss
        let a:sups += s:getSuperClasses()
        call s:safeClose()
    endfor

    return a:sups
endfunction

" Declarations {{{2
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
    call s:gotoTag(0)
    let a:oparen = search('(','Wn')
    let a:cparen = search(')','Wn')
    
    let a:dec = join(getline(a:oparen,a:cparen))
    let a:dec = substitute(a:dec,'.*(\(.*\)).*','\1','')
    if a:dec == ''
        return []
    endif
    let a:car = 0
    let a:args = []
    let a:i = 0
    let a:prev = 0
    while a:i < len(a:dec)
        let char = a:dec[a:i]
        if char == ',' && a:car == 0
            call add(a:args,strpart(a:dec,a:prev,(a:i - a:prev)))
            let a:prev = a:i + 1
        elseif char == '>'
            let a:car -= 1
        elseif char == '<'
            let a:car += 1
        endif
        let a:i += 1
    endwhile
    call add(a:args,strpart(a:dec,a:prev,len(a:dec)-a:prev))
    call map(a:args, {n,arg -> [split(arg)[-1],join(split(arg)[:-2]),line('.')]})

    call cursor(a:prev[0],a:prev[1])
    return a:args
endfunction

" getNextDec {{{3
function! s:getNextDec()
    let a:get_variable = '^\s*\(' . s:access_query . '\|for\s*(\)\s*\(' . s:java_identifier . 
                \ s:collection_identifier . '\=\)\s\+\(\<' . s:java_identifier . '\>[^:=;]*\)[;=:].*'
    
    let a:alt_get = '^\s*' . s:access_query . '\s*\(' . s:java_identifier . 
                \ s:collection_identifier . '\=\)\s\+\(\<' . s:java_identifier . '\>[^=;]*\)[=;].*'

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
            let a:fline = split(substitute(getline(a:match[0]),a:get_variable,'\7',''),',')
        else
            let a:var = substitute(getline(a:match[0]),a:alt_get,'\4','')
            let a:fline = split(substitute(getline(a:match[0]),a:alt_get,'\6',''),',')
        endif
        call map(a:fline,{n,var -> s:trim(var)})
        call map(a:fline,{n,var -> substitute(var,'^\<\(' . s:java_identifier . '\)\>.*','\1','')})

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
    let a:access = '\<\(void\|public\|private\|protected\|static\|abstract\|final\|synchronized\)\>'
    let a:query = '^\s*' . s:access_query . '\s*\(' .  s:java_identifier . s:collection_identifier . '\=\)\_s\+\(' . s:java_identifier . '\)\_s*\([;=(]\).*'
    let a:decs = {'types' : [], 'names' : []}
    try
        let a:class_tag = s:getClassTag()
        let a:close = s:getClosingBracket(1,[a:class_tag[0],1])
        execute 'silent vimgrep /' . a:query . '/j %:p'
        let a:greps = getqflist()

        for g in a:greps
            let a:fname = substitute(g['text'],a:query,'\4|\6\7','')
            if match(a:fname,s:java_keywords) >= 0 || match(a:fname,a:access) >= 0
                continue
            endif

            if a:fname[len(a:fname)-1] == '('
                let [a:type,a:name] = split(a:fname,'|')
            else
                call cursor(g['lnum'],g['col'])
                if searchpair('{','','}','Wnb') == a:class_tag[0]
                    let [a:type,a:name] = split(a:fname[:-2],'|')
                else
                    continue
                endif
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

    let a:hier = s:getSuperClasses()

    let a:defs = {'types' : [], 'names' : []}
    for class in a:hier
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

    if len(a:funcs) > 1
        let old = a:funcs[0]
        call remove(a:funcs,0)
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
    let a:search = s:no_comment . s:access_query . '\(' . s:java_identifier . s:collection_identifier . '\=\)\_s\+\<' . a:func . '\(\<\|\>\|)\|\s\).*'
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
    let a:search = s:no_comment  . '.\{-\}\(' . s:access_query . '\|for\s*(\)\s*\(' . s:java_identifier .
                \ s:collection_identifier . '\=\)\s\+\<' . a:var . '\>.*'
    let a:jump = '\<' . a:var . '\>'

    let a:pos = search(a:search,'Wb')
    call search(a:jump)
    let a:res = substitute(getline(a:pos),a:search,'\5','')
    while s:isQuoted(a:res,getline(a:pos)) == 1 || s:isCommented() == 1 || match(a:res,s:java_keywords) >= 0
        if a:pos == 0
            return ''
        endif
        call cursor(a:pos-1,a:pos)
        let a:pos = search(a:search,'Wb')
        call search(a:jump)
        let a:res = substitute(getline(a:pos),a:search,'\5','')
    endwhile

    call cursor(a:orig[0],a:orig[1])
    return a:res
endfunction

" getClassVarDec {{{3
function! s:getClassVarDec(var)
    let a:orig = [line('.'),col('.')]
    call s:gotoTag(1)
    let a:search = '.*\<\(' . s:java_identifier . s:collection_identifier . '\=\)\_s\+\<' . a:var . '\>.*'
    let a:find = search(a:search,'Wn')
    let a:res = substitute(getline(a:find),a:search,'\1','') 
    call cursor(a:orig[0],a:orig[1])
    return a:res
endfunction

" getUsingVar {{{3
function! s:getUsingVar()
    let a:orig = [line('.'),col('.')]

    while 1 == 1
        let a:adj = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')
        if a:adj == ')'
            call cursor(line('.'),col('.')-1)
            normal %
            if searchpos('\.','bn') == searchpos('[^[:space:]]\_\s*\<' . s:java_identifier . '\>','bn')
                call search('\.','b')
            else
                let a:end = col('.')
                call search('\<' . s:java_identifier . '\>','b')
                let a:begin = col('.') - 1
                let a:var = strpart(getline('.'),a:begin,a:end - a:begin)
                let a:dec = s:getFuncDec(a:var)
                break
            endif
        else
            let a:end = col('.') - 1
            call search('\<' . s:java_identifier . '\>','b')
            let a:dot = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')
            if a:dot != '.'
                let a:begin = col('.') - 1
                let a:var = strpart(getline('.'),a:begin,a:end - a:begin)
                let a:dec = s:getVarDec(a:var)
                break
            else
                let a:this = searchpos('\<this\>\.','Wbne')
                if a:this[1] == col('.') - 1
                    let a:begin = col('.') - 1
                    let a:var = strpart(getline('.'),a:begin,a:end - a:begin)
                    let a:dec = s:getClassVarDec(a:var)
                    break
                endif
            endif
            call search('\.','b')
        endif 
    endwhile

    let a:funcs = []
    let a:search = '\.\<' . s:java_identifier . '\>[([]\='
    let a:next = searchpos(a:search,'Wn')
    let a:next_end = searchpos(a:search,'Wnez')
    while s:isBefore(a:next,a:orig) == 1
        call cursor(a:next[0],a:next[1])
        call add(a:funcs,[strpart(getline('.'),a:next[1], a:next_end[1] - a:next[1])])
        if matchstr(getline('.'), '\%' . a:next_end[1] . 'c.') == '('
            call search('(')
            normal %
        elseif matchstr(getline('.'), '\%' . a:next_end[1] . 'c.') == '['
            call search('[')
            normal %
        endif
        let a:next = searchpos(a:search,'Wn')
        let a:next_end = searchpos(a:search,'Wnez')
    endwhile
    call cursor(a:orig[0],a:orig[1])

    let a:dec = s:getStructVars(a:var,a:dec,a:funcs)
    return [a:var,a:dec,a:funcs]
endfunction

" followChain {{{3
function! s:followChain(classes,funcs,new_method)
    let a:chain_file = '.Factorus' . a:new_method . 'Chain'
    let a:names_list = []
    for class in a:classes
        call add(a:names_list,' -name "' . class . '.java" ') 
    endfor
    let a:names = join(a:names_list,'-or')
    call system('find ' . getcwd() . a:names . '> ' . a:chain_file)
    
    let a:vars = copy(a:classes)
    let a:chain_files = readfile(a:chain_file)
    while len(a:funcs) > 0
        let func = '\(' . join(a:funcs[0],'\|') . '\)'
        let a:temp_list = []
        for file in a:chain_files
            let a:next = ''
            execute 'silent tabedit! ' . file
            call cursor(1,1)
            let a:search = s:no_comment . s:access_query . '\(' . s:java_identifier . s:collection_identifier . '\=\)\_s\+\<' . func . '\(\<\|\>\|)\|\s\).*'
            let a:find =  search(a:search)
            if a:find > 0
                call cursor(line('.'),1)
                let a:next = substitute(getline('.'),a:search,'\4','')
            else
                let a:all_funcs = s:getAllFunctions()
                let a:ind = match(a:all_funcs['names'],func)
                if a:ind >= 0
                    let a:next = a:all_funcs['types'][a:ind]
                endif
            endif

            if a:next != ''
                let a:vars = s:getStructVars(func,a:next,a:funcs)
            endif
            let a:next_list = []
            for var in a:vars
                call add(a:next_list,' -name "' . var . '.java" ') 
            endfor
            let a:nexts = join(a:next_list,'-or')

            call system('find ' . getcwd() . a:nexts . '> ' . a:chain_file)
            let a:temp_list += readfile(a:chain_file)

            call s:safeClose()
        endfor
        let a:chain_files = copy(a:temp_list)
        if len(a:funcs) > 0
            call remove(a:funcs,0)
        endif
    endwhile

    let a:res = 0
    for file in a:chain_files
        execute 'silent tabedit! ' . file
        let a:search = s:no_comment . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+\<' . a:new_method . '\>\_s*('
        let a:find =  search(a:search)
        call s:safeClose()

        if a:find > 0
            let a:res = 1
            break
        endif
    endfor
    call system('rm -rf ' . a:chain_file)

    return a:res
endfunction

" References {{{2
" getNextReference {{{3
function! s:getNextReference(var,type,...)
    if a:type == 'right'
        let a:search = s:no_comment . s:access_query . '\s*\(' . s:java_identifier . s:collection_identifier . 
                    \ '\=\s\)\=\s*\(' . s:java_identifier . '\)\s*[(.=]\_[^{;]*\<\(' . a:var . '\)\>\_.\{-\};$'
        let a:index = '\6'
        let a:alt_index = '\7'
    elseif a:type == 'left'
        let a:search = s:no_comment . '\(.\{-\}\[[^]]\{-\}\<\(' . a:var . '\)\>.\{-\}]\|\<\(' . a:var . '\)\>\)\s*\(++\_s*;\|--\_s*;\|[-\^|&~+*/]\=[.=][^=]\).*'
        let a:index = '\1'
        let a:alt_index = '\1'
    elseif a:type == 'cond'
        let a:search = s:no_comment . '\<\(\(switch\|while\|if\|else\s\+if\)\>\_s*(\_[^{;]*\<\(' . a:var . '\)\>\_[^{;]*).*\|' .
                    \ '\<\(for\)\>\_s*(\_[^{]*\<\(' . a:var . '\)\>\_[^{]*).*\)'
        let a:index = '\2'
        let a:alt_index = '\3'
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

            if match(getline(a:line[0]),'\<\(new\|true\|false\)\>') >= 0 
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
        if a:type == 'cond'
            let a:for = match(a:state,'\<for\>')
            let a:c = match(a:state,'\<\(switch\|while\|if\|else\s\+if\)\>')
            if a:c == -1 || (a:for != -1 && a:for < a:c)
                let a:index = '\4'
                let a:alt_index = '\5'
            endif
        endif
        let a:loc = substitute(a:state,a:search,a:index,'')
        if a:type == 'left'
            let a:loc = substitute(a:loc,'.*\<\(' . a:var . '\)\>.*','\1','')
        endif
        if a:0 > 0 && a:1 == 1
            let a:name = substitute(a:state,a:search,a:alt_index,'')
            if a:type == 'left'
                let a:name = a:loc
            endif
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
function! s:updateFile(old_name,new_name,is_method,is_local,is_static)
    let a:orig = [line('.'),col('.')]

    if a:is_local == 1
        let a:query = '\([^.]\)\<' . a:old_name . '\>'
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent s/' . a:query . '/\1' . a:new_name . '/g'

        call s:gotoTag(0)
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
            execute 'silent lvimgrep /\(\<super\>\.\|\<this\>\.\|[^.]\)\<' . a:old_name . '\>' . a:paren . '/j %:p'
            let g:factorus_qf += map(getloclist(0),{n,val -> {'filename' : expand('%:p'), 'lnum' : val['lnum'], 'text' : s:trim(val['text'])}})
        catch /.*/
        endtry
        call setloclist(0,[])

        execute 'silent %s/\(\<super\>\.\|\<this\>\.\|[^.]\)\<' . a:old_name . '\>' . a:paren . '/\1' . a:new_name . a:paren . '/ge'
    endif

    call cursor(a:orig[0],a:orig[1])
    silent write!
endfunction

" updateClassFile {{{3
function! s:updateClassFile(class_name,old_name,new_name) abort
    let a:prev = [line('.'),col('.')]
    call cursor(1,1)
    let a:restricted = 0
    let a:here = line('.')

    let a:search = ['\([^.]\|\<this\>\.\)\<\(' . a:old_name . '\)\>' , '\(\<this\>\.\)\<\(' . a:old_name . '\)\>']

    let [a:dec,a:next] = s:getNextArg(a:class_name,a:old_name)
    if a:next[0] == 0
        let a:next = line('$')
    endif

    let a:rep = searchpos(a:search[a:restricted],'Wn')
    while a:rep != [0,0]

        if a:rep[0] >= a:next[0]
            call cursor(a:next[0],1)
            let a:restricted = 1 - a:restricted
            if a:restricted == 1
                let a:next = s:getNextTag()
            else
                let [a:dec,a:next] = s:getNextArg(a:class_name,a:old_name)
                if a:next[0] == 0
                    let a:next = [line('$'),1]
                endif
            endif
        else
            call cursor(a:rep[0],1)
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
            execute 'silent s/' . a:search[a:restricted] . '/\1' . a:new_name . '/g'
        endif

        let a:here = line('.')
        let a:rep = searchpos(a:search[a:restricted],'Wn')
        if a:rep == [0,0]
            call cursor(a:next[0],1)
            let a:rep = searchpos(a:search[1-a:restricted],'Wn')
        endif

    endwhile
    call cursor(a:prev[0],a:prev[1])

    silent write!
endfunction

" updateDeclaration {{{3
function! s:updateDeclaration(method_name,new_name)
    let a:orig = [line('.'),col('.')]
    call cursor(1,1)

    let a:prev = [line('.'),col('.')]
    let a:next = searchpos('^\s*' . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+' . a:method_name . '\_s*(','Wn')

    while a:next[0] != a:prev[0] && a:next[0] != 0
        call cursor(a:next[0],a:next[1])

        if s:isValidTag(a:next[0])
            let a:prev = [line('.'),col('.')]
            let a:next = s:getNextTag()
            let a:match = match(getline('.'),'\<' . a:method_name . '\>')
            if a:match >= 0
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                execute 'silent s/\<' . a:method_name . '\>/' . a:new_name . '/e'
            endif
        endif

        let a:prev = [line('.'),col('.')]
        let a:next = searchpos('^\s*' . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+' . a:method_name . '\_s*(','Wn')
    endwhile
    silent write!

    call cursor(a:orig[0],a:orig[1])
endfunction

" updateSubClassFiles {{{3
function! s:updateSubClassFiles(class_name,old_name,new_name,paren,is_static)
"    let a:pc = s:getPackageClasses(a:class_name,s:getPackage(expand('%:p')))
    let [a:sub_files,a:sub_classes] = s:getSubClasses(a:class_name)
    let a:is_method = a:paren == '(' ? 1 : 0
"    let a:sub_classes = map(copy(a:sub_files),{n,val -> substitute(substitute(val,s:strip_dir,'\2',''),'\.java','','')})

    try
        execute 'silent lvimgrep /\(\<super\>\.\|\<this\>\.\|[^.]\)\<' . a:old_name . '\>' . a:paren . '/j ' . join(a:sub_files)
    catch /.*/
        return [a:class_name]
    endtry

    let a:use_subs = map(getloclist(0),{key,val -> getbufinfo(val['bufnr'])[0]['name']})
    for file in a:use_subs
        execute 'silent tabedit! ' . file
        call cursor(1,1)
        if a:is_static == 1 || a:paren == '('
            if a:paren == '('
                call s:updateDeclaration(a:old_name,a:new_name)
            endif

            call s:updateFile(a:old_name,a:new_name,a:is_method,0,a:is_static)
        else
            call s:updateClassFile(expand('%:t:r'),a:old_name,a:new_name)
        endif

        call s:safeClose()
    endfor
    silent edit!

    call add(a:sub_classes,a:class_name)
    return a:sub_classes
endfunction

" updateMethodFile {{{3
function! s:updateMethodFile(class_name,method_name,new_name,paren) abort
    call s:gotoTag(1)
    call cursor(line('.')+1,1)
    let a:here = [line('.'),col('.')]
    let a:classes = '\<\(' . a:class_name . '\)\>'
    let a:search = '\.' . a:method_name . a:paren

    let a:next = searchpos(a:search,'Wn')
    while a:next != [0,0]
        call cursor(a:next[0],a:next[1])
        let [a:var,a:dec,a:funcs] = s:getUsingVar()
        if len(a:funcs) == 0 
            let a:dec = join(a:dec,'|')
            if match(a:dec,a:classes) >= 0
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                execute 'silent s/\<' .a:method_name . '\>' . a:paren . '/' . a:new_name . a:paren . '/e'
            endif
        else
            if s:followChain(a:dec,a:funcs,a:new_name) == 1
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                execute 'silent s/\<' . a:method_name . '\>' . a:paren . '/' . a:new_name . a:paren . '/e'
            endif
        endif
        let a:next = searchpos(a:search,'Wn')
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
    let a:temp_file = '.Factorus' . a:new_name . 'References'
    let a:class_names = join(a:classes,'\|')
    if a:is_static == 1
        let a:search = '\<\(' . a:class_names . '\)\>\.\<' . a:old_name . '\>' . a:paren
        call s:findTags(a:temp_file,a:search,'no')
        call s:updateQuickFix(a:temp_file,a:search)
        call system('cat ' . a:temp_file . ' | xargs sed -i "s/' . a:search . '/\1\.' . a:new_name . a:paren . '/g"')  
    else
        call s:findTags(a:temp_file,'\.' . a:old_name . a:paren,'no')
        call s:narrowTags(a:temp_file,'\(' . a:class_names . '\)')
        let a:files = readfile(a:temp_file)
        call s:updateMethodFiles(a:files,a:class_names,a:old_name,a:new_name,a:paren)
    endif
    call system('rm -rf ' . a:temp_file)
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
function! s:updateParamFile(method_name,commas,default,is_static)
    let a:orig = [line('.'),col('.')]
    let a:rep = a:is_static ? ['\2','\3'] : ['\1','\2']
    let a:meth = a:is_static ? '\1.' . substitute(a:method_name,'.*)\\>\\\.\(.*\)','\1','') : a:method_name
    call cursor(1,1)

    let [a:param_search,a:insert] = ['',a:default . ')']
    if a:commas > 0
        let a:insert = ', ' . a:insert
        let a:param_search = '\_[^;]\{-\}'
        let a:param_search .= repeat(',' . '\_[^;]\{-\}',a:commas - 1)
    endif
    let a:param_search = '\((' . a:param_search . '\))'

    let a:func_search = a:is_static ? '\<' . a:method_name . '\>(' : '\(\<super\>\.\|\<this\>\.\|[^.]\)\<' . a:method_name . '\>('
    let a:next = searchpos(a:func_search,'Wn')
    while a:next != [0,0]
        call cursor(a:next[0],a:next[1]+1)
        if a:next[0] != s:getAdjacentTag('b') && s:getArgs() == a:commas
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
            call search('(')
            normal %
            let a:end = line('.')
            let a:leftover = substitute(strpart(getline('.'),col('.')),s:special_chars,'\\\1','g')
            call cursor(a:next[0],a:next[1])
            execute 'silent ' . line('.') . ',' . a:end . 's/\<' . a:method_name . '\>' . a:param_search . '\(' . a:leftover . '\)/' . 
                        \ a:meth . a:rep[0] . a:insert . a:rep[1] . '/e'
            call cursor(a:next[0],a:next[1])
        endif
        let a:next = searchpos(a:func_search,'Wn')
    endwhile

    call cursor(a:orig[0],a:orig[1])
    silent write!
endfunction

" updateParamDeclaration {{{3
function! s:updateParamDeclaration(method_name,commas,param_name,param_type)
    let a:orig = [line('.'),col('.')]
    call cursor(1,1)

    let [a:param_search,a:insert] = ['',a:param_type . ' ' . a:param_name . ')']
    if a:commas > 0
        let a:insert = ', ' . a:insert
        let a:param_search = '\_[^;]\{-\}'
        let a:param_search .= repeat(',' . '\_[^;]\{-\}',a:commas - 1)
    endif
    let a:param_search = '\((' . a:param_search . '\))'

    let a:search = '^\s*' . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+' . a:method_name . '\_s*('
    let a:next = searchpos(a:search,'Wn')

    while a:next[0] != 0
        call cursor(a:next[0],a:next[1])

        if s:isValidTag(a:next[0]) && s:getArgs() == a:commas
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
            call search('(')
            normal %
            let a:end = line('.')
            let a:leftover = substitute(strpart(getline('.'),col('.')),s:special_chars,'\\\1','g')
            call cursor(a:next[0],a:next[1])
            execute 'silent ' . line('.') . ',' . a:end . 's/\<' . a:method_name . '\>' . a:param_search . '\(' . a:leftover . '\)/' . 
                        \ a:method_name . '\1' . a:insert . '\2/e'
            call cursor(a:next[0],a:next[1])
        endif

        let a:next = searchpos(a:search,'Wn')
    endwhile
    silent write!

    call cursor(a:orig[0],a:orig[1])
endfunction

" updateParamSubClassFiles {{{3
function! s:updateParamSubClassFiles(old_name,commas,default,param_name,param_type,is_static)
    let a:class_name = expand('%:t:r')
"    let a:pc = s:getPackageClasses(a:class_name,s:getPackage(expand('%:p')))
    let [a:sub_files,a:sub_classes] = s:getSubClasses(a:class_name)
"    let a:sub_classes = map(copy(a:sub_files),{n,val -> substitute(substitute(val,s:strip_dir,'\2',''),'\.java','','')})

    try
        execute 'silent lvimgrep /\(\<super\>\.\|\<this\>\.\|[^.]\)\<' . a:old_name . '\>(' . '/j ' . join(a:sub_files)
    catch /.*/
        return [a:class_name]
    endtry

    let a:rep_name = a:is_static == 0 ? a:old_name : '\(' . join(copy(a:sub_classes),'\|') . '\)\>\.' . a:old_name
    let a:use_subs = map(getloclist(0),{key,val -> getbufinfo(val['bufnr'])[0]['name']})
    for file in a:use_subs
        execute 'silent tabedit! ' . file
        call cursor(1,1)
        call s:updateParamFile(a:rep_name,a:commas,a:default,a:is_static)
        if a:is_static == 0
            call s:updateParamDeclaration(a:rep_name,a:commas,a:param_name,a:param_type)
        endif
        call s:safeClose()
    endfor
    silent edit!

    call add(a:sub_classes,a:class_name)
    return a:sub_classes
endfunction

" updateParamUsingFile {{{3
function! s:updateParamUsingFile(class_name,method_name,commas,default,is_static) abort
    call s:gotoTag(1)
    call cursor(line('.')+1,1)
    let a:here = [line('.'),col('.')]
    let a:classes = '\<\(' . a:class_name . '\)\>'
    let a:search = a:is_static ? a:classes . '\.' . a:method_name . '(' : '\.' . a:method_name . '('

    let a:next = searchpos(a:search,'Wn')
    let [a:param_search,a:insert] = ['',a:default . ')']
    if a:commas > 0
        let a:insert = ', ' . a:insert
        let a:param_search = '\_[^;]\{-\}'
        let a:param_search .= repeat(',' . '\_[^;]\{-\}',a:commas - 1)
    endif
    let a:param_search = '\((' . a:param_search . '\))'
    while a:next != [0,0]
        call cursor(a:next[0],a:next[1])
        if s:getArgs() == a:commas
            if a:is_static
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                call search('(')
                normal %
                let a:end = line('.')
                let a:leftover = substitute(strpart(getline('.'),col('.')),s:special_chars,'\\\1','g')
                let a:leftover = strpart(getline('.'),col('.'))
                call cursor(a:next[0],a:next[1])
                let a:meth = a:classes . '\.\<' . a:method_name . '\>' . a:param_search . '\(' . a:leftover . '\)'
                execute 'silent ' . line('.') . ',' . a:end . 's/' . a:meth . '/\1.' . a:method_name . '\2' . a:insert . '\3/e'
            else
                let [a:var,a:dec,a:funcs] = s:getUsingVar()
                if len(a:funcs) == 0 
                    let a:dec = join(a:dec,'|')
                    if match(a:dec,a:classes) >= 0
                        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                        call search('(')
                        normal %
                        let a:end = line('.')
                        let a:leftover = substitute(strpart(getline('.'),col('.')),s:special_chars,'\\\1','g')
                        let a:leftover = strpart(getline('.'),col('.'))
                        call cursor(a:next[0],a:next[1])
                        execute 'silent ' . line('.') . ',' . a:end . 's/\<' .a:method_name . '\>' . a:param_search . '\(' . a:leftover . '\)/' . 
                                    \ a:method_name . '\1' . a:insert . '\2/e'

                    endif
                else
                    if s:followChain(a:dec,a:funcs,a:method_name) == 1
                        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
                        call cursor(a:next[0],a:next[1])
                        call search('(')
                        normal %
                        let a:end = line('.')
                        let a:leftover = substitute(strpart(getline('.'),col('.')),s:special_chars,'\\\1','g')
                        let a:leftover = strpart(getline('.'),col('.'))
                        call cursor(a:next[0],a:next[1])
                        execute 'silent ' . line('.') . ',' . a:end . 's/\<' .a:method_name . '\>' . a:param_search . '\(' . a:leftover . '\)/' . 
                                    \ a:method_name . '\1' . a:insert . '\2/e'
                    endif
                endif
                call cursor(a:next[0],a:next[1])
            endif
        endif
        let a:next = searchpos(a:search,'Wn')
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
    let a:temp_file = '.FactorusParam'
    let a:class_names = join(a:classes,'\|')

    call s:findTags(a:temp_file,'\.' . a:name . '(','no')
    call s:narrowTags(a:temp_file,'\(' . a:class_names . '\)')
    let a:files = readfile(a:temp_file)
    call s:updateParamUsingFiles(a:files,a:class_names,a:name,a:commas,a:default,a:is_static)

    call system('rm -rf ' . a:temp_file)
endfunction

" Renaming {{{2
" renameArg {{{3
function! s:renameArg(new_name,...) abort
    let a:var = expand('<cword>')
    let g:factorus_history['old'] = a:var
    call s:updateFile(a:var,a:new_name,0,1,0)

    redraw
    echo 'Re-named ' . a:var . ' to ' . a:new_name
    return a:var
endfunction

" renameClass {{{3
function! s:renameClass(new_name,...) abort
    let a:class_name = expand('%:t:r')
    let g:factorus_history['old'] = a:class_name
    let a:class_tag = s:getClassTag()
    if a:class_name == a:new_name
        throw 'Factorus:Duplicate'
    endif
    let a:old_file = expand('%:p')
    let a:new_file = expand('%:p:h') . '/' . a:new_name . '.java'
    let a:package_name = s:getPackage(a:old_file)
    call add(g:factorus_qf,{'filename' : a:new_file, 'lnum' : a:class_tag[0], 'text' : s:trim(join(getline(a:class_tag[0],a:class_tag[1])))})

    let a:temp_file = '.Factorus' . a:class_name
    call s:findTags(a:temp_file,a:package_name,'no')
    call s:narrowTags(a:temp_file,'\<' . a:class_name . '\>')
    call s:updateQuickFix(a:temp_file,'\<' . a:class_name . '\>')

    call system('cat ' . a:temp_file . ' | xargs sed -i "s/\<' . a:class_name . '\>/' . a:new_name . '/g"') 
    call system('mv ' . a:old_file . ' ' . a:new_file)
    call system('rm -rf ' . a:temp_file)

    let a:bufnr = bufnr('.')
    execute 'silent edit! ' . a:new_file
    execute 'silent! bwipeout ' . a:bufnr

    redraw
    echo 'Re-named class ' . a:class_name . ' to ' . a:new_name
    return a:class_name
endfunction

" renameField {{{3
function! s:renameField(new_name,...) abort
    let a:search = '^\s*' . s:access_query . '\(' . s:java_identifier . s:collection_identifier . '\=\)\=\s*\(' . s:java_identifier . '\)\s*[;=].*'

    let a:line = getline('.')
    let a:is_static = match(a:line,'\<static\>') >= 0 ? 1 : 0
    let a:is_local = s:getAdjacentTag('b') != s:getClassTag()[0]
    let a:type = substitute(a:line,a:search,'\4','')
    let a:var = substitute(a:line,a:search,'\6','')
    if a:var == '' || a:type == '' || match(a:var,'[^' . s:search_chars . ']') >= 0
        if a:is_local == 1 || match(getline(s:getClassTag()[0]),'\<enum\>') < 0
            throw 'Factorus:Invalid'
        endif
        let a:var = expand('<cword>')
        let a:enum_name = expand('%:t:r')
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent s/\<' . a:var . '\>/' . a:new_name . '/e'
        silent write!

        let a:temp_file = '.FactorusEnum'
        
        echo 'Updating enum...'
        call s:findTags(a:temp_file,a:enum_name . '\.' . a:var,'no')
        call s:updateQuickFix(a:temp_file,a:enum_name . '\.' . a:var)
        call system('cat ' . a:temp_file . ' | xargs sed -i "s/' . a:enum_name . '\.' . a:var . '/' . a:enum_name . '.' . a:new_name . '/g"')
        call system('rm -rf ' . a:temp_file)

        redraw
        echo 'Renamed enum ' . a:var . ' to ' . a:new_name . '.'
        return a:var
    elseif a:var == a:new_name
        throw 'Factorus:Duplicate'
    endif
    let g:factorus_history['old'] = a:var

    let a:file_name = expand('%:p')
    let a:supers = s:getSuperClasses()
    let a:top = len(a:supers) - 1
    let a:var_search = s:no_comment . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+\<' . a:var . '\>\_s*[;=]'
    while a:top >= 1
        if a:supers[a:top] != a:file_name
            execute 'silent tabedit! ' . a:supers[a:top]
            call cursor(1,1)
            if search(a:var_search) != 0
                break
            endif
            call s:safeClose()
        endif
        let a:top -= 1
    endwhile

    if a:is_local == 1
        call s:updateFile(a:var,a:new_name,0,a:is_local,a:is_static)
    else
        if a:is_static == 0
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
            execute 'silent s/\<' . a:var . '\>/' . a:new_name . '/e'
            call s:updateClassFile(a:type,a:var,a:new_name)
        endif

        redraw
        echo 'Updating sub-classes...'
        let a:classes = s:updateSubClassFiles(expand('%:t:r'),a:var,a:new_name,'',a:is_static)

        redraw
        echo 'Updating references...'
        call s:updateReferences(a:classes,a:var,a:new_name,'',a:is_static)
    endif

    if a:top > 0
        call s:safeClose()
    endif

    redraw
    echo 'Re-named ' . a:var . ' to ' . a:new_name
    return a:var
endfunction

" renameMethod {{{3
function! s:renameMethod(new_name,...) abort
    call s:gotoTag(0)

    let a:method_name = matchstr(getline('.'),'\s\+' . s:java_identifier . '\s*(')
    let a:method_name = matchstr(a:method_name,'[^[:space:](]\+')
    if a:method_name == a:new_name
        throw 'Factorus:Duplicate'
    endif
    let g:factorus_history['old'] = a:method_name

    let a:file_name = expand('%:p')
    let a:supers = s:getSuperClasses()
    let a:top = len(a:supers) - 1
    let a:func_search = s:no_comment . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+\<' . a:method_name . '\>\_s*('
    while a:top >= 1
        if a:supers[a:top] != a:file_name
            execute 'silent tabedit! ' . a:supers[a:top]
            call cursor(1,1)
            if search(a:func_search) != 0
                break
            endif
            call s:safeClose()
        endif
        let a:top -= 1
    endwhile

    let s:all_funcs = {}
    let a:is_static = match(getline('.'),'\s*\<static\>\s*[^)]\+(') >= 0 ? 1 : 0

    redraw
    echo 'Updating hierarchy...'
    let a:classes = s:updateSubClassFiles(expand('%:t:r'),a:method_name,a:new_name,'(',a:is_static)

    redraw
    echo 'Updating references...'
    call s:updateReferences(a:classes,a:method_name,a:new_name,'(',a:is_static)

    if a:top > 0
        call s:safeClose()
    endif

    redraw
    let a:keyword = a:is_static == 1 ? ' static' : ''
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
    let a:if = '\<if\>\_s*(\_[^{;]*)\_s*{\='
    let a:for = '\<for\>\_s*(\(\_[^{;]*;\_[^{;]*;\_[^{;]*\|\_[^{;]*:\_[^{;]*\))\_s*{\='
    let a:while = '\<while\>\_s*(\_[^{;]*)'
    let a:try = '\<try\>\_s*{'
    let a:do = '\<do\>\_s*{'
    let a:switch = '\<switch\>\_s*(\_[^{]*)\_s*{'
    let a:search = '\(' . a:if . '\|' . a:for . '\|' . a:while . '\|' . a:try . '\|' . a:do . '\|' . a:switch . '\)'

    let a:orig = [line('.'),col('.')]
    call s:gotoTag(0)
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

        if match(getline('.'),'\<\(if\|try\|for\|while\)\>') >= 0
            let a:open = [line('.'),col('.')]
            call search('(')
            normal %

            let a:ret =  searchpos('{','Wn')
            let a:semi = searchpos(';','Wn')

            let a:o = line('.')
            if s:isBefore(a:semi,a:ret) == 1
                call cursor(a:semi[0],a:semi[1])
                call add(a:blocks,[a:open[0],line('.')])
            elseif match(getline('.'),'\<\(if\|try\)\>') >= 0
                call cursor(a:ret[0],a:ret[1])
                normal %

                let a:continue = '}\_s*\(else\_s*\(\<if\>\_[^{]*)\)\=\|\<catch\>\_[^{]*\|\<finally\>\_[^{]*\){'
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
        if match(getline('.'),'\<for\>') >= 0
            call search('(')
            normal %
            if s:isBefore(searchpos(';','Wn'),searchpos('{','Wn'))
                let a:start_lines = range(var[2],search(';','Wn'))
            else
                call search('{')
                normal %
                let a:start_lines = range(var[2],line('.'))
            endif
            call cursor(var[2],1)
        else
            let a:start_lines = [var[2]]
        endif
        let a:local_close = var[2] == a:begin ? s:getClosingBracket(1) : s:getClosingBracket(0)
        let a:closes[var[0]] = copy(a:local_close)
        call cursor(a:orig[0],a:orig[1])
        if index(keys(a:lines),var[0]) < 0
            let a:lines[var[0]] = {var[2] : a:start_lines}
        else
            let a:lines[var[0]][var[2]] = a:start_lines
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
    let a:search = '[^.]\<\(' . join(a:names,'\|') . '\)\>'
    let a:search = s:no_comment . '.\{-\}' . a:search . '.*'
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

    let a:dspaces = repeat(a:spaces,2)
    let a:i = 0

    call map(a:body,{n,line -> substitute(line,'\s*\(.*\)','\1','')})
    while a:i < len(a:body)
        if match(a:body[a:i],'}') >= 0
            let a:dspaces = strpart(a:dspaces,len(a:spaces))
        endif
        let a:body[a:i] = a:dspaces . a:body[a:i]

        if match(a:body[a:i],'{') >= 0
            let a:dspaces .= a:spaces
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
                        if match(line,';') >= 0 && match(line,'[^.]\<' . var[0] . '\>[^.]') >= 0
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
                            if match(getline(a:lines[j]),'[^.]\<' . var[0] . '\>[^.][^=]*=') >= 0
                                call add(a:removes,j)
                                let k = j
                                while match(getline(a:lines[k]),';') < 0
                                    let k += 1
                                    call add(a:removes,k)
                                endwhile
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

    let a:build = s:buildArgs(a:args,0)
    let a:name = a:0 == 0 ? g:factorus_method_name : a:1
    let a:build_string = 'public ' . a:type . ' ' . a:name  . '(' . a:build . ') {'
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

" rollbackEncapsulation {{{3
function! s:rollbackEncapsulation()
        let a:orig = [line('.'),col('.')]
        let [a:var,a:type,a:is_pub] = g:factorus_history['old']
        let a:cap = substitute(a:var,'\(.\)\(.*\)','\U\1\E\2','')

        if a:is_pub == 1
            execute 'silent s/\<private\>/public/e'
        endif
       
        let a:open = search('public ' . a:type . ' get' . a:cap . '() {','n')
        if match(getline(a:open-1),'^\s*$') >= 0
            let a:open -= 1
        endif

        let a:close = s:getClosingBracket(1,[a:open,1])[0]
        if match(getline(a:close+1),'^\s*$') >= 0
            let a:close += 1
        endif
        execute 'silent ' . a:open . ',' . a:close . 'delete'

        let a:open = search('public void set' . a:cap . '(','n')
        let a:close = s:getClosingBracket(1,[a:open,1])[0]
        if match(getline(a:close+1),'^\s*$') >= 0
            let a:close += 1
        endif
        execute 'silent ' . a:open . ',' . a:close . 'delete'
        call cursor(a:orig[0],a:orig[1])
        silent write!
endfunction

" rollbackRename {{{3
function! s:rollbackRename(new_name,type)
    let a:files = {}
    let a:old = g:factorus_history['old']
    let a:new = g:factorus_history['args'][0]

    if a:type == 'Class'
        call s:renameClass(a:new_name)
        execute 'bwipeout ' . g:factorus_history['file']
    else
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
                execute 'silent! s/\<' . a:new . '\>/' . a:old . '/ge'
            endfor
            silent write!
            call s:safeClose()
        endfor
    endif

    return 'Rolled back renaming of ' . substitute(g:factorus_history['args'][-1],'\(.\)\(.*\)','\L\1\E\2','') . ' ' . a:old
endfunction

" rollbackExtraction {{{3
function! s:rollbackExtraction()
    let a:open = search('public .*' . g:factorus_method_name . '(')
    let a:close = s:getClosingBracket(1)[0]

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
    let a:close = s:getClosingBracket(1)[0]

    execute 'silent ' . a:open . ',' . a:close . 'delete'
    call append(line('.')-1,g:factorus_history['old'][1])
    call cursor(a:open,1)
    silent write!
endfunction

" Global Functions {{{1
" encapsulateField {{{2
function! java#factorus#encapsulateField(...) abort
    if factorus#isRollback(a:000)
        call s:rollbackEncapsulation() 
        return 'Rolled back encapsulation for ' . g:factorus_history['old'][0]
    endif

    let a:search = '\s*' . s:access_query . '\(' . s:java_identifier . s:collection_identifier . '\=\)\_s*\(' . s:java_identifier . '\)\_s*[;=].*'

    let a:line = getline('.')
    let a:is_static = substitute(a:line,a:search,'\2','')
    let a:type = substitute(a:line,a:search,'\4','')
    let a:var = substitute(a:line,a:search,'\6','')
    let a:cap = a:0 > 0 ? substitute(a:1,'\(.\)\(.*\)','\U\1\E\2','') : substitute(a:var,'\(.\)\(.*\)','\U\1\E\2','')

    let a:is_local = s:getClassTag()[0] == s:getAdjacentTag('b') ? 0 : 1
    if a:is_local == 1
        throw 'Factorus:EncapLocal'
    endif

    if a:is_static == 1
        throw 'Factorus:EncapStatic'
    endif

    let a:is_pub = 0
    if match(getline('.'),'\<\(public\|protected\)\>') >= 0
        let a:is_pub = 1
        execute 'silent! s/\<public\>/private/e'
    elseif match(getline('.'),'\<private\>') < 0
        execute 'silent! s/^\(\s*\)/\1private /e'
    endif

    let g:factorus_history['old'] = [a:var,a:type,a:is_pub]

    let a:get = ["\tpublic " . a:type . " get" . a:cap . "() {" , "\t\treturn " . a:var . ";" , "\t}"]
    let a:set = ["\tpublic void set" . a:cap . "(" . a:type . ' ' . a:var . ") {" , "\t\tthis." . a:var . " = " . a:var . ";" , "\t}"]
    let a:encap = [""] + a:get + [""] + a:set + [""]

    let a:end = s:getClosingBracket(1,s:getClassTag())
    call append(a:end[0] - 1,a:encap)
    call cursor(a:end[0] + 1,1)
    silent write!

    redraw
    echo 'Created getters and setters for ' . a:var
    return 
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
    let [a:orig,a:prev_dir,a:curr_buf] = s:setEnvironment()

    try
        call s:gotoTag(0)
        let a:is_static = (match(getline('.'),'\<static\>') >= 0)
        let a:next = searchpos(')','Wn')
        let [a:type,a:name,a:params] = split(substitute(join(getline(line('.'),a:next[0])),'^.*\<\(' . s:java_identifier . 
                    \ s:collection_identifier . '\=\)\s*\<\(' . s:java_identifier . '\)\>\s*(\(.*\)).*','\1 | \3 | \4',''),'|')
        let [a:type,a:name] = [s:trim(a:type),s:trim(a:name)]
        let g:factorus_history['old'] = [a:name,a:param_name]

        let a:file_name = expand('%:p')
        let a:supers = s:getSuperClasses()
        let a:top = len(a:supers) - 1
        let a:func_search = s:no_comment . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+\<' . a:name . '\>\_s*('
        while a:top >= 1
            if a:supers[a:top] != a:file_name
                execute 'silent tabedit! ' . a:supers[a:top]
                call cursor(1,1)
                if search(a:func_search) != 0
                    break
                endif
                call s:safeClose()
            endif
            let a:top -= 1
        endwhile

        let a:count = 0
        while 1 == 1
            let a:cut_params = substitute(a:params,'\(' . s:java_identifier . s:collection_identifier . '\=\s*\<' . s:java_identifier . '\>\)\(.*\)','\3','')
            if a:cut_params == a:params
                break
            endif
            let a:count += 1
            let a:params = a:cut_params
        endwhile
        let a:com = a:count > 0 ? ', ' : ''

        let a:next = searchpos(')','Wn')
        let a:line = substitute(getline(a:next[0]), ')', a:com . a:param_type . ' ' . a:param_name . ')', '')
        call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : s:trim(getline('.'))})
        execute 'silent ' .  a:next[0] . 'd'
        call append(a:next[0] - 1,a:line)
        silent write!

        if g:factorus_add_default == 1
            let a:default = a:0 > 0 ? a:1 : 'null'

            redraw
            echo 'Updating hierarchy...'
            let a:classes = s:updateParamSubClassFiles(a:name,a:count,a:default,a:param_name,a:param_type,a:is_static)

            redraw
            echo 'Updating references...'
            call s:updateParamReferences(a:classes,a:name,a:count,a:default,a:is_static)

        endif
        redraw
        echo 'Added parameter ' . a:param_name . ' to method ' . a:name . '.'

        if a:top > 0
            call s:safeClose()
        endif

        if g:factorus_show_changes > 0
            call s:setChanges(a:name,'addParam')
        endif

        call s:resetEnvironment(a:orig,a:prev_dir,a:curr_buf,'addParam')

        return [a:name,a:param_name,a:count+1]
    catch /.*/
        call s:resetEnvironment(a:orig,a:prev_dir,a:curr_buf,'addParam')
        let a:err = match(v:exception,'^Factorus:') >= 0 ? v:exception : 'Factorus:' . v:exception
        throw a:err . ', at ' . v:throwpoint
    endtry
endfunction

" renameSomething {{{2
function! java#factorus#renameSomething(new_name,type,...)
    let [a:orig,a:prev_dir,a:curr_buf] = s:setEnvironment()

    let a:res = ''
    try
        if factorus#isRollback(a:000)
            let a:res = s:rollbackRename(a:new_name,a:type)
            let g:factorus_qf = []
        else
            let g:factorus_qf = []
            let Rename = function('s:rename' . a:type)
            let a:res = Rename(a:new_name)

            if g:factorus_show_changes > 0
                call s:setChanges(a:res,'rename',a:type)
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
function! java#factorus#extractMethod(...)
    if factorus#isRollback(a:000)
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif
    echo 'Extracting new method...'
    call s:gotoTag(0)
    let a:tab = substitute(getline('.'),'\(\s*\).*','\1','')
    let a:method_name = substitute(getline('.'),'.*\s\+\(' . s:java_identifier . '\)\s*(.*','\1','')

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

    call search('public.*\<' . g:factorus_method_name . '\>(')
    silent write!
    redraw
    echo 'Extracted ' . len(a:best_lines) . ' lines from ' . a:method_name
    return [a:method_name,a:old_lines]
endfunction

" manualExtract {{{2
function! java#factorus#manualExtract(...)
    if factorus#isRollback(a:000)
        call s:rollbackExtraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif

    let a:name = a:0 <= 2 ? g:factorus_method_name : a:3

    echo 'Extracting new method...'
    call s:gotoTag(0)
    let [a:open,a:close] = [line('.'),s:getClosingBracket(1)]
    let a:tab = substitute(getline('.'),'\(\s*\).*','\1','')
    let a:method_name = substitute(getline('.'),'.*\s\+\(' . s:java_identifier . '\)\s*(.*','\1','')

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

    call search('public.*\<' . a:name . '\>(')
    silent write!
    redraw
    echo 'Extracted ' . len(a:extract_lines) . ' lines from ' . a:method_name

    return [a:name,a:old_lines]
endfunction
