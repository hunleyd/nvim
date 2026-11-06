-- =============================================================================
-- Core: Autocompletion (ins-autocompletion)
-- =============================================================================

-- Neovim v0.12 introduced a built-in 'autocomplete' feature that automatically
-- triggers the completion menu as you type, providing a modern experience 
-- without needing external plugins.

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- Disable built-in autocomplete as we are switching to mini.completion.
vim.opt.autocomplete = false

-- Configure the completion menu behavior:
-- menuone : Show the menu even if there is only one match.
-- noselect: Do not automatically select a match from the menu.
-- popup   : Show documentation/extra info in a popup window.
vim.opt.completeopt = { "menuone", "noselect", "popup" }

-- Use rounded borders on the popup menu to match UI2 and meowsoot floating windows.
vim.opt.pumborder = "rounded"
