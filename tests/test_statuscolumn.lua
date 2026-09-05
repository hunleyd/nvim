local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "tests/minimal_init.lua" })
    end,
    post_once = function()
      child.stop()
    end,
  },
})

-- -----------------------------------------------------------------------------
-- Status Column Integration (mini.statuscolumn)
-- -----------------------------------------------------------------------------

T["Statuscolumn"] = MiniTest.new_set()

T["Statuscolumn"]["plugin is loadable and configured"] = function()
  -- The plugin is required and sets vim.o.statuscolumn
  local has_statuscolumn = child.lua_get("pcall(require, 'mini.statuscolumn')")
  MiniTest.expect.equality(has_statuscolumn, true)

  child.api.nvim_command("new")
  local stc = child.lua_get("vim.wo.statuscolumn")
  MiniTest.expect.equality(stc ~= "", true)
  MiniTest.expect.equality(stc:find("MiniStatuscolumn", 1, true) ~= nil, true)
end

T["Statuscolumn"]["separator highlights exist and match meowsoot"] = function()
  local sep_hl = child.lua_get("vim.api.nvim_get_hl(0, { name = 'MiniStatuscolumnSep' })")
  MiniTest.expect.equality(sep_hl.fg ~= nil, true)
  MiniTest.expect.equality(sep_hl.bg ~= nil, true)

  local sep_cur_hl = child.lua_get("vim.api.nvim_get_hl(0, { name = 'MiniStatuscolumnSepCursor' })")
  MiniTest.expect.equality(sep_cur_hl.fg ~= nil, true)
  MiniTest.expect.equality(sep_cur_hl.bg ~= nil, true)
end

T["Statuscolumn"]["renders statuscolumn structure correctly"] = function()
  child.api.nvim_command("new")
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "local a = 1", "local b = 2" })
  local win_id = child.api.nvim_get_current_win()

  local active_str = child.lua_get("require('mini.statuscolumn').active()")
  local inactive_str = child.lua_get("require('mini.statuscolumn').inactive()")

  MiniTest.expect.equality(active_str:find("%%s", 1, false) ~= nil, true)
  MiniTest.expect.equality(active_str:find("%%l", 1, false) ~= nil, true)
  MiniTest.expect.equality(active_str:find("│", 1, true) ~= nil, true)

  MiniTest.expect.equality(inactive_str:find("%%s", 1, false) ~= nil, true)
  MiniTest.expect.equality(inactive_str:find("%%l", 1, false) ~= nil, true)
  MiniTest.expect.equality(inactive_str:find("│", 1, true) ~= nil, true)
end

T["Statuscolumn"]["updates CursorLineNr and separator highlights on mode changes"] = function()
  child.api.nvim_command("new")
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "line 1", "line 2" })

  -- 1. Normal mode (default) -> Green (#98cdaa / 0x98cdaa)
  local cur_nr_norm = child.lua_get("vim.api.nvim_get_hl(0, { name = 'CursorLineNr' }).fg")
  local sep_cur_norm = child.lua_get("vim.api.nvim_get_hl(0, { name = 'MiniStatuscolumnSepCursor' }).fg")
  MiniTest.expect.equality(cur_nr_norm, tonumber("98cdaa", 16))
  MiniTest.expect.equality(sep_cur_norm, tonumber("98cdaa", 16))

  -- 2. Insert mode -> Blue (#96bddf / 0x96bddf)
  child.type_keys("i")
  local cur_nr_ins = child.lua_get("vim.api.nvim_get_hl(0, { name = 'CursorLineNr' }).fg")
  local sep_cur_ins = child.lua_get("vim.api.nvim_get_hl(0, { name = 'MiniStatuscolumnSepCursor' }).fg")
  MiniTest.expect.equality(cur_nr_ins, tonumber("96bddf", 16))
  MiniTest.expect.equality(sep_cur_ins, tonumber("96bddf", 16))

  -- 3. Visual mode -> Magenta (#96d8e3 / 0x96d8e3)
  child.type_keys("<Esc>", "v")
  local cur_nr_vis = child.lua_get("vim.api.nvim_get_hl(0, { name = 'CursorLineNr' }).fg")
  local sep_cur_vis = child.lua_get("vim.api.nvim_get_hl(0, { name = 'MiniStatuscolumnSepCursor' }).fg")
  MiniTest.expect.equality(cur_nr_vis, tonumber("96d8e3", 16))
  MiniTest.expect.equality(sep_cur_vis, tonumber("96d8e3", 16))

  -- 4. Return to Normal mode -> Restored to Green
  child.type_keys("<Esc>")
  local cur_nr_back = child.lua_get("vim.api.nvim_get_hl(0, { name = 'CursorLineNr' }).fg")
  local sep_cur_back = child.lua_get("vim.api.nvim_get_hl(0, { name = 'MiniStatuscolumnSepCursor' }).fg")
  MiniTest.expect.equality(cur_nr_back, tonumber("98cdaa", 16))
  MiniTest.expect.equality(sep_cur_back, tonumber("98cdaa", 16))
end

return T
