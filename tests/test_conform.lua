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
-- conform.nvim Integration
-- -----------------------------------------------------------------------------

T["Conform Formatting"] = MiniTest.new_set()

T["Conform Formatting"]["can be successfully loaded"] = function()
  -- Verify the plugin can be required
  local can_require = child.lua([[
    local ok, _ = pcall(require, "conform")
    return ok
  ]])
  MiniTest.expect.equality(can_require, true)
end

T["Conform Formatting"]["commands FormatDisable and FormatEnable exist"] = function()
  local disable_exists = child.lua_get("vim.fn.exists(':FormatDisable')")
  local enable_exists = child.lua_get("vim.fn.exists(':FormatEnable')")
  MiniTest.expect.equality(disable_exists, 2) -- 2 means command exists
  MiniTest.expect.equality(enable_exists, 2)
end

T["Conform Formatting"]["FormatDisable command disables autoformatting"] = function()
  -- Disable for the current buffer
  child.api.nvim_command("FormatDisable")
  local buf_disabled = child.lua_get("vim.b.disable_autoformat")
  MiniTest.expect.equality(buf_disabled, true)
  
  -- Disable globally
  child.api.nvim_command("FormatDisable!")
  local global_disabled = child.lua_get("vim.g.disable_autoformat")
  MiniTest.expect.equality(global_disabled, true)
end

T["Conform Formatting"]["FormatEnable command re-enables autoformatting"] = function()
  -- Disable first
  child.api.nvim_command("FormatDisable!")
  child.api.nvim_command("FormatDisable")
  
  -- Enable
  child.api.nvim_command("FormatEnable")
  local buf_disabled = child.lua_get("vim.b.disable_autoformat")
  local global_disabled = child.lua_get("vim.g.disable_autoformat")
  
  MiniTest.expect.equality(buf_disabled, false)
  MiniTest.expect.equality(global_disabled, false)
end

return T
