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

-- Save the original vim.notify at module load time to avoid recursion
local original_notify = vim.notify

--- Display a transient floating notification using mini.notify.
--- @param msg string|table: The message to display.
--- @param level number|string|nil: The log level (e.g., vim.log.levels.INFO).
--- @param opts table|nil: Optional settings (title, timeout, id).
M.notify = function(msg, level, opts)
  -- Convert message to string if it's not one
  if type(msg) ~= "string" then
    msg = vim.inspect(msg)
  end

  opts = opts or {}
  level = level or vim.log.levels.INFO

  -- Map levels to timeouts and icons
  local level_map = {
    [vim.log.levels.INFO] = { icon = "󰋽", timeout = 3000, key = "INFO" },
    [vim.log.levels.WARN] = { icon = "󰀦", timeout = 10000, key = "WARN" },
    [vim.log.levels.ERROR] = { icon = "󰅙", timeout = 30000, key = "ERROR" },
    [vim.log.levels.DEBUG] = { icon = "󰃤", timeout = 3000, key = "DEBUG" },
    [vim.log.levels.TRACE] = { icon = "󰙔", timeout = 3000, key = "TRACE" },
  }

  local config = level_map[level] or level_map[vim.log.levels.INFO]
  local timeout = opts.timeout or config.timeout
  local icon = config.icon
  local level_key = config.key

  -- Ensure mini.notify is loaded (it might be called during early init)
  local ok, mininotify = pcall(require, "mini.notify")
  if not ok then
    -- Fallback to the original notify (captured before any overrides)
    return original_notify(msg, level, opts)
  end

  local full_msg = icon .. " " .. msg
  local id = opts.id

  if id and mininotify.get(id) then
    mininotify.update(id, { msg = full_msg, level = level_key })
  else
    id = mininotify.add(full_msg, level_key)
  end

  -- Auto-remove after timeout
  if timeout > 0 then
    vim.defer_fn(function()
      mininotify.remove(id)
    end, timeout)
  end

  return id
end

return M
