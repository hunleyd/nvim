-- =============================================================================
-- Plugin: justify
-- =============================================================================

-- justify is an optional built-in plugin that provides commands to align text.
-- It adds :Justify, :Left, :Right, and :Center commands.

-- Load the optional justify plugin using the built-in package manager.
vim.pack.add({ name = "justify" })

-- -----------------------------------------------------------------------------
-- Keybindings
-- -----------------------------------------------------------------------------

-- <leader>jj: Full justification (aligns both left and right margins).
vim.keymap.set("v", "<leader>jj", ":Justify<CR>", { desc = "Justify text", silent = true })

-- <leader>jc: Center text.
vim.keymap.set("v", "<leader>jc", ":Center<CR>", { desc = "Center text", silent = true })
