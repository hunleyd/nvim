-- =============================================================================
-- Plugin: hardtime.nvim
-- =============================================================================

--- Hardtime Configuration
---
--- `hardtime.nvim` enforces efficient Neovim usage by restricting repetitive 
--- keystrokes and suggesting better motions. It acts as a digital coach to 
--- break bad habits like spamming `hjkl` or arrow keys.
--- @tag hardtime

local M = {}

-- Load the plugin and its dependency using the built-in package manager.
vim.pack.add({
  {
    name = "nui.nvim",
    src = "https://github.com/MunifTanjim/nui.nvim",
  },
  {
    name = "hardtime.nvim",
    src = "https://github.com/m4xshen/hardtime.nvim",
  },
})

-- -----------------------------------------------------------------------------
-- Configuration (Strict Mode)
-- -----------------------------------------------------------------------------

local ok, hardtime = pcall(require, "hardtime")
if ok then
  hardtime.setup({
    -- "block" mode actively prevents you from pressing keys too many times
    restriction_mode = "block",
    
    -- Very strict: allow only 2 repetitive presses within 1000ms
    max_count = 2,
    max_time = 1000,
    
    -- Allow different keys to reset the count? 
    -- e.g., j, k, j, k. Setting to false means total hjkl presses are counted together.
    allow_different_key = false,

    -- Enable hints to teach better motions (e.g., suggesting `c` instead of `d...i`)
    hint = true,
    
    -- Restrict these keys in Normal (n), Visual (x), and Operator-Pending (o) modes
    restricted_keys = {
      ["h"] = { "n", "x" },
      ["j"] = { "n", "x" },
      ["k"] = { "n", "x" },
      ["l"] = { "n", "x" },
      ["-"] = { "n", "x" },
      ["+"] = { "n", "x" },
      ["gj"] = { "n", "x" },
      ["gk"] = { "n", "x" },
      ["<CR>"] = { "n", "x" },
      ["<BS>"] = { "n", "x" },
      ["<Space>"] = { "n", "x" },
      ["<Up>"] = { "n", "x", "i", "c" },
      ["<Down>"] = { "n", "x", "i", "c" },
      ["<Left>"] = { "n", "x", "i", "c" },
      ["<Right>"] = { "n", "x", "i", "c" },
    },
    
    -- Disable in certain buffers where spamming is expected (e.g., file explorers)
    disabled_filetypes = { 
      "qf", 
      "netrw", 
      "minifiles", 
      "minipick", 
      "checkhealth" 
    },
  })
else
  vim.notify("Could not load hardtime.nvim", vim.log.levels.ERROR)
end

return M
