-- =============================================================================
-- Plugin: nvim.undotree
-- =============================================================================

--- Built-in Undo Tree Visualizer
---
--- Loads Neovim v0.12's built-in `nvim.undotree` optional package to visually
--- inspect and navigate branched undo history (`:Undotree`), paired with
--- persistent undo files (`undofile`).
--- @tag plugins.undotree

local M = {}

-- Load the optional built-in nvim.undotree plugin.
vim.cmd.packadd("nvim.undotree")

-- Enable persistent undo history across sessions.
vim.opt.undofile = true

-- -----------------------------------------------------------------------------
-- Keybindings
-- -----------------------------------------------------------------------------

-- <leader>u: Toggle the visual undo tree window.
vim.keymap.set("n", "<leader>u", "<cmd>Undotree<CR>", { desc = "Toggle Undo Tree" })

return M
