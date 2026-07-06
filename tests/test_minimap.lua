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
-- Minimap Performance & Deferral behavior
-- -----------------------------------------------------------------------------

T["Minimap"] = MiniTest.new_set()

T["Minimap"]["minimap loads instantly for small files"] = function()
  -- Open a small file
  child.api.nvim_command("new small_file.lua")
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "print('hello')" })
  
  -- Force trigger BufEnter to auto-open
  child.api.nvim_exec_autocmds("BufEnter", { buffer = 0 })
  
  -- Settle the asynchronous window creation of mini.map
  child.api.nvim_command("sleep 100m")
  
  -- Verify minimap is opened instantly (map window exists in win_data)
  local is_open = child.lua_get("#MiniMap.current.win_data > 0")
  MiniTest.expect.equality(is_open, true)
end

T["Minimap"]["minimap deferral and notification for large files"] = function()
  -- Create a temporary large file on disk with > 500 lines
  local f = io.open("temp_large_file.lua", "w")
  for i = 1, 600 do
    f:write("local a = " .. i .. "\n")
  end
  f:close()
  
  -- Open the file (triggers BufEnter on loading the already large file)
  child.api.nvim_command("edit temp_large_file.lua")
  
  -- Settle state, clear any prior notifications
  child.lua("require('mini.notify').clear()")
  
  -- Force trigger BufEnter to simulate entering a >500 line buffer
  child.api.nvim_exec_autocmds("BufEnter", { buffer = 0 })
  
  -- Verify that the "Generating minimap" notification is created
  local notif_created = child.lua([[
    local notifs = require('mini.notify').get_all()
    for _, n in ipairs(notifs) do
      if n.msg:find("Generating minimap") then
        return true
      end
    end
    return false
  ]])
  MiniTest.expect.equality(notif_created, true)
  
  -- Now, wait for the deferral (50ms + some buffer time)
  child.api.nvim_command("sleep 100m")
  
  -- Verify minimap is opened after the delay
  local is_open_after = child.lua_get("#MiniMap.current.win_data > 0")
  MiniTest.expect.equality(is_open_after, true)
  
  -- Verify that the notification was updated/completed to "Minimap generated! [Done]"
  local notif_completed = child.lua([[
    local notifs = require('mini.notify').get_all()
    for _, n in ipairs(notifs) do
      if n.msg:find("Minimap generated") then
        return true
      end
    end
    return false
  ]])
  MiniTest.expect.equality(notif_completed, true)
  
  -- Cleanup
  os.remove("temp_large_file.lua")
end

return T
