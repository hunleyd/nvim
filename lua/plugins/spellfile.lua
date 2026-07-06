-- =============================================================================
-- Plugin: spellfile.lua & vim-dirtytalk
-- =============================================================================

--- Programming-specific spell checker and general spell management
---
--- Integrates `psliwka/vim-dirtytalk` to provide spelling support for
--- programming terms and configures native Neovim spell checking.
--- @tag plugins.spellfile

-- Add psliwka/vim-dirtytalk to managed packages
vim.pack.add({
  {
    name = "vim-dirtytalk",
    src = "https://github.com/psliwka/vim-dirtytalk",
  },
})

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- Enable spell checking.
vim.opt.spell = true

-- Dynamically configure spelllang. We only include "programming" if the compiled
-- spell file actually exists within the Neovim runtimepath. This prevents blocking
-- "No spell file found" dialogs and errors on clean installations or during isolated tests.
local lang = { "en_us" }
if #vim.api.nvim_get_runtime_file("spell/programming.*.spl", false) > 0 then
  table.insert(lang, "programming")
end
vim.opt.spelllang = lang

-- Define a dedicated directory for spell-check files (dictionaries and word lists).
local spell_dir = vim.fn.stdpath("data") .. "/spell"

-- Ensure the directory exists.
if vim.fn.isdirectory(spell_dir) == 0 then
  vim.fn.mkdir(spell_dir, "p")
end

-- Add this directory to the beginning of runtimepath so Neovim uses it
-- for downloading and finding .spl (dictionary) files.
vim.opt.runtimepath:prepend(spell_dir)

-- The 'spellfile' option points to the file where 'zg' (add to dictionary)
-- and 'zw' (mark as wrong) commands save your personal word list.
vim.opt.spellfile = spell_dir .. "/en.utf-8.add"

-- -----------------------------------------------------------------------------
-- Automations
-- -----------------------------------------------------------------------------

-- Compile programming-specific dictionary on plugin install/update
local spell_group = vim.api.nvim_create_augroup("SpellDirtytalk", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = spell_group,
  pattern = "PackChanged",
  callback = function(evt)
    if evt.data and evt.data.spec and evt.data.spec.name == "vim-dirtytalk" then
      if evt.data.kind == "install" or evt.data.kind == "update" then
        vim.notify("Compiling programming spell dictionary...", vim.log.levels.INFO, { title = " Spell " })
        -- Ensure runtime files of the plugin are sourced so the command exists
        vim.cmd("runtime! plugin/dirtytalk.vim")
        -- Run DirtytalkUpdate inside a pcall to safely capture errors
        local ok, err = pcall(vim.cmd, "DirtytalkUpdate")
        if ok then
          vim.notify("Programming spell dictionary compiled successfully.", vim.log.levels.INFO, { title = " Spell " })
          
          -- Dynamically enable the programming dictionary now that it exists
          local current_langs = vim.opt.spelllang:get()
          local has_programming = false
          for _, l in ipairs(current_langs) do
            if l == "programming" then
              has_programming = true
              break
            end
          end
          if not has_programming then
            table.insert(current_langs, "programming")
            vim.opt.spelllang = current_langs
            -- Also set the global default so any new windows/buffers inherit it
            vim.go.spelllang = table.concat(current_langs, ",")
          end
        else
          vim.notify("Failed to compile programming spell dictionary: " .. tostring(err), vim.log.levels.ERROR, { title = " Spell " })
        end
      end
    end
  end,
})

-- -----------------------------------------------------------------------------
-- Spelling Diagnostics Integration
-- -----------------------------------------------------------------------------

-- This integrates Neovim's built-in spell checker with the standard diagnostic FFI.
-- Spelling errors will be published as HINT diagnostics, ensuring they appear
-- in the diagnostic gutter (signcolumn), statusline, and list pickers automatically.

local spell_ns = vim.api.nvim_create_namespace("SpellingDiagnostics")
local spell_timers = {}

--- Run spelling diagnostic checks on a buffer
--- @param bufnr number Buffer ID
--- @private
local function run_spell_check(bufnr)
  -- Resolve buffer 0 to current buffer ID
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  -- Find all windows currently displaying this buffer
  local win_ids = vim.fn.win_findbuf(bufnr)
  if #win_ids == 0 then
    -- Background/hidden buffer: skip to avoid clearing diagnostics
    return
  end

  -- Check if any of the windows displaying this buffer has 'spell' checking enabled.
  -- This ensures split windows (some active, some inactive) behave correctly and don't collide.
  local has_active_spell = false
  for _, win in ipairs(win_ids) do
    local ok_spell, spell = pcall(vim.api.nvim_get_option_value, "spell", { win = win })
    if ok_spell and spell then
      has_active_spell = true
      break
    end
  end

  if vim.bo[bufnr].buftype ~= "" or not has_active_spell then
    vim.diagnostic.set(spell_ns, bufnr, {})
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local diagnostics = {}

  for lnum, line in ipairs(lines) do
    local search_str = line
    local current_col = 0

    while #search_str > 0 do
      -- spellbadword returns { bad_word, type }
      local bad_info = vim.fn.spellbadword(search_str)
      local bad_word = bad_info[1]
      local err_type = bad_info[2]

      if bad_word == "" then
        break
      end

      -- Find byte index of the misspelled word in the remaining search string
      local start_idx = search_str:find(bad_word, 1, true)
      if not start_idx then
        break
      end

      local word_len = #bad_word
      local abs_start = current_col + start_idx - 1
      local abs_end = abs_start + word_len

      table.insert(diagnostics, {
        bufnr = bufnr,
        lnum = lnum - 1,
        col = abs_start,
        end_col = abs_end,
        severity = vim.diagnostic.severity.HINT,
        message = string.format("Spelling error: '%s' (%s)", bad_word, err_type),
        source = "Spell",
      })

      -- Advance search past the current word
      search_str = search_str:sub(start_idx + word_len)
      current_col = current_col + start_idx + word_len - 1
    end
  end

  vim.diagnostic.set(spell_ns, bufnr, diagnostics)
end

--- Debounce spelling diagnostic runs during typing
--- @param bufnr number Buffer ID
--- @private
local function debounce_spell_check(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  if spell_timers[bufnr] then
    spell_timers[bufnr]:stop()
    spell_timers[bufnr]:close()
  end

  local timer = vim.uv.new_timer()
  spell_timers[bufnr] = timer
  timer:start(500, 0, vim.schedule_wrap(function()
    run_spell_check(bufnr)
    if spell_timers[bufnr] == timer then
      spell_timers[bufnr] = nil
    end
  end))
end

local spell_diag_group = vim.api.nvim_create_augroup("SpellDiagnostics", { clear = true })

-- Ensure spell checking is enabled and run diagnostics on load/save/display
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufWritePost" }, {
  group = spell_diag_group,
  callback = function(args)
    if vim.bo[args.buf].buftype == "" then
      pcall(function() vim.wo.spell = true end)
    end
    run_spell_check(args.buf)
  end,
})

-- Debounce spelling checks during active edits
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  group = spell_diag_group,
  callback = function(args)
    debounce_spell_check(args.buf)
  end,
})

-- Clean up active timers on buffer delete
vim.api.nvim_create_autocmd("BufDelete", {
  group = spell_diag_group,
  callback = function(args)
    local bufnr = args.buf
    if spell_timers[bufnr] then
      spell_timers[bufnr]:stop()
      spell_timers[bufnr]:close()
      spell_timers[bufnr] = nil
    end
  end,
})

-- -----------------------------------------------------------------------------
-- Interactive Spell Mappings: On-The-Fly Diagnostic Refresh
-- -----------------------------------------------------------------------------

-- Intercept standard dictionary commands (zg, zw, etc.) to immediately
-- re-scan the active buffer and clear or add diagnostics on the fly.
local function map_spell_trigger(lhs, rhs_cmd)
  vim.keymap.set("n", lhs, function()
    -- Execute original command natively
    vim.cmd("normal! " .. rhs_cmd)
    -- Defer refresh slightly to let Neovim's internal spelling database update
    vim.schedule(function()
      run_spell_check(0)
    end)
  end, { desc = "Update spelling dictionary and refresh diagnostics instantly" })
end

map_spell_trigger("zg", "zg")
map_spell_trigger("zw", "zw")
map_spell_trigger("zG", "zG")
map_spell_trigger("zW", "zW")
map_spell_trigger("zug", "zug")
map_spell_trigger("zuw", "zuw")
map_spell_trigger("zuG", "zuG")
map_spell_trigger("zuW", "zuW")

-- Map z= to open mini.extra's spellsuggest picker for a beautiful UI2 popup
vim.keymap.set("n", "z=", function()
  require("mini.extra").pickers.spellsuggest()
end, { desc = "Pick spell suggestions with UI2 popup" })

