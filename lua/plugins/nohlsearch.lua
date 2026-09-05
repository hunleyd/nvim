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

-- Map <Esc> in Normal mode to clear search highlights and the search lens.
-- This ensures immediate visual cleanup when canceling a search.
vim.keymap.set(
  "n",
  "<Esc>",
  ":nohlsearch<CR><cmd>lua require('plugins.hlsearch_lens').clear()<CR><Esc>",
  { desc = "Clear search highlights and lens", silent = true }
)
