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
-- Message Redirection
-- -----------------------------------------------------------------------------

T["Messages"] = MiniTest.new_set()

T["Messages"]["redirects nvim_echo to notifications"] = function()
  child.lua([[
    _G.notif_count = 0
    local mock = function(...)
      _G.notif_count = _G.notif_count + 1
    end
    
    -- Mock both because nvim_echo uses Utils.notify and print uses vim.notify
    _G.Utils.notify = mock
    vim.notify = mock
    
    local original_list_uis = vim.api.nvim_list_uis
    vim.api.nvim_list_uis = function() return { { id = 1 } } end
    
    vim.api.nvim_echo({{"Test Echo", "Normal"}}, true, {})
    
    vim.wait(500, function() return _G.notif_count > 0 end)
    vim.api.nvim_list_uis = original_list_uis
  ]])
  
  local count = child.lua_get("_G.notif_count")
  MiniTest.expect.equality(count, 1)
end

T["Messages"]["redirects print to notifications"] = function()
  child.lua([[
    _G.notif_count = 0
    local mock = function(...)
      _G.notif_count = _G.notif_count + 1
    end
    
    _G.Utils.notify = mock
    vim.notify = mock
    
    print("Test Print")
    
    vim.wait(500, function() return _G.notif_count > 0 end)
  ]])
  
  local count = child.lua_get("_G.notif_count")
  MiniTest.expect.equality(count, 1)
end

T["Messages"]["u and C-r are mapped to silent popup callbacks"] = function()
  -- Check that u is mapped
  local u_map = child.lua_get("vim.fn.maparg('u', 'n')")
  MiniTest.expect.equality(u_map ~= "", true)

  -- Check that <C-r> is mapped
  local redo_map = child.lua_get("vim.fn.maparg('<C-r>', 'n')")
  MiniTest.expect.equality(redo_map ~= "", true)
end

T["Messages"]["saving triggers a BufWritePost floating notification"] = function()
  -- Create a temporary file and save it
  child.api.nvim_command("new temp_test_write.txt")
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "write content" })
  
  -- Settle state, clear prior notifications
  child.lua("require('mini.notify').clear()")
  
  -- Mock notify
  child.lua([[
    _G.notif_msg = ""
    vim.notify = function(msg, level, opts)
      _G.notif_msg = msg
    end
  ]])
  
  -- Save the file (this triggers BufWritePost)
  child.api.nvim_command("write!")
  
  -- Verify the save notification was triggered with "Written: temp_test_write.txt"
  local msg = child.lua_get("_G.notif_msg")
  local has_written = msg:find("Written:") ~= nil
  MiniTest.expect.equality(has_written, true)
  
  -- Clean up
  os.remove("temp_test_write.txt")
end

T["Messages"]["line deletion triggers fewer lines popup notification"] = function()
  -- Create a new buffer
  child.api.nvim_command("new")
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "line1", "line2", "line3", "line4", "line5" })
  
  -- Force trigger BufEnter to initialize line count
  child.api.nvim_exec_autocmds("BufEnter", { buffer = 0 })
  
  -- Settle state, clear prior notifications
  child.lua("require('mini.notify').clear()")
  
  -- Mock notify
  child.lua([[
    _G.line_notif = ""
    vim.notify = function(msg, level, opts)
      _G.line_notif = msg
    end
  ]])
  
  -- Delete 3 lines (e.g. from line 2 to 4)
  child.api.nvim_command("2,4delete")
  
  -- Settle
  child.api.nvim_command("sleep 50m")
  
  -- Verify that the notification was triggered with "3 fewer lines"
  local msg = child.lua_get("_G.line_notif")
  MiniTest.expect.equality(msg, "3 fewer lines")
end

T["Messages"]["v:starttime and v:exitreason are available in v0.12.3"] = function()
  local starttime = child.lua_get("vim.v.starttime")
  local exitreason_exists = child.lua_get("vim.v.exitreason ~= nil")
  MiniTest.expect.equality(type(starttime), "number")
  MiniTest.expect.equality(starttime > 0, true)
  MiniTest.expect.equality(exitreason_exists, true)
end

T["Messages"]["writefile accepts lua string blob directly in v0.12.3"] = function()
  local ok = child.lua([[
    local tmp = vim.fn.tempname()
    vim.fn.writefile("hello world", tmp)
    local lines = vim.fn.readfile(tmp)
    os.remove(tmp)
    return lines[1] == "hello world"
  ]])
  MiniTest.expect.equality(ok, true)
end

return T
