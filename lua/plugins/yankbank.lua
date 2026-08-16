-- =============================================================================
-- Plugins: sqlite.lua & yankbank-nvim
-- =============================================================================

--- SQLite database and Clipboard History bank
---
--- Integrates `kkharji/sqlite.lua` as the persistence layer for `yankbank-nvim`
--- to save, search, and navigate your clipboard history across sessions.
--- @tag plugins.yankbank

-- Define the SQLite system library path explicitly for our Gentoo/64-bit environment.
-- This ensures the LuaJIT FFI binding can load libsqlite3.so natively without search failure.
vim.g.sqlite_clib_path = "/usr/lib64/libsqlite3.so"

-- Add sqlite.lua dependency
vim.pack.add({
  {
    name = "sqlite.lua",
    src = "https://github.com/kkharji/sqlite.lua",
  },
})

-- Add yankbank-nvim to managed packages
vim.pack.add({
  {
    name = "yankbank-nvim",
    src = "https://github.com/ptdewey/yankbank-nvim",
  },
})

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

local ok, yankbank = pcall(require, "yankbank")
if ok then
  yankbank.setup({
    -- Number of yanks/deletions to persist
    max_entries = 15,

    -- Separator between entries
    sep = "-----",

    -- Navigation behavior inside popup: jump directly to index by pressing numbers (1-9)
    num_behavior = "jump",

    -- Persistence settings
    persist_type = "sqlite",
    db_path = vim.fn.stdpath("data"),

    -- Register selection
    registers = {
      yank_register = "+", -- System clipboard register
    },
  })
end

-- Mapping: <leader>py to open the YankBank popup
-- Fits cleanly next to other pickers (<leader>pd, <leader>ps, <leader>pz)
vim.keymap.set("n", "<leader>py", "<cmd>YankBank<CR>", { desc = "Pick Yank (YankBank)" })
