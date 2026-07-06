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
-- Global Assets & Shared Configuration
-- -----------------------------------------------------------------------------

local state_path = vim.fn.stdpath("state") .. "/plugin_update_time"

-- Color Palette (Extracted from Meowsoot for UI Consistency)
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

-- -----------------------------------------------------------------------------
-- Configuration: mini.extra (Supplementary Features)
-- -----------------------------------------------------------------------------

-- mini.extra provides non-essential but very useful features that complement
-- other mini modules, such as extra textobjects and pickers.
require("mini.extra").setup({})

-- -----------------------------------------------------------------------------
-- Configuration: mini.icons (Icon Support)
-- -----------------------------------------------------------------------------

-- mini.icons provides lightweight icon support across various categories.
-- It acts as a performant replacement for nvim-web-devicons.
require("mini.icons").setup({
  -- Style of icons: 'glyph' (requires Nerd Fonts) or 'ascii'.
  style = "glyph",
})

-- Mock nvim-web-devicons for compatibility with other plugins.
require("mini.icons").mock_nvim_web_devicons()

-- Automation: Update plugin update timestamp
-- When vim.pack successfully updates a plugin, record the current time.
-- This timestamp is used by mini.starter to show how long ago plugins were updated.
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("PackUpdateTimestamp", { clear = true }),
  pattern = "PackChanged",
  callback = function(data)
    if data.data.kind == "update" then
      local f = io.open(state_path, "w")
      if f then
        f:write(tostring(os.time()))
        f:close()
      end
    end
  end,
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.notify (Consolidated Notifications)
-- -----------------------------------------------------------------------------

-- mini.notify manages floating notifications in a single consolidated window.
require("mini.notify").setup({
  -- Content management.
  content = {
    -- Use custom icons from mini.icons.
    format = function(notif)
      return notif.msg
    end,
  },
  -- Window configuration.
  window = {
    -- Solid background.
    winblend = 0,
    config = function(buf_id)
      -- Calculate max line length in the active notification buffer
      local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
      local max_len = 0
      for _, line in ipairs(lines) do
        max_len = math.max(max_len, #line)
      end
      -- Sane minimum width of 16 to fit the "Notifications" title cleanly
      local width = math.max(16, max_len)
      
      -- Place notifications in the bottom-right corner, safely above statusline
      local has_statusline = vim.o.laststatus > 0
      local pad = vim.o.cmdheight + (has_statusline and 1 or 0)
      return {
        anchor = "SE",
        col = vim.o.columns,
        row = vim.o.lines - pad,
        width = width,
        border = "rounded",
        title = " Notifications ",
        title_pos = "center",
      }
    end,
  },
  -- Automatically show LSP progress.
  lsp_progress = { enable = true },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.starter (Welcome Screen)
-- -----------------------------------------------------------------------------

-- mini.starter provides a clean, fast dashboard for Neovim.
local starter = require("mini.starter")

local version = "NEOVIM " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
local user = os.getenv("USER") or os.getenv("LOGNAME") or "user"
local welcome = "  Welcome to " .. version .. ", " .. user

local function get_last_update_text()
  local last_update = 0
  local f = io.open(state_path, "r")
  if f then
    last_update = tonumber(f:read("*all")) or 0
    f:close()
  end
  if last_update == 0 then
    return " (Never)"
  end
  local diff = os.time() - last_update
  if diff < 60 then
    return " (Just now)"
  end
  if diff < 3600 then
    return string.format(" (%d mins ago)", math.floor(diff / 60))
  end
  if diff < 86400 then
    return string.format(" (%d hrs ago)", math.floor(diff / 3600))
  end
  return string.format(" (%d days ago)", math.floor(diff / 86400))
end

starter.setup({
  evaluate_single = true,
  items = {
    function()
      local items = starter.sections.recent_files(9, false)()
      for _, item in ipairs(items) do
        item.section = "Recent files:"
        -- Extract path from 'filename (path)' format
        local path = item.name:match("%((.*)%)")
        if path then
          item.name = vim.fn.fnamemodify(path, ":~:.")
        end
      end
      return items
    end,
    { name = "Edit new buffer", action = "enew", section = "Actions:" },
    function()
      return { name = "Update Plugins" .. get_last_update_text(), action = "PackUpdate", section = "Actions:" }
    end,
    function()
      return { name = "Update Treesitter", action = "PackTSUpdate", section = "Actions:" }
    end,
    { name = "Quit Neovim", action = "qall", section = "Actions:" },
  },
  header = table.concat({
    "│ ╲ ││",
    "││╲╲││" .. welcome,
    "││ ╲ │",
  }, "\n"),
  footer = "",
  content_hooks = {
    -- Insert a blank line before 'Quit Neovim'
    function(content)
      for i, line in ipairs(content) do
        for _, unit in ipairs(line) do
          if unit.string == "Quit Neovim" then
            table.insert(content, i, { { string = "", type = "empty" } })
            return content
          end
        end
      end
      return content
    end,
    starter.gen_hook.indexing("all", { "Actions:" }),
    -- Apply consistent highlighting and format triggers as 'index - '
    function(content)
      local coords = starter.content_coords(content, "item")

      for i = #coords, 1, -1 do
        local coord = coords[i]
        local line = content[coord.line]
        local unit = line[coord.unit]
        local item = unit.item
        local index_str, rest

        if item.section == "Actions:" then
          local shortcut = "?"
          if item.name:match("^Edit new buffer") then
            shortcut = "e"
          elseif item.name:match("^Update Plugins") then
            shortcut = "p"
          elseif item.name:match("^Update Treesitter") then
            shortcut = "t"
          elseif item.name:match("^Quit Neovim") then
            shortcut = "q"
          end
          index_str = shortcut:upper() .. " - "
          rest = item.name
        else
          local index, filename = unit.string:match("^(%d+)%. (.*)$")
          if index then
            index_str = string.format("%d - ", tonumber(index))
            rest = filename
          end
        end

        if index_str then
          -- Keep as a single unit to ensure the entire line is treated as one 'item'.
          -- This ensures the blue selection bar (MiniStarterCurrent) covers the whole text.
          unit.string = index_str .. rest
        end
      end
      return content
    end,
    -- Draw boxes around sections
    function(content)
      local get_line_width = function(line)
        local w = 0
        for _, u in ipairs(line) do
          w = w + vim.fn.strdisplaywidth(u.string)
        end
        return w
      end

      -- First pass: find global max width and group lines into sections
      local max_w_all = 0
      local sections = {}
      local i = 1
      while i <= #content do
        local line = content[i]
        local section_name = nil
        for _, u in ipairs(line) do
          if u.type == "section" then
            section_name = u.string
            break
          end
        end

        if section_name then
          local sec = { name = section_name, lines = { line } }
          i = i + 1
          while i <= #content do
            local next_line = content[i]
            local next_has_section = false
            for _, u in ipairs(next_line) do
              if u.type == "section" then
                next_has_section = true
                break
              end
            end
            if next_has_section or (#next_line == 0 and i < #content) then
              break
            end
            table.insert(sec.lines, next_line)
            i = i + 1
          end
          for _, l in ipairs(sec.lines) do
            max_w_all = math.max(max_w_all, get_line_width(l))
          end
          table.insert(sections, sec)
        else
          table.insert(sections, line)
          i = i + 1
        end
      end

      -- Second pass: render with uniform box widths
      local res = {}
      local border_hl = "MiniStarterItemBullet"
      for _, entry in ipairs(sections) do
        if entry.name then
          local sec_name = entry.name
          local sec_lines = entry.lines
          local header_w = vim.fn.strdisplaywidth(sec_name)

          -- Ensure the item box is at least as wide as the header tab
          local box_content_w = math.max(max_w_all, header_w - 1)
          -- Total width of the item box (including │ and internal padding)
          local total_w = box_content_w + 4

          -- 1. Top of the tab
          table.insert(res, { { string = "┌" .. string.rep("─", header_w) .. "┐", type = "empty", hl = border_hl } })

          -- 2. Header line with junction to the main box
          local junction_dashes = total_w - (header_w + 2) - 1
          table.insert(
            res,
            {
              {
                string = "│" .. sec_name .. "└" .. string.rep("─", math.max(0, junction_dashes)) .. "┐",
                type = "empty",
                hl = border_hl,
              },
            }
          )

          -- 3. Spacer line inside the box
          table.insert(res, {
            { string = "│ " .. string.rep(" ", box_content_w) .. " │", type = "empty", hl = border_hl },
          })

          -- 4. Render the items
          for j = 2, #sec_lines do
            local l = sec_lines[j]
            local w = get_line_width(l)
            local padding = string.rep(" ", box_content_w - w)
            local new_l = { { string = "│ ", type = "empty", hl = border_hl } }
            vim.list_extend(new_l, l)
            table.insert(new_l, { string = padding .. " │", type = "empty", hl = border_hl })
            table.insert(res, new_l)
          end

          -- 5. Bottom of the box
          table.insert(res, { { string = "└" .. string.rep("─", total_w - 2) .. "┘", type = "empty", hl = border_hl } })
        else
          table.insert(res, entry)
        end
      end
      return res
    end,
    starter.gen_hook.padding(3, 2),
    starter.gen_hook.aligning("center", "center"),
  },
})

-- Startup Screen Highlights: Match Meowsoot palette
vim.api.nvim_set_hl(0, "MiniStarterHeader", { fg = c.blue }) -- Blue header
vim.api.nvim_set_hl(0, "MiniStarterItemIndex", { fg = c.peach }) -- Peach index
vim.api.nvim_set_hl(0, "MiniStarterItemBullet", { fg = c.blue }) -- Blue bullet
-- Full line highlight on selection
vim.api.nvim_set_hl(0, "MiniStarterCurrent", { bg = c.blue, fg = c.bg, bold = true })

-- Enable cursorline and custom trigger highlights in starter buffer
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("StarterCursorLine", { clear = true }),
  pattern = "ministarter",
  callback = function()
    vim.wo.cursorline = true
    vim.wo.winhighlight = "CursorLine:MiniStarterCurrent"
    -- Manually highlight the trigger (number or letter) as orange
    vim.fn.matchadd("MiniStarterItemIndex", "[0-9A-Z] - ")
  end,
})

-- Robustly hide statusline on the dashboard and restore it globally elsewhere.
-- 1. On BufEnter, we check the active filetype. Since mini.starter uses noautocmd during initial setup,
--    BufEnter will handle any subsequent switches back to the starter screen.
local starter_status_group = vim.api.nvim_create_augroup("StarterStatusline", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = starter_status_group,
  callback = function()
    if vim.bo.filetype == "ministarter" then
      vim.opt.laststatus = 0
    else
      vim.opt.laststatus = 3 -- Standard global statusline for Neovim v0.12+
    end
  end,
})

-- 2. On initial open, mini.starter sets the filetype using 'noautocmd', bypassing the FileType/BufEnter
--    checks. We hook into the 'MiniStarterOpened' User event to hide the statusline at startup/initial open.
vim.api.nvim_create_autocmd("User", {
  group = starter_status_group,
  pattern = "MiniStarterOpened",
  callback = function()
    vim.opt.laststatus = 0
  end,
})

-- Mapping: <leader>s to reopen the starter dashboard.
vim.keymap.set("n", "<leader>s", function()
  starter.open()
end, { desc = "Open Starter Dashboard" })

-- -----------------------------------------------------------------------------
-- Configuration: mini.git (Git Integration)
-- -----------------------------------------------------------------------------

-- mini.git provides high-level git management (staging, committing)
-- and automated repository tracking.
require("mini.git").setup({})

-- Mapping: <leader>gs to show git information for the item under the cursor.
vim.keymap.set("n", "<leader>gs", function()
  require("mini.git").show_at_cursor()
end, { desc = "Show Git at Cursor" })

-- Mapping: <leader>gc to initiate a git commit.
vim.keymap.set("n", "<leader>gc", ":Git commit<CR>", { desc = "Git Commit" })

-- Mapping: <leader>gb to blame the current file.
vim.keymap.set("n", "<leader>gb", ":Git blame -- %<CR>", { desc = "Git Blame" })

-- -----------------------------------------------------------------------------
-- Configuration: mini.files (File Explorer)
-- -----------------------------------------------------------------------------

-- mini.files is a buffer-based file explorer that treats the filesystem
-- like text. It uses Miller Columns for navigation.
require("mini.files").setup({
  windows = {
    -- Maximum number of side-by-side windows to show.
    max_number = math.huge,
    -- Enable file preview window to the right.
    preview = true,
    -- Column widths.
    width_focus = 30,
    width_nofocus = 15,
    width_preview = 30,
  },
  options = {
    -- Use mini.files as the default explorer (replaces netrw).
    use_as_default_explorer = true,
  },
})

-- Mapping: <leader>e to open file explorer at the current buffer's directory.
vim.keymap.set("n", "<leader>e", function()
  -- If the buffer has no name (e.g., new file), open at CWD.
  local buf_name = vim.api.nvim_buf_get_name(0)
  local path = (buf_name ~= "" and buf_name) or vim.fn.getcwd()
  require("mini.files").open(path, true)
end, { desc = "Open File Explorer" })

-- LSP Integration: Update imports when renaming/moving files in mini.files
vim.api.nvim_create_autocmd("User", {
  pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
  callback = function(args)
    local changes = {
      files = {
        {
          oldUri = vim.uri_from_fname(args.data.from),
          newUri = vim.uri_from_fname(args.data.to),
        },
      },
    }
    local clients = vim.lsp.get_clients()
    for _, client in ipairs(clients) do
      if client:supports_method("workspace/willRenameFiles") then
        local res = client:request_sync("workspace/willRenameFiles", changes, 1000, 0)
        if res and res.result then
          vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding)
        end
      end
      if client:supports_method("workspace/didRenameFiles") then
        client:notify("workspace/didRenameFiles", changes)
      end
    end
  end,
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.ai (Extended Text Objects)
-- -----------------------------------------------------------------------------

-- mini.ai extends Neovim's text objects (around 'a', inside 'i') with 
-- smarter search and next/last variants.
local ai = require("mini.ai")
local extra = require("mini.extra")
ai.setup({
  -- Custom textobjects from mini.extra.
  custom_textobjects = {
    -- i: Indentation (around/inside indentation level)
    i = extra.gen_ai_spec.indent(),
    -- b: Buffer (around/inside entire buffer)
    e = extra.gen_ai_spec.buffer(),
    -- d: Diagnostic (around/inside error/warning)
    d = extra.gen_ai_spec.diagnostic(),
    -- n: Number (around/inside a number)
    n = extra.gen_ai_spec.number(),
  },
  -- Number of lines within which to look for a text object.
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

-- mini.completion provides async autocompletion.
-- We integrate it with mini.fuzzy for smarter filtering of completion items.
require("mini.completion").setup({
  delay = {
    completion = 100,
    info = 100,
    signature = 50,
  },
  fallback_action = function()
    -- Sane Habits: If spelling is active and the word at/before the cursor is misspelled,
    -- automatically trigger Neovim's built-in spelling completion (<C-x><C-s>) instead of <C-n>!
    if vim.wo.spell then
      local bad_info = vim.fn.spellbadword()
      local bad_word = bad_info[1]
      if bad_word ~= "" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-s>", true, true, true), "t", false)
        return
      end
    end
    -- Default fallback: keyword completion
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, true, true), "t", false)
  end,
  lsp_completion = {
    source_func = "completefunc",
    auto_setup = false,
    -- Use mini.fuzzy to filter and sort LSP completion items.
    process_items = function(items, base)
      return require("mini.fuzzy").process_lsp_items(items, base)
    end,
  },
  window = {
    info = { border = "rounded" },
    signature = { border = "rounded" },
  },
})

-- -----------------------------------------------------------------------------
-- Auto-Trigger Spelling Completion on Hover
-- -----------------------------------------------------------------------------

-- Automatically and snappily trigger spelling completion when the cursor lands
-- on a misspelled word in Insert mode (e.g. when moving off a bad word and coming back).
-- It uses a 150ms debounce timer on CursorMovedI to prevent intrusion while typing/scrolling.
local spell_comp_timer = nil

local function check_and_trigger_spell_completion()
  -- Ensure we are still in Insert mode and the popup is not already visible
  if vim.api.nvim_get_mode().mode ~= "i" or vim.fn.pumvisible() == 1 then
    return
  end

  if vim.wo.spell and vim.bo.buftype == "" then
    local bad_info = vim.fn.spellbadword()
    local bad_word = bad_info[1]
    if bad_word ~= "" then
      pcall(function()
        require("mini.completion").complete_twostage()
      end)
    end
  end
end

local function debounce_spell_completion()
  if spell_comp_timer then
    spell_comp_timer:stop()
    spell_comp_timer:close()
    spell_comp_timer = nil
  end

  local timer = vim.uv.new_timer()
  spell_comp_timer = timer
  timer:start(150, 0, vim.schedule_wrap(function()
    check_and_trigger_spell_completion()
    if spell_comp_timer == timer then
      spell_comp_timer = nil
    end
  end))
end

local spell_comp_group = vim.api.nvim_create_augroup("SpellCompletionAuto", { clear = true })
vim.api.nvim_create_autocmd("CursorMovedI", {
  group = spell_comp_group,
  callback = function()
    debounce_spell_completion()
  end,
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.fuzzy (Fuzzy Matching Engine)
-- -----------------------------------------------------------------------------

--- Fuzzy matching engine
---
--- mini.fuzzy provides a minimal and fast fuzzy matching algorithm.
--- It is integrated into `mini.completion` to allow for smarter filtering.
--- @tag mini.fuzzy
require("mini.fuzzy").setup({})

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
      require("mini.completion").complete_twostage()
      return ""
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
-- Configuration: mini.input (Modern Input Prompt)
-- -----------------------------------------------------------------------------

-- mini.input provides a modernized replacement for vim.ui.input.
-- It uses a floating window for prompts, ensuring a consistent UI2 experience.
require("mini.input").setup({
  -- Default context scope for the input prompt.
  scope = "editor",
})
vim.ui.input = require("mini.input").ui_input

-- -----------------------------------------------------------------------------
-- Configuration: mini.jump
-- -----------------------------------------------------------------------------

-- mini.jump enhances standard f/F/t/T motions with multi-line reach
-- and smart case sensitivity.
require("mini.jump").setup({
  mappings = {
    forward = "f",
    backward = "F",
    forward_till = "t",
    backward_till = "T",
    -- Disable mini.jump's repeat mappings so treesitter-textobjects can
    -- handle repeating all jumps (including f/t and ]m, ]d, etc.)
    repeat_jump = "",
  },
  -- Delay (in ms) before highlighting target characters.
  delay = {
    highlight = 250,
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.jump2d
-- -----------------------------------------------------------------------------

-- mini.jump2d provides 2D jumping to any visible word start or character.
require("mini.jump2d").setup({
  -- Custom mappings.
  mappings = {
    -- Disable default <CR> mapping as it's often intrusive.
    start_jumping = "",
  },
  -- Visual options.
  view = {
    -- Dim lines; makes targets and labels pop.
    dim = true,
  },
})

-- Mapping: <leader>j to start jumping to word starts.
vim.keymap.set("n", "<leader>j", "<cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.word_start)<CR>", { desc = "Jump 2D (Words)" })

-- Mapping: <leader>jc to jump to a specific character with a modern delayed prompt.
vim.keymap.set("n", "<leader>jc", function()
  local jump2d = require("mini.jump2d")
  -- Use vim.ui.input (leveraging mini.input) for a floating prompt.
  vim.ui.input({ prompt = "Jump to character: " }, function(input)
    if input and #input > 0 then
      -- Target only the first character entered.
      local char = input:sub(1, 1)
      -- Generate a spotter for that specific character.
      local spotter = jump2d.gen_spotter.pattern(vim.pesc(char))
      -- Start the 2D jump session.
      jump2d.start({ spotter = spotter })
    end
  end)
end, { desc = "Jump 2D (Character)" })

-- Mapping: <leader>jl to jump to the start of visible lines.
vim.keymap.set("n", "<leader>jl", "<cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.line_start)<CR>", { desc = "Jump 2D (Lines)" })

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
    },
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.misc
-- -----------------------------------------------------------------------------

-- mini.misc is a collection of miscellaneous helper functions.
require("mini.misc").setup({
  -- Array of function names to be made available in global scope.
  -- 'put' and 'put_text' are extremely useful for debugging.
  make_global = { "put", "put_text" },
})

-- Automation: Project Root
-- Automatically change CWD to the project root (e.g., where .git is).
require("mini.misc").setup_auto_root({ ".git", "Makefile", "package.json" })

-- Automation: Restore Cursor
-- Remember and restore the last cursor position when opening a file.
require("mini.misc").setup_restore_cursor()

-- Automation: Terminal Background Sync
-- Synchronize the terminal background color to remove "frames".
require("mini.misc").setup_termbg_sync()

-- -----------------------------------------------------------------------------
-- Configuration: mini.pick (Fuzzy Picker)
-- -----------------------------------------------------------------------------

-- mini.pick is a minimal and fast fuzzy picker.
local pick = require("mini.pick")
pick.setup({
  -- Window configuration to match UI2 and meowsoot.
  window = {
    config = {
      border = "rounded",
    },
  },
})

-- Use mini.pick as the default for vim.ui.select.
vim.ui.select = pick.ui_select

-- Mapping: <leader>pf to pick files.
vim.keymap.set("n", "<leader>pf", function()
  pick.builtin.files()
end, { desc = "Pick Files" })

-- Mapping: <leader>pb to pick buffers.
vim.keymap.set("n", "<leader>pb", function()
  pick.builtin.buffers()
end, { desc = "Pick Buffers" })

-- Mapping: <leader>pg to live grep.
vim.keymap.set("n", "<leader>pg", function()
  pick.builtin.grep_live()
end, { desc = "Pick Grep (Live)" })

-- Mapping: <leader>ph to pick help tags.
vim.keymap.set("n", "<leader>ph", function()
  pick.builtin.help()
end, { desc = "Pick Help" })

-- Mapping: <leader>pr to resume the last picker.
vim.keymap.set("n", "<leader>pr", function()
  pick.builtin.resume()
end, { desc = "Pick Resume" })

-- -----------------------------------------------------------------------------
-- Configuration: mini.extra Pickers
-- -----------------------------------------------------------------------------

-- Complementary pickers from mini.extra.
local extra = require("mini.extra")

-- Mapping: <leader>pd to pick diagnostics.
vim.keymap.set("n", "<leader>pd", function()
  extra.pickers.diagnostic()
end, { desc = "Pick Diagnostics" })

-- Mapping: <leader>ps to pick LSP symbols.
vim.keymap.set("n", "<leader>ps", function()
  extra.pickers.lsp({ scope = "document_symbol" })
end, { desc = "Pick LSP Symbols" })

-- Mapping: <leader>pv to pick visited paths (frecency).
vim.keymap.set("n", "<leader>pv", function()
  extra.pickers.visit_paths()
end, { desc = "Pick Visits (Frecency)" })

-- Mapping: <leader>pgb to pick git branches.
vim.keymap.set("n", "<leader>pgb", function()
  extra.pickers.git_branches()
end, { desc = "Pick Git Branches" })

-- Mapping: <leader>pgc to pick git commits.
vim.keymap.set("n", "<leader>pgc", function()
  extra.pickers.git_commits()
end, { desc = "Pick Git Commits" })

-- Mapping: <leader>pz to pick fuzzy-searchable spell suggestions.
-- Integrates with psliwka/vim-dirtytalk and native spelling, leveraging
-- mini.extra's modern spellsuggest picker to easily fix spelling errors.
vim.keymap.set("n", "<leader>pz", function()
  extra.pickers.spellsuggest()
end, { desc = "Pick Spell Suggestions" })

-- -----------------------------------------------------------------------------
-- Configuration: mini.visits (Frecency Tracking)
-- -----------------------------------------------------------------------------

-- mini.visits tracks and manages file visit history (frecency) and labels.
local visits = require("mini.visits")
visits.setup({})

-- Mapping: <leader>va to add a label to the current file.
vim.keymap.set("n", "<leader>va", function()
  visits.add_label()
end, { desc = "Add Visit Label" })

-- Mapping: <leader>vr to remove a label from the current file.
vim.keymap.set("n", "<leader>vr", function()
  visits.remove_label()
end, { desc = "Remove Visit Label" })

-- Mapping: <leader>vl to pick files by labels.
vim.keymap.set("n", "<leader>vl", function()
  extra.pickers.visit_labels()
end, { desc = "Pick Visit Labels" })

-- -----------------------------------------------------------------------------
-- Configuration: mini.trailspace (Whitespace Management)
-- -----------------------------------------------------------------------------

-- mini.trailspace highlights and trims trailing whitespace.
require("mini.trailspace").setup({
  -- Only highlight in normal buffers (buftype == "").
  only_in_normal_buffers = true,
})

-- Highlight: Subtle red background for trailing whitespace.
vim.api.nvim_set_hl(0, "MiniTrailspace", { bg = c.red, fg = c.bg })

-- Automation: Auto-trim on save.
-- Clean up trailing whitespace and trailing empty lines automatically.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("MiniTrailspaceAutoTrim", { clear = true }),
  callback = function()
    require("mini.trailspace").trim()
    require("mini.trailspace").trim_last_lines()
  end,
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.animate (Subtle Animations)
-- -----------------------------------------------------------------------------

-- mini.animate provides smooth, asynchronous animations.
-- We use faster timings (200ms) for a "subtle" feel.
require("mini.animate").setup({
  -- Cursor path animation.
  cursor = {
    enable = true,
    timing = require("mini.animate").gen_timing.linear({ duration = 150, unit = "total" }),
  },
  -- Vertical scroll animation.
  scroll = {
    enable = true,
    timing = require("mini.animate").gen_timing.linear({ duration = 150, unit = "total" }),
  },
  -- Window resize animation.
  resize = {
    enable = true,
    timing = require("mini.animate").gen_timing.linear({ duration = 150, unit = "total" }),
  },
  -- Window open/close animation.
  open = {
    enable = true,
    timing = require("mini.animate").gen_timing.linear({ duration = 150, unit = "total" }),
  },
  close = {
    enable = true,
    timing = require("mini.animate").gen_timing.linear({ duration = 150, unit = "total" }),
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.cursorword
-- -----------------------------------------------------------------------------

-- mini.cursorword automatically highlights the word under the cursor
-- and its other occurrences in the window.
require("mini.cursorword").setup({})

-- -----------------------------------------------------------------------------
-- Configuration: mini.hipatterns (Pattern Highlighting)
-- -----------------------------------------------------------------------------

-- mini.hipatterns provides high-performance pattern highlighting.
local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    -- Highlight hex color strings (#rrggbb) with their color.
    hex_color = hipatterns.gen_highlighter.hex_color(),

    -- Highlight common keywords.
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack  = { pattern = "%f[%w]()HACK()%f[%W]",  group = "MiniHipatternsHack"  },
    todo  = { pattern = "%f[%w]()TODO()%f[%W]",  group = "MiniHipatternsTodo"  },
    note  = { pattern = "%f[%w]()NOTE()%f[%W]",  group = "MiniHipatternsNote"  },
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.indentscope (Scope Visualization)
-- -----------------------------------------------------------------------------

-- mini.indentscope provides an animated visual indicator for the current scope.
require("mini.indentscope").setup({
  -- Use a subtle vertical line.
  symbol = "│",
  -- Animation timing matching the subtle feel of mini.animate.
  draw = {
    delay = 100,
    animation = require("mini.indentscope").gen_animation.linear({ duration = 150, unit = "total" }),
  },
})

-- -----------------------------------------------------------------------------
-- Configuration: mini.map (Code Minimap)
-- -----------------------------------------------------------------------------

-- mini.map provides a code minimap with integrated feedback.
local minimap = require("mini.map")
minimap.setup({
  -- Integrations to show rich data on the map.
  integrations = {
    minimap.gen_integration.builtin_search(),
    minimap.gen_integration.diagnostic(),
    minimap.gen_integration.diff(),
  },
  -- Symbols used for the map (default is 3x2 resolution).
  symbols = {
    encode = minimap.gen_encode_symbols.dot("4x2"),
    scroll_line = "▶",
    scroll_view = "║",
  },
  -- Window configuration.
  window = {
    -- Width of the map.
    width = 10,
    -- Side to show the map.
    side = "right",
    -- Match UI2/meowsoot.
    winblend = 0,
  },
})

-- Automation: Auto-open Minimap
-- Automatically open the map for every buffer, excluding special buffers and dashboards.
-- For files with more than 500 lines, we defer generation to prevent startup lag and
-- notify the user via our floating notification system.
vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "VimEnter" }, {
  group = vim.api.nvim_create_augroup("MiniMapAutoOpen", { clear = true }),
  callback = function()
    local exclude_ft = { "ministarter", "minifiles", "minipick" }
    local ft = vim.bo.filetype
    local buftype = vim.bo.buftype

    if vim.tbl_contains(exclude_ft, ft) or buftype ~= "" then
      minimap.close()
    else
      local line_count = vim.api.nvim_buf_line_count(0)
      if line_count > 500 then
        -- Large file: defer generation to a background tick and notify the user
        vim.schedule(function()
          local notif_id = vim.notify(
            string.format("Generating minimap for %d lines...", line_count),
            vim.log.levels.INFO,
            { title = " Map ", keep = function() return false end }
          )

          -- Defer map generation slightly to let the UI render completely first
          vim.defer_fn(function()
            -- Ensure we are still in the same buffer and filetype is valid before opening
            if vim.tbl_contains(exclude_ft, vim.bo.filetype) or vim.bo.buftype ~= "" then
              pcall(require("mini.notify").clear)
              return
            end

            minimap.open()

            vim.notify(
              "Minimap generated! [Done]",
              vim.log.levels.INFO,
              { title = " Map ", id = notif_id, timeout = 1000 }
            )
          end, 50)
        end)
      else
        -- Small file: open instantly
        minimap.open()
      end
    end
  end,
})

-- Mapping: <leader>mc to close the map manually.
vim.keymap.set("n", "<leader>mc", function()
  minimap.close()
end, { desc = "Close Minimap" })

-- Mapping: <leader>mf to toggle focus on the map.
vim.keymap.set("n", "<leader>mf", function()
  minimap.toggle_focus()
end, { desc = "Focus Minimap" })

-- -----------------------------------------------------------------------------
-- Configuration: mini.statusline (Status Bar)
-- -----------------------------------------------------------------------------

-- mini.statusline provides a fast, minimal status bar.
local statusline = require("mini.statusline")
statusline.setup({
  content = {
    -- Custom active statusline content.
    active = function()
      local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
      local git = statusline.section_git({ trunc_width = 75, icon = "󰊢" })
      local diff = statusline.section_diff({ trunc_width = 75, icon = "󰙇" })
      local diagnostics = statusline.section_diagnostics({ trunc_width = 75, icon = "󰋼" })
      local filename = statusline.section_filename({ trunc_width = 140 })
      local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
      local location = statusline.section_location({ trunc_width = 75 })

      -- Macro recording indicator.
      local recording = vim.fn.reg_recording()
      local macro = recording ~= "" and ("󰑊 " .. recording) or ""

      -- Custom: Integration with mini.visits (show labels for current buffer).
      local label = ""
      local ok_visits, visits = pcall(require, "mini.visits")
      if ok_visits and vim.bo.buftype == "" then
        local labels = visits.list_labels()
        if #labels > 0 then
          label = "󱗿 " .. table.concat(labels, ",")
        end
      end

      -- Combine all sections into a single string using 'strings' arrays as expected by combine_groups.
      return statusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
        "%<", -- Mark general truncate point
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=", -- End left alignment
        { hl = "MiniStatuslineDevinfo", strings = { macro, label } },
        { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
        { hl = mode_hl, strings = { location } },
      })
    end,
  },
})

-- Statusline Tweaks:
-- We give the entire statusline a subtle background so it looks like a "bar".
-- The mode indicators use colored text on this dark background for a clean, modern look.
local status_bg = c.bg_1
vim.api.nvim_set_hl(0, "StatusLine", { fg = c.fg, bg = status_bg })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = c.fg_faint, bg = status_bg })

-- Mode Highlights: Distinct colors for each mode on the statusline background.
vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { fg = c.green, bg = status_bg, bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { fg = c.blue, bg = status_bg, bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { fg = c.magenta, bg = status_bg, bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { fg = c.red, bg = status_bg, bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { fg = c.pink, bg = status_bg, bold = true })

-- Information Highlights: Muted colors for auxiliary information.
vim.api.nvim_set_hl(0, "MiniStatuslineDevinfo", { fg = c.fg_mute, bg = status_bg })
vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { fg = c.fg, bg = status_bg, bold = true })
vim.api.nvim_set_hl(0, "MiniStatuslineFileinfo", { fg = c.fg_mute, bg = status_bg })

-- -----------------------------------------------------------------------------
-- Configuration: mini.cmdline (Disabled in favor of tiny-cmdline.nvim)
-- -----------------------------------------------------------------------------

-- mini.cmdline is disabled because we migrated to rachartier/tiny-cmdline.nvim.
-- tiny-cmdline provides a sleek centered floating command window utilizing
-- Neovim v0.12+ UI2 capabilities, paired with cmdheight = 0.
-- require("mini.cmdline").setup({
--   completion = { delay = 100 },
--   correction = { delay = 100 },
--   peek = { delay = 100 },
-- })

-- -----------------------------------------------------------------------------
-- Configuration: mini.diff
-- -----------------------------------------------------------------------------

-- mini.diff provides live gutter signs and in-buffer diff overlays.
-- It tracks changes against the Git index by default.
require("mini.diff").setup({
  -- Use signs in the gutter (signcolumn).
  view = {
    style = "sign",
    -- Use symbols for better distinction between change types.
    signs = { add = "+", change = "~", delete = "-" },
  },
})

-- Mapping to toggle the detailed in-buffer diff overlay.
vim.keymap.set("n", "<leader>go", function()
  require("mini.diff").toggle_overlay(0)
end, { desc = "Toggle Diff Overlay" })

-- Always-on Overlay: Automatically enable the diff overlay for every buffer.
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniDiffUpdated",
  callback = function(data)
    local buf_id = data.buf
    -- Ensure we only auto-toggle once per buffer to avoid infinite loops
    -- or annoying behavior when manually toggling.
    if not vim.b[buf_id].minidiff_overlay_auto_enabled then
      require("mini.diff").toggle_overlay(buf_id)
      vim.b[buf_id].minidiff_overlay_auto_enabled = true
    end
  end,
})

-- Build keyboard habits: Disable mouse support entirely.
vim.opt.mouse = ""

-- Clean UI: Disable showing invisible characters (tabs, trailing spaces).
vim.opt.list = false

-- Responsive Hover: Set updatetime to 300ms (default is 4000ms).
-- This ensures diagnostic hovers (including spelling errors) display near-instantly when hovering.
vim.opt.updatetime = 300

-- Cursor Aesthetics: Keep the cursor as a solid block in all modes
vim.opt.guicursor = ""

-- Scrolling Context: Keep 8 lines of context above/below the cursor when scrolling
vim.opt.scrolloff = 8

-- Indentation Deletion: Delete 4 spaces on backspace if they act as a tab
vim.opt.softtabstop = 4

-- -----------------------------------------------------------------------------
-- Sane Habits: Message Redirection to Pop-ups
-- -----------------------------------------------------------------------------

-- Suppress standard file-writing ("W") and search-hit ("s") messages from replacing the statusline.
-- We will instead show them as beautiful floating pop-up notifications or let them silence cleanly.
vim.opt.shortmess:append("Ws")

-- Prevent changed lines reports (such as "9 fewer lines" or search/substitute tallies)
-- from replacing/overwriting our statusline by setting the reporting threshold to an extremely large value.
vim.opt.report = 99999

-- Show file saving feedback inside our modern floating notification system
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("PristineWriteNotif", { clear = true }),
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    file = file ~= "" and vim.fn.fnamemodify(file, ":~:.") or "[No Name]"
    vim.notify(string.format("Written: %s", file), vim.log.levels.INFO, { title = " System " })
  end,
})

-- Execute Undo and Redo silently to prevent statusline replacement,
-- instead routing their feedback to our transient floating notifications.
vim.keymap.set("n", "u", function()
  local ok, err = pcall(vim.cmd, "silent undo")
  if ok then
    vim.notify("Undo performed", vim.log.levels.INFO, { title = " System ", timeout = 1000 })
  else
    local msg = tostring(err)
    if msg:find("oldest") then
      msg = "Already at oldest change"
    end
    vim.notify(msg, vim.log.levels.WARN, { title = " System ", timeout = 1000 })
  end
end, { desc = "Undo silently with popup feedback" })

vim.keymap.set("n", "<C-r>", function()
  local ok, err = pcall(vim.cmd, "silent redo")
  if ok then
    vim.notify("Redo performed", vim.log.levels.INFO, { title = " System ", timeout = 1000 })
  else
    local msg = tostring(err)
    if msg:find("newest") then
      msg = "Already at newest change"
    end
    vim.notify(msg, vim.log.levels.WARN, { title = " System ", timeout = 1000 })
  end
end, { desc = "Redo silently with popup feedback" })

-- -----------------------------------------------------------------------------
-- Sane Habits: Line Count Change Notifications
-- -----------------------------------------------------------------------------

-- Since we natively set 'report = 99999' to suppress lines changed console messages
-- (avoiding statusline-replacement glitches), we dynamically track buffer line counts
-- and route substantial additions/deletions (>= 2 lines) to floating popup notifications instead.
local line_track_group = vim.api.nvim_create_augroup("LineCountTracker", { clear = true })

-- Initialize line count on load, save, and window display
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "BufWinEnter" }, {
  group = line_track_group,
  callback = function(args)
    if vim.bo[args.buf].buftype == "" then
      vim.b[args.buf].last_line_count = vim.api.nvim_buf_line_count(args.buf)
    end
  end,
})

-- Track line additions and deletions on TextChanged
vim.api.nvim_create_autocmd("TextChanged", {
  group = line_track_group,
  callback = function(args)
    local bufnr = args.buf
    if vim.bo[bufnr].buftype ~= "" then
      return
    end

    local last = vim.b[bufnr].last_line_count
    if not last then
      vim.b[bufnr].last_line_count = vim.api.nvim_buf_line_count(bufnr)
      return
    end

    local current = vim.api.nvim_buf_line_count(bufnr)
    local diff = current - last

    if diff ~= 0 then
      vim.b[bufnr].last_line_count = current
      
      -- Only notify for changes of 2 or more lines (standard Neovim 'report' threshold)
      if math.abs(diff) >= 2 then
        local msg
        if diff < 0 then
          msg = string.format("%d fewer lines", math.abs(diff))
        else
          msg = string.format("%d more lines", diff)
        end
        vim.notify(msg, vim.log.levels.INFO, { title = " System ", timeout = 1000 })
      end
    end
  end,
})
