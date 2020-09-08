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
let s:reflect = s:collection_identifier . '\_s\+' . s:java_identifier .  s:collection_identifier . '\=\_s\+' . s:java_identifier . '\_s*('

let s:tag_query = '^\s*' . s:access_query . '\(' . s:struct . '\|' . s:common . '\|' . s:reflect . '\)'

" Local Functions {{{1
" Utilities {{{2
" get_closing_bracket {{{3
function! s:get_closing_bracket(stack, ...)
    let l:orig = [line('.'), col('.')]
    if a:0 > 0
        call cursor(a:1)
    endif

    if a:stack == 0
        call searchpair('{','','}','Wb')
    else
        call search('{','Wc')
    endif

    normal %
    let l:res = [line('.'), col('.')]
    call cursor(l:orig)
    return l:res
endfunction

" is_quoted {{{3
function! s:is_quoted(pattern, statement)
    let l:temp = a:statement
    let l:match = match(l:temp, a:pattern)
    let l:res = 1
    while l:match >= 0 && l:res == 1
        let l:begin = strpart(l:temp, 0, l:match)
        let l:quotes = len(l:begin) - len(substitute(l:begin, '"', '', 'g'))
        let l:res = (l:quotes % 2 == 1) ? 1 : 0

        let l:temp = substitute(l:temp, a:pattern, '', '')
        let l:match = match(l:temp, a:pattern)
    endwhile
    return l:res
endfunction

" is_wrapped {{{3

" Checks if a:class is 'wrapped' within a pair of <> blocks. Used to check if a
" class inheritance is actually an inheritance.
function! s:is_wrapped(class, class_line)
    let l:match = match(a:class_line, a:class)
    let l:temp = a:class_line

    " For every instance of a:class within a:class_line, we check if that instance is
    " between a pair of <> brackets. We do this by looking at how many < and >
    " symbols are before it; if there are more <'s than >'s, that instance is
    " wrapped, and we move on.
    while l:match >= 0
        let l:begin = split(strpart(l:temp, 0, l:match), '\zs')
        " If there's a single unwrapped instance of a:class, it is considered to
        " be unwrapped.
        if count(l:begin, '>') >= count(l:begin, '<')
            return 0
        endif
        let l:temp = substitute(l:temp, a:class, '', '')
        let l:match = match(l:temp, a:class)
    endwhile

    " If all instances were wrapped, a:class itself is wrapped.
    return 1
endfunction

" is_commented {{{3

" Checks if the current line is part of a comment.
function! s:is_commented()
    if match(getline('.'),'//') >= 0 && match(getline('.'),'//') < col('.')
        return 1
    endif
    if searchpairpos('[^/]\/\*','','\*\/','Wbn') != [0,0]
        return 1
    endif
    return 0
endfunction

" get_endline {{{3
function! s:get_endline(start, search)
    let l:orig = [line('.'), col('.')]
    call cursor(a:start)
    let l:fin = searchpos(a:search, 'Wen')
    call cursor(l:orig)
    return l:fin
endfunction

" get_statement {{{3
function! s:get_statement()

endfunction

" File Navigation {{{2
" is_valid_tag {{{3
"
" Checks if the line at a:line is valid; it's possible that searching
" s:tag_query actually returns a commented or otherwise invalid result, so
" this serves as a sanity check.
function! s:is_valid_tag(line)
    " Check if a:line is part of a comment.
    let l:first_char = strpart(substitute(getline(a:line), '\s*', '', 'g'), 0, 1)   
    if l:first_char == '*' || l:first_char == '/'
        return 0
    endif

    " Check if a:line contains any java keywords that shouldn't appear in a
    " tag definition (continue, if/else, etc.)
    let l:has_keyword = match(getline(a:line), s:java_keywords)
    if l:has_keyword >= 0 && !s:is_quoted(s:java_keywords, getline(a:line))
        return 0
    endif

    " Check if the line before a:line is a new object?
    if match(getline(a:line-1), '\<new\>.*{') >= 0
        return 0   
    endif

    " If all the previous checks succeeded, we have a valid tag.
    return 1
endfunction

" get_adjacent_tag {{{3
"
" Gets the nearest 'tag' to the cursor; if a:dir == '', it searches forward,
" and if a:dir == 'b', it search backwards. A tag is either a function
" definition or a class/enum definition.
function! s:get_adjacent_tag(dir)
    let l:orig = [line('.'), col('.')]
    call cursor(line('.'), 1)

    let l:func = searchpos(s:tag_query, 'Wnc' . a:dir)
    let l:is_valid = 0
    while l:func != [0, 0]
        let l:is_valid = s:is_valid_tag(l:func[0])
        if l:is_valid
            call cursor(l:orig)
            return l:func[0]
        endif

        call cursor(l:func)
        let l:func = searchpos(s:tag_query, 'Wn' . a:dir)
    endwhile
    call cursor(l:orig)
    return 0
endfunction

" get_next_tag {{{3
function! s:get_next_tag()
    let l:orig = [line('.'), col('.')]
    call cursor(line('.') - 1, 1)
    let l:res = s:get_adjacent_tag('')
    call cursor(l:orig)
    return [l:res,1]
endfunction

" get_class_tag {{{3
function! s:get_class_tag()
    let l:orig = [line('.'), col('.')]
    call cursor(1, 1)
    let l:class_tag = search(s:tag_query, 'cn')
    let l:tag_end = search(s:tag_query, 'ne')
    call cursor(l:orig)
    return [l:class_tag, l:tag_end]
endfunction

" go_to_tag {{{3

" If a:head is 0, jumps to the closest tag before the current line. If it's
" 1, jumps to the opening tag of the file.
function! s:go_to_tag(head)
    let l:tag = (a:head == 1) ? s:get_class_tag()[0] : s:get_adjacent_tag('b') 
    if l:tag != 0
        call cursor(l:tag,1)
    elseif a:head == 1
        call cursor(1,1)
    else
        echo 'No tag found'
    endif
endfunction

" Class Hierarchy {{{2
" get_package {{{3

" Gets the package a:file belongs to.
function! s:get_package(file)
    let l:lines = split(system('cat ' . a:file))

    " Go through the lines of a:file. If we hit a package definition, return
    " the package name; if we hit a class definition, return ''.
    for line in l:lines
        if match(line, '^\s*package') >= 0
            let l:package = substitute(l:head,'^\s*package\s*\(.*\);.*','\1','')
            let l:package = substitute(l:package, '\.', '\\.', 'g')
            return l:package
        endif

        if match(line, '^\s*\(' . s:modifiers . '\|' . s:class . '\)') >= 0
            return ''
        endif
    endfor
endfunction

" get_package_files {{{3

" Gets all files associated with current file's package (in the same directory
" or in subdirectories).
function! s:get_package_files(file)
    let l:package_dir = expand('%:p:h')
    call system('find ' . l:package_dir . ' -name  "*.java" >> ' . a:file)
endfunction

" get_upward_hierarchy {{{3

"Gets the upwards hierarchy of the current file. The search is recursive, and the
" current class is considered a superclass of itself, so if A is a subclass of B,  
" and B is a subclass of C, then get_upward_hierarchy() will return A, B and C.
function! s:get_upward_hierarchy()
    let l:class_tag = s:get_class_tag()
    let l:class_name = expand('%:t:r')
    let l:super_search = '.*' . s:class . '\_s\+\<' . l:class_name . '\>[^{]\_[^{]\{-\}' . s:sub_class . '\_s\+\<\(' . s:java_identifier . '\)\>\_[^{]*{.*'
    let l:sups = [expand('%:p')]

    let l:class_line = join(getline(l:class_tag[0],l:class_tag[1]))
    let l:class_line = substitute(l:class_line,',',' ','g')
    let l:inherits = []

    while match(l:class_line, l:super_search) >= 0
        let l:super = substitute(l:class_line, l:super_search, '\3', '')
        if s:is_wrapped(l:super, l:class_line)
            let l:class_line = substitute(l:class_line, s:sub_class, '', '')
        elseif match(l:super, s:sub_class) < 0
            call add(l:inherits, l:super)
        endif
        let l:class_line = substitute(l:class_line, l:super, '', '')
    endwhile

    if l:inherits == []
        return l:sups
    endif

    let l:names = join(map(l:inherits, {n,val -> ' -name "' . val . '.java"'}), ' -or')
    let l:search = 'find ' . getcwd() . l:names
    let l:possibles = system(l:search)
    let l:possibles = split(l:possibles, '\n')
    for poss in l:possibles
        execute 'silent tabedit! ' . poss
        let l:sups += s:get_upward_hierarchy()
        call factorus#util#safe_close()
    endfor

    return l:sups
endfunction

" get_declaration_file {{{3

" Gets the file where something is declared, found by using search as the
" search pattern.
function! s:get_declaration_file(search)
    let l:supers = s:get_upward_hierarchy()
    let l:top = len(l:supers) - 1

    while l:top >= 1
        if l:supers[l:top] != expand('%:p')
            execute 'silent tabedit! ' . l:supers[l:top]
            call cursor(1,1)
            if search(a:search) != 0
                break
            endif
            call factorus#util#safe_close()
        endif
        let l:top -= 1
    endwhile

    return (l:top > 0)
endfunction

"get_downward_hierarchy {{{3

" Returns the downward hierarchy of the current class, including the base class
" itself.
function! s:get_downward_hierarchy()
    let l:temp_file = '.Factorus' . expand('%:t:r') . 'E'
    call system('> ' . l:temp_file)

    let l:sub = [expand('%:p')]
    let l:subc = [expand('%:t:r')]
    let l:all = [expand('%:p')]

    while l:sub != []
        let l:sub_classes = '\<\(' . join(l:subc) . '\)\>'
        let l:exclude = '[^\;}()=+\-\*/|&~!''\"]*'
        let l:fsearch = '^' . l:exclude . l:sub_classes . l:exclude . '$'
        let l:search = '^.\{-\}' . s:class . '\_[^{;]\{-\}' . s:sub_class . '\_[^;{]\{-\}' . l:sub_classes . '\_[^;{]\{-\}{'
        call factorus#util#find_tags(l:temp_file,l:fsearch,'no')

        let l:sub = []
        for file in readfile(l:temp_file)
            if index(l:all,file) < 0
                execute 'silent tabedit! ' . file
                call cursor(1,1)
                let l:found = search(l:search,'W')
                if l:found > 0
                    call add(l:sub,file)
                    let l:new_sub = expand('%:t:r')
                    if l:found != s:get_class_tag()[0]
                        let l:new_sub .= '\.' . substitute(getline('.'),'^.\{-\}' . s:class . '\s*\<\(' . s:java_identifier . '\)\>.*','\2','')
                    endif
                    call add(l:subc,l:new_sub)
                endif
                call factorus#util#safe_close()
            endif
        endfor
        let l:all += l:sub
    endwhile

    call system('rm -rf ' . l:temp_file)
    return [l:all,l:subc]
endfunction

" Declarations {{{2
" get_next_named_def {{{3

" Returns the next use of a:var_name as an argument or defined variable in a
" function.
function! s:get_next_named_def(var_name)
    let l:search = s:java_identifier . s:collection_identifier . '\=\_s\+\(\<' . a:var_name . '\>\)'
    return searchpos(l:search, 'Wn')
endfunction

" get_function_defs {{{3

" Gets all functions defined in the current file.
function! s:get_function_defs()
    let l:access = '\<\(void\|public\|private\|protected\|static\|abstract\|final\|synchronized\)\>'
    let l:query = '^\s*' . s:access_query . '\s*\(' .  s:java_identifier . s:collection_identifier . '\=\)\_s\+\(' . s:java_identifier . '\)\_s*(.*'
    let l:decs = {'types' : [], 'names' : []}

    let l:next = searchpos(l:query, 'Wn')
    while l:next != [0,0]
        call cursor(l:next)
        let l:type = substitute(getline('.'), l:query, '\4', '')
        let l:name = substitute(getline('.'), l:query, '\6', '')
        call add(l:decs['types'], l:type)
        call add(l:decs['names'], l:name)

        let l:next = searchpos(l:query, 'Wn')
    endwhile

    return l:decs
endfunction

" get_all_functions {{{3

" Gets all functions defined in the upwards hierarchy of the current file.
function! s:get_all_functions()
    if index(keys(s:all_funcs),expand('%:p')) >= 0
        return s:all_funcs[expand('%:p')]
    endif

    let l:hier = s:get_upward_hierarchy()

    let l:decs = {'types' : [], 'names' : []}
    for class in l:hier
        execute 'silent tabedit! ' . class
        let l:funcs = s:get_function_defs()
        let l:decs['types'] += l:funcs['types']
        let l:decs['names'] += l:funcs['names']
        call factorus#util#safe_close()
    endfor
    silent edit!

    let s:all_funcs[expand('%:p')] = l:decs
    return l:decs
endfunction

" get_func_dec {{{3

" Gets the return type of function a:func.
function! s:get_func_dec(func)
    let l:all_funcs = s:get_all_functions()
    let l:ind = match(l:all_funcs['names'], a:func)
    if l:ind >= 0
        return l:all_funcs['types'][l:ind]
    endif

    return ''
endfunction

" get_var_dec {{{3

" Gets the declaration of variable a:var.
" NOTE: This also gets called if a:var is just a class name, in which case
" l:res should be ''. 
function! s:get_var_dec(var)
    let l:orig = [line('.'),col('.')]

    " Search backwards for the declaration of a variable with name a:var.
    "let l:search = s:no_comment  . '.\{-\}\(' . s:access_query . '\|for\s*(\)\s*\(' . s:java_identifier .
    let l:search = '\(' . s:access_query . '\|for\s*(\)\s*\(\<' . s:java_identifier . '\>' .
                \ s:collection_identifier . '\=\)\s\+\<' . a:var . '\>'

    let l:pos = searchpos(l:search, 'Wb')
    let l:res = substitute(getline(l:pos[0]), '.*\(' . l:search . '\).*', '\1', '')
    let l:res = substitute(l:res, l:search, '\5', '')

    " Jump backwards until the declaration is valid (not commented, quoted, or
    " otherwise mismatched).
    while s:is_commented() || s:is_quoted(l:res, getline(l:pos[0])) || match(l:res, s:java_keywords) >= 0
        if l:pos == [0,0]
            return ''
        endif

        call cursor(l:pos[0]-1, 1)
        let l:pos = searchpos(l:search, 'Wb')
        let l:res = substitute(getline(l:pos[0]), '.*\(' . l:search . '\).*', '\1', '')
        let l:res = substitute(l:res, l:search, '\5', '')
    endwhile

    call cursor(l:orig)
    return l:res
endfunction

" get_struct_vars {{{3

" Decomposes a structure of multiple types of classes into all those classes.
" For example, a HashMap could have two separate classes, so following a chain
" might have to look for methods/fields in either of those two classes.
function! s:get_struct_vars(var, dec, chain)
    " If we're not dealing with a structure, move on.
    if match(a:dec,'>$') < 0
        return [a:dec]
    endif

    "if len(a:chain) > 1
    "    let old = a:chain[0]
    "    call remove(a:chain,0)
    "    call add(a:chain[0],old)
    "endif

    " Separate out all the component classes of the structure.
    let l:orig = substitute(a:dec, '^\([^<]*\)<.*', '\1', '')
    let l:res = substitute(a:dec, '^.*<', '', '')
    let l:res = substitute(l:res, '\(<\|>\|\s\)', '', 'g')
    return [l:orig] + split(l:res, ',')
endfunction

" get_using_var {{{3

" Gets the variable that is referring to a method or field.
function! s:get_using_var()
"function! factorus#java#get_using_var()
    let l:orig = [line('.'), col('.')]
    let l:chain = []

    " Jump backwards through the chain of structs/functions until we get to
    " the front of the chain.
    while v:true
        " Get the character right before the '.'.
        let l:adj = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')
        let l:paren = ''

        " In the case where we're dealing with something like 'func()[0]',
        " we need to jump multiple times.
        while l:adj == ')' || l:adj == ']'
            if l:adj == ')'
                let l:paren = '('
            endif
            call cursor(line('.'),col('.')-1)
            normal %
            let l:adj = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')
        endwhile

        let l:curr = matchstr(getline('.'), '\%' . col('.') . 'c.')

        " If we haven't reached the front of the chain, keep going.
        if searchpos('\.','Wbn') == searchpos('[^[:space:]]\_s*\<' . s:java_identifier . '\>','Wbn') && (search('//', 'Wbn') != search('\.', 'Wbn'))
            call search('\.','b')
            let l:chain = [expand('<cword>') . l:paren] + l:chain
        " Otherwise, we get the front of the chain and its declaration,
        " whether it's a field, a function, or the class itself.
        else
            call search('\<' . s:java_identifier . '\>','b')
            let l:var = expand('<cword>')
            if l:curr == '('
                let l:dec = s:get_func_dec(l:var)
            elseif l:var == 'this' || l:var == 'super'
                let l:dec = expand('%:t:r')
            else
                let l:dec = s:get_var_dec(l:var)
            endif
            break
        endif
    endwhile

    let l:dec = s:get_struct_vars(l:var, l:dec, l:chain)
    call cursor(l:orig)
    return [l:dec, l:chain]
endfunction

" follow_chain {{{3

" Follows a chain of method/field calls, starting with a:dec and ending with
" the method/field you're trying to rename. Returns 1 if the method/field is a
" valid instance of what we're trying to rename, and 0 otherwise.
function! s:follow_chain(dec, chain)

    " Find all files with the class name of a:dec.
    let l:chain_file = '.FactorusChain'
    let l:names_list = []
    for class in a:dec
        call add(l:names_list, ' -name "' . class . '.java" ') 
    endfor
    let l:names = join(l:names_list, '-or')
    call system('find ' . getcwd() . l:names . '> ' . l:chain_file)
    
    " While there's another method/field in the chain, get the type of that
    " item and jump to the next item.
    let l:vars = copy(a:dec)
    let l:chain_files = readfile(l:chain_file)
    while len(a:chain) > 0
        let func = '\(' . a:chain[0] . '\)'
        "let func = '\(' . join(a:chain[0], '\|') . '\)'
        let l:temp_list = []
        " The current item might be a structure of different classes, so we
        " need to check every possible file.
        for file in l:chain_files
            let l:next = ''
            execute 'silent tabedit! ' . file
            call cursor(1,1)

            " Get the declaration of the next item in the chain, and figure
            " out its type so we can check the item after that.
            let l:search = s:no_comment . s:access_query . '\(' . s:java_identifier . s:collection_identifier . '\=\)\_s\+\<' . func . '\(\<\|\>\|)\|\s\).*'
            let l:find =  search(l:search)

            if l:find > 0
                call cursor(line('.'), 1)
                let l:next = substitute(getline('.'), l:search, '\4', '')
            else
                let l:all_funcs = s:get_all_functions()
                let l:ind = match(l:all_funcs['names'], func)
                if l:ind >= 0
                    let l:next = l:all_funcs['types'][l:ind]
                endif
            endif

            " Decompose the next item into its component classes (if
            " necessary), and get all files for all of that item's classes.
            if l:next != ''
                let l:vars = s:get_struct_vars(func, l:next, a:chain)
            endif

            let l:next_list = []
            for var in l:vars
                call add(l:next_list,' -name "' . var . '.java" ') 
            endfor
            let l:nexts = join(l:next_list,'-or')

            call system('find ' . getcwd() . l:nexts . '> ' . l:chain_file)
            let l:temp_list += readfile(l:chain_file)

            call factorus#util#safe_close()
        endfor
        
        " Set files for the next item, and repeat the process.
        let l:chain_files = copy(l:temp_list)
        if len(a:chain) > 0
            call remove(a:chain, 0)
        endif
    endwhile

    " Now that we've reached the last item in the chain, we need to check if
    " we're at the correct class. We do this by searching for the new method
    " declaration (since we've already changed the declaration by now) in the
    " files in l:chain_files.
    let l:res = 0
    for file in l:chain_files
        execute 'silent tabedit! ' . file
        let l:search = s:no_comment . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+\<' . a:new_name . '\>\_s*('
        let l:find =  search(l:search)
        call factorus#util#safe_close()

        if l:find > 0
            let l:res = 1
            break
        endif
    endfor
    call system('rm -rf ' . l:chain_file)

    return l:res
endfunction

" get_args {{{3
function! s:get_args() abort
    let l:prev = [line('.'), col('.')]
    if matchstr(getline('.'), '\%' . col('.') . 'c.') != '('
        call search('(')
    endif
    let l:start = strpart(getline('.'), 0, col('.')-1)
    normal %
    let l:leftover = strpart(getline('.'), col('.'))
    let l:end = line('.')
    call cursor(l:prev)

    let l:start = substitute(l:start, s:special_chars, '\\\1', 'g')
    let l:leftover = substitute(l:leftover, s:special_chars, '\\\1', 'g')

    let l:args = join(getline(l:prev[0], l:end))
    let l:args = substitute(l:args, l:start . '(\(.*\))' . l:leftover, '\1', '')

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
" is_valid_use {{{3

" Checks to see if the using variable for the next instance of a field/method
" matches what we're looking for.
function! s:is_valid_use(object)
    " Get the variable that is 'using' the current instance.
    let [l:dec, l:chain] = s:get_using_var()

    " If the chain is empty, that means we can just check if l:dec is the
    " proper type.
    if len(l:chain) == 0 
        let l:dec = join(l:dec, '|')
        let l:search = '\<\(' . join(a:object['sub_classes'], '\|') . '\)\>'
        return (match(l:dec, l:search) >= 0)
    " Otherwise, we need to follow the chain to see if the resulting
    " variable calling the field/method is the proper type.
    else
        return s:follow_chain(l:dec, l:chain)
    endif
endfunction

" File Updating {{{2
" update_definition {{{3

" Updates the defintion of a:object in the file (if it exists).
function! s:update_definition(object, new_name)
    let l:orig = [line('.'), col('.')]
    call cursor(1,1)

    let l:prev = [line('.'), col('.')]
    let l:object_type = substitute(a:object['type'], '[]','\\[\\]','g')

    let l:search = '^\s*' . s:access_query . l:object_type . s:collection_identifier . '\=\_s\+\(\<' . a:object['old_name'] . '\>\)\_s*[;=].*'
    let l:next = searchpos(l:search, 'Wn')

    if l:next != [0,0]
        call cursor(l:next)
        if s:get_adjacent_tag('b') == s:get_class_tag()[0]
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : factorus#util#trim(getline('.'))})
            execute 'silent s/\<' . a:object['old_name'] . '\>/' . a:new_name . '/e'
            silent write!
        endif
    endif

    call cursor(l:orig)
endfunction

" update_file {{{3

" Renames all valid definitions or uses of object in a subclass of where
" object is defined.
function! s:update_file(object, new_name)
    let l:orig = [line('.'),col('.')]

    " If the object is a local one, we just need to rename all references to
    " it in its method.
    if a:object['is_local']
        let l:query = '\([^.]\)\<' . a:object['old_name'] . '\>'
        call add(g:factorus_qf, {'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : factorus#util#trim(getline('.'))})
        execute 'silent s/' . l:query . '/\1' . a:new_name . '/g'

        call s:go_to_tag(0)
        let l:closing = s:get_closing_bracket(1)

        let l:next = searchpos(l:query, 'Wn')
        while factorus#util#is_before(l:next, l:closing)
            if l:next == [0,0]
                break
            endif
            call cursor(l:next)
            call add(g:factorus_qf, {'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : factorus#util#trim(getline('.'))})
            execute 'silent s/' . l:query . '/\1' . a:new_name . '/g'

            let l:next = searchpos(l:query, 'Wn')
        endwhile
    " Otherwise, we have to be more careful when renaming instances of the
    " object.
    else
        " If we're updating a field, we need to modify the definition of the
        " field, if it exists.
        if !a:object['is_method']
            call s:update_definition(a:object, a:new_name)
        endif

        " Go through the file each match at a time, and modify it if it's a
        " valid match. When renaming a method, it will always be a valid
        " match; however, with a field, it's possible that a different
        " variable with the same name exists, in which case we won't want to
        " rename that.
        call cursor(1,1)

        " When l:restricted is 1, we can only rename a mention of the field if
        " it's specified by this or super; otherwise, it's a mention to a
        " different field.
        let l:restricted = 0
        let l:paren = a:object['is_method'] ? '(' : ''

        let l:search = ['\([^.]\|\<this\>\.\|\<super\>\.\)\<\(' . a:object['old_name'] . '\)\>' . l:paren, '\(\<this\>\.\|\<super\>\.\)\<\(' . a:object['old_name'] . '\)\>' . l:paren]

        " We get the next definition of a variable matching old_name. This is
        " an irrelevant value for methods, but is necessary for fields.
        let l:next_def = s:get_next_named_def(a:object['old_name'])
        if l:next_def == [0, 0]
            let l:next_def = [line('$'), 1]
        endif

        " Get the next valid mention of the variable and replace it. If our
        " next match takes us past l:next_def, we need to switch the value of
        " l:restricted and check to see if it's still valid. (Not important
        " for renaming methods)
        let l:next_rep = searchpos(l:search[l:restricted], 'Wn')
        while l:next_rep != [0, 0]

            " If our search took us past the next named definition, we jump
            " back to the definition and search again with l:restricted
            " flipped (if we were restricted we aren't anymore, and vice
            " versa).
            if l:next_rep[0] >= l:next_def[0] && !a:object['is_method']
                call cursor(l:next_def)
                let l:restricted = !l:restricted
                if l:restricted
                    let l:next_def = s:get_next_tag()
                else
                    let l:next_def = s:get_next_named_def(a:object['old_name'])
                    if l:next_def == [0, 0]
                        let l:next_def = [line('$'), 1]
                    endif
                endif
            else
                call cursor(l:next_rep)
                call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : factorus#util#trim(getline('.'))})
                execute 'silent s/' . l:search[l:restricted] . '/\1' . a:new_name . l:paren . '/g'
            endif

            let l:next_rep = searchpos(l:search[l:restricted], 'Wn')
            if l:next_rep == [0,0] && !a:object['is_method']
                call cursor(l:next_def[0], 1)
                let l:next_rep = searchpos(l:search[1-l:restricted], 'Wn')
            endif
        endwhile
    endif

    call cursor(l:orig)
    silent write!
endfunction

" update_hierarchy {{{3

" Renames all instances of object to new_name in the entire downward hierarchy
" of the class object is defined in.
function! s:update_hierarchy(object, new_name)

    " Try to find any subclasses that use object.
    try
        let l:paren = a:object['is_method'] ? '(' : ''
        execute 'silent lvimgrep /\(\<super\>\.\|\<this\>\.\|[^.]\)\<' . a:object['old_name'] . '\>' . l:paren . '/j ' . join(a:object['sub_files'])
    catch /.*/
        return
    endtry

    " If we find any, get all the files that contain a reference and update
    " all references.
    " NOTE: Do we need to update method definitions in subclasses? We just
    " might have to.
    let l:use_subs = map(getloclist(0), {key, val -> getbufinfo(val['bufnr'])[0]['name']})
    for file in l:use_subs
        execute 'silent tabedit! ' . file
        call cursor(1,1)
        call s:update_file(a:object, a:new_name)

        call factorus#util#safe_close()
    endfor
    silent edit!
endfunction

" update_subclass_param_file {{{3

" Adds param to a subclass file of the original method. This updates
" the declarations of the relevant method, and any inherited reference (i.e.,
" super/this) of the method.
function! s:update_subclass_param_file(object, default, param_type, param_name)
    let l:orig = [line('.'), col('.')]

    " Define the proper search for the method's parameters.
    let l:param_search = ''
    let l:insert = [a:param_type . ' ' . a:param_name . ')', a:default . ')']
    if a:object['num_params'] > 0
        let l:insert = [', ' . l:insert[0], ', ' . l:insert[1]]
        let l:param_search = '\_[^;]\{-\}' . repeat(',\_[^;]\{-\}', a:object['num_params'] - 1)
    endif
    let l:param_search = '\((' . l:param_search . '\))'

    " We want to define the search for the method declaration and the function
    " call.
    let l:declaration_search = '^\s*' . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+' . a:object['old_name'] . '\_s*('
    let l:func_search = '\(\<super\>\.\|\<this\>\.\|[^.]\)' . '\<' . a:object['old_name'] . '\>('
    let l:search = [l:declaration_search, l:func_search]

    " First we search through the file for the declaration, then for the
    " function calls. We go through each occurence of the method, check to see
    " if it has the proper number of arguments, and update it if it does.
    for i in [0,1]
        call cursor(1, 1)
        let l:next = searchpos(l:search[i], 'Wn')
        
        while l:next != [0,0]
            " Depending on whether we're updating declarations or references,
            " we need a different condtion to check.
            call cursor(l:next[0], l:next[1] + 1)
            if i == 0
                let l:cond = s:is_valid_tag(l:next[0]) && s:get_args() == a:object['num_params']
            else
                let l:cond = l:next[0] != s:get_adjacent_tag('b') && s:get_args() == a:object['num_params']
            endif

            " If that condition holds, get all lines the method is defined on,
            " and update them accordingly.
            if l:cond
                call add(g:factorus_qf, {'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : factorus#util#trim(getline('.'))})
                call search('(')
                normal %
                let l:end = line('.')
                let l:leftover = strpart(getline('.'), col('.'))
                call cursor(l:next)
                execute 'silent ' . line('.') . ',' . l:end . 's/\<' . a:object['old_name'] . '\>' . l:param_search . '\(' . l:leftover . '\)/' . 
                            \ a:object['old_name'] . '\1' . l:insert[i] . '\2/e'
                call cursor(l:next)
            endif

            let l:next = searchpos(l:func_search, 'Wn')
        endwhile
    endfor

    call cursor(l:orig)
    silent write!
endfunction

" update_param_hierarchy {{{3
"
" Updates the lower hierarchy of object, adding param_name to any definitions
" of object. 
function! s:update_param_hierarchy(object, param_name, param_type, default)
    let l:class_name = expand('%:t:r')

    " Find any files in a:object's downward hierarchy that reference the
    " method being modified.
    try
        execute 'silent lvimgrep /\(\<super\>\.\|\<this\>\.\|[^.]\)\<' . a:object['old_name'] . '\>(' . '/j ' . join(a:object['sub_files'])
    catch /.*/
        return
    endtry

    " For each subclass file that references the relevant method, update the
    " declaration and any inherited uses with the new parameter.
    let l:use_subs = map(getloclist(0),{key,val -> getbufinfo(val['bufnr'])[0]['name']})
    for file in l:use_subs
        execute 'silent tabedit! ' . file
        call cursor(1,1)
        call s:update_subclass_param_file(a:object, a:default, a:param_type, a:param_name)
        call factorus#util#safe_close()
    endfor
    silent edit!
endfunction

" update_param_using_file {{{3

" Adds a default parameter to all valid uses of object in the current file.
function! s:update_param_using_file(object, default)
    call s:go_to_tag(1)
    call cursor(line('.') + 1, 1)

    " Define all the various search patterns we're looking for.
    let l:classes = '\<\(' . join(a:object['sub_classes'], '\|') . '\)\>'
    let l:search = '\.' . a:object['old_name'] . '('
    if a:object['is_static']
        let l:search = l:classes . l:search
    endif

    let [l:param_search, l:insert] = ['',a:default . ')']
    if a:object['num_params'] > 0
        let l:insert = ', ' . l:insert
        let l:param_search = '\_[^;]\{-\}' . repeat(',\_[^;]\{-\}', a:object['num_params'] - 1)
    endif
    let l:param_search = '\((' . l:param_search . '\))'

    " For each match of our search, we check if the number of arguments
    " matches. If that's true, and either the method is static or the using
    " variable is valid, we add a:default to the method.
    let l:next = searchpos(l:search, 'Wn')
    while l:next != [0,0]
        call cursor(l:next)
        if s:get_args() == a:object['num_params'] && (a:object['is_static'] || s:is_valid_use(a:object))
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : factorus#util#trim(getline('.'))})
            call search('(')
            normal %
            let l:end = line('.')
            let l:leftover = strpart(getline('.'),col('.'))
            call cursor(l:next)
            execute 'silent ' . line('.') . ',' . l:end . 's/\<' .a:object['old_name'] . '\>' . l:param_search . '\(' . l:leftover . '\)/' . 
                        \ a:object['old_name'] . '\1' . l:insert . '\2/e'
            call cursor(l:next)
        endif

        let l:next = searchpos(l:search,'Wn')
    endwhile

    silent write!
endfunction

" update_param_references {{{3
"
" Adds a default parameter to all valid uses of object.
function! s:update_param_references(object, default)
    let l:temp_file = '.FactorusParam'
    let l:class_names = join(a:object['sub_classes'], '\|')

    " Find all possible uses of the relevant method, and put them in a
    " temporary file.
    call factorus#util#find_tags(l:temp_file, '\.' . a:object['old_name'] . '(', 'no')
    call factorus#util#narrow_tags(l:temp_file, '\(' . l:class_names . '\)')
    let l:files = readfile(l:temp_file)

    " Go through all the candidate files and update them with the default
    " parameter value.
    for file in l:files
        execute 'silent tabedit! ' . file
        call s:update_param_using_file(a:object, a:default)
        call factorus#util#safe_close()
    endfor
    silent edit!

    call system('rm -rf ' . l:temp_file)
endfunction

" Renaming {{{2
" get_object_attributes {{{3

" Gets the attributes of an object to be renamed, in the form of a dictionary.
" Which attributes get returned depends on a:type.
function! s:get_object_attributes(type)
    let l:orig = [line('.'), col('.')]
    let l:object = {'category': a:type, 'is_method': 0, 'is_static': 0, 'is_local': 0}

    " Get the definition of the object, its name, whether or not it's local or
    " static, etc.
    if a:type == 'Arg'
        let l:object['old_name'] = expand('<cword>')
        let l:object['is_local'] = 1
    elseif a:type == 'Class'
        let l:object['old_name'] = expand('%:t:r')
        let l:object['old_file'] = expand('%:p')
        let l:object['dir'] = expand('%:p:h')
        let l:object['package'] = s:get_package(l:object['old_file'])
    elseif a:type == 'Field'
        let l:search = '^\s*' . s:access_query . '\(' . s:java_identifier . s:collection_identifier . '\=\)\=\s*\(' . s:java_identifier . '\)\s*[;=].*'
        let l:line = getline('.')

        let l:object['is_static'] = match(l:line,'\<static\>') >= 0 ? 1 : 0
        let l:object['is_local'] = s:get_adjacent_tag('b') != s:get_class_tag()[0]
        let l:type = substitute(l:line,l:search,'\4','')
        let l:name = substitute(l:line,l:search,'\6','')

        if l:name == '' || l:type == '' || match(l:name, '[^' . s:search_chars . ']') >= 0
            if l:object['is_local'] == 1 || match(getline(s:get_class_tag()[0]), '\<enum\>') < 0
                throw 'Factorus:Invalid'
            endif

            let l:object['old_name'] = expand('<cword>')
            let l:object['enum'] = expand('%:t:r')
        else
            let l:object['old_name'] = l:name
            let l:object['type'] = l:type
        endif
    elseif a:type == 'Method'
        call s:go_to_tag(0)

        let l:next = searchpos(')', 'Wn')
        let l:func_def = join(getline(line('.'), l:next[0]))

        let l:search = '^.*\<\(' . s:java_identifier . s:collection_identifier . '\=\)\s*\<\(' . s:java_identifier . '\)\>\s*(\(.*\)).*'
        let [l:method_type, l:method_name, l:params] = split(substitute(l:func_def, l:search, '\1 | \3 | \4', ''), '|') 
        let [l:method_type, l:method_name] = [factorus#util#trim(l:method_type), factorus#util#trim(l:method_name)]
        let l:is_static = (match(l:func_def, '\<static\>') >= 0)

        let l:count = 0
        while v:true
            let l:cut_params = substitute(l:params,'\(' . s:java_identifier . s:collection_identifier . '\=\s*\<' . s:java_identifier . '\>\)\(.*\)','\3','')
            if l:cut_params == l:params
                break
            endif
            let l:count += 1
            let l:params = l:cut_params
        endwhile

        let l:object['def'] = l:func_def
        let l:object['type'] = l:method_type
        let l:object['old_name'] = l:method_name
        let l:object['num_params'] = l:count
        let l:object['is_static'] = l:is_static
        let l:object['is_method'] = 1
    endif

    call cursor(l:orig)
    return l:object
endfunction

" get_referring_files {{{3

" Gets any files that may refer to a:object. These files will be updated in
" update_referring_files. 
function! s:get_referring_files(object, type)

    " If we're renaming an argument, we only need to modify the current file.
    if a:type == 'Arg'
        let a:object['files'] = [expand('%:p')]
    " If we're renaming a class, we need to update any files that may
    " reference the class, which would be all files in the same package and
    " all files that import that package.
    elseif a:type == 'Class'
        let l:temp_file = '.Factorus' . a:object['old_name']
        call s:get_package_files(l:temp_file)

        if a:object['package'] != ''
            call factorus#util#find_tags(l:temp_file, a:object['package'], 'yes')
            call factorus#util#narrow_tags(l:temp_file, '\<' . a:object['old_name'] . '\>')
        endif

        let a:object['temp_file'] = l:temp_file
    " If we're renaming a field or method, we need to update the file in which
    " it's defined. We also need to update all files that reference this
    " field/method; if it's local, this isn't any files, but otherwise we need
    " to get subclass files and referencing files.
    " TODO: Currently, subclass files and referencing files are considered two
    " distinct entities when updating, but that may not be necessary.
    elseif a:type == 'Field' || a:type == 'Method'
        " If we're renaming an enum field, we just need files referencing that
        " enum.
        " TODO: This may not be the best way to do things.
        if has_key(a:object, 'enum')
            let l:temp_file = '.FactorusEnum'
            call factorus#util#find_tags(l:temp_file,l:enum_name . '\.' . l:var,'no')

            let a:object['temp_file'] = l:temp_file
        " If it's not an enum field and isn't local, we need to first jump
        " into the highest-level defining class, then get all subclasses and
        " all referencing classes.
        elseif !a:object['is_local']
            " Get the upwards hierarchy, and jump into the highest-level file
            " that defines this function (maybe an interface, for example).
            let [l:paren, l:end_search] = (a:type == 'Method') ? ['(', '('] : ['', '[;=]']
            let l:def_search = s:no_comment . s:access_query . s:java_identifier . s:collection_identifier . '\=\_s\+\<' . a:object['old_name'] . '\>\_s*' . l:end_search
            let l:inherited = s:get_declaration_file(l:def_search)

            " Get all subclasses that inherit this highest-level class.
             let [l:sub_files, l:sub_classes] = s:get_downward_hierarchy()
             let l:class_names = join(l:sub_classes, '\|')
             let l:temp_file = '.Factorus' . a:object['old_name'] . 'References'

            " Get all referencing files that may need to be updated.
            if a:object['is_static'] == 1
                let l:search = '\<\(' . l:class_names . '\)\>\.\<' . a:object['old_name'] . '\>' . l:paren
                call factorus#util#find_tags(l:temp_file, l:search, 'no')
            else
                call factorus#util#find_tags(l:temp_file, '\.' . a:object['old_name'] . l:paren, 'no')
                call factorus#util#narrow_tags(l:temp_file, '\(' . l:class_names . '\)')
            endif

            let a:object['temp_file'] = l:temp_file
            let a:object['sub_files'] = l:sub_files
            let a:object['sub_classes'] = l:sub_classes

            " If we had to jump into a higher-level file, get out of it.
            if l:inherited
                let a:object['def_file'] = expand('%:p')
                let a:object['def_line'] = line('.')
                call factorus#util#safe_close()
            endif
        endif
    endif
endfunction

" update_using_file {{{3

" Renames all valid uses of object to new_name, in a file that references object.
function! s:update_using_file(object, new_name) abort
    " Jump to the top of the file and search for the next use of object.
    call s:go_to_tag(1)
    call cursor(line('.') + 1, 1)
    let l:classes_search = '\<\(' . join(a:object['sub_classes'], '\|') . '\)\>'
    let l:paren = a:object['is_method'] ? '(' : ''

    let l:search = '\.' . a:object['old_name'] . l:paren
    let l:next = searchpos(l:search, 'Wn')

    " For each use of object, we check if the using variable is actually the
    " same class/subclass we want it to be, and then update the reference if it's valid.
    while l:next != [0,0]
        call cursor(l:next)

        " Get the variable using a:object. If the using variable is valid, rename the use of the field/method.
        if s:is_valid_use(a:object)
            call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : factorus#util#trim(getline('.'))})
            execute 'silent s/\.\<' .a:object['old_name'] . '\>' . l:paren . '/.' . a:new_name . l:paren . '/e'
        endif

        let l:next = searchpos(l:search,'Wn')
    endwhile

    silent write!
endfunction

" update_references {{{3

" Updates all references to a:object in files where it is just used (not
" defined).
function! s:update_references(object, new_name) abort
    let l:temp_file = '.Factorus' . a:new_name . 'References'
    let l:class_names = join(a:object['sub_classes'], '\|')
    let l:paren = a:object['is_method'] ? '(' : ''

    " Get all files that might possibly refer to object and put them in
    " temp_file.
    call factorus#util#find_tags(l:temp_file, '\.' . a:object['old_name'] . l:paren, 'no')
    call factorus#util#narrow_tags(l:temp_file, '\(' . l:class_names . '\)')
    let l:files = readfile(l:temp_file)

    " Go through each file and update any valid references to object in them.
    for file in l:files
        execute 'silent tabedit! ' . file
        call s:update_using_file(a:object, a:new_name)
        call factorus#util#safe_close()
    endfor
    silent edit!

    call system('rm -rf ' . l:temp_file)
endfunction

" update_referring_files {{{3

" Updates all references to a:object in a:files.
function! s:update_referring_files(object, type, new_name)

    " If we're just renaming a method-local object, we do that.
    if a:type == 'Arg' || a:object['is_local']
        call s:update_file(a:object, a:new_name)
        return
    endif

    " If we're renaming a class, static object, or enum field, part of that
    " will involve a global find-replace; renaming a class also involves
    " creating a new file and deleting the old one.
    if a:type == 'Class' || has_key(a:object, 'enum') || a:object['is_static'] == 1 
        if a:type == 'Class'
            let l:search = '\<' . a:object['old_name'] . '\>'
            let l:replace = a:new_name
        elseif has_key(a:object, 'enum')
            call add(g:factorus_qf, {'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : factorus#util#trim(getline('.'))})
            execute 'silent s/\<' . a:object['old_name'] . '\>/' . a:new_name . '/e'
            silent write!

            let l:search = a:object['enum'] . '\.' . a:object['old_name']
            let l:replace = a:object['enum'] . '\.' . a:new_name
        else
            let l:paren = (a:type == 'Method') ? '(' : ''
            let l:search = '\<\(' . join(a:object['sub_classes'],'\|') . '\)\>\.\<' . a:object['old_name'] . '\>' . l:paren
            let l:replace = '\1\.' . a:new_name . l:paren
        endif

        call factorus#util#update_quick_fix(a:object['temp_file'], l:search)
        call system('cat ' . a:object['temp_file'] . ' | xargs sed -i "s/' . l:search . '/' . l:replace . '/g"')  

        if a:type == 'Class'
            let l:bufnr = bufnr('%')
            let l:new_file = a:object['dir'] . '/' . a:new_name . '.java'

            call system('mv ' . a:object['old_file'] . ' ' . l:new_file)
            call system('rm -rf ' . a:object['temp_file'])

            execute 'silent edit! ' . l:new_file
            execute 'silent! bwipeout ' . l:bufnr
        endif
    endif

    " If we're renaming a method or non-enum field, we first need to update
    " the hierarchy (where it's defined), then update any uses of object.
    if a:type == 'Method' || (a:type == 'Field' && !has_key(a:object, 'enum'))
        redraw
        echo 'Updating hierarchy...'
        call s:update_hierarchy(a:object, a:new_name)

        if !a:object['is_static']
            redraw
            echo 'Updating references...'
            call s:update_references(a:object, a:new_name)
        endif
    endif

    " Lastly, if we created a temp file for this rename, we just delete it.
    if has_key(a:object, 'temp_file')
        call system('rm -rf ' . a:object['temp_file'])
    endif

endfunction

" Extraction {{{2
" get_params {{{3

" Returns all parameters of the current function.
function! s:get_params() abort
    let l:prev = [line('.'),col('.')]
    call s:go_to_tag(0)
    let l:oparen = search('(','Wn')
    let l:cparen = search(')','Wn')
    
    " Get the string of declarations; if it's empty, there are no
    " declarations.
    let l:dec = join(getline(l:oparen, l:cparen))
    let l:dec = substitute(l:dec, '.*(\(.*\)).*','\1','')
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
            call add(l:args, strpart(l:dec, l:prev, (l:i - l:prev)))
            let l:prev = l:i + 1
        elseif char == '>'
            let l:car -= 1
        elseif char == '<'
            let l:car += 1
        endif
        let l:i += 1
    endwhile
    call add(l:args, strpart(l:dec, l:prev,len(l:dec) - l:prev))
    call map(l:args, {n, arg -> [split(arg)[-1], join(split(arg)[:-2]), line('.')]})

    call cursor(l:prev)
    return l:args
endfunction

" get_next_dec {{{3

" Gets the next variable declaration, starting from current line.
function! s:get_next_dec()
    " Define our regex searches; l:get_variable is our general search, which
    " includes for loop declarations, while l_alt_get is for specifically
    " finding declarations that aren't part of the for loop.
    let l:get_variable = '^\s*\(' . s:access_query . '\|for\s*(\)\s*\(' . s:java_identifier . 
                \ s:collection_identifier . '\=\)\s\+\(\<' . s:java_identifier . '\>[^:=;]*\)[;=:].*'
    
    let l:alt_get = '^\s*' . s:access_query . '\s*\(' . s:java_identifier . 
                \ s:collection_identifier . '\=\)\s\+\(\<' . s:java_identifier . '\>[^=;]*\)[=;].*'

    let [l:line,l:col] = [line('.'), col('.')]

    " Find the first match that isn't a return statement.
    let l:match = searchpos(l:get_variable, 'Wn')
    while l:match != [0,0] && match(getline(l:match[0]), '\<return\>') >= 0
        call cursor(l:match)
        let l:match = searchpos(l:get_variable, 'Wn')
    endwhile
    call cursor(l:line, l:col)

    " If the declaration is in the for loop, use l:get_variable to grab the
    " declaration. Otherwise, use l:alt_get.
    if factorus#util#is_before([l:line, l:col], l:match) == 1
        if match(getline(l:match[0]), '\<for\>') >= 0
            let l:var = substitute(getline(l:match[0]), l:get_variable, '\5','')
            let l:fline = split(substitute(getline(l:match[0]), l:get_variable, '\7', ''), ',')
        else
            let l:var = substitute(getline(l:match[0]), l:alt_get, '\4', '')
            let l:fline = split(substitute(getline(l:match[0]), l:alt_get, '\6', ''), ',')
        endif
        call map(l:fline, {n, var -> s:trim(var)})
        call map(l:fline, {n, var -> substitute(var, '^\<\(' . s:java_identifier . '\)\>.*', '\1', '')})

        return [l:var, l:fline, l:match]
    endif

    return ['none', [], [0, 0]]
endfunction

" get_local_decs {{{3

" Returns all declarations until close, including function arguments,
" variables declared within functions, and variables declared within for loops
" within function.
function! s:get_local_decs(close)
    let l:vars = s:get_params()

    let l:orig = [line('.'),col('.')]
    let l:next = s:get_next_dec()

    " As long as the next declaration is before a:close, add the next
    " declaration to l:vars.
    while factorus#util#is_before(l:next[2], a:close)
        if l:next[2] == [0,0]
            break
        endif
        
        let l:type = l:next[0]
        for name in l:next[1]
            call add(l:vars, [name, l:type, l:next[2][0]])
        endfor

        call cursor(l:next[2])
        let l:next = s:get_next_dec()
    endwhile
    call cursor(l:orig)

    return l:vars   
endfunction

" get_all_blocks {{{3

" Get all blocks of a function. A block is a segment of code like an if
" statement, loop, etc.
function! s:get_all_blocks(close)
    " Define all of our search sequences for various blocks.
    let l:if = '\<if\>\_s*(\_[^{;]*)\_s*{\='
    let l:for = '\<for\>\_s*(\(\_[^{;]*;\_[^{;]*;\_[^{;]*\|\_[^{;]*:\_[^{;]*\))\_s*{\='
    let l:while = '\<while\>\_s*(\_[^{;]*)'
    let l:try = '\<try\>\_s*{'
    let l:do = '\<do\>\_s*{'
    let l:switch = '\<switch\>\_s*(\_[^{]*)\_s*{'
    let l:search = '\(' . l:if . '\|' . l:for . '\|' . l:while . '\|' . l:try . '\|' . l:do . '\|' . l:switch . '\)'

    let l:orig = [line('.'), col('.')]
    call s:go_to_tag(0)
    let l:blocks = [[line('.'), a:close[0]]]

    " For each block, we need to find the last line of that block, and add it
    " to l:blocks.
    let l:open = searchpos('{', 'Wn')
    let l:next = searchpos(l:search, 'Wn')
    while l:next[0] <= a:close[0]
        if l:next == [0, 0]
            break
        endif
        call cursor(l:next)

        " If the match is an elseif block or the end of a do/while loop, we
        " just move on.
        if match(getline('.'), '\<else\>') >= 0 || match(getline('.'), '}\s*\<while\>') >= 0
            let l:next = searchpos(l:search, 'Wn')
            continue
        endif

        " If we find an if/try/for/while block, we essentially add the blocks
        " between the {} brackets.
        if match(getline('.'), '\<\(if\|try\|for\|while\)\>') >= 0
            let l:open = [line('.'), col('.')]
            call search('(')
            normal %

            let l:ret =  searchpos('{', 'Wn')
            let l:semi = searchpos(';', 'Wn')

            " If this is a single-line statement (i.e., no brackets), we just
            " add those lines and move on.
            let l:o = line('.')
            if factorus#util#is_before(l:semi, l:ret) == 1
                call cursor(l:semi)
                call add(l:blocks, [l:open[0], line('.')])
            " Otherwise, if this is an if/try block, we may need to get
            " multiple parts of the block (else, catch, etc.)
            elseif match(getline('.'), '\<\(if\|try\)\>') >= 0
                call cursor(l:ret)
                normal %

                " As long as there is another part of the if/try block, we
                " isolate that part and add it.
                let l:continue = '}\_s*\(else\_s*\(\<if\>\_[^{]*)\)\=\|\<catch\>\_[^{]*\|\<finally\>\_[^{]*\){'
                let l:next = searchpos(l:continue, 'Wnc')
                while l:next == [line('.'), col('.')]
                    if l:next == [0, 0]
                        let l:next = l:ret
                        break
                    endif
                    call add(l:blocks, [l:o, line('.')])
                    call search('{', 'W')
                    let l:o = line('.')
                    normal %

                    let l:next = searchpos(l:continue, 'Wnc')
                endwhile
                call add(l:blocks, [l:o, line('.')])
                if l:o != l:open[0]
                    call add(l:blocks, [l:open[0], line('.')])
                endif
            " If we just found a for/while loop, we can just jump to the } and
            " add all those lines.
            else
                call search('{', 'W')
                let l:prev = [line('.'), col('.')]
                normal %
                call add(l:blocks, [l:next[0], line('.')])
                call cursor(l:prev)
            endif

            call cursor(l:open)
        " If we found a switch block, we also add every case statement as a
        " separate block.
        elseif match(getline('.'), '\<switch\>') >= 0
            let l:open = [line('.'), col('.')]
            call searchpos('{', 'W')

            normal %
            let l:sclose = [line('.'), col('.')]
            normal %

            let l:continue = '\<\(case\|default\)\>[^:]*:'
            let l:next = searchpos(l:continue, 'Wn')

            " For each case/default block, add that to the list of blocks.
            while factorus#util#is_before(l:next, l:sclose) && l:next != [0, 0]
                call cursor(l:next)
                let l:next = searchpos(l:continue, 'Wn')
                if factorus#util#is_before(a:close, l:next) == 1 || l:next == [0, 0]
                    call add(l:blocks, [line('.'), a:close[0]])
                    break
                endif
                call add(l:blocks, [line('.'), l:next[0]-1])
            endwhile
            call add(l:blocks, [l:open[0], l:sclose[0]])
        " Finally, if we found a do block, add that to the list of blocks.
        " TODO: I think we can wrap this into the for/while blocks?
        else
            call search('{', 'W')
            let l:prev = [line('.'), col('.')]
            normal %
            call add(l:blocks, [l:next[0], line('.')])
            call cursor(l:prev)
        endif

        let l:next = searchpos(l:search, 'Wn')
    endwhile

    call cursor(l:orig)
    return uniq(sort(l:blocks, 'factorus#util#compare_blocks'))
endfunction

" get_next_reference {{{3
function! s:get_next_reference(var, type, ...)
    if a:type == 'right'
        let l:search = s:no_comment . s:access_query . '\s*\(' . s:java_identifier . s:collection_identifier . 
                    \ '\=\s\)\=\s*\(' . s:java_identifier . '\)\s*[(.=]\_[^{;]*\<\(' . a:var . '\)\>\_.\{-\};'
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

    let l:line = searchpos(l:search, 'Wn')
    let l:endline = s:get_endline(l:line, l:search)
    if a:type == 'right'
        let l:prev = [line('.'), col('.')]
        while !s:is_valid_tag(l:line[0])
            if l:line == [0, 0]
                break
            endif

            if match(getline(l:line[0]), '\<\(new\|true\|false\)\>') >= 0 
                break
            endif

            call cursor(l:line)
            let l:line = searchpos(l:search, 'Wn')
            let l:endline = s:get_endline(l:line, l:search)
        endwhile
        call cursor(l:prev)
    endif

    if l:line[0] > line('.')
        let l:state = join(getline(l:line[0], l:endline[0]))
        if a:type == 'cond'
            let l:for = match(l:state, '\<for\>')
            let l:c = match(l:state, '\<\(switch\|while\|if\|else\s\+if\)\>')
            if l:c == -1 || (l:for != -1 && l:for < l:c)
                let l:index = '\4'
                let l:alt_index = '\5'
            endif
        endif
        let l:loc = substitute(l:state, l:search, l:index, '')
        if a:type == 'left'
            let l:loc = substitute(l:loc, '.*\<\(' . a:var . '\)\>.*', '\1', '')
        endif
        if a:0 > 0 && a:1 == 1
            let l:name = substitute(l:state, l:search, l:alt_index, '')
            if a:type == 'left'
                let l:name = l:loc
            endif
            return [l:loc, l:line, l:name]
        endif
        return [l:loc, l:line]
    endif
        
    return (a:0 > 0 && a:1 == 1) ? ['none', [0, 0], 'none'] : ['none', [0, 0]]
endfunction


" get_next_use {{{3
function! s:get_next_use(var, ...)
    let l:right = s:get_next_reference(a:var, 'right', a:0)
    let l:left = s:get_next_reference(a:var, 'left', a:0)
    let l:cond = s:get_next_reference(a:var, 'cond', a:0)
    let l:return = s:get_next_reference(a:var, 'return', a:0)

    let l:min = [l:right[0], copy(l:right[1]), 'right']
    let l:min_name = a:0 > 0 ? l:right[2] : ''

    let l:poss = [l:right, l:left, l:cond, l:return]
    let l:idents = ['right', 'left', 'cond', 'return']
    for i in range(4)
        let temp = l:poss[i]
        if temp[1] != [0, 0] && (factorus#util#is_before(temp[1], l:min[1]) == 1 || l:min[1] == [0, 0])
            let l:min = [temp[0], copy(temp[1]), l:idents[i]]
            if a:0 > 0
                let l:min_name = temp[2]
            endif
        endif
    endfor

    if a:0 > 0
        call add(l:min, l:min_name)
    endif

    return l:min
endfunction

" get_all_relevant_lines {{{3

" Gets all relevant lines for each var in vars.
function! s:get_all_relevant_lines(vars, names, close)

    " Get original position and previous tag.
    let l:orig = [line('.'), col('.')]
    let l:begin = s:get_adjacent_tag('b')

    let l:lines = {}
    let l:closes = {}
    let l:isos = {}

    " For each variable, we get the line it's defined on and add that to its
    " relevant lines.
    for var in a:vars
        call cursor(var[2], 1)
        " If var is defined in a for loop, we need to add all the lines of the
        " for loop.
        if match(getline('.'), '\<for\>') >= 0
            call search('(')
            normal %
            if factorus#util#is_before(searchpos(';', 'Wn'), searchpos('{', 'Wn'))
                let l:start_lines = range(var[2], search(';', 'Wn'))
            else
                call search('{')
                normal %
                let l:start_lines = range(var[2], line('.'))
            endif
            call cursor(var[2], 1)
        " Otherwise, we just add the defining line.
        else
            let l:start_lines = [var[2]]
        endif
        " We add the various definition lines of var to l:lines, and add the
        " closing part of its block to l:closes.
        let l:local_close = var[2] == l:begin ? s:get_closing_bracket(1) : s:get_closing_bracket(0)
        let l:closes[var[0]] = copy(l:local_close)
        call cursor(l:orig)
        if index(keys(l:lines), var[0]) < 0
            let l:lines[var[0]] = {var[2] : l:start_lines}
        else
            let l:lines[var[0]][var[2]] = l:start_lines
        endif
        let l:isos[var[0]] = {}
    endfor

    let l:search = join(a:names, '\|')
    let l:next = s:get_next_use(l:search, 1)

    " For each use of a variable, we need to add it to l:lines.
    while factorus#util#is_before(l:next[1], a:close) == 1
        if l:next[1] == [0, 0]
            break
        endif

        let l:pause = copy(l:next)
        let l:new_search = l:search
        while l:pause[1] == l:next[1]
            let l:name = l:next[3]

            let l:ldec = s:get_latest_dec(l:lines, l:name, l:next[1])

            let l:quoted = s:is_quoted('\<' . l:name . '\>', s:get_statement(l:next[1][0]))
            if factorus#util#is_before(l:next[1], l:closes[l:name])1 && !l:quoted && l:ldec > 0
                if index(l:lines[l:name][l:ldec], l:next[1][0]) < 0
                    call add(l:lines[l:name][l:ldec], l:next[1][0])
                endif
            endif

            if match(l:new_search, '\\|') < 0
                break
            endif

            let l:new_search = substitute(l:new_search, '\\|\<' . l:name . '\>', '', '')
            let l:new_search = substitute(l:new_search, '\<' . l:name . '\>\\|', '', '')

            let l:next = s:get_next_use(l:new_search, 1)
        endwhile
        let l:next = copy(l:pause)

        call cursor(l:next[1])
        let l:next = s:get_next_use(l:search, 1)
    endwhile
    
    call cursor(l:orig)
    return [l:lines, l:isos]
endfunction

" init_extraction {{{3

" Gets all necessary variables for extractMethod.
"
" Return values:
"   orig: Original position of cursor.
"   tab: The indent level of the current method.
"   method_name: Name of the current method.
"   open: First line of the current method.
"   close: Last line of the current method.
"   old_lines: All lines of the current method.
"   vars: All variables defined in the current method.
"   compact: Compactified list of all names and declarations.
"   blocks: All blocks within the current method.
"   all: All relevant lines for each defined variable.
"   isos: All isolated lines for each defined variable.
function! s:init_extraction()
    let l:orig = [line('.'), col('.')]
    call s:go_to_tag(0)

    let l:tab = substitute(getline('.'), '\(\s*\).*', '\1', '')
    let l:method_name = substitute(getline('.'), '.*\s\+\(' . s:java_identifier . '\)\s*(.*', '\1', '')

    " Get the opening and closing lines, and copy those lines of code in case
    " we need to roll back.
    let [l:open, l:close] = [line('.'), s:get_closing_bracket(1)]
    let l:old_lines = getline(l:open, l:close[0])

    " Jump to opening bracket of function
    call searchpos('{', 'W')

    " Get all variables defined in method, not referenced.
    let l:vars = s:get_local_decs(l:close)
    let l:names = map(deepcopy(l:vars), {n, var -> var[0]})
    let l:decs = map(deepcopy(l:vars), {n, var -> var[2]})
    let l:compact = [l:names, l:decs]

    " Get all blocks of code (if statements, loops, etc.)
    let l:blocks = s:get_all_blocks(l:close)

    let [l:all, l:isos] = s:get_all_relevant_lines(l:vars, l:names, l:close)

    return [l:orig, l:tab, l:method_name, l:open, l:close, l:old_lines, l:vars, l:compact, l:blocks, l:all, l:isos]
endfunction

" get_containing_block {{{3
function! s:get_containing_block(line, ranges, exclude)
    for range in a:ranges
        if range[0] > a:line
            return [a:line, a:line]
        endif

        if range[1] >= a:line && range[0] > a:exclude[0]
            return range
        endif
    endfor
    return [a:line, a:line]
endfunction

" is_isolated_block {{{3
function! s:is_isolated_block(block, var, rels, close)
    let l:orig = [line('.'), col('.')]
    call cursor(a:block[0], 1)
    if a:block[1] - a:block[0] == 0
        call cursor(line('.')-1, 1)
    endif

    let l:search = join(keys(a:rels), '\|')
    let l:search = substitute(l:search, '\\|\<' . a:var[0] . '\>', '', '')
    let l:search = substitute(l:search, '\<' . a:var[0] . '\>\\|', '', '')
    let l:ref = s:get_next_reference(l:search, 'left', 1)
    let l:return = search('\<\(return\)\>', 'Wn')
    let l:continue = search('\<\(continue\|break\)\>', 'Wn')

    let l:res = 1
    if factorus#util#contains(a:block, l:return) == 1
        let l:res = 0
    elseif s:contains(a:block, l:continue)
        call cursor(l:continue, 1)
        let l:loop = searchpair('\<\(for\|while\)\>', '', '}', 'Wbn')
        if l:loop != 0 && l:loop < a:block[0]
            let l:res = 0
        endif
    else
        while l:ref[1] != [0, 0] && factorus#util#is_before(l:ref[1], [a:block[1]+1, 1]) == 1
            let l:i = s:get_latest_dec(a:rels, l:ref[2], l:ref[1])
            if s:contains(a:block, l:i) == 0
                let l:res = 0
                break
            endif
            call cursor(l:ref[1])
            let l:ref = s:get_next_reference(l:search, 'left', 1)
        endwhile
    endif

    call cursor(l:orig)
    return l:res
endfunction

" get_isolated_lines {{{3
function! s:get_isolated_lines(var, compact, rels, blocks, close)
    let l:refs = a:rels[a:var[0]][a:var[2]]
    let [l:names, l:decs] = a:compact

    if len(l:refs) == 1
        return []
    endif

    let l:orig = [line('.'), col('.')]
    let [l:name, l:type, l:dec] = a:var

    let l:wraps = []
    if match(getline(a:var[2]), '\<for\>') >= 0
        let l:for = s:get_containing_block(a:var[2], a:blocks, a:blocks[0])
        if s:is_isolated_block(l:for, a:var, a:rels, a:close) == 0
            return []
        endif
    endif
    let l:dec_block = s:get_containing_block(a:var[2], a:blocks, a:blocks[0])
    if l:dec_block[1] - l:dec_block[0] == 0
        call add(l:wraps, copy(a:blocks[0]))
    endif
    call add(l:wraps, s:get_containing_block(l:refs[1], a:blocks, a:blocks[0]))

    let l:usable = []
    for i in range(len(l:wraps))
        let twrap = l:wraps[i]
        let l:temp = []

        let l:next_use = s:get_next_reference(a:var[0], 'right')
        call cursor(l:next_use[1])

        let l:block = [0, 0]
        for j in range(i, len(l:refs)-1)
            let line = l:refs[j]

            if line == l:next_use[1][0]
                if index(l:names, l:next_use[0]) >= 0
                    break
                endif
                call cursor(l:next_use[1])
                let l:next_use = s:get_next_reference(a:var[0], 'right')
            endif
            if line >= l:block[0] && line <= l:block[1]
                continue
            endif

            let l:block = s:get_containing_block(line, a:blocks, twrap)
            if l:block[0] < twrap[0] || l:block[1] > twrap[1]
                break
            endif

            if s:is_isolated_block(l:block, a:var, a:rels, a:close) == 0 
                break
            endif

            if l:block[1] - l:block[0] == 0 && match(getline(l:block[0]), '\<\(try\|for\|if\|while\)\>') < 0
                let l:stop = l:block[0]
                while match(getline(l:stop), ';') < 0
                    let l:stop += 1
                endwhile
                let l:block[1] = l:stop
            endif
            let l:i = l:block[0]
            while l:i <= l:block[1]
                if index(l:temp, l:i) < 0
                    call add(l:temp, l:i)
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

" get_best_var {{{3

" Gets the best variable to extract the method around, according to the
" desired heuristic.
function! s:get_best_var(vars, compact, isos, all, blocks, open, close)
    let l:best_var = ['', '', 0]
    let l:best_lines = []
    let l:method_length = (a:close - line('.')) * 1.0

    " Go through all declared variables and try to extract 'isolated' lines.
    " Isolated means lines that can be extracted from the function without
    " breaking the rest of the function.
    for var in a:vars
        let l:iso = s:get_isolated_lines(var, a:compact, a:all, a:blocks, a:close)
        let a:isos[var[0]][var[2]] = copy(l:iso)

        let l:ratio = (len(l:iso) / l:method_length)
        if g:factorus_extract_heuristic == 'longest'
            if len(l:iso) > len(l:best_lines) && index(l:iso, a:open) < 0 "&& l:ratio < g:factorus_method_threshold
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
    if index(l:best_lines, l:best_var[2]) < 0 && l:best_var[2] != a:open
        let l:stop = l:best_var[2]
        let l:dec_lines = [l:stop]
        while match(getline(l:stop), ';') < 0
            let l:stop += 1
            call add(l:dec_lines, l:stop)
        endwhile

        let l:best_lines = l:dec_lines + l:best_lines
    endif

    return [l:best_var, l:best_lines]
endfunction

" manual_extract {{{3

" Manually extracts the code selected by the cursor.
function! s:manual_extract(args)
    " If we're just rolling back an extraction, roll it back and let the user
    " know.
    if factorus#util#is_rollback(a:args)
        call s:rollback_extraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif

    " Get the lines the user extracted and the name they want for the new
    " function (if any), and find the level of spacing that would make the new
    " method 'fit' with the current method. Also store the old method's lines,
    " in case we have to roll it back.
    let l:name = len(a:args) <= 2 ? g:factorus_method_name : a:args[2]

    echo 'Extracting new method...'
    call s:go_to_tag(0)
    let l:tab = substitute(getline('.'), '\(\s*\).*', '\1', '')
    let l:method_name = substitute(getline('.'), '.*\s\+\(' . s:java_identifier . '\)\s*(.*', '\1', '')

    let l:extract_lines = range(a:args[0], a:args[1])
    let l:old_lines = getline(l:open, l:close[0])

    " Get the structure of the current method--the name,
    " the variable declarations, the blocks, etc.
    let [l:orig, l:tab, l:method_name, l:open, l:close, l:old_lines, l:vars, l:compact, l:blocks, l:all, l:isos] = s:init_extraction()

    " Then, we wrap any necessary annotations around the new method, get all
    " the arguments needed for that function, and build the new method line by
    " line.
    let l:new_args = s:get_new_args(l:extract_lines, l:vars, l:all)
    let [l:final, l:rep] = s:build_new_method(l:extract_lines, l:new_args, l:blocks, l:vars, l:all, l:tab, l:close, l:name)

    " Once the method has been built, we add it to the file just after the
    " current method, and jump to it.
    call append(l:close[0], l:final)
    call append(l:extract_lines[-1], l:rep)

    let l:i = len(l:extract_lines) - 1
    while l:i >= 0
        call cursor(l:extract_lines[l:i], 1)
        d 
        let l:i -= 1
    endwhile

    call search('public.*\<' . l:name . '\>(')
    silent write!
    redraw
    echo 'Extracted ' . len(l:extract_lines) . ' lines from ' . l:method_name

    return [l:name, l:old_lines]   
endfunction

" Method-Building {{{2
" get_latest_dec {{{3
function! s:get_latest_dec(rels, name, loc)
    let l:min = 0
    for dec in keys(a:rels[a:name])
        if l:min <= dec && dec <= a:loc[0]
            let l:min = dec
        endif
    endfor
    return l:min
endfunction

" find_var {{{3
function! s:find_var(vars, names, name, dec)
    let l:i = index(a:names, a:name)
    let l:var = a:vars[l:i]
    while l:var[2] != a:dec
        let l:i = index(a:names, a:name, l:i + 1)
        let l:var = a:vars[l:i]
    endwhile
    return l:var
endfunction

" get_new_args {{{3
function! s:get_new_args(lines, vars, rels, ...)
    let l:names = map(deepcopy(a:vars), {n, var -> var[0]})
    let l:search = '[^.]\<\(' . join(l:names, '\|') . '\)\>'
    let l:search = s:no_comment . '.\{-\}' . l:search . '.*'
    let l:args = []

    for line in a:lines
        let l:this = getline(line)
        if match(l:this, '^\s*\(\/\/\|*\)') >= 0
            continue
        endif
        let l:new = substitute(l:this, l:search, '\1', '')
        while l:new != l:this
            let l:spot = str2nr(s:get_latest_dec(a:rels, l:new, [line, 1]))
            if l:spot == 0
                break
            endif
            let l:next_var = s:find_var(a:vars, l:names, l:new, l:spot)

            if index(l:args, l:next_var) < 0 && index(a:lines, l:spot) < 0 && (a:0 == 0 || l:next_var[0] != a:1[0] || l:next_var[2] == a:1[2]) 
                call add(l:args, l:next_var)
            endif
            let l:this = substitute(l:this, '\<' . l:new . '\>', '', 'g')
            let l:new = substitute(l:this, l:search, '\1', '')
        endwhile
    endfor
    return l:args
endfunction

" wrap_decs {{{3
function! s:wrap_decs(var, lines, vars, rels, isos, args, close)
    let l:head = s:get_adjacent_tag('b')
    let l:orig = [line('.'), col('.')]
    let l:fin = copy(a:lines)
    let l:fin_args = deepcopy(a:args)
    for arg in a:args

        if arg[2] == l:head
            continue
        endif

        let l:wrap = 1
        let l:name = arg[0]
        let l:next = s:get_next_use(l:name)

        while l:next[1] != [0, 0] && factorus#util#is_before(l:next[1], a:close) == 1
            if l:next[2] != 'left' && l:next[2] != 'return' && index(a:lines, l:next[1][0]) < 0
                let l:wrap = 0    
                break
            endif
            call cursor(l:next[1])
            let l:next = s:get_next_use(l:name)
        endwhile

        if l:wrap == 1
            let l:relevant = a:rels[arg[0]][arg[2]]
            let l:stop = arg[2]
            let l:dec = [l:stop]
            while match(getline(l:stop), ';') < 0
                let l:stop += 1
                call add(l:dec, l:stop)
            endwhile
            let l:iso = l:dec + a:isos[arg[0]][arg[2]]

            let l:con = 1
            for rel in l:relevant
                if index(l:iso, rel) < 0 && index(a:lines, rel) < 0 && match(getline(rel), '\<return\>') < 0
                    let l:con = 0
                    break
                endif
            endfor
            if l:con == 0
                continue
            endif

            let l:next_args = s:get_new_args(l:iso, a:vars, a:rels, arg)
            let l:fin = uniq(s:merge(l:fin, l:iso))

            call remove(l:fin_args, index(l:fin_args, arg))
            for narg in l:next_args
                if index(l:fin_args, narg) < 0 && narg[0] != a:var[0]
                    call add(l:fin_args, narg)
                endif
            endfor
        endif
        call cursor(l:orig)
    endfor

    call cursor(l:orig)
    return [l:fin, l:fin_args]
endfunction

" wrap_annotations {{{3
function! s:wrap_annotations(lines)
    for line in a:lines
        let l:prev = line - 1
        if match(getline(l:prev),'^\s*@') >= 0
            call add(a:lines,l:prev)
        endif
    endfor
    return uniq(sort(a:lines,'N'))
endfunction

" build_args {{{3
function! s:build_args(args,is_call)
    if a:is_call == 0
        let l:defs = map(deepcopy(a:args),{n,arg -> arg[1] . ' ' . arg[0]})
        let l:sep = '| '
    else
        let l:defs = map(deepcopy(a:args),{n,arg -> arg[0]})
        let l:sep = ', '
    endif
    return join(l:defs,l:sep)
endfunction

" format_method {{{3
function! s:format_method(def,body,spaces)
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

" build_new_method {{{3
function! s:build_new_method(lines,args,ranges,vars,rels,tab,close,...)
    let l:body = map(copy(a:lines),{n,line -> getline(line)})

    call cursor(a:lines[-1],1)
    let l:type = 'void'
    let l:return = ['}'] 
    let l:call = ''

    let l:outer = s:get_containing_block(a:lines[0],a:ranges,a:ranges[0])
    let l:include_dec = 1
    for var in a:vars
        if index(a:lines,var[2]) >= 0

            let l:outside = s:get_next_use(var[0])    
            if l:outside[1] != [0,0] && factorus#util#is_before(l:outside[1],a:close) == 1 && s:get_latest_dec(a:rels,var[0],l:outside[1]) == var[2]

                let l:contain = s:get_containing_block(var[2],a:ranges,a:ranges[0])
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

                    let l:inner = s:get_containing_block(a:lines[i+1],a:ranges,l:outer)
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

    let l:build = s:build_args(a:args,0)
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
    call s:format_method(l:def,l:body,a:tab)
    let l:final = [''] + l:def + l:body + ['']

    let l:arg_string = s:build_args(a:args,1)
    let l:call_space = substitute(getline(a:lines[-1]),'\(\s*\).*','\1','')
    let l:rep = [l:call_space . l:call . l:name . '(' . l:arg_string . ');']

    return [l:final,l:rep]
endfunction

" Rollback {{{2
" rollback_add_param {{{3

" Rolls back a parameter add command to the state before the command was initiated.
function! s:rollback_add_param()
    " Get the original state of the file.
    let [l:method_name, l:param_name, l:count] = g:factorus_history['old']

    " For each line in the changelog that was marked 'Modified', get the
    " change and add it to l:files.
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

    " For every file in l:files, make all the necessary changes.
    for file in keys(l:files)
        execute 'silent tabedit! ' . file
        for line in l:files[file]
            call cursor(line,1)
            let l:nline = search(l:method_name . '(','We')
            let l:call_count = 0
            while l:nline == line
                if s:get_args() == l:count
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
        call factorus#util#safe_close()
    endfor

    return 'Rolled back adding of param ' . l:param_name . '.'
endfunction

" rollback_encapsulation {{{3

" Rolls back an encapsulation command to the state before the command was initiated.
function! s:rollback_encapsulation()
    " Get the original state of the file.
    let l:orig = [line('.'),col('.')]
    let [l:var,l:type,l:is_pub] = g:factorus_history['old']
    let l:cap = substitute(l:var,'\(.\)\(.*\)','\U\1\E\2','')

    " If the old field was public, we need to reset it.
    if l:is_pub == 1
        execute 'silent s/\<private\>/public/e'
    endif
   
    " Get the encapsulated lines and remove them.
    let l:open = search('public ' . l:type . ' get' . l:cap . '() {','n')
    if match(getline(l:open-1),'^\s*$') >= 0
        let l:open -= 1
    endif

    let l:close = s:get_closing_bracket(1,[l:open,1])[0]
    if match(getline(l:close+1),'^\s*$') >= 0
        let l:close += 1
    endif
    execute 'silent ' . l:open . ',' . l:close . 'delete'

    let l:open = search('public void set' . l:cap . '(','n')
    let l:close = s:get_closing_bracket(1,[l:open,1])[0]

    if match(getline(l:close+1),'^\s*$') >= 0
        let l:close += 1
    endif

    execute 'silent ' . l:open . ',' . l:close . 'delete'
    call cursor(l:orig)
    silent write!
endfunction

" rollback_extraction {{{3

" Rolls back a method extraction command to the state before the command was initiated.
function! s:rollback_extraction()
    " Get the original state of the file.
    let l:method_name = g:factorus_history['old'][0]
    let l:open = search('public .*' . l:method_name . '(')
    let l:close = s:get_closing_bracket(1)[0]

    " Remove all the lines from the new method.
    if match(getline(l:open - 1), '^\s*$') >= 0
        let l:open -= 1
    endif

    if match(getline(l:close + 1), '^\s*$') >= 0
        let l:close += 1
    endif

    execute 'silent ' . l:open . ',' . l:close . 'delete'

    " Remove the lines from the modified old method, and insert the lines from
    " the unmodified old method.
    call search('\<' . l:method_name . '\>(')
    call s:go_to_tag(0)
    let l:open = line('.')
    let l:close = s:get_closing_bracket(1)[0]

    execute 'silent ' . l:open . ',' . l:close . 'delete'
    call append(line('.') - 1, g:factorus_history['old'][1])
    call cursor(l:open, 1)
    silent write!
endfunction
" rollback_rename {{{3

" Rolls back a rename command to the state before the command was initiated.
function! s:rollback_rename(new_name, type)
    " Get the original state of the file.
    let l:old = g:factorus_history['old']
    let l:new = g:factorus_history['args'][0]

    " If the last command renamed a class, we can just do it again.
    " TODO: This doesn't work if you're in a different file.
    if a:type == 'Class'
        call factorus#java#rename_something(a:new_name, a:type)
    " Otherwise, go through every line changed, and change the line back to
    " the old instance.
    else
        let l:files = {}
        " For each line in the changelog that was marked 'Modified', get the
        " change and add it to l:files.
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

        " For every file in l:files, make all the necessary changes.
        for file in keys(l:files)
            execute 'silent tabedit! ' . file
            for line in l:files[file]
                call cursor(line,1)
                execute 'silent! s/\<' . l:new . '\>/' . l:old . '/ge'
            endfor
            silent write!
            call factorus#util#safe_close()
        endfor
    endif

    return 'Rolled back renaming of ' . substitute(g:factorus_history['args'][-1],'\(.\)\(.*\)','\L\1\E\2','') . ' ' . l:old
endfunction

" Global Functions {{{1
" add_param {{{2
"
" Adss a new parameter with name a:param_name and type a:param_type to the
" current method, at the end of the current list of arguments.
function! factorus#java#add_param(param_name, param_type, ...) abort
    " Check if we're rolling back something, and if so run the rollback
    " function.
    if factorus#util#is_rollback(a:000)
        call s:rollback_add_param()
        let g:factorus_qf = []
        return 'Removed new parameter ' . a:param_name . '.'
    endif

    " Set the environment for changing the code.
    let g:factorus_qf = []
    let s:all_funcs = {}
    let [l:orig, l:prev_dir, l:curr_buf] = factorus#util#set_environment()

    try
        " Jump to the declaration of the function and isolate the end of its
        " declaration. Also determine its name, type, and whether or not it's
        " static.
        
        call s:go_to_tag(0)
        let l:object = s:get_object_attributes('Method')
        call s:get_referring_files(l:object, 'Method')
        if has_key(l:object, 'def_file')
            execute 'silent edit! ' . l:object['def_file']
            call cursor(l:object['def_line'], 1)
        endif

        " Get the number of other parameters in the function definition. If
        " there is at least one parameter, we need to add a comma.
        let l:comma = l:object['num_params'] > 0 ? ', ' : ''

        " Get the end of the function defintion, and append the new parameter
        " right before the parenthesis.
        " NOTE: Right now, the function always adds the new parameter on the
        " same line as the last parameter, even if the function is defined on
        " multiple lines. Maybe we can improve this.
        
        "let l:next = searchpos(')','Wn')
        "let l:line = substitute(getline(l:next[0]), ')', l:comma . a:param_type . ' ' . a:param_name . ')', '')
        "call add(g:factorus_qf,{'lnum' : line('.'), 'filename' : expand('%:p'), 'text' : factorus#util#trim(getline('.'))})
        "execute 'silent ' .  l:next[0] . 'd'
        "call append(l:next[0] - 1, l:line)
        "silent write!

        if g:factorus_add_default
            let l:default = a:0 > 0 ? a:1 : 'null'

            redraw
            echo 'Updating hierarchy...'
            let l:classes = s:update_param_hierarchy(l:object, a:param_name, a:param_type, l:default)

            redraw
            echo 'Updating references...'
            call s:update_param_references(l:object, l:default)

        endif
        redraw
        echo 'Added parameter ' . a:param_name . ' to method ' . l:object['old_name'] . '.'

        if has_key(l:object, 'def_file')
            call factorus#util#safe_close()
        endif

        if g:factorus_show_changes > 0
            call factorus#util#set_changes(l:object['old_name'], 'addParam')
        endif

        call factorus#util#reset_environment(l:orig, l:prev_dir, l:curr_buf, 'addParam')

        return [l:object['old_name'], a:param_name, l:object['num_params'] + 1]
    catch /.*/
        call factorus#util#reset_environment(l:orig, l:prev_dir, l:curr_buf, 'addParam')
        let l:err = match(v:exception, '^Factorus:') >= 0 ? v:exception : 'Factorus:' . v:exception
        throw l:err . ', at ' . v:throwpoint
    endtry
endfunction

" encapsulate_field {{{2

" Encapsulates the field on the current line, creating a getter and a setter
" function.
function! factorus#java#encapsulate_field(...) abort

    " Check if we're rolling back something, and if so run the rollback
    " function.
    if factorus#util#is_rollback(a:000)
        call s:rollback_encapsulation() 
        return 'Rolled back encapsulation for ' . g:factorus_history['old'][0]
    endif

    " If we're trying to encapsulate a local variable, don't allow it.
    " TODO: Possibility of a class defined in a class, which current
    " implementation wouldn't allow.
    let l:is_local = (s:get_class_tag()[0] == s:get_adjacent_tag('b')) ? 0 : 1
    if l:is_local
        throw 'Factorus:EncapLocal'
    endif

    " Get the current line and the things we need to encapsulate the variable.
    let l:line = getline('.')
    let l:search = '\(\s*\)' . s:access_query . '\(' . s:java_identifier . s:collection_identifier . '\=\)\_s*\(' . s:java_identifier . '\)\_s*[;=].*'

    " If the variable is static, don't let them encapsulate it.
    let l:is_static = (match(l:line, '\<static\>') >= 0)
    if l:is_static
        throw 'Factorus:EncapStatic'
    endif

    " Get type and name of variable, and capitalize variable name for getters
    " and setters.
    let l:type = substitute(l:line, l:search, '\5', '')
    let l:var = substitute(l:line, l:search, '\7', '')
    let l:tab = substitute(l:line, l:search, '\1', '')
    let l:cap = a:0 > 0 ? substitute(a:1, '\(.\)\(.*\)', '\U\1\E\2', '') : substitute(l:var, '\(.\)\(.*\)', '\U\1\E\2', '')

    " If we're encapsulating a non-private variable, make it private.
    let l:is_pub = 0
    if match(getline('.'), '\<\(public\|protected\)\>') >= 0
        let l:is_pub = 1
        execute 'silent! s/\<public\>/private/e'
    elseif match(getline('.'), '\<private\>') < 0
        execute 'silent! s/^\(\s*\)/\1private /e'
    endif

    " Create our getters and setters for the encapsulated variable.
    let l:get = [l:tab . 'public ' . l:type . ' get' . l:cap . '() {' , l:tab . l:tab . 'return ' . l:var . ';' , l:tab . '}']
    let l:set = [l:tab . 'public void set' . l:cap . '(' . l:type . ' ' . l:var . ') {' , l:tab . l:tab . 'this.' . l:var . ' = ' . l:var . ';' , l:tab . '}']
    let l:encap = [''] + l:get + [''] + l:set + ['']

    let l:end = s:get_closing_bracket(1, s:get_class_tag())
    call append(l:end[0] - 1, l:encap)
    call cursor(l:end[0] + 1, 1)
    silent write!

    " Let the user know it's done, and return important info for
    " g:factorus_history.
    redraw
    echo 'Created getters and setters for ' . l:var
    return [l:var, l:type, l:is_pub]

endfunction

" extract_method {{{2

" Extracts sub-method from current method by finding 'blocks' of code that are
" isolated from the rest of the method. Not guaranteed to be useful, but can
" sometimes speed up the refactoring process.
function! factorus#java#extract_method()

    " If the command is to roll back previous extraction, do so.
    if factorus#util#is_rollback(a:000)
        call s:rollback_extraction()
        return 'Rolled back extraction for method ' . g:factorus_history['old'][0]
    endif

    " If the user selected a range of lines, use manual_extract instead.
    if a:1 != 1 || a:2 != line('$')
        return s:manual_extract(a:000)
    endif

    echo 'Extracting new method...'

    " Get the structure of the current method--the name,
    " the variable declarations, the blocks, etc.
    let [l:orig, l:tab, l:method_name, l:open, l:close, l:old_lines, l:vars, l:compact, l:blocks, l:all, l:isos] = s:init_extraction()

    redraw
    echo 'Finding best lines...'

    " Once we've gotten the method's structure, we find the 'best' variable to
    " extract, depending on the desired heuristic.
    let [l:best_var, l:best_lines] = s:get_best_var(l:vars, l:compact, l:isos, l:all, l:blocks, l:open, l:close)

    " After finding the variable to extract, we wrap all the variables we can
    " into our new method. This means variables that are only defined to be
    " used in the definition of this variable, and nowhere else.
    let l:new_args = s:get_new_args(l:best_lines, l:vars, l:all, l:best_var)
    let [l:wrapped, l:wrapped_args] = s:wrap_decs(l:best_var, l:best_lines, l:vars, l:all, l:isos, l:new_args, l:close)
    while l:wrapped != l:best_lines
        let [l:best_lines, l:new_args] = [l:wrapped, l:wrapped_args]
        let [l:wrapped, l:wrapped_args] = s:wrap_decs(l:best_var, l:best_lines, l:vars, l:all, l:isos, l:new_args, l:close)
    endwhile

    if l:best_var[2] == l:open && index(l:new_args, l:best_var) < 0
        call add(l:new_args, l:best_var)
    endif

    " Then, we wrap any necessary annotations around the new method, get all
    " the arguments needed for that function, and build the new method line by
    " line.
    let l:best_lines = s:wrap_annotations(l:best_lines)

    let l:new_args = s:get_new_args(l:best_lines, l:vars, l:all, l:best_var)
    let [l:final, l:rep] = s:build_new_method(l:best_lines, l:new_args, l:blocks, l:vars, l:all, l:tab, l:close)

    " Once the method has been built, we add it to the file just after the
    " current method, and jump to it. The user doesn't name this new method,
    " because they don't know what it's going to be (they can give a name if
    " they use manualExtract).
    call append(l:close[0], l:final)
    call append(l:best_lines[-1], l:rep)

    let l:i = len(l:best_lines) - 1
    while l:i >= 0
        call cursor(l:best_lines[l:i], 1)
        d 
        let l:i -= 1
    endwhile

    call search('public.*\<' . g:factorus_method_name . '\>(')
    silent write!
    redraw
    echo 'Extracted ' . len(l:best_lines) . ' lines from ' . l:method_name
    return [l:method_name, l:old_lines]
endfunction

" rename_something {{{2

" Renames some object of type a:type to a:new_name.
function! factorus#java#rename_something(new_name, type, ...)

    try
        if factorus#util#is_rollback(a:000)
            " Roll back previous rename command.
            let l:res = s:rollback_rename(a:new_name, a:type)
            let g:factorus_qf = []
        else
            let [l:orig, l:prev_dir, l:curr_buf] = factorus#util#set_environment()
            let s:all_funcs = {}

            " Rename desired thing.
            let g:factorus_qf = []

            "echo 'Getting object attributes...'
            let l:object = s:get_object_attributes(a:type)

            if l:object['old_name'] == a:new_name
                throw 'Factorus:Duplicate'
            endif

            "echo 'Getting referring files...'
            call s:get_referring_files(l:object, a:type)

            "echo 'Updating referring files...'
            call s:update_referring_files(l:object, a:type, a:new_name)

            if g:factorus_show_changes > 0
                call factorus#util#set_changes(l:object['old_name'], 'rename', a:type)
            endif

            call factorus#util#reset_environment(l:orig, l:prev_dir, l:curr_buf, a:type)
            return l:object['old_name']
        endif
    catch /.*/
        " Reset environment and abort.
        call factorus#util#reset_environment(l:orig, l:prev_dir, l:curr_buf, a:type)
        let l:err = match(v:exception, '^Factorus:') >= 0 ? v:exception : 'Factorus:' . v:exception
        throw l:err . ', at ' . v:throwpoint
    endtry
endfunction


