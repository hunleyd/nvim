-- =============================================================================
-- Plugin: man.lua
-- =============================================================================

-- man.lua is a built-in module for viewing system man pages with 
-- syntax highlighting and navigation.

-- -----------------------------------------------------------------------------
-- Keybindings
-- -----------------------------------------------------------------------------

-- <leader>mm: Prompt for a man page to open.
vim.keymap.set("n", "<leader>mm", ":Man ", { desc = "Open Man Page" })
