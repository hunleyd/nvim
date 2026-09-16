-- =============================================================================
-- Plugins: sqlite.lua & yankbank-nvim
-- =============================================================================

--- SQLite database and Clipboard History bank
---
--- Integrates `kkharji/sqlite.lua` as the persistence layer for `yankbank-nvim`
--- to save, search, and navigate your clipboard history across sessions.
--- @tag plugins.yankbank

-- Define the SQLite system library path explicitly so the LuaJIT FFI binding
-- can dlopen it without relying on default search paths.
-- macOS has no physical libsqlite3.dylib on disk since Big Sur (system libs
-- live only in the dyld shared cache), so the Homebrew keg's real file is used
-- there instead of the OS-provided one.
local sqlite_clib_candidates = {
  "/usr/lib64/libsqlite3.so", -- Gentoo/64-bit Linux
  "/opt/homebrew/opt/sqlite/lib/libsqlite3.dylib", -- Homebrew on Apple Silicon
  "/usr/local/opt/sqlite/lib/libsqlite3.dylib", -- Homebrew on Intel macOS
}
for _, path in ipairs(sqlite_clib_candidates) do
  if vim.uv.fs_stat(path) then
    vim.g.sqlite_clib_path = path
    break
  end
end

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
