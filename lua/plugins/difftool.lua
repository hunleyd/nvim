-- =============================================================================
-- Plugin: nvim.difftool
-- =============================================================================

-- nvim.difftool is a modern built-in directory and file comparison tool.
-- It provides side-by-side diffs and directory comparisons.

-- Load the optional nvim.difftool plugin.
vim.cmd.packadd("nvim.difftool")

-- -----------------------------------------------------------------------------
-- Keybindings
-- -----------------------------------------------------------------------------

-- <leader>dt: Start the Diff Tool. 
-- Leaves the command line open for the user to specify the target to compare against.
vim.keymap.set("n", "<leader>dt", ":DiffTool ", { desc = "Diff Tool (Compare)" })
