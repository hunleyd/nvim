-- =============================================================================
-- Plugin: osc52.lua
-- =============================================================================

-- osc52.lua provides native support for copying text to the system clipboard
-- using the OSC 52 escape sequence. This is particularly useful for 
-- synchronizing the clipboard when working over SSH or inside tmux.

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- Configure the system clipboard to use the built-in OSC 52 provider.
-- Neovim v0.12+ accepts the provider name string directly (see :help clipboard-osc52).
vim.g.clipboard = "osc52"
