-- =============================================================================
-- Plugin: meowsoot.nvim (Colorscheme)
-- =============================================================================

-- meowsoot.nvim is a modern colorscheme that leverages Neovim's latest features.

-- Load the plugin using the built-in package manager.
vim.pack.add({
  {
    name = "meowsoot.nvim",
    src = "https://github.com/marekh19/meowsoot.nvim",
  },
})

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- Apply the colorscheme.
pcall(vim.cmd.colorscheme, "meowsoot")
