-- =============================================================================
-- Plugin: rachartier/tiny-cmdline.nvim
-- =============================================================================

--- Centered floating command-line using Neovim v0.12+ UI2
---
--- Replaces the native bottom-anchored cmdline with a sleek, responsive,
--- and centered floating window, utilizing Neovim's experimental UI2.
--- @tag plugins.cmdline

-- Add rachartier/tiny-cmdline.nvim to managed packages
vim.pack.add({
  {
    name = "tiny-cmdline.nvim",
    src = "https://github.com/rachartier/tiny-cmdline.nvim",
  },
})

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- Set cmdheight to 0 to hide the legacy message/cmd area at the bottom.
-- This properly signals Neovim and the ui2 architecture to route the cmdline
-- to our newly configured floating window.
vim.opt.cmdheight = 0

local ok, tiny_cmdline = pcall(require, "tiny-cmdline")
if ok then
  tiny_cmdline.setup({
    -- Command-line window dimensions
    width = {
      value = "50%", -- Centered pop-up width as a fraction of editor columns
      min = 40,
      max = 80,
    },

    position = {
      x = "50%", -- Centered horizontally
      y = "35%", -- Positioned slightly higher than center for ideal eye tracking
    },

    -- Clean, modern rounded border
    border = "rounded",

    -- Set empty to center search queries (/ and ?) in the floating window as well
    native_types = {},

    -- Enable dynamic titles on the border
    title = {
      enabled = true,
      pos = "center",
    },
  })
end
