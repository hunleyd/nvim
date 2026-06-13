-- =============================================================================
-- Plugin: matchparen.vim
-- =============================================================================

-- matchparen is a standard plugin that highlights the matching pair 
-- (parenthesis, bracket, or brace) under the cursor.

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- Set timeouts (in milliseconds) for the matching logic to ensure 
-- Neovim remains responsive, especially in large files.
vim.g.matchparen_timeout = 20
vim.g.matchparen_insert_timeout = 20
