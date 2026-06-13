-- =============================================================================
-- Package Management (vim.pack)
-- =============================================================================

-- This module manages external plugins using the built-in vim.pack API.
-- Each plugin's specification is defined here, and its configuration is
-- modularized into separate files within the 'lua/plugins/' directory.

local M = {}

-- -----------------------------------------------------------------------------
-- Plugin Specifications
-- -----------------------------------------------------------------------------

-- justify: Built-in text alignment commands.
require("plugins.justify")

-- matchit: Extended % matching for HTML, if/else, etc.
require("plugins.matchit")

-- nohlsearch: Automatically clear search highlights.
require("plugins.nohlsearch")

-- nvim.difftool: Modern directory and file comparison.
require("plugins.difftool")

-- fzf.vim: Fuzzy finder integration.
require("plugins.fzf")

-- man.lua: Enhanced man page viewer.
require("plugins.man")

-- matchparen: Highlight matching brackets.
require("plugins.matchparen")

-- osc52: Native OSC 52 clipboard support.
require("plugins.osc52")

-- shada: Shared data (history, marks, registers) persistence.
require("plugins.shada")

-- spellfile: Automatic management of spell-check dictionaries.
require("plugins.spellfile")

-- comment: Native commenting support.
require("plugins.comment")

-- ui2: Experimental modernized UI architecture.
require("plugins.ui2")

return M
