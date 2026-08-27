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
