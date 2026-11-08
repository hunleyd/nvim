# nvim/

## Install Instructions

> Install requires Neovim 0.12+. Always review the code before installing a configuration.
> - **Leader Key**: `<Space>`
> - **Plugin Manager**: Built-in `vim.pack`

Clone the repository and install the plugins:

```sh
git clone git@github.com:hunleyd/nvim ~/.config/hunleyd/nvim
```

Open Neovim with this config:

```sh
NVIM_APPNAME=hunleyd/nvim/ nvim
```

## Plugins

### cmdline

- [rachartier/tiny-cmdline.nvim](https://github.com/rachartier/tiny-cmdline.nvim) - A Neovim plugin that repositions the cmdline as a centered floating window, powered by Neovim's native ui2 system.

### colorscheme

- [marekh19/meowsoot.nvim](https://github.com/marekh19/meowsoot.nvim) - A pink–cyan–lavender Neovim colorscheme. Strings are yellow, functions are pink, types are lavender — and green never reaches code. Pure Lua, zero deps, 22 plugin integrations, AAA contrast. Matching Ghostty / Kitty / Alacritty / WezTerm / Tmux / Fish configs.

### editing-support

- [Einenlum/yaml-revealer](https://github.com/Einenlum/yaml-revealer) - A vim plugin to easily navigate through Yaml files
- [psliwka/vim-dirtytalk](https://github.com/psliwka/vim-dirtytalk) - spellcheck dictionary for programmers 📖
- [ptdewey/yankbank-nvim](https://github.com/ptdewey/yankbank-nvim) - Neovim plugin improving access to clipboard history

### lsp

- [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - Quickstart configs for Nvim LSP

### lsp-installer

- [williamboman/mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) - Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim.
- [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) - Portable package manager for Neovim that runs everywhere Neovim runs. Easily install and manage LSP servers, DAP servers, linters, and formatters.

### markdown-and-latex

- [MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) - Improve viewing Markdown in Neovim

### nvim-dev

- [MunifTanjim/nui.nvim](https://github.com/MunifTanjim/nui.nvim) - UI Component Library for Neovim.
- [kkharji/sqlite.lua](https://github.com/kkharji/sqlite.lua) - SQLite LuaJIT binding with a very simple api.

### snippet

- [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) - Set of preconfigured snippets for different languages.

### syntax

- [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Nvim Treesitter configurations and abstraction layer
- [nvim-treesitter/nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) - Syntax aware text-objects, select, move, swap, and peek support.
- [pearofducks/ansible-vim](https://github.com/pearofducks/ansible-vim) - A vim plugin for syntax highlighting Ansible's common filetypes

### utility

- [echasnovski/mini.nvim](https://github.com/echasnovski/mini.nvim) - Library of 45+ independent Lua modules improving Neovim experience with minimal effort

### workflow

- [m4xshen/hardtime.nvim](https://github.com/m4xshen/hardtime.nvim) - Break bad habits, master Vim motions

## Language Servers

- [harper_ls](https://github.com/Automattic/harper) - Offline, privacy-first grammar checker. Fast, open-source, Rust-powered
- [lua_ls](https://github.com/LuaLS/lua-language-server) - A language server that offers Lua language support - programmed in Lua
