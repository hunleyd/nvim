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
-- Hardtime Integration
-- -----------------------------------------------------------------------------

T["Hardtime"] = MiniTest.new_set()

T["Hardtime"]["plugin is loadable and configured"] = function()
  -- Check if hardtime is in runtimepath and loaded
  local has_hardtime = child.lua_get("pcall(require, 'hardtime')")
  MiniTest.expect.equality(has_hardtime, true)
  
  -- Check if nui is available since it's a dependency
  local has_nui = child.lua_get("pcall(require, 'nui.popup')")
  MiniTest.expect.equality(has_nui, true)
end

T["Hardtime"]["starts correctly in normal buffers"] = function()
  -- Create a new normal buffer
  child.api.nvim_command("enew")
  child.api.nvim_buf_set_name(0, "test_file.lua")
  
  -- Hardtime creates an autocmd or a state flag per buffer
  local disabled_types = child.lua_get("require('hardtime.config').config.disabled_filetypes")
  
  -- We expect lua to NOT be in the disabled list
  local is_lua_disabled = false
  for _, v in ipairs(disabled_types) do
    if v == "lua" then is_lua_disabled = true end
  end
  
  MiniTest.expect.equality(is_lua_disabled, false)
end

return T
