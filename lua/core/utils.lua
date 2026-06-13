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
  local title = opts.title or " System "

  -- Map levels to titles, highlights, and timeouts
  local level_map = {
    [vim.log.levels.INFO] = { title = " Info ", hl = "DiagnosticInfo", timeout = 3000 },
    [vim.log.levels.WARN] = { title = " Warning ", hl = "DiagnosticWarn", timeout = 10000 },
    [vim.log.levels.ERROR] = { title = " Error ", hl = "DiagnosticError", timeout = 30000 },
    [vim.log.levels.DEBUG] = { title = " Debug ", hl = "Comment", timeout = 3000 },
    [vim.log.levels.TRACE] = { title = " Trace ", hl = "Comment", timeout = 3000 },
  }

  local config = level_map[level] or level_map[vim.log.levels.INFO]
  title = opts.title or config.title
  local timeout = opts.timeout or config.timeout

  local buf = vim.api.nvim_create_buf(false, true)

  -- Split message into lines for multi-line support
  local lines = {}
  for s in msg:gmatch("[^\r\n]+") do
    table.insert(lines, "  " .. s .. "  ")
  end

  local max_line_width = 0
  for _, line in ipairs(lines) do
    max_line_width = math.max(max_line_width, #line)
  end

  local width = math.max(max_line_width, #title) + 2
  local height = #lines

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
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Highlight consistent with meowsoot
  vim.api.nvim_set_hl(0, "NotifyWin", { link = "NormalFloat" })
  vim.api.nvim_set_hl(0, "NotifyBorder", { link = config.hl })
  vim.wo[win].winhl = "Normal:NotifyWin,FloatBorder:NotifyBorder"

  -- Auto-close after timeout (if timeout > 0)
  if timeout > 0 then
    vim.defer_fn(function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end, timeout)
  end
end

return M
