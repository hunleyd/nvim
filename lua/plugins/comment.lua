-- =============================================================================
-- Module: vim._comment
-- =============================================================================

-- vim._comment is a built-in Lua module in Neovim v0.12 providing native
-- support for commenting and uncommenting code. It replaces the need for 
-- external plugins like Comment.nvim.

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- In Neovim v0.12, the built-in commenting is enabled by default and 
-- does not currently expose a .setup() function for configuration.
-- It follows standard 'gc' and 'gcc' mappings.

-- -----------------------------------------------------------------------------
-- Default Mappings (provided by the core):
-- -----------------------------------------------------------------------------
-- gcc      : Toggle comment on the current line (Normal mode).
-- gc{motion} : Toggle comment based on a motion (Normal mode).
-- gc       : Toggle comment on the visual selection (Visual mode).
-- gb{motion} : Toggle block comment based on a motion (Normal mode).
-- gb       : Toggle block comment on the visual selection (Visual mode).
