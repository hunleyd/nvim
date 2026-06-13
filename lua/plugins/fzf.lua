-- =============================================================================
-- Plugin: fzf.vim
-- =============================================================================

-- fzf.vim is a built-in wrapper for the fzf command-line fuzzy finder.
-- It requires the 'fzf' binary to be installed on the system.

-- -----------------------------------------------------------------------------
-- Keybindings
-- -----------------------------------------------------------------------------

-- <leader>ff: Find Files using fzf.
vim.keymap.set("n", "<leader>ff", ":Files<CR>", { desc = "FZF Find Files", silent = true })

-- <leader>fb: Find open Buffers.
vim.keymap.set("n", "<leader>fb", ":Buffers<CR>", { desc = "FZF Find Buffers", silent = true })

-- <leader>fg: Find Git files (files tracked by git).
vim.keymap.set("n", "<leader>fg", ":GFiles<CR>", { desc = "FZF Find Git Files", silent = true })

-- <leader>fh: Find help tags.
vim.keymap.set("n", "<leader>fh", ":HelpTags<CR>", { desc = "FZF Find Help", silent = true })
