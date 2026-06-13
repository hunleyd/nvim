-- =============================================================================
-- Plugin: justify
-- =============================================================================

-- justify is an optional built-in plugin that provides commands to align text.
-- It adds :Justify, :Left, :Right, and :Center commands.

-- Load the optional justify plugin.
vim.cmd.packadd("justify")

-- -----------------------------------------------------------------------------
-- Keybindings
-- -----------------------------------------------------------------------------

-- <leader>jj: Full justification (aligns both left and right margins).
vim.keymap.set("v", "<leader>jj", ":Justify<CR>", { desc = "Justify text", silent = true })

-- <leader>jc: Center text.
vim.keymap.set("v", "<leader>jc", ":Center<CR>", { desc = "Center text", silent = true })

-- <leader>jl: Left-align text.
vim.keymap.set("v", "<leader>jl", ":Left<CR>", { desc = "Left-align text", silent = true })

-- <leader>jr: Right-align text.
vim.keymap.set("v", "<leader>jr", ":Right<CR>", { desc = "Right-align text", silent = true })
