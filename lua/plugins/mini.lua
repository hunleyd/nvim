-- =============================================================================
-- Collection: mini.nvim
-- =============================================================================

-- mini.nvim is a collection of high-quality, minimal Lua modules.

-- Load the mini.nvim collection using the built-in package manager.
vim.pack.add({
  {
    name = "mini.nvim",
    src = "https://github.com/echasnovski/mini.nvim",
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.ai (Extended Text Objects)
-- -----------------------------------------------------------------------------

require("mini.ai").setup({
  n_lines = 500,
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.align (Interactive Alignment)
-- -----------------------------------------------------------------------------

require("mini.align").setup({
  mappings = {
    start = "ga",
    start_with_preview = "gA",
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.comment (Native Commenting Alternative)
-- -----------------------------------------------------------------------------

require("mini.comment").setup({
  mappings = {
    comment_line = "gcc",
    comment_visual = "gc",
    textobject = "gc",
  },
  options = {
    pad_comment_parts = true,
    ignore_blank_line = true,
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.completion (Async Autocompletion)
-- -----------------------------------------------------------------------------

require("mini.completion").setup({
  delay = {
    completion = 100,
    info = 100,
    signature = 50,
  },
  fallback_action = "<C-n>",
  lsp_completion = {
    source_func = "completefunc",
    auto_setup = true,
  },
  window = {
    info = { border = "rounded", winblend = 0 },
    signature = { border = "rounded", winblend = 0 },
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.keymap (Mapping Orchestrator)
-- -----------------------------------------------------------------------------

require("mini.keymap").setup({})

-- -----------------------------------------------------------------------------
-- Configuration: mini.snippets (Snippet Management)
-- -----------------------------------------------------------------------------

local gen_loader = require("mini.snippets").gen_loader
require("mini.snippets").setup({
  snippets = {
    -- Correct pattern strings for loaders
    gen_loader.from_lang({}),
    gen_loader.from_runtime(".*%.json$"),
    gen_loader.from_runtime(".*%.code-snippets$"),
    gen_loader.from_runtime(".*%.lua$"),
  },
  -- Visual feedback during interactive sessions (default: true).
  -- Shows virtual text for unvisited tabstops and highlights the current one.
  mappings = {
    -- We disable these as we use the smart <Tab> system in mini.keymap.
    expand = "",
    jump_next = "",
    jump_prev = "",
    -- Keep <C-c> as a way to manually stop a snippet session.
    stop = "<C-c>",
  },
  -- Functions describing snippet expansion.
  expand = {
    -- Use fuzzy matching for snippet prefixes.
    match = function(snippets)
      return require("mini.snippets").default_match(snippets, {
        -- Perform fuzzy match based on alphanumeric characters.
        pattern_fuzzy = "%w*",
      })
    end,
  },
})

-- Enable the LSP server for snippet integration
-- (In v0.12/mini.snippets, this is done via start_lsp_server)
require("mini.snippets").start_lsp_server()

-- -----------------------------------------------------------------------------
-- Keybindings: mini.completion / mini.snippets (via mini.keymap)
-- -----------------------------------------------------------------------------

local mk = require("mini.keymap")

-- Smart <Tab>: Navigate menu, jump snippets, expand snippets, indent, or trigger completion.
mk.map_multistep("i", "<Tab>", {
  "pmenu_next",
  "minisnippets_next",
  "minisnippets_expand",
  "increase_indent",
  {
    condition = function()
      return true
    end,
    action = function()
      return require("mini.completion").completefunc_twostep()
    end,
  },
})

-- Smart <S-Tab>: Navigate menu backwards, jump snippets backwards, or dedent.
mk.map_multistep("i", "<S-Tab>", {
  "pmenu_prev",
  "minisnippets_prev",
  "decrease_indent",
  {
    condition = function()
      return true
    end,
    action = function()
      return vim.api.nvim_replace_termcodes("<S-Tab>", true, true, true)
    end,
  },
})

-- -----------------------------------------------------------------------------
-- Keybindings: Escape Combos (via mini.keymap)
-- -----------------------------------------------------------------------------

mk.map_combo("i", "jk", "<BS><BS><Esc>")
mk.map_combo("i", "kj", "<BS><BS><Esc>")

-- -----------------------------------------------------------------------------
-- Configuration: mini.pairs (Autopairing)
-- -----------------------------------------------------------------------------

require("mini.pairs").setup({
  mappings = {
    ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
    ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
    ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]." },
    [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
    ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
    ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },
    ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
    ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%w\\].", register = { cr = false } },
    ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },
    [" "] = { action = "open", pair = "  ", neigh_pattern = "[%(%[{][%)%]}]" },
    ["%"] = { action = "open", pair = "%%", neigh_pattern = "[{][}]" },
    ["<"] = { action = "open", pair = "<>", neigh_pattern = "[{][}]" },
    [">"] = { action = "close", pair = "<>", neigh_pattern = "[{][}]" },
  },
  modes = {
    command = true,
  },
})
