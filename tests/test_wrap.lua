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

T["Wrap"] = MiniTest.new_set()

T["Wrap"]["global default is enabled"] = function()
  MiniTest.expect.equality(child.lua_get("vim.go.wrap"), true)
end

T["Wrap"]["is enabled for a regular file window"] = function()
  child.cmd("edit tests/test_wrap.lua")
  MiniTest.expect.equality(child.lua_get("vim.wo.wrap"), true)
end

return T
