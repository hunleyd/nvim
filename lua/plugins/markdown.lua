-- =============================================================================
-- Plugin: MeanderingProgrammer/render-markdown.nvim
-- =============================================================================

--- Real-time Markdown rendering with high-fidelity aesthetics
---
--- Leverages Treesitter to render Markdown headers, code blocks, lists,
--- tables, checkboxes, and callouts directly inside the Neovim buffer.
--- Fully customized to match the meowsoot colorscheme.
--- @tag plugins.markdown

-- Add render-markdown.nvim to managed packages
vim.pack.add({
  {
    name = "render-markdown.nvim",
    src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  },
})

-- -----------------------------------------------------------------------------
-- Color Palette Integration
-- -----------------------------------------------------------------------------

-- Extract our meowsoot palette variables to ensure unified visual consistency.
local c = {
  fg = "#e2e0df",
  bg = "#171616",
  bg_1 = "#282625",
  fg_faint = "#b1ada9",
  fg_mute = "#454240",
  green = "#98cdaa",   -- GitAdd
  blue = "#96bddf",    -- Info / GitChange
  peach = "#dfd286",   -- Warning
  magenta = "#96d8e3", -- Hint
  red = "#e99696",     -- Error / GitDelete
  pink = "#eaa4c9",    -- Selection / Highlight
}

-- Set up custom highlights to match meowsoot palette for rendering Markdown.
vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = c.blue, bold = true })
vim.api.nvim_set_hl(0, "RenderMarkdownH2", { fg = c.magenta, bold = true })
vim.api.nvim_set_hl(0, "RenderMarkdownH3", { fg = c.green, bold = true })
vim.api.nvim_set_hl(0, "RenderMarkdownH4", { fg = c.peach, bold = true })
vim.api.nvim_set_hl(0, "RenderMarkdownH5", { fg = c.pink, bold = true })
vim.api.nvim_set_hl(0, "RenderMarkdownH6", { fg = c.fg_faint, bold = true })

-- Customize block headers background to integrate cleanly with meowsoot.
-- We keep background transparent to prevent harsh visual rectangles, relying
-- on clean bold foreground coloring.
for i = 1, 6 do
  vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i .. "Bg", { link = "Normal" })
end

vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { fg = c.blue })
vim.api.nvim_set_hl(0, "RenderMarkdownQuote", { fg = c.fg_mute })

-- Checkbox elements
vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", { fg = c.fg_faint })
vim.api.nvim_set_hl(0, "RenderMarkdownChecked", { fg = c.green })
vim.api.nvim_set_hl(0, "RenderMarkdownTodo", { fg = c.peach })

-- Callout alerts (Obsidian / GitHub style alerts)
vim.api.nvim_set_hl(0, "RenderMarkdownInfo", { fg = c.blue })
vim.api.nvim_set_hl(0, "RenderMarkdownSuccess", { fg = c.green })
vim.api.nvim_set_hl(0, "RenderMarkdownHint", { fg = c.magenta })
vim.api.nvim_set_hl(0, "RenderMarkdownWarn", { fg = c.peach })
vim.api.nvim_set_hl(0, "RenderMarkdownError", { fg = c.red })

-- Code Blocks
vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = c.bg_1 })
vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = c.bg_1, fg = c.pink })

-- Table Border highlights
vim.api.nvim_set_hl(0, "RenderMarkdownTable", { fg = c.fg_mute })
vim.api.nvim_set_hl(0, "RenderMarkdownTableHead", { fg = c.blue, bold = true })
vim.api.nvim_set_hl(0, "RenderMarkdownTableRow", { fg = c.fg })

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

require("render-markdown").setup({
  -- Enable rendering on markdown files
  file_types = { "markdown" },
  
  -- Enable rendering in normal, command, and terminal modes,
  -- but toggle off in Insert mode for flawless, non-disruptive editing.
  render_modes = { "n", "c", "t" },

  -- Configure heading visual style (minimalist, clean and robust)
  heading = {
    enabled = true,
    sign = true,
    icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    position = "overlay",
    width = "full",
  },

  -- Code block options
  code = {
    enabled = true,
    sign = true,
    style = "full",
    position = "left",
    language_pad = 1,
    language_name = true,
    language_icon = true,
    highlight = "RenderMarkdownCode",
    highlight_inline = "RenderMarkdownCodeInline",
  },

  -- Bullet list formatting
  bullet = {
    enabled = true,
    icons = { "●", "○", "◆", "◇" },
    highlight = "RenderMarkdownBullet",
  },

  -- Checkbox / To-Do item rendering
  checkbox = {
    enabled = true,
    unchecked = {
      icon = "󰄱 ",
      highlight = "RenderMarkdownUnchecked",
    },
    checked = {
      icon = "󰱒 ",
      highlight = "RenderMarkdownChecked",
    },
    custom = {
      todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
    },
  },

  -- Quotes
  quote = {
    enabled = true,
    icon = "▋",
    highlight = "RenderMarkdownQuote",
  },

  -- Clean tables rendering
  pipe_table = {
    enabled = true,
    preset = "none",
    style = "full",
    cell = "padded",
    padding = 1,
    border = {
      "┌", "┬", "┐",
      "├", "┼", "┤",
      "└", "┴", "┘",
      "│", "─", " ",
    },
    highlight = "RenderMarkdownTable",
    head = "RenderMarkdownTableHead",
    row = "RenderMarkdownTableRow",
  },

  -- Modern Alert / Callout banners
  callout = {
    note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
    tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
    important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
    warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
    caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
  },

  -- LaTeX equations conversion (disable to avoid shell warnings if CLI tools are missing)
  latex = {
    enabled = false,
  },
})
