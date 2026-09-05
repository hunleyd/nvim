--- Neovim Package Management
---
--- This module manages external plugins using the built-in `vim.pack` API.
--- Each plugin's specification is defined here, and its configuration is
--- modularized into separate files within the `lua/plugins/` directory.
--- @tag core.packs

local M = {}

-- Define the plugins to be managed by vim.pack.
-- This MUST be done before requiring the configuration modules so that
-- the plugins are downloaded and added to the runtimepath.
vim.pack.add({
  {
    name = "friendly-snippets",
    src = "https://github.com/rafamadriz/friendly-snippets",
  },
  {
    name = "mini.nvim",
    src = "https://github.com/echasnovski/mini.nvim",
  },
  {
    name = "conform.nvim",
    src = "https://github.com/stevearc/conform.nvim",
  },
})

-- justify: Built-in text alignment commands.
require("plugins.justify")

-- matchit: Extended % matching for HTML, if/else, etc.
require("plugins.matchit")

-- nohlsearch: Automatically clear search highlights.
require("plugins.nohlsearch")

-- hlsearch_lens: Native virtual text search match indexing and count lens.
-- Complements nohlsearch by displaying [current/total] match indicators at the
-- end of the cursor line using native searchcount and extmarks, clearing
-- automatically on cursor movements, mode switches, or manual :nohlsearch calls.
require("plugins.hlsearch_lens")

-- nvim.difftool: Modern directory and file comparison.
require("plugins.difftool")

-- fzf.vim: Fuzzy finder integration.
require("plugins.fzf")

-- man.lua: Enhanced man page viewer.
require("plugins.man")

-- matchparen: Highlight matching brackets.
require("plugins.matchparen")

-- osc52: Native OSC 52 clipboard support.
require("plugins.osc52")

-- shada: Shared data (history, marks, registers) persistence.
require("plugins.shada")

-- spellfile: Automatic management of spell-check dictionaries.
require("plugins.spellfile")

-- ui2: Experimental modernized UI architecture.
require("plugins.ui2")

-- meowsoot: Main colorscheme.
require("plugins.meowsoot")

-- treesitter: High-fidelity syntax highlighting.
require("plugins.treesitter")

-- markdown: Real-time Markdown rendering.
require("plugins.markdown")

-- ansible: Ansible configuration assistance.
require("plugins.ansible")

-- yaml-revealer: Help navigate deeply nested YAML files.
require("plugins.yaml-revealer")

-- yankbank: Clipboard history manager.
require("plugins.yankbank")

-- cmdline: Centered floating command-line interface.
require("plugins.cmdline")

-- lsp: Language Server Protocol configuration.
require("plugins.lsp")

-- tabline: Custom GUI-style physical tabs.
require("plugins.tabline")

-- statuscolumn: High-fidelity status column layout (mini.statuscolumn).
require("plugins.statuscolumn")

-- hardtime: Enforce efficient Neovim usage and break bad habits.
require("plugins.hardtime")

-- conform: Fast, async, diff-based formatting.
require("plugins.conform")

-- mini.nvim: Collection of minimal, high-quality Lua modules.
require("plugins.mini")

-- -----------------------------------------------------------------------------
-- Commands: Plugin Management
-- -----------------------------------------------------------------------------

--- Update managed plugins
---
--- Leverages the built-in `vim.pack.update()` API. It runs non-interactively
--- (using `force = true`) and provides feedback through a single,
--- auto-updating notification popup.
--- @tag :PackUpdate
vim.api.nvim_create_user_command("PackUpdate", function()
  vim.notify("Checking for plugin updates...", vim.log.levels.INFO, { title = " Pack " })

  -- Record the update check timestamp to stdpath("state")/plugin_update_time.
  -- This ensures the starter dashboard "last update" indicator updates even if
  -- all plugins are already up-to-date (no actual PackChanged events fired).
  local state_path = vim.fn.stdpath("state") .. "/plugin_update_time"
  vim.fn.writefile(tostring(os.time()), state_path)

  -- Refresh mini.starter on the fly if we are currently on the dashboard to update the timestamp instantly
  local ok_starter, starter = pcall(require, "mini.starter")
  if ok_starter and vim.bo.filetype == "ministarter" then
    pcall(starter.refresh)
  end

  vim.pack.update(nil, { force = true })
end, { desc = "Update managed plugins" })

--- Update Treesitter parsers
---
--- Executes `:TSUpdate` to update all installed Tree-sitter parsers.
--- @tag :PackTSUpdate
vim.api.nvim_create_user_command("PackTSUpdate", function()
  local state_path = vim.fn.stdpath("state") .. "/ts_update_time"
  vim.fn.writefile(tostring(os.time()), state_path)

  -- Refresh mini.starter on the fly if currently on the dashboard
  local ok_starter, starter = pcall(require, "mini.starter")
  if ok_starter and vim.bo.filetype == "ministarter" then
    pcall(starter.refresh)
  end

  vim.cmd("TSUpdate")
end, { desc = "Update Treesitter parsers" })

-- -----------------------------------------------------------------------------
-- Automations: Plugin Notifications
-- -----------------------------------------------------------------------------

-- Route plugin lifecycle events (install, update, delete) through the 
-- notification system to provide visual feedback without disruptive buffers.
-- We use a single persistent notification ID to provide a "live" progress pipe.
local pack_group = vim.api.nvim_create_augroup("PackNotifications", { clear = true })
local pack_notif_id = nil

vim.api.nvim_create_autocmd("User", {
  group = pack_group,
  pattern = "PackChangedPre",
  callback = function(data)
    local msg = string.format("%s: %s...", data.data.kind:gsub("^%l", string.upper), data.data.spec.name)
    pack_notif_id = vim.notify(msg, vim.log.levels.INFO, { title = " Pack ", id = pack_notif_id })
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = pack_group,
  pattern = "PackChanged",
  callback = function(data)
    local msg = string.format("%s: %s [Done]", data.data.kind:gsub("^%l", string.upper), data.data.spec.name)
    pack_notif_id = vim.notify(msg, vim.log.levels.INFO, { title = " Pack ", id = pack_notif_id })
  end,
})

return M
