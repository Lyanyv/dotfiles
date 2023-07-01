" Coc completion source of syntax keywords
" Language:     All languages, uses existing syntax highlighting rules
" Author:       Lianyu
" Last Change:  2023 Jul 1
" Usage:        Put this file in: `stdpath('config') . '/autoload/coc/source'`
"               For those filetypes whose syntax is disabled by tree-sitter
"               `coc.nvim` is required

function! coc#source#syntax#init() abort
    let s:cache_dict = {}
    return {
        \ 'shortcut'          : 'syn',
        \ 'priority'          : 0,
        \ 'firstMatch'        : v:true,
        \ 'triggerCharacters' : [],
        \ }
endfunction

function! coc#source#syntax#on_enter(option) abort
    " see `:h coc-document-filetype`
    " `:CocCommand document.echoFiletype` to echo mapped ft of current buffer
    let temp_ft = a:option['languageId']
    if temp_ft ==? 'latex' | let temp_ft = 'tex' | endif
    if temp_ft ==? 'javascript' | let temp_ft = 'javaScript' | endif

    if has_key(s:cache_dict, temp_ft) | return | endif

    if empty(temp_ft) || temp_ft ==? 'text' || temp_ft ==? 'markdown'
            \ || temp_ft ==? 'help'
        let s:cache_dict[temp_ft] = []
        return
    endif

    let temp_list = s:get_synkw(temp_ft)
    " cpp = cpp + c
    if temp_ft ==? 'cpp'
        let temp_list += s:get_synkw('c')
        call uniq(temp_list)
    endif

    let s:cache_dict[temp_ft] = temp_list
endfunction

function s:get_synkw(ft)
    let cmd_1 = "!nvim --clean --headless --cmd \"set ft="
    " TODO: support syntax settings of more filetypes
    let cmd_1_5 = " | let c_gnu=1 | let g:tex_flavor='latex' | let python_highlight_all=1"
    " do not know how to put regex in below
    let cmd_2 =
        \ " | syntax enable | let b:temp_list=uniq(syntaxcomplete\\#OmniSyntaxList())"
        \." | call filter(b:temp_list, 'len(v:val) >= 2')"
        \." | call filter(b:temp_list, 'v:val[0] < ''0'' || v:val[0] > ''9''')"
        \." | call filter(b:temp_list, 'v:val[0] < ''@'' || v:val[0] > ''@''')"
        \." | call writefile(b:temp_list, $TEMP.'/synkw-"
    let cmd_3 = ".txt', 's') | q\""

    let synkw_path = $TEMP.'/synkw-'.a:ft.'.txt'
    if empty(glob(synkw_path))
        silent execute cmd_1 . a:ft . cmd_1_5 . cmd_2 . a:ft . cmd_3
    endif
    return readfile(synkw_path)
endfunction

function! coc#source#syntax#complete(option, cb) abort
    let inputtext = a:option['input']
    if empty(inputtext) | call a:cb([]) | return | endif

    let temp_ft = a:option['filetype']
    if temp_ft ==? 'latex' | let temp_ft = 'tex' | endif
    if temp_ft ==? 'javascript' | let temp_ft = 'javaScript' | endif

    " when event `BufEnter` is not triggered
    if !has_key(s:cache_dict, temp_ft)
        call coc#source#syntax#on_enter({'languageId': a:option['filetype']})
    endif

    " smartcase for the first character
    if inputtext[0]->toupper() ==# inputtext[0]
        call a:cb(filter(copy(s:cache_dict[temp_ft]),
                \ "v:val[0] ==# '".inputtext[0]."'"))
    else
        call a:cb(filter(copy(s:cache_dict[temp_ft]),
                \ "v:val[0] ==? '".inputtext[0]."'"))
    endif
endfunction
