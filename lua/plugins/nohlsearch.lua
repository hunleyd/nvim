-- =============================================================================
-- Plugin: nohlsearch
-- =============================================================================

-- nohlsearch is an optional built-in plugin that automatically clears search
-- highlighting after a search is finished and the cursor moves or a timer expires.

-- Load the optional nohlsearch plugin.
vim.cmd.packadd("nohlsearch")

-- -----------------------------------------------------------------------------
-- Keybindings
-- -----------------------------------------------------------------------------

-- Map <Esc> in Normal mode to also manually clear search highlights.
-- This is a common pattern to quickly clean up the UI.
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR><Esc>", { desc = "Clear search highlights", silent = true })
