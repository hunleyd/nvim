-- =============================================================================
-- Plugin: spellfile.lua
-- =============================================================================

-- spellfile.lua handles automatic downloading of missing spell dictionaries.

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- Enable spell checking by default.
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }

-- Define a dedicated directory for spell-check files (dictionaries and word lists).
local spell_dir = vim.fn.stdpath("data") .. "/spell"

-- Ensure the directory exists.
if vim.fn.isdirectory(spell_dir) == 0 then
  vim.fn.mkdir(spell_dir, "p")
end

-- Add this directory to the beginning of runtimepath so Neovim uses it
-- for downloading and finding .spl (dictionary) files.
vim.opt.runtimepath:prepend(spell_dir)

-- The 'spellfile' option points to the file where 'zg' (add to dictionary)
-- and 'zw' (mark as wrong) commands save your personal word list.
vim.opt.spellfile = spell_dir .. "/en.utf-8.add"
