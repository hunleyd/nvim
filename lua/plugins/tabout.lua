-- =============================================================================
-- Plugin: tabout (Native Insert Mode Delimiter Navigation)
-- =============================================================================

--- Native Tabout Module
---
--- Provides smart delimiter navigation out of parentheses, brackets, braces,
--- quotes, and backticks in Insert mode. Integrates seamlessly with
--- `mini.keymap.map_multistep` without external dependencies.
---
--- Supports forward tabout (`<Tab>`) past closing delimiters and backward
--- tabout (`<S-Tab>`) before opening delimiters, bounded strictly to the
--- current line.
---@tag tabout
---@tag plugins.tabout

local M = {}

--- Closing delimiter pattern for forward tabout.
--- Matches ')', ']', '}', '"', '\'', and '`'.
---@private
local CLOSE_PATTERN = [=[[)\]}\x22'`]]=]

--- Opening delimiter pattern for backward tabout.
--- Matches '(', '[', '{', '"', '\'', and '`'.
---@private
local OPEN_PATTERN = [=[[(\[{\x22'`]]=]

--- Check if forward tabout is valid at the current cursor position.
---
--- Verifies that the active buffer is normal/valid (ignoring terminal buffers)
--- and at least one closing delimiter exists on the current line at or after the cursor column.
---@return boolean: True if forward tabout can be performed.
---@tag Tabout.can_tabout_forward
function M.can_tabout_forward()
  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype == "terminal" then
    return false
  end
  -- Check if a closing delimiter exists on the current line at or after cursor
  -- 'c' accepts match at cursor, 'n' suppresses moving cursor, 'W' prevents wrap
  return vim.fn.search(CLOSE_PATTERN, "cnW", vim.fn.line(".")) > 0
end

--- Execute forward tabout to the position immediately following the next closing delimiter.
---
--- Searches for the next closing delimiter on the current line. Upon matching,
--- moves the cursor past the delimiter (+1 column) using 0-indexed coordinates.
---@return function: Deferred action callback executed after expression mapping.
---@tag Tabout.tabout_forward
function M.tabout_forward()
  return function()
    local had_match = vim.fn.search(CLOSE_PATTERN, "cW", vim.fn.line("."))
    if had_match > 0 then
      local pos = vim.api.nvim_win_get_cursor(0)
      pcall(vim.api.nvim_win_set_cursor, 0, { pos[1], pos[2] + 1 })
    end
  end
end

--- Check if backward tabout is valid at the current cursor position.
---
--- Verifies that the active buffer is normal/valid (ignoring terminal buffers)
--- and at least one opening delimiter exists on the current line before the cursor column.
---@return boolean: True if backward tabout can be performed.
---@tag Tabout.can_tabout_backward
function M.can_tabout_backward()
  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype == "terminal" then
    return false
  end
  -- Check if an opening delimiter exists on the current line before cursor
  -- 'b' searches backward, 'n' suppresses moving cursor, 'W' prevents wrap
  return vim.fn.search(OPEN_PATTERN, "bnW", vim.fn.line(".")) > 0
end

--- Execute backward tabout to the position immediately before the previous opening delimiter.
---
--- Searches backward for the previous opening delimiter on the current line and
--- positions the cursor before it for Insert mode typing.
---@return function: Deferred action callback executed after expression mapping.
---@tag Tabout.tabout_backward
function M.tabout_backward()
  return function()
    vim.fn.search(OPEN_PATTERN, "bW", vim.fn.line("."))
  end
end

--- Step definitions for `mini.keymap.map_multistep`
M.step_forward = {
  condition = M.can_tabout_forward,
  action = function()
    return M.tabout_forward()
  end,
}

M.step_backward = {
  condition = M.can_tabout_backward,
  action = function()
    return M.tabout_backward()
  end,
}

return M
