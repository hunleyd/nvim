-- =============================================================================
-- Module: vim._comment
-- =============================================================================

-- vim._comment is a built-in Lua module in Neovim v0.12 providing native
-- support for commenting and uncommenting code. It replaces the need for 
-- external plugins like Comment.nvim.

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- Enable and configure the built-in commenting.
require("vim._comment").setup({
  -- Add a space between the comment character and the line content.
  add_space = true,
  -- Do not comment empty lines.
  ignore_empty_lines = true,
})

-- -----------------------------------------------------------------------------
-- Default Mappings (provided by the module):
-- -----------------------------------------------------------------------------
-- gcc      : Toggle comment on the current line (Normal mode).
-- gc{motion} : Toggle comment based on a motion (Normal mode).
-- gc       : Toggle comment on the visual selection (Visual mode).
-- gb{motion} : Toggle block comment based on a motion (Normal mode).
-- gb       : Toggle block comment on the visual selection (Visual mode).
