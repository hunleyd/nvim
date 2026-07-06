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
-- Statusline Visibility & Hide/Show Behavior
-- -----------------------------------------------------------------------------

T["Statusline"] = MiniTest.new_set()

T["Statusline"]["hides on starter and shows globally on other buffers"] = function()
  -- 1. Verify that laststatus is initially hidden (0) because Neovim starts on the starter dashboard
  local laststatus_initial = child.lua_get("vim.o.laststatus")
  MiniTest.expect.equality(laststatus_initial, 0)

  -- 2. Create a regular buffer and ensure laststatus is restored to 3 (global statusline)
  child.api.nvim_command("new test_file.lua")
  local laststatus_regular = child.lua_get("vim.o.laststatus")
  MiniTest.expect.equality(laststatus_regular, 3)

  -- 3. Open the starter screen and verify laststatus is hidden (0)
  child.lua("require('mini.starter').open()")
  local laststatus_starter = child.lua_get("vim.o.laststatus")
  MiniTest.expect.equality(laststatus_starter, 0)

  -- 4. Leave the starter buffer (create a new regular buffer) and ensure laststatus is restored to 3
  child.api.nvim_command("new another_file.txt")
  local laststatus_after = child.lua_get("vim.o.laststatus")
  MiniTest.expect.equality(laststatus_after, 3)

  -- 5. Re-open starter (simulates re-entrance / pressing <leader>s) and verify laststatus becomes 0
  child.lua("require('mini.starter').open()")
  local laststatus_reopen = child.lua_get("vim.o.laststatus")
  MiniTest.expect.equality(laststatus_reopen, 0)

  -- 6. Leave once more and verify laststatus is successfully restored back to 3 (re-entrance safety check!)
  child.api.nvim_command("new final_file.md")
  local laststatus_final = child.lua_get("vim.o.laststatus")
  MiniTest.expect.equality(laststatus_final, 3)
end

T["Statusline"]["shows globally on startup when opening a file directly"] = function()
  -- Restart the child with a file argument
  child.restart({ "-u", "tests/minimal_init.lua", "startup_file.lua" })
  
  -- Verify that laststatus is 3 (global statusline)
  local laststatus_startup = child.lua_get("vim.o.laststatus")
  MiniTest.expect.equality(laststatus_startup, 3)
end

T["Statusline"]["PackUpdate command updates the plugin update timestamp file"] = function()
  -- Define the state path
  local state_path = child.lua_get("vim.fn.stdpath('state') .. '/plugin_update_time'")
  
  -- Delete the file if it exists to ensure a clean test state
  os.remove(state_path)
  
  -- Open starter screen in child and check that the initial item says "Never" or does not say "Just now"
  child.lua("require('mini.starter').open()")
  
  local before_lines = child.api.nvim_buf_get_lines(0, 0, -1, false)
  local found_just_now_before = false
  for _, line in ipairs(before_lines) do
    if line:find("Just now") then
      found_just_now_before = true
    end
  end
  MiniTest.expect.equality(found_just_now_before, false)
  
  -- Execute the PackUpdate user command
  -- This should write the timestamp and immediately refresh the starter dashboard on the fly!
  child.api.nvim_command("PackUpdate")
  
  -- Verify the file exists now
  local post_exists = child.lua_get("vim.fn.filereadable(vim.fn.stdpath('state') .. '/plugin_update_time') == 1")
  MiniTest.expect.equality(post_exists, true)
  
  -- Verify that the displayed text on the starter dashboard now instantly shows "(Just now)" on the fly!
  local after_lines = child.api.nvim_buf_get_lines(0, 0, -1, false)
  local found_just_now_after = false
  for _, line in ipairs(after_lines) do
    if line:find("Just now") then
      found_just_now_after = true
    end
  end
  MiniTest.expect.equality(found_just_now_after, true)
  
  -- Cleanup
  os.remove(state_path)
end

return T
