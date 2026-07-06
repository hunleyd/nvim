-- =============================================================================
-- Plugin: Custom GUI-Style Tabline
-- =============================================================================

--- Custom GUI-Style Tabline
---
--- This module implements a from-scratch tabline that looks like physical tabs.
--- We avoid mini.tabline to allow for independent coloring of separators (│)
--- without them inheriting the active tab's background.
--- @tag MyTabLine

local M = {}

-- Color Palette (Synced with Meowsoot / mini.lua)
--- @private
M.colors = {
  fg = "#e2e0df",
  bg = "#171616",
  bg_2 = "#282625",     -- Inactive tab / Fill background
  bg_4 = "#454240",     -- Subdued separator color (fg_mute)
  blue = "#96bddf",     -- Active tab text
  yellow = "#dfd286",   -- Modified indicator (peach)
  fg_mute = "#85807a",  -- Inactive text
}

-- -----------------------------------------------------------------------------
-- Highlights Setup
-- -----------------------------------------------------------------------------

--- Setup highlights for the tabline
--- @private
local function setup_highlights()
  local c = M.colors
  -- Active tab: Uses main background, blue text, blue underline
  vim.api.nvim_set_hl(0, "TabLineSel", { fg = c.blue, bg = c.bg, bold = true, underline = true, sp = c.blue })
  -- Inactive tab: Uses darker background, muted text
  vim.api.nvim_set_hl(0, "TabLine", { fg = c.fg_mute, bg = c.bg_2 })
  -- Fill space: Darker background
  vim.api.nvim_set_hl(0, "TabLineFill", { bg = c.bg_2 })
  -- Separators: Subdued color on dark background
  vim.api.nvim_set_hl(0, "TabSeparator", { fg = c.bg_4, bg = c.bg_2 })
  -- Modified inactive: Warning color on dark background
  vim.api.nvim_set_hl(0, "TabLineHiddenMod", { fg = c.yellow, bg = c.bg_2 })
end

-- -----------------------------------------------------------------------------
-- Tabline Logic
-- -----------------------------------------------------------------------------

--- Render the custom GUI-style tabline
---
--- This function iterates through all listed buffers and constructs a string
--- representing physical tabs. It uses `TabSeparator` for vertical lines and
--- `TabLineSel` / `TabLineHiddenMod` for buffer states.
---
--- It is intended to be used as `vim.o.tabline = "%!v:lua.MyTabLine()"`.
---
--- @return string Rendered tabline string
function _G.MyTabLine()
  setup_highlights() -- Ensure highlights are updated (handles colorscheme changes)

  local s = ""
  local active_buf = vim.api.nvim_get_current_buf()
  local n_listed_bufs = 0
  
  -- Iterate through all buffers to find listed ones
  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.buflisted(buf_id) == 1 then
      n_listed_bufs = n_listed_bufs + 1
      local is_active = (buf_id == active_buf)
      local name = vim.api.nvim_buf_get_name(buf_id)
      name = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[No Name]"

      -- Check if modified
      if vim.bo[buf_id].modified then
        name = name .. " ●"
      end

      -- Every tab draws a single separator on its left side
      s = s .. "%#TabSeparator#│"

      -- Draw the actual tab content
      if is_active then
        s = s .. "%#TabLineSel#  " .. name .. "  "
      elseif vim.bo[buf_id].modified then
        s = s .. "%#TabLineHiddenMod#  " .. name .. "  "
      else
        s = s .. "%#TabLine#  " .. name .. "  "
      end
    end
  end

  -- Cap the entire list of tabs with one final right separator
  if n_listed_bufs > 0 then
    s = s .. "%#TabSeparator#│"
  end

  -- Fill the rest of the line and reset to normal behavior
  s = s .. "%#TabLineFill#%T"
  return s
end

-- -----------------------------------------------------------------------------
-- Options
-- -----------------------------------------------------------------------------

-- Enable the custom tabline.
vim.o.tabline = "%!v:lua.MyTabLine()"

-- Always show the tabline.
vim.o.showtabline = 2

return M
