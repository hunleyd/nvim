-- =============================================================================
-- Plugin: shada.lua
-- =============================================================================

-- shada.lua manages SHAred DAta (history, marks, registers) across sessions.
-- This configuration tunes how much data is preserved.

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- ! : Save global variables (all uppercase, no lowercase).
-- ' : Remember marks for the last 100 edited files.
-- < : Save up to 50 lines for each register.
-- s : Limit item size to 10 KiB.
-- h : Disable 'hlsearch' when loading the shada file.
vim.opt.shada = "!,'100,<50,s10,h"
