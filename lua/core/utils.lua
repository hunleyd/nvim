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
--- @param msg string: The message to display.
--- @param title string|nil: Optional title for the notification window.
--- @param timeout number|nil: Optional timeout in milliseconds (defaults to 3000).
M.notify = function(msg, title, timeout)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.max(#msg, #(title or "")) + 4
  local height = 1
  timeout = timeout or 3000

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = vim.o.columns - width - 2,
    row = 1,
    style = "minimal",
    border = "rounded",
    title = title or " Notification ",
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, false, opts)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  " .. msg .. "  " })

  -- Highlight consistent with meowsoot's FloatBorder
  vim.api.nvim_set_hl(0, "NotifyWin", { link = "NormalFloat" })
  vim.api.nvim_set_hl(0, "NotifyBorder", { link = "FloatBorder" })
  vim.wo[win].winhl = "Normal:NotifyWin,FloatBorder:NotifyBorder"

  -- Auto-close after timeout
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, timeout)
end

return M
