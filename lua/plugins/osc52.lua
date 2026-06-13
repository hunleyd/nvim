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
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = function(lines) require('vim.ui.osc52').copy('+')(lines) end,
    ['*'] = function(lines) require('vim.ui.osc52').copy('*')(lines) end,
  },
  paste = {
    ['+'] = function() return require('vim.ui.osc52').paste('+')() end,
    ['*'] = function() return require('vim.ui.osc52').paste('*')() end,
  },
}
