-- =============================================================================
-- Neovim Configuration (Lua-based)
-- Target: Neovim v0.12+ (UI2 support)
-- =============================================================================

-- This is the entry point for Neovim configuration.
-- In Neovim v0.12, we can leverage the new UI2 architecture for enhanced
-- rendering and interaction.

-- -----------------------------------------------------------------------------
-- Initial Setup
-- -----------------------------------------------------------------------------

-- Placeholder for future configuration modules.
-- We will follow a modular approach by placing logic in the 'lua/' directory.
_G.Utils = require("core.utils")
require("core.packs")
require("core.completion")

Utils.notify("Neovim configuration initialized.", " System ")
