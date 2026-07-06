-- =============================================================================
-- Plugin: statuscol.nvim
-- =============================================================================

--- Status Column Configuration
---
--- `statuscol.nvim` overrides Neovim's default `statuscolumn` (the gutter).
--- We use it exclusively for high-fidelity visual layout, as mouse support
--- is disabled in this configuration.
---
--- Layout: [Git Signs] [Diagnostics] [Line Numbers] [Separator]
--- @tag statuscol

local M = {}

local ok, statuscol = pcall(require, "statuscol")
if not ok then
  vim.notify("Could not load statuscol.nvim: " .. tostring(statuscol), vim.log.levels.ERROR)
  return M
end

local builtin = require("statuscol.builtin")

-- Color Palette (Synced with Meowsoot / tabline.lua)
--- @private
M.colors = {
  bg_2 = "#282625",     -- Inactive tab / Fill background
  bg_4 = "#454240",     -- Subdued separator color (fg_mute)
}

-- Ensure the separator highlight matches our tabline aesthetic
vim.api.nvim_set_hl(0, "StatusColSeparator", { fg = M.colors.bg_4, bg = M.colors.bg_2 })

statuscol.setup({
  -- We don't need click handlers since mouse is disabled
  clickhandlers = {},
  
  -- We don't need the fold column in this config (using mini.indentscope)
  relculright = true, -- Right-align relative numbers
  
  -- The core layout of the gutter
  segments = {
    -- 1. Git Signs (mini.diff or gitsigns)
    -- Automatically hidden (collapsed) if there are no git modifications in the buffer.
    {
      sign = { namespace = { "MiniDiffViz", "gitsigns" }, maxwidth = 1, colwidth = 2, auto = true },
      click = "v:lua.ScSa"
    },
    -- 2. Diagnostics & Spelling Signs
    -- Automatically hidden (collapsed) if there are no diagnostic warnings or spelling errors.
    {
      sign = { namespace = { "diagnostic/signs", "SpellingDiagnostics" }, maxwidth = 1, colwidth = 2, auto = true },
      click = "v:lua.ScSa"
    },
    -- 3. Line Numbers (Right aligned)
    {
      text = { builtin.lnumfunc, " " },
      condition = { true, builtin.not_empty },
      click = "v:lua.ScLa",
    },
    -- 4. A subtle vertical separator mimicking our physical tabs
    {
      text = { "%#StatusColSeparator#│%*" },
      condition = { true },
    },
  },
})

return M
