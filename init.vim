" TODO:
" file explorer, symbols outline
" statusline,    tabline
" text-object,   multi cursors
" debugger,      git support

" multibyte charsets
set fileencodings=ucs-bom,utf-8,gb18030,gbk,cp936,gb2312,latin1
set ambiwidth=double
call setcellwidths([
    \ [0x0391, 0x03A9, 1],
    \ [0x03B1, 0x03C9, 1],
    \ [0x00ac, 0x00ac, 1],
    \ [0x2423, 0x2423, 1],
    \ [0x2588, 0x2588, 1],
    \ [0x258f, 0x258f, 1],
    \ [0x2591, 0x2593, 1],
    \ [0x25e6, 0x25e6, 1],
  \ ])
set formatoptions+=mM nojoinspaces

let mapleader = ' '
" requires `pynvim` and `neovim-remote`
let g:python3_host_prog='python'
" or specify it explictly
" let g:python3_host_prog=".../python.exe"
" let g:conda_env = 'some_env'

if has('win32')
    let s:cmd_open = 'start'
    function UsePowerShell()
        " `:h shell-powershell`
        let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
        let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command '
            \ .'[Console]::InputEncoding=[Console]::OutputEncoding='
            \ .'[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues'
            \ .'[''Out-File:Encoding'']=''utf8'';'
        let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
        let &shellpipe  = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
        set shellquote= shellxquote=
    endfunction
else
    let s:cmd_open = 'open'
endif

" plugins
" default plug path: `stdpath('data') . '/plugged'`
call plug#begin()
Plug 'junegunn/vim-plug'

Plug 'sainnhe/gruvbox-material'
let g:gruvbox_material_better_performance = 1
let g:gruvbox_material_foreground = 'original'
let g:gruvbox_material_statusline_style = 'original'
let g:gruvbox_material_background = 'medium'
let g:gruvbox_material_enable_bold = 1
let g:gruvbox_material_enable_italic = 1

let g:gruvbox_material_transparent_background = 0
let g:gruvbox_material_dim_inactive_windows = 1
let g:gruvbox_material_visual = 'blue background'
let g:gruvbox_material_current_word = 'reverse'
let g:gruvbox_material_menu_selection_background = 'purple'
let g:gruvbox_material_spell_foreground = 'colored'
let g:gruvbox_material_diagnostic_text_highlight = 1

Plug 'catgoose/nvim-colorizer.lua'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'RRethy/vim-illuminate'
" <A-p> & <A-n>: move previous/next reference
" <A-i>: select the cursor-text-object
Plug 'machakann/vim-highlightedyank'
let g:highlightedyank_highlight_duration = -1

Plug 'godlygeek/tabular'
Plug 'LunarWatcher/auto-pairs', {'tag': 'v4.0.1'}
let g:AutoPairsDefaultDisableKeybinds = 1
let g:AutoPairsCompatibleMaps = 0  " recommended
let g:AutoPairsPrefix = ""
let g:AutoPairsShortcutToggle = ""
let g:AutoPairsShortcutToggleMultilineClose = ""
let g:AutoPairsShortcutJump = ""
let g:AutoPairsShortcutBackInsert = ""
let g:AutoPairsShortcutIgnore = ""
let g:AutoPairsMoveExpression = ""
" <BS>
let g:AutoPairsMapBS = 1
let g:AutoPairsMultilineBackspace = 1
let g:AutoPairsBSAfter = 1
let g:AutoPairsBSIn = 1
" <CR>
let g:AutoPairsMapCR = 0
" <Space>
let g:AutoPairsMapSpace = 1
" expand management
let g:AutoPairsCompleteOnlyOnSpace = 0
let g:AutoPairsSingleQuoteMode = 0
autocmd FileType python let b:AutoPairsSingleQuoteMode = 2
" balance management
let g:AutoPairsPreferClose = 1
let g:AutoPairsMultilineClose = 1
let g:AutoPairsMultilineCloseDeleteSpace = 1
let g:AutoPairsSearchCloseAfterSpace = 1
let g:AutoPairsStringHandlingMode = 0  " since syntax is killed by treesitter
" jump
let g:AutoPairsNoJump = 0
" fast wrap
let g:AutoPairsShortcutFastWrap = "<C-l>"
let g:AutoPairsMultilineFastWrap = 1
let g:AutoPairsMultibyteFastWrap = 1

Plug 'psliwka/vim-smoothie'
Plug 'smoka7/hop.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
" highlight, indent and fold
" :TSInstall all
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()
" set nofoldenable  " disable folding at startup

Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}
let g:coc_global_extensions = [ 'coc-json', 'coc-lists', 'coc-markdownlint',
            \ 'coc-pyright', 'coc-snippets', 'coc-texlab', 'coc-word' ]

" key mappings
function s:check_backspace() abort
    let col_ = col('.') - 1
    return !col_ || getline('.')[col_ - 1] =~# '\s'
endfunction
inoremap <silent><expr> <Tab>
    \ coc#pum#visible() ? coc#pum#next(1) :
    \ <SID>check_backspace() ? "\<Tab>" : coc#refresh()
imap <silent><expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<C-d>"
" <C-g>u breaks undo chain at current position
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
    \: "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"

nmap <silent> <leader>d <Plug>(coc-definition)
nmap <silent> <leader>s <Plug>(coc-declaration)
nmap <silent> <leader>i <Plug>(coc-implementation)
nmap <silent> <leader>t <Plug>(coc-type-definition)
nmap <silent> <leader>r <Plug>(coc-references)
nmap <leader>n <Plug>(coc-rename)

nnoremap <silent> K <Cmd>call <SID>show_doc()<CR>
function s:show_doc()
    if CocAction('hasProvider', 'hover') | call CocActionAsync('doHover')
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
" requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" scroll float windows/popups
function s:scroll_float(forward)
    if coc#float#has_scroll()
        call coc#float#scroll(a:forward)
    elseif a:forward == 1
        call smoothie#do("\<C-f>")
    elseif a:forward == 0
        call smoothie#do("\<C-b>")
    endif
endfunction
nnoremap <silent><nowait> <C-f> <Cmd>call <SID>scroll_float(1)<CR>
nnoremap <silent><nowait> <C-b> <Cmd>call <SID>scroll_float(0)<CR>
vnoremap <silent><nowait> <C-f> <Cmd>call <SID>scroll_float(1)<CR>
vnoremap <silent><nowait> <C-b> <Cmd>call <SID>scroll_float(0)<CR>
imap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<CR>" : ''
imap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<CR>" : ''

" snippets and signature
" autocmd CursorHoldI * silent call CocActionAsync('showSignatureHelp')
" autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
imap <silent> <C-h> <Cmd>call CocActionAsync('showSignatureHelp')<CR>
vmap <silent> <C-h> <Cmd>call CocActionAsync('showSignatureHelp')<CR>
let g:coc_snippet_prev = '<C-k>'
let g:coc_snippet_next = '<C-j>'
vmap <C-x> <Plug>(coc-snippets-select)

" coc-lists
nmap <silent> [e <Plug>(coc-diagnostic-prev)
nmap <silent> ]e <Plug>(coc-diagnostic-next)
nmap <silent> \e <Cmd>CocList diagnostics<CR>
nmap <silent> \s <Cmd>CocList symbols<CR>
nmap <silent> \f <Cmd>CocList files<CR>
nmap <silent> \g <Cmd>CocList grep<CR>
nnoremap <silent> <leader>g :exe 'CocList -A --no-quit -I --input=\b'.expand('<cword>').'\b grep -F -e'<CR>
nmap <silent> \l <Cmd>CocList lines<CR>
nmap <silent> \m <Cmd>CocList mru<CR>

" command and autocmd
command Format :call CocActionAsync('format')
autocmd FileType tex command! -buffer Format
    \ echoerr "latexindent's behavior is weird, use `gq` instead"
command Or :call CocActionAsync('runCommand', 'editor.action.organizeImport')
autocmd FileType tex nmap <buffer> <leader>i :CocCommand latex.ForwardSearch<CR>
autocmd FileType tex nmap <buffer> <F5> :up!<CR>:CocCommand latex.Build<CR>
autocmd FileType python nmap <buffer> <leader>v :call CocAction('showOutline', 1)<CR>

" statusline
set statusline=%#StatusLine#%(%y\ %)%<%f%(\ %h%m%r%)
set statusline+=%#Label#%=%(%.50{TruncatedCocStatus(50)}\ \|\ %)
set statusline+=%#Function#%(%{get(b:,'coc_current_function','')}\ \|\ %)
set statusline+=%#CocErrorSign#%-4.{CocDiagnosticsStatus('error')}
set statusline+=%#CocWarningSign#%-4.{CocDiagnosticsStatus('warning')}
set statusline+=%#CocInfoSign#%-4.{CocDiagnosticsStatus('information')}
set statusline+=%#CocHintSign#%-4.{CocDiagnosticsStatus('hint')}
set statusline+=%#StatusLine#%-14.(%l,%c%V%)\ %P

function TruncatedCocStatus(max_len)
    let info = get(g:, 'coc_status', '')
    if len(info) > a:max_len
        return info[:a:max_len / 2 - 1 - 2] .. '....'
                \ .. info[-(a:max_len - a:max_len / 2 - 2):]
    else
        return info
    endif
endfunction

function CocDiagnosticsStatus(key)
    let info = get(b:, 'coc_diagnostic_info', {})
    let signs = {'error': '', 'warning': '', 'information': '', 'hint': ''}
    if !empty(info) && get(info, a:key, 0)
        return signs[a:key] . ' ' . info[a:key]
    else | return ' ' | endif
endfunction
autocmd User CocStatusChange redrawstatus

" manage workspace folders `:h coc-workspace`
" 1. `:CocList folders` lists workspace folders, supports `delete` and `edit`
" 2. `:echo coc#util#root_patterns()` gets patterns used for resolve workspace
"    folder of current buffer
" 3. `g:WorkspaceFolders` stores workspace folders
" to enable multiple workspace folders, open at least one file of each folder

Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 0
let g:mkdp_refresh_slow = 1

let g:mkdp_theme = 'dark'
let g:mkdp_markdown_css = ''
let g:mkdp_highlight_css = ''
let g:mkdp_preview_options = {
    \ 'mkit': { 'breaks': v:false },
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
    \ 'toc': {'listType' : 'ol'},
    \ }  " toc.listType: ul for unordered, ol for ordered

" add `firefox.exe` to PATH Environment Variable
function OpenBrowserInANewWindow(url)
    execute 'silent !firefox --new-window ' . a:url
endfunction
let g:mkdp_browserfunc = 'OpenBrowserInANewWindow'
autocmd FileType markdown nmap <buffer> <F5> <Plug>MarkdownPreview

Plug 'kiyoon/jupynium.nvim', { 'do': 'pip3 install --user .' }
" Plug 'kiyoon/jupynium.nvim', { 'do': 'conda run --no-capture-output -n '
"     \. g:conda_env . ' pip install .' }

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

" autopairs
call autopairs#Variables#InitVariables()
let g:AutoPairs = autopairs#AutoPairsDefine([
    \ {"open": '（', "close": '）'},
    \ {"open": '【', "close": '】'},
    \ {"open": '‘', "close": '’'},
    \ {"open": '“', "close": '”'},
    \ {"open": '《', "close": '》'},
    \ {"open": "$", "close": "$", "filetype": ["tex", "markdown"]},
    \ ])

" set by lua
if has('termguicolors') | set termguicolors | endif
lua << EOF
require("colorizer").setup({
    filetypes = { "*" },
    user_commands = false,
    names = true,
    names_opts = { -- options for mutating/filtering names.
        lowercase = true, -- name:lower(), highlight `blue` and `red`
        camelcase = true, -- name, highlight `Blue` and `Red`
        uppercase = false, -- name:upper(), highlight `BLUE` and `RED`
        strip_digits = false, -- ignore names with digits,
        -- highlight `blue` and `red`, but not `blue3` and `red4`
    },
    RGB = false, -- #RGB hex codes
    RGBA = false, -- #RGBA hex codes
    RRGGBB = true, -- #RRGGBB hex codes
    RRGGBBAA = false, -- #RRGGBBAA hex codes
    AARRGGBB = false, -- 0xAARRGGBB hex codes
})
require('illuminate').configure({
    providers = {
        -- 'lsp',
        -- 'treesitter',
        'regex',
    },
    delay = 100,
    -- `:help mode()`, Normal and Terminal modes
    -- flicker when enter and quit Operator-pending modes
    -- seems that Operator-pending modes will block Vim
    modes_allowlist = { 'n', 't', 'nt', 'ntT', },
})
require'hop'.setup {
    case_insensitive = false,
    jump_on_sole_occurrence = false,
    multi_windows = false,
}
require'nvim-treesitter.configs'.setup {
    -- run Neovim via Visual Studio's "x64 Native Tools Command Prompt" console
    sync_install = true,
    auto_install = false,
    prefer_git = true,
    highlight = {
        enable = true,
        -- disable = { 'c', 'cpp', },
        additional_vim_regex_highlighting = false,  -- will disable syntax
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
    default_notebook_URL = "localhost:8888",
    jupynium_file_pattern = { "*.ju.*" },
    auto_start_server = { enable = true, file_pattern = { "*.ju.*" }, },
    auto_attach_to_server = { enable = true, file_pattern = { "*.ju.*" }, },
    auto_start_sync = { enable = false, file_pattern = { "*.ju.*" }, },
    auto_download_ipynb = false,

    use_default_keybindings = false,
    textobjects = { use_default_keybindings = false, },
    syntax_highlight = { enable = true, },
    shortsighted = true,  -- dim all cells except the current one
})
EOF

map s <Cmd>HopChar2<CR>
map <leader>l <Cmd>HopLine<CR>
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
    nmap <buffer> <F5> <Cmd>JupyniumStartSync<CR>
    map <buffer> <S-CR> <Cmd>JupyniumExecuteSelectedCells<CR><Cmd>lua require'jupynium.textobj'.goto_next_cell_separator()<CR>
    map <buffer> <leader>c <Cmd>JupyniumClearSelectedCellsOutputs<CR>
    nmap <buffer> <leader>i <Cmd>JupyniumKernelHover<CR>
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
let g:loaded_zip         = 0
let g:loaded_zipPlugin   = 0
let loaded_gzip          = 0
" plugins `editorconfig`, `man.lua` and `matchit` are enabled by default

" ui and font
set background=dark
" `LineNr`: bg = SpecialKey's fg, fg = Normal's bg
" be sure that ColorColumn and CursorLine/CursorColumn have the same highlight
function s:gruvbox_material_custom()
    let palette = gruvbox_material#get_palette(
        \ g:gruvbox_material_background,
        \ g:gruvbox_material_foreground, {})
    call gruvbox_material#highlight('LineNr', palette.bg0, palette.bg5, 'bold')
    call gruvbox_material#highlight('CursorLineNr', palette.fg0, palette.bg0, 'bold')
    call gruvbox_material#highlight('CursorLine', palette.none, palette.bg_visual_blue)
    call gruvbox_material#highlight('CursorColumn', palette.none, palette.bg_visual_blue)
    call gruvbox_material#highlight('ColorColumn', palette.none, palette.bg_visual_blue)

    call gruvbox_material#highlight('CocVirtualText', palette.bg5, palette.none)
    call gruvbox_material#highlight('VirtualTextError', palette.grey2, palette.bg_visual_red, 'underline')
    call gruvbox_material#highlight('VirtualTextWarning', palette.grey2, palette.bg_visual_yellow, 'underline')
    call gruvbox_material#highlight('VirtualTextInfo', palette.grey2, palette.bg_visual_blue, 'underline')
    call gruvbox_material#highlight('VirtualTextHint', palette.grey2, palette.bg_visual_green, 'underline')

    call gruvbox_material#highlight('HighlightedyankRegion', palette.none, palette.bg_diff_blue)
    call gruvbox_material#highlight('JupyniumShortsighted', palette.none, palette.bg_dim)
endfunction
augroup GruvboxMaterialCustom
    autocmd!
    autocmd ColorScheme gruvbox-material call s:gruvbox_material_custom()
augroup END
colorscheme gruvbox-material

lua << EOF
require("ibl").setup {
    viewport_buffer = { min = 1024 },
    indent = {
        char = "▏",
        highlight = {
            "Purple", "Blue", "Aqua", "Green", "Yellow", "Orange", "Red",
        },
        repeat_linebreak = false,
    },
    whitespace = { remove_blankline_trail = false },
    scope = { enabled = false },
}
EOF

set guifont=等距更纱黑体\ SC\ Nerd\ Font:h15
set guicursor=n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor
" args of Nvy: --geometry=120x30 --position=320,160 --cursor-timeout=2000
if !exists('g:nvy') && has('gui_running')
    set lines=30 columns=120
endif

" VimTweak
if has('win32') && has('gui_running')
    runtime autoload/vimtweak2.vim
    " recommended value: 200~255
    autocmd UIEnter * call SetAlpha(247)
    let g:topMost = 0
    nmap <leader>q <Cmd>let g:topMost = 1 - g:topMost<Bar>call EnableTopMost(g:topMost)<CR>
    let g:maximize = 0
    nmap <leader>m <Cmd>let g:maximize = 1 - g:maximize<Bar>call EnableMaximize(g:maximize)<CR>
endif

" layout
set title
set signcolumn=number number norelativenumber numberwidth=3
set colorcolumn=81 nocursorline
set laststatus=2
set noruler  " since it's redefined

" movement
set scrolloff=0 nostartofline
set virtualedit=block
set jumpoptions=view

" text display
set wrap nolinebreak breakindent showbreak=\|~>
" turn off physical line wrapping (automatic insertion of newlines)
" but except LaTeX
set textwidth=0 wrapmargin=0
autocmd FileType * call s:setlocal_textwidth()
function s:setlocal_textwidth()
    if &filetype=='tex' | setlocal textwidth=80
        \ | else | setlocal textwidth=0 | endif
    setlocal wrapmargin=0
endfunction

set display=lastline,uhex conceallevel=0
" ◦␣¬░▒▓█
set list listchars=space:◦,trail:█,eol:¬,nbsp:␣

set nospell spelllang=en,cjk
set showmatch

" other info
set wildmenu wildmode=longest,full
set report=0
set shortmess-=F shortmess+=mrI
set belloff=
silent! aunmenu PopUp.-1-
silent! aunmenu PopUp.-2-
silent! aunmenu PopUp.Inspect
silent! aunmenu PopUp.How-to\ disable\ mouse
" copy and paste with system clipboard
set clipboard=unnamedplus

" dir and files
set autochdir noautoread
set updatetime=200
set backup undofile backupdir-=.

" some keys' behaviors
set nosmarttab expandtab shiftround
autocmd FileType * set expandtab
set tabstop=4 softtabstop=4 shiftwidth=4
autocmd FileType c,cpp,json,jsonc,yaml
    \ setlocal tabstop=2 softtabstop=2 shiftwidth=2
set backspace=indent,eol,start
set mouse=a mousemodel=popup mousehide
set mousescroll=ver:2,hor:4

" key mappings
" movement
" horizontal
map <leader>a ^
map <leader>e $
" hold selection when shifting sidewards
xnoremap < <gv
xnoremap > >gv
" vertical
" j/k will move over virtual lines (lines that wrap)
noremap <expr> j  (v:count == 0 ? 'gj' : 'j')
noremap <expr> k  (v:count == 0 ? 'gk' : 'k')
map <expr> <Down> (v:count == 0 ? 'gj' : 'j')
map <expr> <Up>   (v:count == 0 ? 'gk' : 'k')
imap <Down> <C-o>gj
imap <Up> <C-o>gk
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

" insert and cmdline
imap <C-Tab> <C-t>
iabbrev idate <C-r>=strftime('%y/%m/%d %H:%M:%S')<CR>
nmap ： :
" In Terminal mode, type `<C-\><C-n>` to enter Normal mode
" NOTE: Some processes really rely on `<Esc>`, e.g. Neovim nested in Terminal
tnoremap <Esc> <C-\><C-n>

" other
nmap <leader><leader> <C-l>
nmap <leader>o <Cmd>only<CR>
nmap <leader>p <Cmd>setlocal spell!<CR>
" as a hotkey of GoldenDict
nmap <C-c>c <Nop>
nmap <C-c> <Nop>

nmap \c /\<TODO\>\\|\<NOTE\>\\|\<XXX\>\\|\<FIX\>\\|\<FIXME\>\\|\<BUG\><CR>
nmap \w / \+$\\|[^^ ]\zs \{2,}<CR>
autocmd FileType python nmap <buffer> \w / \+$\\|[^^ ]\zs \{2,}\ze[^#]<CR>
autocmd FileType vim nmap <buffer> \w / \+$\\|[^^ ]\zs \{2,}\ze[^"]<CR>

" filetype related
autocmd FileType python nmap <buffer> <F5> :up!<CR>:!python -u %<CR>
autocmd FileType tex nmap <buffer> <F6> :sp %:r.log<CR>/\.tex:\d<CR>
autocmd FileType tex command! -buffer Pdf2Svg
    \ exec "!dvisvgm -P " .. expand('%:r') .. '.pdf'

" Neovim's default mappings
" nnoremap Y y$
" nnoremap <C-L> <Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>
" inoremap <C-U> <C-G>u<C-U>
" inoremap <C-W> <C-G>u<C-W>
" xnoremap * y/\V<C-R>"<CR>
" xnoremap # y?\V<C-R>"<CR>
" nnoremap & :&&<CR>

" highlight
set pumblend=0 winblend=0
hi MatchParen ctermbg=24 guibg=#005F87
hi Search ctermfg=15 ctermbg=32 guifg=#FFFFFF guibg=#0087D7
hi Cursor cterm=None gui=None ctermbg=36 guibg=#00BF9F

" highlight for treesitter
hi @variable.parameter ctermfg=DarkCyan guifg=DarkCyan

" highlight for markdown
hi! link @text.title1 markdownH1
hi! link @text.title2 markdownH2
hi! link @text.title3 markdownH3
hi! link @text.title4 markdownH4
hi! link @text.title5 markdownH5
hi! link @text.title6 markdownH6
hi! link @text.quote Comment

" highlight for jupynium
hi! link JupyniumCodeCellSeparator     MatchParen
hi! link JupyniumMarkdownCellSeparator MatchParen
hi! link JupyniumMagicCommand          Keyword

" utils for tex
let g:tex_flavor = "latex"
function UsePDFLaTeX()
    call writefile(['$pdf_mode = 1;'], '.latexmkrc', 's')
endfunction
function MapPeriod()
    execute '%s/。/./g'
    imap <buffer> 。 .
endfunction

" rearrange line breaks in text copied from PDF
function s:rearrange_linebreaks()
    let cliptext = getreg('+')
    let maps = [
        \ [ 'e\.g\.'                , 'for example'            ],
        \ [ 'i\.e\.'                , 'that is'                ],
        \ [ 'etc\.'                 , 'and so on.'             ],
        \ [ 'et[ \t\n\r]\{1,\}al\.' , 'and others '            ],
        \ [ ' ff\.'                 , ' and following.'        ],
        \ [ 'cf\.'                  , 'see '                   ],
        \ [ 'cp\.'                  , 'see '                   ],
        \ [ 'Q\.E\.D\.'             , 'that which was proven.' ],
        \ [ 'i\.i\.d\.'             , 'independent and identically distributed' ],
        \ [ 'w\.r\.t\.'             , 'with respect to'        ],
        \ [ 'viz\.'                 , 'namely'                 ],
        \ [ 'Fig\.'                 , 'figure'                 ],
        \ [ 'Tab\.'                 , 'table'                  ],
        \ [ 'Eq\.'                  , 'equation'               ],
        \ [ '[\e\t\r\b\n]'          , ' '                      ],
        \ [ '\s\{1,\}'              , ' '                      ],
        \ [ '[?!\.]\@<=\s'          , '\n'                     ],
        \ [ '^\s\{1,\}'             , ''                       ],
        \ [ '\s\{1,\}$'             , ''                       ],
        \ ]
    for [pat, sub] in maps
        let cliptext = substitute(cliptext, pat, sub, 'g')
    endfor
    call setreg('+', cliptext)
endfunction
nmap \\ <Cmd>autocmd FocusGained * call <SID>rearrange_linebreaks()<CR>

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
    \ && &ft !~# "commit\|rebase" && !exists('b:jumped')
    \ | exe "normal! g`\"" | call feedkeys('zzzv', 'n') | let b:jumped = 1 | endif

" tips
" user config dir `:echo stdpath('config')`
autocmd BufRead coc-settings.json set filetype=jsonc
command Vimrc execute('CocConfig') | vsplit $MYVIMRC
command HtmlColorNames exec 'tabe ' .. stdpath("config") .. '/mds/HtmlColorNames.md'
" `<Cmd>...<CR>` in key mappings
" vim can't distinguish between `<Tab>` and `<C-i>`, `<Esc>` and `<C-[>`

" `:TOhtml`
" `:echo synIDattr(synID(line('.'), col('.'), 1), 'name')` or just `:Inspect`
" diff jump: [c ]c
" spell jump: [s ]s
" spell suggest: z=
