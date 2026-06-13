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
})
