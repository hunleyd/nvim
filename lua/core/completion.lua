-- =============================================================================
-- Core: Autocompletion (ins-autocompletion)
-- =============================================================================

-- Neovim v0.12 introduced a built-in 'autocomplete' feature that automatically
-- triggers the completion menu as you type, providing a modern experience 
-- without needing external plugins.

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- Enable automatic completion for all sources (LSP, Buffer, Tags, etc.).
vim.opt.autocomplete = "all"

-- Configure the completion menu behavior:
-- menuone : Show the menu even if there is only one match.
-- noselect: Do not automatically select a match from the menu.
-- popup   : Show documentation/extra info in a popup window.
vim.opt.completeopt = { "menuone", "noselect", "popup" }

-- Set a short delay (in milliseconds) before the completion menu appears.
-- This prevents the menu from flickering while typing quickly.
vim.opt.autocompletedelay = 100
