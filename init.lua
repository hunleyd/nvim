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

-- Override vim.api.nvim_echo and other output methods to route direct calls
-- through our floating notification system. This is done early to capture
-- messages from plugins that load during startup (like nvim-treesitter).
local original_echo = vim.api.nvim_echo
local in_echo = false
vim.api.nvim_echo = function(chunks, history, opts)
  if in_echo then
    return original_echo(chunks, history, opts)
  end

  -- If we're in headless mode, fall back to the original echo for CLI output.
  if #vim.api.nvim_list_uis() == 0 then
    return original_echo(chunks, history, opts)
  end

  local msg = ""
  for _, chunk in ipairs(chunks) do
    msg = msg .. tostring(chunk[1])
  end

  -- Determine level based on common highlight groups used in echo
  local level = vim.log.levels.INFO
  for _, chunk in ipairs(chunks) do
    local hl = chunk[2]
    if hl == "ErrorMsg" or hl == "Error" then
      level = vim.log.levels.ERROR
      break
    elseif hl == "WarningMsg" or hl == "Warning" then
      level = vim.log.levels.WARN
    end
  end

  -- We use a deferred call to ensure Utils is loaded if this is called extremely early.
  vim.schedule(function()
    in_echo = true
    local ok, err = pcall(function()
      if _G.Utils and _G.Utils.notify then
        _G.Utils.notify(msg, level, { title = " System " })
      else
        -- Fallback if Utils is not yet available
        vim.notify(msg, level)
      end
    end)
    in_echo = false
    if not ok then
      error(err)
    end
  end)
end

-- Override the global print function to also use floating notifications.
_G.print = function(...)
  local args = { ... }
  local msg = ""
  for i, arg in ipairs(args) do
    msg = msg .. (i > 1 and " " or "") .. tostring(arg)
  end
  vim.notify(msg, vim.log.levels.INFO, { title = " Message " })
end

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

require("core.packs")
require("core.completion")

vim.notify("Neovim configuration initialized.", vim.log.levels.INFO, { title = " System " })
