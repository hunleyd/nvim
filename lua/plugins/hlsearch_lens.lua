-- =============================================================================
-- Plugin: hlsearch_lens (Native Neovim Search Lens)
-- =============================================================================

--- Native Search Lens
---
--- Displays non-intrusive virtual text at the end of the line indicating the
--- current search match index and total match count (`[current/total]`), leveraging
--- Neovim v0.12's native `vim.fn.searchcount` and extmarks.
---
--- Integrates seamlessly with `meowsoot` highlights and automatically clears on
--- cursor movement, mode change, or `:nohlsearch`.
--- @tag hlsearch_lens
--- @tag plugins.hlsearch_lens

local M = {}

--- Dedicated namespace for search lens extmarks.
--- @private
local ns_id = vim.api.nvim_create_namespace("hlsearch_lens")

--- Active lens tracking state.
--- @private
local active_lens = nil

--- Highlight group definition aligned with Meowsoot palette.
vim.api.nvim_set_hl(0, "SearchLens", {
  fg = "#dfd286", -- meowsoot peach
  bg = "#282625", -- meowsoot bg_1
  bold = true,
})

--- Clear all active search lens extmarks.
--- @tag HlSearchLens.clear
function M.clear(bufnr)
  bufnr = bufnr or 0
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
  end
  active_lens = nil
end

--- Render search lens at the current cursor line.
--- @return table|nil: The searchcount result, or nil if no active match.
--- @tag HlSearchLens.show
function M.show()
  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype == "terminal" then
    return nil
  end

  -- Verify search pattern exists and search highlighting is not disabled
  local reg_search = vim.fn.getreg("/")
  if reg_search == "" or vim.v.hlsearch == 0 then
    M.clear(bufnr)
    return nil
  end

  -- Compute match count using native C searchcount
  local sc = vim.fn.searchcount({ recompute = 1, maxcount = 999 })
  if sc.total == 0 or sc.current == 0 then
    M.clear(bufnr)
    return nil
  end

  -- Clear previous lens extmark
  M.clear(bufnr)

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local text = string.format(" [%d/%d]", sc.current, sc.total)
  if sc.incomplete == 2 then
    text = string.format(" [%d/>%d]", sc.current, sc.maxcount)
  end

  -- Place virtual text at end of line (unobtrusive, doesn't shift code columns)
  local mark_id = vim.api.nvim_buf_set_extmark(bufnr, ns_id, row, 0, {
    virt_text = { { text, "SearchLens" } },
    virt_text_pos = "eol",
    priority = 100,
  })

  active_lens = {
    bufnr = bufnr,
    row = row,
    col = cursor[2],
    mark_id = mark_id,
  }

  return sc
end

--- Statusline helper for search count representation.
--- @return string: Formatted statusline snippet or empty string if inactive.
--- @tag HlSearchLens.statusline
function M.statusline()
  if vim.v.hlsearch == 0 then
    return ""
  end
  local sc = vim.fn.searchcount({ recompute = 0, maxcount = 999 })
  if sc.total == 0 then
    return ""
  end
  return string.format("󰍉 %d/%d", sc.current, sc.total)
end

-- -----------------------------------------------------------------------------
-- Normal Mode Search Jumps Keybindings
-- -----------------------------------------------------------------------------

local function make_search_jump(motion)
  return function()
    local cnt = vim.v.count1
    local ok, err = pcall(vim.cmd, "normal! " .. cnt .. motion)
    if ok then
      M.show()
    else
      M.clear()
    end
  end
end

vim.keymap.set("n", "n", make_search_jump("n"), { desc = "Next search match with lens", silent = true })
vim.keymap.set("n", "N", make_search_jump("N"), { desc = "Previous search match with lens", silent = true })
vim.keymap.set("n", "*", make_search_jump("*"), { desc = "Search forward for word under cursor with lens", silent = true })
vim.keymap.set("n", "#", make_search_jump("#"), { desc = "Search backward for word under cursor with lens", silent = true })
vim.keymap.set("n", "g*", make_search_jump("g*"), { desc = "Search forward (partial) with lens", silent = true })
vim.keymap.set("n", "g#", make_search_jump("g#"), { desc = "Search backward (partial) with lens", silent = true })

-- -----------------------------------------------------------------------------
-- Lifecycle & Auto-Cleanup Autocommands
-- -----------------------------------------------------------------------------

local group = vim.api.nvim_create_augroup("HlSearchLensLifecycle", { clear = true })

-- Trigger lens when leaving cmdline after searching (/ or ?)
vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = group,
  callback = function()
    local cmdtype = vim.v.event and vim.v.event.cmdtype or ""
    if cmdtype == "/" or cmdtype == "?" then
      vim.schedule(function()
        M.show()
      end)
    end
  end,
})

-- Clear or update lens on cursor movement
vim.api.nvim_create_autocmd("CursorMoved", {
  group = group,
  callback = function(args)
    if not active_lens then
      return
    end

    -- If search highlights were cleared (e.g. by nohlsearch), clear lens
    if vim.v.hlsearch == 0 then
      M.clear(args.buf)
      return
    end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local cur_row = cursor[1] - 1
    -- If cursor moved to a different row, clear the lens
    if args.buf ~= active_lens.bufnr or cur_row ~= active_lens.row then
      M.clear(args.buf)
    end
  end,
})

-- Clear lens on mode change to Insert/Visual/Replace
vim.api.nvim_create_autocmd({ "InsertEnter", "BufLeave", "WinLeave" }, {
  group = group,
  callback = function(args)
    M.clear(args.buf)
  end,
})

-- Reapply highlight colors if colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = function()
    vim.api.nvim_set_hl(0, "SearchLens", {
      fg = "#dfd286",
      bg = "#282625",
      bold = true,
    })
  end,
})

return M
