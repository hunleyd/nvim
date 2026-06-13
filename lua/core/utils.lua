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

--- Display a transient floating notification.
--- @param msg string|table: The message to display.
--- @param level number|string|nil: The log level (e.g., vim.log.levels.INFO).
--- @param opts table|nil: Optional settings (title, timeout).
M.notify = function(msg, level, opts)
  -- Convert message to string if it's not one (handles tables/numbers)
  if type(msg) ~= "string" then
    msg = vim.inspect(msg)
  end

  opts = opts or {}
  level = level or vim.log.levels.INFO
  local timeout = opts.timeout or 3000
  local title = opts.title or " System "

  -- Map levels to titles and highlights
  local level_map = {
    [vim.log.levels.INFO] = { title = " Info ", hl = "DiagnosticInfo" },
    [vim.log.levels.WARN] = { title = " Warning ", hl = "DiagnosticWarn" },
    [vim.log.levels.ERROR] = { title = " Error ", hl = "DiagnosticError" },
    [vim.log.levels.DEBUG] = { title = " Debug ", hl = "Comment" },
    [vim.log.levels.TRACE] = { title = " Trace ", hl = "Comment" },
  }

  local config = level_map[level] or level_map[vim.log.levels.INFO]
  title = opts.title or config.title

  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.max(#msg, #title) + 4
  local height = 1

  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = vim.o.columns - width - 2,
    row = 1,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, false, win_opts)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  " .. msg .. "  " })

  -- Highlight consistent with meowsoot
  vim.api.nvim_set_hl(0, "NotifyWin", { link = "NormalFloat" })
  vim.api.nvim_set_hl(0, "NotifyBorder", { link = config.hl })
  vim.wo[win].winhl = "Normal:NotifyWin,FloatBorder:NotifyBorder"

  -- Auto-close after timeout
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, timeout)
end

return M
