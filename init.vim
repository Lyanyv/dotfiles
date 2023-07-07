" TODO:
" file explorer, symbols outline
" statusline, tabline, icons(nerd font)
" text-object, multi cursors
" debugger, fuzzy finder, git support

" multibyte charsets
language message zh_CN.UTF-8
set fileencodings=ucs-bom,utf-8,gb2312,cp936,gbk,gb18030,latin1
set ambiwidth=single  " required by indent-blankline
set formatoptions+=mM nojoinspaces

" b f g h u w x y z
let mapleader = ' '
" requires `pynvim` and `neovim-remote`
let g:python3_host_prog='python'
" or specify it explictly
" let g:python3_host_prog="C:/softwares/anaconda3/envs/opencda/python.exe"
let g:conda_env = 'opencda'

if has('win32')
    let s:cmd_open = 'start'
else
    let s:cmd_open = 'open'
endif

" plugins
" default plug path: `stdpath('data') . '/plugged'`
call plug#begin()
Plug 'junegunn/vim-plug'

Plug 'sainnhe/gruvbox-material'
let g:gruvbox_material_better_performance = 1
let g:gruvbox_material_foreground = 'mix'
let g:gruvbox_material_background = 'medium'
let g:gruvbox_material_enable_bold = 1
let g:gruvbox_material_enable_italic = 1

let g:gruvbox_material_transparent_background = 0
let g:gruvbox_material_dim_inactive_windows = 1
let g:gruvbox_material_visual = 'red background'
let g:gruvbox_material_current_word = 'reverse'
let g:gruvbox_material_menu_selection_background = 'blue'
let g:gruvbox_material_spell_foreground = 'colored'
let g:gruvbox_material_diagnostic_text_highlight = 1

Plug 'lukas-reineke/indent-blankline.nvim'
let g:indent_blankline_show_end_of_line = v:true
let g:indent_blankline_show_trailing_blankline_indent = v:true
let g:indent_blankline_space_char_blankline = ' '

let g:indent_blankline_use_treesitter = v:false
let g:indent_blankline_use_treesitter_scope = v:false
let g:indent_blankline_show_current_context = v:true
let g:indent_blankline_show_current_context_start = v:true
let g:indent_blankline_context_highlight_list = ['Label']
let g:indent_blankline_viewport_buffer = 64

Plug 'RRethy/vim-illuminate'
" <A-p> & <A-n>: move previous/next reference
" <A-i>: select the cursor-text-object
Plug 'machakann/vim-highlightedyank'
let g:highlightedyank_highlight_duration = -1

Plug 'godlygeek/tabular'
Plug 'psliwka/vim-smoothie'
Plug 'phaazon/hop.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" highlight, indent and fold
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()
" set nofoldenable  " disable folding at startup

Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = [ 'coc-highlight', 'coc-json', 'coc-pairs',
    \ 'coc-pyright', 'coc-snippets', 'coc-texlab', 'coc-word' ]

" key mappings
function s:check_backspace() abort
    let col_ = col('.') - 1
    return !col_ || getline('.')[col_ - 1] =~# '\s'
endfunction
inoremap <silent><expr> <Tab>
    \ coc#pum#visible() ? coc#pum#next(1) :
    \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
    \ <SID>check_backspace() ? "\<Tab>" : coc#refresh()
imap <silent><expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<C-d>"
" <C-g>u breaks undo chain at current position
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nmap <silent> [e <Plug>(coc-diagnostic-prev)
nmap <silent> ]e <Plug>(coc-diagnostic-next)
nmap <silent> <leader>e <Cmd>CocList diagnostics<CR>

nmap <silent> \f <Cmd>CocList symbols<CR>
nmap <silent> <leader>d <Plug>(coc-definition)
nmap <silent> <leader>s <Plug>(coc-declaration)
nmap <silent> <leader>i <Plug>(coc-implementation)
nmap <silent> <leader>t <Plug>(coc-type-definition)
nmap <silent> <leader>r <Plug>(coc-references)

nmap <leader>n <Plug>(coc-rename)

nnoremap <silent> K <Cmd>call <SID>show_doc()<CR>
function s:show_doc()
    if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else | call feedkeys('K', 'in') | endif
endfunction
" open the url/file link or jump to the tag under the cursor
nnoremap <C-]> <Cmd>call <SID>open_link()<CR>
function s:open_link()
    if empty(&buftype) || &buftype == 'acwrite'
        if CocAction('openLink') | return | endif
    endif
    " https://github.com/itchyny/vim-highlighturl
    let url_pattern =
        \ '\v\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%('
        \.'[&:#*@~%_\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\-=?!+/0-9a-z]+|:\d+|'
        \.',%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|'
        \.'\([&:#*@~%_\-=?!+;/.0-9a-z]*\)|\[[&:#*@~%_\-=?!+;/.0-9a-z]*\]|'
        \.'\{%([&:#*@~%_\-=?!+;/.0-9a-z]*|\{[&:#*@~%_\-=?!+;/.0-9a-z]*\})\})+'
    let url = matchstr(getline('.'), url_pattern)
    if empty(url)
        if &buftype == 'help'
            " `noremap` and argument 'n' prevent vim from doing nested mappings
            " can't feed <LeftMouse> key
            return feedkeys("\<C-]>", 'n')
        else | return feedkeys("gf", 'n') | endif
    endif
    let output = system(s:cmd_open . ' ' . url)
    if v:shell_error && output !=# '' | echoerr output | endif
endfunction

" map function and class text-object
" NOTE: requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" snippets and signature
autocmd CursorHoldI,CursorMovedI * silent call CocActionAsync('showSignatureHelp')
autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
let g:coc_snippet_prev = '<C-k>'
let g:coc_snippet_next = '<C-j>'

" command and autocmd
command Format :call CocActionAsync('format')
autocmd FileType tex command! -buffer Format
    \ echoerr "latexindent's behavior is weird, use `gq` instead"
command OR :call CocActionAsync('runCommand', 'editor.action.organizeImport')

autocmd FileType tex,markdown let b:coc_pairs = [['$', '$']]
autocmd FileType tex nmap <buffer> <leader>d :CocCommand latex.ForwardSearch<CR>
autocmd FileType tex nmap <buffer> <F5> :up!<CR>:CocCommand latex.Build<CR>

" statusline
set statusline=%#ModeMsg#%y
set statusline+=%#StatusLine#%<%F\ %h%m%r
set statusline+=\ %#Label#%{get(b:,'coc_snippet_active',0)?'SNIP':''}
set statusline+=%#PmenuSel#%{get(b:,'coc_snippet_active',0)?'':get(b:,'coc_current_function','')}
set statusline+=%#StatusLine#%=%-10.(%l,%c%V%)\ %P

Plug 'jackguo380/vim-lsp-cxx-highlight'
" :LspCxxHlCursorSym

Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() },
    \ 'for': ['markdown', 'vim-plug']}
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 0
let g:mkdp_refresh_slow = 1

let g:mkdp_markdown_css = ''
let g:mkdp_highlight_css = ''
let g:mkdp_preview_options = {
    \ 'mkit': { 'breaks': v:true },
    \ 'katex': { 'minRuleThickness': 0.10, 'fleqn': v:true },
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 1,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 0,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 0,
    \ 'toc': {'listType' : 'ul'},
    \ }  " toc.listType: ul for unordered, ol for ordered

autocmd FileType markdown nmap <buffer> <F5> <Plug>MarkdownPreview

" Plug 'kiyoon/jupynium.nvim', { 'do': 'pip3 install --user .' }
Plug 'kiyoon/jupynium.nvim', { 'do': 'conda run --no-capture-output -n '
    \. g:conda_env . ' pip install .' }

" usage:
" 1. open a `*.ju.py` file
" 2. `:JupyniumStartAndAttachToServer` to open Jupyter Notebook in Firefox
" 3. `:JupyniumStartSync [filename]` to create an `Untitled.ipynb` file
" 4. type `# %%` in nvim to create a code cell
" note: do not make changes inside the browser, as the sync is only one-way

" jupynium file format (*.ju.py or *.ju.*) follows Jupytext's percent format
" code cell separator: `# %%`
" magic commands: `# %time`
" markdown cell: `# %% [md]` or `# %% [markdown]`
"    in python, wrap the whole cell content as a multi-line string:
"    # %% [md]
"    """
"    # This is a markdown heading
"    This is markdown content
"    """

call plug#end()

" set by lua
lua << EOF
require('illuminate').configure({
    providers = {
        -- 'lsp',
        'treesitter',
        'regex',
    },
    delay = 100,
    -- `:help mode()`, Normal and Terminal modes
    -- flicker when enter and quit Operator-pending modes
    -- seems that Operator-pending modes will block Vim
    modes_allowlist = { 'n', 'niI', 'niR', 'niV', 't', 'nt', 'ntT', },
})
require'hop'.setup {
    case_insensitive = false,
    jump_on_sole_occurrence = false,
    multi_windows = false,
}
require'nvim-treesitter.configs'.setup {
    -- run Neovim via Visual Studio's "x64 Native Tools Command Prompt" console
    ensure_installed = { 'bibtex', 'c', 'comment', 'cpp', 'json', 'jsonc',
                         'latex', 'markdown', 'markdown_inline', 'python',
                         'query', 'vim', 'vimdoc',
    },
    sync_install = false,
    auto_install = false,
    prefer_git = true,
    highlight = {
        enable = true,
        disable = { 'c', 'cpp', },
        additional_vim_regex_highlighting = false,  -- XXX will disable syntax
    },
    indent = { enable = true },
}
require("jupynium").setup({
    python_host = vim.g.python3_host_prog,
    -- python_host = { "conda", "run", "--no-capture-output", "-n",
    --                 vim.g.conda_env, "python" },
    jupyter_command = "jupyter",
    -- jupyter_command = { "conda", "run", "--no-capture-output", "-n",
    --                     vim.g.conda_env, "jupyter" },
    jupynium_file_pattern = { "*.ju.*" },
    auto_start_server = { enable = true, file_pattern = { "*.ju.*" }, },
    auto_attach_to_server = { enable = true, file_pattern = { "*.ju.*" }, },
    auto_start_sync = { enable = false, file_pattern = { "*.ju.*" }, },
    auto_download_ipynb = true,

    use_default_keybindings = false,
    textobjects = { use_default_keybindings = false, },
    syntax_highlight = { enable = true, },
    -- dim all cells except the current one
    shortsighted = true,
})
EOF

map s <Cmd>HopChar2<CR>
nmap s <Cmd>HopChar2MW<CR>
map <leader>l <Cmd>HopLine<CR>
nmap <leader>l <Cmd>HopLineMW<CR>
map <leader>j <Cmd>HopVerticalAC<CR>
map <leader>k <Cmd>HopVerticalBC<CR>

call coc#config('python', {'pythonPath': g:python3_host_prog})
call coc#config('snippets', {'userSnippetsDirectory' : stdpath('config').'\ultisnips'})

function s:goto_the_one_cell_sep_above()
    if match(getline('.'), '^# %%') == 0
        lua require'jupynium.textobj'.goto_previous_cell_separator()
    else
        lua require'jupynium.textobj'.goto_current_cell_separator()
    endif
endfunction
function s:set_keymap_for_jupynium()
    " text-object key mappings
    map <buffer> [j <Cmd>call <SID>goto_the_one_cell_sep_above()<CR>
    map <buffer> ]j <Cmd>lua require'jupynium.textobj'.goto_next_cell_separator()<CR>
    xmap <buffer> ij <Cmd>lua require'jupynium.textobj'.select_cell(false, false)<CR>
    omap <buffer> ij <Cmd>lua require'jupynium.textobj'.select_cell(false, false)<CR>
    xmap <buffer> aj <Cmd>lua require'jupynium.textobj'.select_cell(true, false)<CR>
    omap <buffer> aj <Cmd>lua require'jupynium.textobj'.select_cell(true, false)<CR>
    " command key mappings
    " nmap <buffer> <F5> <Cmd>lua fn_wo_ext = vim.fn.expand '%:r:r' vim.cmd([[JupyniumStartSync ]] .. fn_wo_ext)<CR>
    nmap <buffer> <F5> <Cmd>JupyniumStartSync<CR>
    map <buffer> <S-CR> <Cmd>JupyniumExecuteSelectedCells<CR><Cmd>lua require'jupynium.textobj'.goto_next_cell_separator()<CR>
    map <buffer> <leader>c <Cmd>JupyniumClearSelectedCellsOutputs<CR>
    nmap <buffer> <leader>v <Cmd>JupyniumKernelHover<CR>
endfunction
augroup JupyniumKeyMap
    autocmd!
    autocmd BufWinEnter *.ju.* call s:set_keymap_for_jupynium()
augroup END

" vim builtin plugins
let g:loaded_netrw       = 0
let g:loaded_netrwPlugin = 0
let g:loaded_tar         = 0
let g:loaded_tarPlugin   = 0
" plugins `editorconfig`, `man.lua` and `matchit` are enabled by default

" ui and font
if has('termguicolors') | set termguicolors | endif
set background=dark
" `LineNr`: bg = SpecialKey's fg, fg = Normal's bg
" be sure that StatusLine, ColorColumn and CursorLine have the same highlight
function s:gruvbox_material_custom()
    let palette = gruvbox_material#get_palette(
        \ g:gruvbox_material_background,
        \ g:gruvbox_material_foreground, {})
    call gruvbox_material#highlight('LineNr', palette.bg0, palette.bg5)
    call gruvbox_material#highlight('JupyniumShortsighted',
                \ palette.none, palette.bg_dim)
endfunction
augroup GruvboxMaterialCustom
    autocmd!
    autocmd ColorScheme gruvbox-material call s:gruvbox_material_custom()
augroup END
colorscheme gruvbox-material

set guifont=等距更纱黑体\ Slab\ SC:h15
set guicursor=n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor
" args of Nvy: --geometry=120x30 --position=320,160
if !exists('g:nvy') && has('gui_running')
    set lines=30 columns=120
endif

" VimTweak
if has('win32') && has('gui_running')
    runtime autoload/vimtweak2.vim
    " recommended value: 200~255
    autocmd UIEnter * call SetAlpha(221)
    let g:topMost = 0
    nmap <leader>q <Cmd>let g:topMost = 1 - g:topMost<Bar>call EnableTopMost(g:topMost)<CR>
    let g:maximize = 0
    nmap <leader>m <Cmd>let g:maximize = 1 - g:maximize<Bar>call EnableMaximize(g:maximize)<CR>
endif

" layout
set title
set signcolumn=number number norelativenumber numberwidth=4
set colorcolumn=81 cursorline
set noruler  " since it's redefined

" movement
set scrolloff=0 nostartofline
set virtualedit=block
" FIXME: after scrolling, the jumplist gets filled with meaningless positions
" solution: map `<C-o>` and `<C-i>` to jump in tagstack
set jumpoptions=view

" text display
set wrap linebreak breakindent showbreak=...
" turn off physical line wrapping (automatic insertion of newlines)
" but except LaTeX
set textwidth=0 wrapmargin=0
autocmd FileType * call s:setlocal_textwidth()
function s:setlocal_textwidth()
    if &filetype=='tex' | setlocal textwidth=80
        \ | else | setlocal textwidth=0 | endif
    setlocal wrapmargin=0
endfunction

set display=lastline,uhex
set list listchars=space:◦,trail:␣,eol:¬
set conceallevel=0

set nospell spelllang=en,cjk
set showmatch

" other info
set wildmenu wildmode=longest,full  " smart wildmenu completion
set report=0
set shortmess-=F shortmess+=mrI
set belloff=
silent! aunmenu PopUp.How-to\ disable\ mouse
silent! aunmenu PopUp.-1-
" copy and paste with system clipboard
set clipboard=unnamedplus

" dir and files
set autochdir noautoread
set updatetime=300
set backup undofile backupdir-=.

" some keys' behaviors
set nosmarttab expandtab shiftround
autocmd FileType * set expandtab
set tabstop=4 softtabstop=4 shiftwidth=4
autocmd FileType c,cpp,json,yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2
set backspace=2
set mouse=a mousemodel=popup mousehide  " Nvy doesn't support `mousehide`

" key mappings
" movement related
" horizontal
map <leader>a ^
" hold selection when shifting sidewards
xnoremap < <gv
xnoremap > >gv
" vertical
" j/k will move over virtual lines (lines that wrap)
noremap <expr> j  (v:count == 0 ? 'gj' : 'j')
noremap <expr> k  (v:count == 0 ? 'gk' : 'k')
map <expr> <Down> (v:count == 0 ? 'gj' : 'j')
map <expr> <Up>   (v:count == 0 ? 'gk' : 'k')
" search smartly, centrally and smoothly
nnoremap n <Cmd>call feedkeys('Nn'[v:searchforward], 'n')<Bar>call feedkeys('zz')<CR>
nnoremap N <Cmd>call feedkeys('nN'[v:searchforward], 'n')<Bar>call feedkeys('zz')<CR>
nnoremap * <Cmd>call feedkeys('*', 'n')<Bar>call feedkeys('zz')<CR>
nnoremap # <Cmd>call feedkeys('#', 'n')<Bar>call feedkeys('zz')<CR>
" switch between windows, buffers and tabpages
" cf. `CTRL-W_p`
nmap gw <C-w>w
nmap gW <C-w>W
nmap gr <C-w>r
nmap gR <C-w>R
nmap gb <Cmd>bnext<CR>
nmap gB <Cmd>bprevious<CR>
" `gt` and `gT` for tabpages by default
" tagstack, useful in vim helpfile
nmap <C-o> <Cmd>pop<CR>
" vim can't distinguish between `<Tab>` and `<C-i>`
nmap <C-i> <Cmd>tag<CR>

" insert
imap <C-Tab> <C-t>
iabbrev idate <C-r>=strftime('%y/%m/%d %H:%M:%S')<CR>

" other
nmap <leader><leader> <C-l>
nmap <leader>o <Cmd>only<CR>
nmap <leader>p <Cmd>setlocal spell!<CR>

" filetype related
autocmd FileType python nmap <buffer> <F5> :up!<CR>:!python -u %<CR>
autocmd FileType tex nmap <buffer> <F6> :sp %:r.log<CR>/\.tex:\d<CR>

" Neovim's default mappings
" nnoremap Y y$
" nnoremap <C-L> <Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>
" inoremap <C-U> <C-G>u<C-U>
" inoremap <C-W> <C-G>u<C-W>
" xnoremap * y/\V<C-R>"<CR>
" xnoremap # y?\V<C-R>"<CR>
" nnoremap & :&&<CR>

" syntax
autocmd FileType json syntax match Comment +\/\/.\+$+

" highlight
set pumblend=30 winblend=30
hi MatchParen ctermbg=24 guibg=#005F87
hi Search ctermfg=15 ctermbg=32 guifg=#FFFFFF guibg=#0087D7
hi Cursor cterm=None gui=None ctermbg=36 guibg=#00BF9F

" highlight for treesitter
" hi! link TSVariable Identifier
hi TSParameter ctermfg=DarkCyan guifg=DarkCyan

" highlight for markdown
hi! link @text.title1 markdownH1
hi! link @text.title2 markdownH2
hi! link @text.title3 markdownH3
hi! link @text.title4 markdownH4
hi! link @text.title5 markdownH5
hi! link @text.title6 markdownH6
hi! link @text.quote Comment

" highlight for jupynium
hi! link JupyniumCodeCellSeparator MatchParen
hi! link JupyniumMarkdownCellSeparator MatchParen
hi! link JupyniumMagicCommand Keyword

" highlight for vim-lsp-cxx-highlight
function s:custom_LspCxxHl()
    hi! link LspCxxHlGroupEnumConstant Constant
    hi! link LspCxxHlGroupNamespace Directory
    hi! link LspCxxHlGroupMemberVariable Identifier
    hi! link LspCxxHlSymVariable Identifier
    hi! link LspCxxHlSymUnknownStaticField Identifier
    " A name dependent on a template, usually a function but can also be a variable?
    hi! link LspCxxHlSymDependentName Function
    hi LspCxxHlSymParameter ctermfg=DarkCyan guifg=DarkCyan
endfunction
autocmd FileType c,cpp call s:custom_LspCxxHl()

" utils for tex
let g:tex_flavor = "latex"
function UsePDFLaTeX()
    call writefile(['$pdf_mode = 1;'], '.latexmkrc', 's')
endfunction
function MapPeriod()
    execute '%s/。/./g'
    imap <buffer> 。 .
endfunction

" a tool function to rearrange line breaks in text copied from PDF
function s:rearrange_linebreaks()
    let cliptext = getreg('+')
    let maps = [
        \ [ 'e\.g\.'         , 'for example'            ],
        \ [ 'i\.e\.'         , 'that is'                ],
        \ [ 'etc\.'          , 'and so on.'             ],
        \ [ 'et\s\{1,\}al\.' , 'and others.'            ],
        \ [ 'ff\.'           , ' and following.'        ],
        \ [ 'cf\.'           , 'see '                   ],
        \ [ 'cp\.'           , 'see '                   ],
        \ [ 'Q\.E\.D\.'      , 'that which was proven.' ],
        \ [ 'viz\.'          , 'namely'                 ],
        \ [ 'Fig\.'          , 'figure'                 ],
        \ [ 'Tab\.'          , 'table'                  ],
        \ [ '[\e\t\r\b\n]'   , ' '                      ],
        \ [ '\s\{1,\}'       , ' '                      ],
        \ [ '[?!\.]\@<=\s'   , '\n'                     ],
        \ [ '^\s\{1,\}'      , ''                       ],
        \ [ '\s\{1,\}$'      , ''                       ],
        \ ]
    for [pat, sub] in maps
        let cliptext = substitute(cliptext, pat, sub, 'g')
    endfor
    call setreg('+', cliptext)
endfunction
command Rlbr call s:rearrange_linebreaks()

command DiffOrig 
    \ let s:temp_ft=&ft | vert new | set buftype=nowrite | read ++edit #
    \ | silent 0d_ | let &ft=s:temp_ft | diffthis | wincmd p | diffthis
" When editing a file, always jump to the last known cursor position. Don't do
" it when the position is invalid, when inside an event handler (happens when
" dropping a file on gvim) and for a commit message (it's likely a different
" one than last time).
" add `b:jumped` for neovim-remote
autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$")
    \ && &ft !~# "commit" && !exists('b:jumped')
    \ | exe "normal! g`\"" | call feedkeys('zzzv', 'n') | let b:jumped = 1 | endif

" tips
" to find user config dir `:echo stdpath('config')`
command Vimrc execute('CocConfig') | vsplit | e $MYVIMRC
" `<Cmd>...<CR>` in key mappings

" `:TOhtml`
" `:echo synIDattr(synID(line('.'), col('.'), 1), 'name')` or just `:Inspect`
" diff jump: [c ]c
" spell jump: [s ]s
" spell suggest: z=

" manage workspace folders `:h coc-workspace`
" 1. `:CocList folders` lists workspace folders, supports `delete` and `edit`
" 2. `:echo coc#util#root_patterns()` gets patterns used for resolve workspace
"    folder of current buffer
" 3. `g:WorkspaceFolders` stores workspace folders
" to enable multiple workspace folders, open at least one file of each folder
