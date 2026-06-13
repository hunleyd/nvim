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

-- -----------------------------------------------------------------------------
-- Configuration: mini.splitjoin
-- -----------------------------------------------------------------------------

-- mini.splitjoin toggles between single-line and multi-line representations
-- of code structures (like function arguments, lists, or tables).
require("mini.splitjoin").setup({
  mappings = {
    -- Toggle between split and join (Normal and Visual modes).
    toggle = "gS",
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.surround
-- -----------------------------------------------------------------------------

-- mini.surround provides a unified way to add, delete, and replace 
-- surroundings (brackets, quotes, tags, etc.). It uses a consistent 's' prefix.
require("mini.surround").setup({
  mappings = {
    add = "sa",            -- Add surrounding
    delete = "sd",         -- Delete surrounding
    find = "sf",           -- Find surrounding (to the right)
    find_left = "sF",      -- Find surrounding (to the left)
    highlight = "sh",      -- Highlight surrounding
    replace = "sr",        -- Replace surrounding
    update_n_lines = "sn", -- Update search range
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.basics
-- -----------------------------------------------------------------------------

-- mini.basics provides sane editor defaults (options, mappings, autocommands).
require("mini.basics").setup({
  -- Options management.
  options = {
    -- Enable basic sane options (number, ignorecase, etc.).
    basic = true,
    -- Enable extra UI enhancements (cursorline, global statusline, etc.).
    extra_ui = true,
  },
  -- Mappings management.
  mappings = {
    -- Enable basic sane mappings (Ctrl+S to save, etc.).
    basic = true,
    -- Enable option toggles (prefix: '\').
    option_toggles = true,
    -- Window navigation/resize mappings.
    windows = true,
    -- DISALBED: Moving cursor in Insert mode is not standard Vim.
    move = false,
  },
  -- Autocommands management.
  autocommands = {
    -- Enable basic autocommands (Highlight on Yank, etc.).
    basic = true,
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.bracketed
-- -----------------------------------------------------------------------------

-- mini.bracketed provides unified bracket mappings ( [ and ] ) for navigating
-- common targets like buffers, diagnostics, treesitter nodes, etc.
require("mini.bracketed").setup({
  -- All targets are enabled by default with standard suffixes:
  -- b: Buffer, c: Comment, d: Diagnostic, f: File, i: Indent,
  -- j: Jump, l: Location, o: Oldfile, q: Quickfix, t: Treesitter,
  -- u: Undo, w: Window, x: Conflict, y: Yank
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.clue
-- -----------------------------------------------------------------------------

-- mini.clue shows a floating window with available keybinding hints
-- when a trigger key (like <Leader> or 'g') is pressed.
local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    -- Leader triggers.
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },

    -- Built-in completion.
    { mode = "i", keys = "<C-x>" },

    -- 'g' key.
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },

    -- Marks.
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },

    -- Registers.
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },

    -- Window commands.
    { mode = "n", keys = "<C-w>" },

    -- 'z' key.
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },

    -- Bracketed navigation.
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = "x", keys = "[" },
    { mode = "x", keys = "]" },
  },

  clues = {
    -- Enhance built-in descriptions.
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },

  -- Window configuration to match UI2 and meowsoot.
  window = {
    -- Delay (in ms) before showing the clue window.
    delay = 500,
    config = {
      border = "rounded",
      -- Solid background.
      winblend = 0,
    },
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.cmdline
-- -----------------------------------------------------------------------------

-- mini.cmdline provides intelligent assistance as you type in the command-line.
-- It features autocomplete, autocorrection, and range previews (autopeek).
require("mini.cmdline").setup({
  -- Behavior sections
  completion = { delay = 100 },
  correction = { delay = 100 },
  peek = { delay = 100 },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.diff
-- -----------------------------------------------------------------------------

-- mini.diff provides live gutter signs and in-buffer diff overlays.
-- It tracks changes against the Git index by default.
require("mini.diff").setup({
  -- Use signs in the gutter (signcolumn).
  view = {
    style = "sign",
    -- Use a clean solid bar for all change types.
    signs = { add = "┃", change = "┃", delete = "┃" },
  },
})

-- Mapping to toggle the detailed in-buffer diff overlay.
vim.keymap.set("n", "<leader>go", function()
  require("mini.diff").toggle_overlay(0)
end, { desc = "Toggle Diff Overlay" })

-- Build keyboard habits: Disable mouse support entirely.
vim.opt.mouse = ""

-- Clean UI: Disable showing invisible characters (tabs, trailing spaces).
vim.opt.list = false
