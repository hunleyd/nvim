-- =============================================================================
-- Plugin: stevearc/conform.nvim
-- =============================================================================

--- Lightweight and powerful code formatting orchestrator
---
--- Integrates external formatters (e.g. stylua, prettier) with Neovim's built-in
--- LSP, implementing minimal-diff text updates and dynamic format-on-save toggles.
--- @tag plugins.conform

local ok, conform = pcall(require, "conform")
if not ok then
  vim.notify("Could not load conform.nvim: " .. tostring(conform), vim.log.levels.ERROR)
  return
end

conform.setup({
  -- Map filetypes to formatters
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    -- Use "_" as a fallback for filetypes that don't have other formatters configured.
    ["_"] = { "trim_whitespace", "trim_last_lines" },
  },

  -- Dynamic Format-on-Save behavior
  format_on_save = function(bufnr)
    -- Respect global or buffer-local variables to disable autoformatting
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    -- Fallback to LSP formatting if a dedicated formatter is unavailable
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end,
})

-- -----------------------------------------------------------------------------
-- Commands
-- -----------------------------------------------------------------------------

--- Disable autoformatting on save
---
--- Run `:FormatDisable` to disable autoformatting on save for the current buffer.
--- Run `:FormatDisable!` (with a bang) to disable it globally for all buffers.
--- @tag :FormatDisable
vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    vim.g.disable_autoformat = true
    vim.notify("Autoformat-on-save disabled globally", vim.log.levels.INFO, { title = " Format " })
  else
    vim.b.disable_autoformat = true
    vim.notify("Autoformat-on-save disabled for current buffer", vim.log.levels.INFO, { title = " Format " })
  end
end, {
  desc = "Disable autoformat-on-save (use ! for global)",
  bang = true,
})

--- Enable autoformatting on save
---
--- Run `:FormatEnable` to re-enable autoformatting on save both globally and for
--- the current buffer.
--- @tag :FormatEnable
vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
  vim.notify("Autoformat-on-save enabled", vim.log.levels.INFO, { title = " Format " })
end, {
  desc = "Re-enable autoformat-on-save",
})
