-- =============================================================================
-- Module: vim._core.ui2 (Experimental UI)
-- =============================================================================

-- UI2 is a major redesign of the core messages and command-line UI in 
-- Neovim v0.12. It aims to modernize the interaction model by replacing 
-- the legacy message grid.

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- Enable the UI2 architecture.
-- Benefits:
--   - Reduces disruptive "Press ENTER" prompts.
--   - Provides live highlighting in the command-line.
--   - Uses a buffer-based pager for long message outputs.
require("vim._core.ui2").enable()
