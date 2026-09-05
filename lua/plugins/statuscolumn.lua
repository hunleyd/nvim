-- =============================================================================
-- Plugin: mini.statuscolumn
-- =============================================================================

--- Status Column Configuration
---
--- `mini.statuscolumn` manages Neovim's `statuscolumn` (the gutter) with high
--- performance, clean defaults for virtual and wrapped lines, and automatic
--- dimming in inactive windows.
---
--- Layout: [Signs (Diff / Diagnostics)] [Line Numbers] [Separator]
--- @tag statuscolumn
--- @tag mini.statuscolumn

local M = {}

local ok, mini_statuscolumn = pcall(require, "mini.statuscolumn")
if not ok then
  vim.notify("Could not load mini.statuscolumn: " .. tostring(mini_statuscolumn), vim.log.levels.ERROR)
  return M
end

-- Color Palette (Synced with Meowsoot / tabline.lua)
---@private
local colors = {
  bg_2 = "#282625",     -- Inactive tab / Fill background
  bg_4 = "#454240",     -- Subdued separator color (fg_mute)
}

-- Ensure the separator highlights match our tabline aesthetic
vim.api.nvim_set_hl(0, "MiniStatuscolumnSep", { fg = colors.bg_4, bg = colors.bg_2 })
vim.api.nvim_set_hl(0, "MiniStatuscolumnSepCursor", { fg = colors.bg_4, bg = colors.bg_2 })

-- Mode Highlights: Sync cursorline number and cursor separator with active mode
---@private
local mode_colors = {
  n = "#98cdaa", -- Normal: Green
  i = "#96bddf", -- Insert: Blue
  v = "#96d8e3", -- Visual: Magenta
  V = "#96d8e3", -- Visual Line: Magenta
  ["\22"] = "#96d8e3", -- Visual Block (<C-v>): Magenta
  s = "#eaa4c9", -- Select: Pink
  S = "#eaa4c9", -- Select Line: Pink
  ["\19"] = "#eaa4c9", -- Select Block (<C-s>): Pink
  R = "#e99696", -- Replace: Red
  c = "#eaa4c9", -- Command: Pink
  t = "#dfd286", -- Terminal: Peach
}

--- Update cursorline number and cursor separator highlights to match active mode.
--- @private
local function update_cursorline_mode_hl()
  local mode = vim.api.nvim_get_mode().mode
  local fg = mode_colors[mode] or mode_colors[mode:sub(1, 1)] or "#e2e0df"
  vim.api.nvim_set_hl(0, "MiniStatuscolumnSep", { fg = colors.bg_4, bg = colors.bg_2 })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = fg, bold = true })
  vim.api.nvim_set_hl(0, "MiniStatuscolumnSepCursor", { fg = fg, bg = colors.bg_2, bold = true })
end

--- Refresh mode-dependent gutter highlights.
--- Updates `CursorLineNr` and `MiniStatuscolumnSepCursor` based on the active mode.
--- @tag Statuscolumn.update_mode
M.update_mode = update_cursorline_mode_hl

-- Hook mode changes and colorscheme reloads to dynamically update gutter indicators
local mode_hl_group = vim.api.nvim_create_augroup("StatuscolumnModeIndicator", { clear = true })
vim.api.nvim_create_autocmd({ "ModeChanged", "ColorScheme" }, {
  group = mode_hl_group,
  callback = update_cursorline_mode_hl,
})

-- Initialize immediately
update_cursorline_mode_hl()

mini_statuscolumn.setup({
  -- Core layout of the gutter
  content = mini_statuscolumn.gen_content.main({
    -- 1. Format: signs on left, line numbers right-aligned, vertical separator
    -- Fold column is omitted (using mini.indentscope)
    { format = "s=l", sep = "│", fold = "" },
    -- 2. Clean indicators for virtual and wrapped lines
    { ltype = "virt", lnum = "•" },
    { ltype = "wrap", lnum = "↳" },
  }),
  -- Automatically dim the statuscolumn in inactive windows
  dim_inactive = true,
})

return M
