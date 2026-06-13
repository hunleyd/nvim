-- =============================================================================
-- Neovim Configuration (Lua-based)
-- Target: Neovim v0.12+ (UI2 support)
-- =============================================================================

-- Set the leader key to Space.
-- This must be set before any plugins are loaded to ensure mappings work correctly.
vim.g.mapleader = " "

-- This is the entry point for Neovim configuration.
-- In Neovim v0.12, we can leverage the new UI2 architecture for enhanced
-- rendering and interaction.

-- -----------------------------------------------------------------------------
-- Initial Setup
-- -----------------------------------------------------------------------------

-- Placeholder for future configuration modules.
-- We will follow a modular approach by placing logic in the 'lua/' directory.
_G.Utils = require("core.utils")

-- -----------------------------------------------------------------------------
-- Global Message Handling
-- -----------------------------------------------------------------------------

-- Override vim.notify to use our transient floating popup system.
vim.notify = Utils.notify

-- Override the global print function to also use floating notifications.
_G.print = function(...)
  local args = { ... }
  local msg = ""
  for i, arg in ipairs(args) do
    msg = msg .. (i > 1 and " " or "") .. tostring(arg)
  end
  Utils.notify(msg, vim.log.levels.INFO, { title = " Message " })
end

require("core.packs")
require("core.completion")

vim.notify("Neovim configuration initialized.", vim.log.levels.INFO, { title = " System " })
