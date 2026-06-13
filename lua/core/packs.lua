-- =============================================================================
-- Package Management (vim.pack)
-- =============================================================================

-- This module manages external plugins using the built-in vim.pack API.
-- Each plugin's specification is defined here, and its configuration is
-- modularized into separate files within the 'lua/plugins/' directory.

local M = {}

-- -----------------------------------------------------------------------------
-- Plugin Specifications
-- -----------------------------------------------------------------------------

-- Example of how to add a plugin:
-- vim.pack.add({
--     src = "https://github.com/username/plugin-name",
--     -- Other options like branch, rev, etc.
-- })
-- require("plugins.plugin-name")

return M
