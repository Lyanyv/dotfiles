My personal Neovim configuration for editing `python`, `c/cpp`, `markdown` and `LaTeX` files in Windows, naive but not simple.

# Screenshots

vimrc and coc-settings
![](./imgs/vimrc.png)

search workspace symbols of pytorch (after finishing index)
![](./imgs/index-torch.png)

list all diagnostics info and locations of the current buffer, and move the cursor to the float window
![](./imgs/diag_torch_and_move_cursor_to_float_win.png)

# Requirements

- `Neovim` >= v0.9.1
    - `Python` 3.4+, packages `pynvim` and `neovim-remote`.

- GUI/client: `Nvy`
> Builtin `neovim-qt/nvim-qt` doesn't support `Direct Write`.

[Nvy](https://github.com/RMichelsen/Nvy/releases)

- `guifont`: 等距更纱黑体 Slab SC

[Sarasa-Gothic](https://github.com/be5invis/Sarasa-Gothic/releases)

- `junegunn/vim-plug`: put `plug.vim` in `stdpath('data') . '/site/autoload'`
    - default plug path: `stdpath('data') . '/plugged'`

## `nvim-treesitter/nvim-treesitter`

- `Visual Studio Build Tools`

After installing this plugin, run Neovim via Visual Studio's "x64 Native Tools Command Prompt" console.

[Windows-support](https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support#msvc)

## `neoclide/coc.nvim`

- `Node.js` >= 14.14

### `coc-pyright`

- python packages: `ruff`, `yapf`

### `coc-texlab`

- `Tex Live` (or other LaTeX distribution)
- `SumatraPDF`

> For the content of `$HOME/.latexmkrc` and the instruction to config inverse search of SumatraPDF, see the comments in `coc-settings.json`.

# TODO

See the beginning of `init.vim`.

Coming soon:

- `ccls` and `jupynium.nvim`
- `VimTweak` for `Neovim`
