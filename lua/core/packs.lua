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

-- justify: Built-in text alignment commands.
require("plugins.justify")

-- matchit: Extended % matching for HTML, if/else, etc.
require("plugins.matchit")

-- nohlsearch: Automatically clear search highlights.
require("plugins.nohlsearch")

return M
