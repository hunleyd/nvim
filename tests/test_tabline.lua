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
-- Tabline Appearance
-- -----------------------------------------------------------------------------

T["Tabline"] = MiniTest.new_set()

T["Tabline"]["correctly highlights active buffer"] = function()
  -- Create a second buffer to ensure we have tabs
  child.api.nvim_command("enew")
  child.api.nvim_buf_set_name(0, "test_file.lua")
  
  -- Get the rendered tabline string
  local rendered = child.lua_get("_G.MyTabLine()")
  
  -- Verify presence of the active highlight and file name
  MiniTest.expect.equality(rendered:find("%%#TabLineSel#") ~= nil, true)
  MiniTest.expect.equality(rendered:find("test_file.lua") ~= nil, true)
  
  -- Verify separators are present
  MiniTest.expect.equality(rendered:find("│") ~= nil, true)
end

T["Tabline"]["shows modified indicator"] = function()
  child.api.nvim_command("enew")
  child.api.nvim_buf_set_name(0, "dirty.lua")
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "change" })
  
  local rendered = child.lua_get("_G.MyTabLine()")
  
  -- Verify the modified dot is present
  MiniTest.expect.equality(rendered:find("●") ~= nil, true)
  -- In active buffer, it should still be in TabLineSel (per our current logic)
  MiniTest.expect.equality(rendered:find("%%#TabLineSel#.*dirty.lua ●") ~= nil, true)
end

T["Tabline"]["uses TabLineHiddenMod for inactive modified buffers"] = function()
  -- Buffer 1: Modified
  child.api.nvim_command("enew")
  child.api.nvim_buf_set_name(0, "dirty.lua")
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "change" })
  
  -- Buffer 2: Active (Switch away from dirty.lua)
  child.api.nvim_command("enew")
  child.api.nvim_buf_set_name(0, "clean.lua")
  
  local rendered = child.lua_get("_G.MyTabLine()")
  
  -- Verify the inactive modified buffer uses the warning highlight
  MiniTest.expect.equality(rendered:find("%%#TabLineHiddenMod#.*dirty.lua ●") ~= nil, true)
end

return T
