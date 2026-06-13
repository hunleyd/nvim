-- =============================================================================
-- Collection: mini.nvim
-- Module: mini.ai (Extended Text Objects)
-- =============================================================================

-- mini.nvim is a collection of high-quality, minimal Lua modules.
-- mini.ai extends Neovim's text objects (around 'a', inside 'i') with 
-- smarter search, next/last variants, and more precise targets.

-- Load the mini.nvim collection using the built-in package manager.
vim.pack.add({
  {
    name = "mini.nvim",
    src = "https://github.com/echasnovski/mini.nvim",
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.ai
-- -----------------------------------------------------------------------------

require("mini.ai").setup({
  -- Number of lines within which to look for a text object.
  n_lines = 500,

  -- Custom text objects (we can extend these as needed later).
  -- By default, it includes:
  -- f: Function call
  -- a: Argument
  -- q: Quote (", ', `)
  -- b: Bracket ((), [], {})
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.align
-- -----------------------------------------------------------------------------

-- mini.align provides interactive structural alignment of code and data.
-- It is more powerful than the built-in 'justify' as it supports 
-- live previews and complex splitting patterns.
require("mini.align").setup({
  mappings = {
    -- Start interactive alignment (Visual mode).
    start = "ga",
    -- Start interactive alignment with live preview (Visual mode).
    start_with_preview = "gA",
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.comment
-- -----------------------------------------------------------------------------

-- mini.comment provides fast, dot-repeatable commenting with 
-- Tree-sitter support and a dedicated 'gc' textobject.
require("mini.comment").setup({
  -- Mappings for commenting actions.
  mappings = {
    -- Toggle comment on current line.
    comment_line = "gcc",
    -- Toggle comment on visual selection.
    comment_visual = "gc",
    -- Define 'comment' textobject (e.g., 'dgc' to delete comment block).
    textobject = "gc",
  },
  -- Options for fine-tuning behavior.
  options = {
    -- Whether to force a single space of padding between comment marker and code.
    pad_comment_parts = true,
    -- Whether to ignore blank lines when commenting a block.
    ignore_blank_line = true,
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.completion
-- -----------------------------------------------------------------------------

-- mini.completion provides asynchronous autocompletion and signature help.
require("mini.completion").setup({
  -- Delay (in ms) before showing completion popups.
  delay = {
    completion = 100,
    info = 100,
    signature = 50,
  },

  -- Action to take when LSP completion is not available.
  -- <C-n> performs standard Neovim buffer-based completion.
  fallback_action = "<C-n>",

  -- LSP completion behavior.
  lsp_completion = {
    -- Function to use for LSP completion.
    source_func = "completefunc",
    -- Automatically set up completion for every attached LSP client.
    auto_setup = true,
  },

  -- Window configuration for info and signature popups.
  window = {
    signature = { border = "rounded", winblend = 0 },
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.keymap
-- -----------------------------------------------------------------------------

-- mini.keymap simplifies complex, multi-step mappings and high-speed combos.
require("mini.keymap").setup({})

-- -----------------------------------------------------------------------------
-- Keybindings: mini.completion (via mini.keymap)
-- -----------------------------------------------------------------------------

local mk = require("mini.keymap")

-- Smart <Tab>: Navigate menu, jump snippets, indent, or trigger completion.
mk.map_multistep("i", "<Tab>", {
  "pmenu_next",
  "vimsnippet_next",
  "increase_indent",
  {
    condition = function()
      return true
    end,
    action = function()
      return require("mini.completion").completefunc_twostep()
    end,
  },
})

-- Smart <S-Tab>: Navigate menu backwards, jump snippets backwards, or dedent.
mk.map_multistep("i", "<S-Tab>", {
  "pmenu_prev",
  "vimsnippet_prev",
  "decrease_indent",
  {
    condition = function()
      return true
    end,
    action = function()
      return vim.api.nvim_replace_termcodes("<S-Tab>", true, true, true)
    end,
  },
})

-- -----------------------------------------------------------------------------
-- Keybindings: Escape Combos (via mini.keymap)
-- -----------------------------------------------------------------------------

-- 'jk' and 'kj' in Insert mode to Escape.
-- Unlike standard mappings, these type the first key immediately for zero lag.
-- We add <BS><BS> to remove the trigger characters from the buffer.
mk.map_combo("i", "jk", "<BS><BS><Esc>")
mk.map_combo("i", "kj", "<BS><BS><Esc>")

-- -----------------------------------------------------------------------------
-- Configuration: mini.pairs
-- -----------------------------------------------------------------------------

-- mini.pairs automatically manages character pairs (brackets, quotes, etc.)
-- with smart neighbor-aware logic. We've combined common defaults with
-- custom mappings for spaces, templates, and nested angle brackets.
require("mini.pairs").setup({
  mappings = {
    -- Common Pairs
    ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
    ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
    ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]." },

    [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
    ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
    ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },

    ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
    ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%w\\].", register = { cr = false } },
    ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },

    -- Custom Mappings
    -- Insert two spaces between brackets/braces when pressing Space.
    [" "] = { action = "open", pair = "  ", neigh_pattern = "[%(%[{][%)%]}]" },
    -- Pair percent signs when inside braces (useful for template tags).
    ["%"] = { action = "open", pair = "%%", neigh_pattern = "[{][}]" },
    -- Pair angle brackets only when inside braces.
    ["<"] = { action = "open", pair = "<>", neigh_pattern = "[{][}]" },
    [">"] = { action = "close", pair = "<>", neigh_pattern = "[{][}]" },
  },
})
