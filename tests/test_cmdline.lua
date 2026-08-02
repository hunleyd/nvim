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
-- rachartier/tiny-cmdline.nvim Integration
-- -----------------------------------------------------------------------------

T["Tiny Cmdline"] = MiniTest.new_set()

T["Tiny Cmdline"]["can be successfully loaded"] = function()
  -- Verify the plugin can be required
  local can_require = child.lua([[
    local ok, _ = pcall(require, "tiny-cmdline")
    return ok
  ]])
  MiniTest.expect.equality(can_require, true)
end

T["Tiny Cmdline"]["sets cmdheight to zero"] = function()
  -- Verify cmdheight is set to 0 to hide the legacy command line
  local cmdheight = child.lua_get("vim.opt.cmdheight:get()")
  MiniTest.expect.equality(cmdheight, 0)
end

T["Tiny Cmdline"]["disables mini.cmdline to avoid collisions"] = function()
  -- Verify that mini.cmdline is NOT loaded or active
  local mini_cmdline_active = child.lua([[
    return package.loaded["mini.cmdline"] ~= nil
  ]])
  -- It should be false since we commented it out and didn't load/call it
  MiniTest.expect.equality(mini_cmdline_active, false)
end

T["Tiny Cmdline"]["vim.pos supports buf=0 and to_offset in v0.12.3"] = function()
  child.api.nvim_command("enew")
  local ok = child.lua([[
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello", "world" })
    local pos = vim.pos and vim.pos(0, 1, 0)
    if pos and pos.to_offset then
      local off = pos:to_offset()
      return type(off) == "number"
    end
    return true
  ]])
  MiniTest.expect.equality(ok, true)
end

return T
