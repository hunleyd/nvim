-- =============================================================================
-- Core Utilities (vim.fs)
-- =============================================================================

-- This module provides utility functions leveraging Neovim's built-in 
-- filesystem (vim.fs) and other core Lua modules.

local M = {}

-- -----------------------------------------------------------------------------
-- Filesystem Helpers
-- -----------------------------------------------------------------------------

--- Get the root directory of the current project.
--- It searches upwards for common project markers like .git or package.json.
--- @return string|nil: The absolute path to the project root, or nil if not found.
M.get_root = function()
  return vim.fs.root(0, { ".git", "package.json", "go.mod", "Cargo.toml", "init.lua" })
end

return M
