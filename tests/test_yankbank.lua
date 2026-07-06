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
-- ptdewey/yankbank-nvim Integration
-- -----------------------------------------------------------------------------

T["YankBank"] = MiniTest.new_set()

T["YankBank"]["can be successfully loaded"] = function()
  -- Check if sqlite and yankbank can be loaded in the child
  local sqlite_ok = child.lua([[
    local ok, _ = pcall(require, "sqlite")
    return ok
  ]])
  MiniTest.expect.equality(sqlite_ok, true)

  local yankbank_ok = child.lua([[
    local ok, _ = pcall(require, "yankbank")
    return ok
  ]])
  MiniTest.expect.equality(yankbank_ok, true)
end

T["YankBank"]["configures leader-p-y keymap and command"] = function()
  -- Verify the command exists
  local has_cmd = child.lua_get("vim.fn.exists(':YankBank')")
  MiniTest.expect.equality(has_cmd, 2) -- 2 means command exists

  -- Verify the keymap <leader>py exists
  local maparg = child.lua_get("vim.fn.maparg('<leader>py', 'n')")
  MiniTest.expect.equality(maparg ~= "", true)

  -- Query nvim_get_keymap to inspect details
  local keymap = child.api.nvim_get_keymap("n")
  local found_mapping = nil
  for _, map in ipairs(keymap) do
    if map.lhs == " py" then
      found_mapping = map
      break
    end
  end

  MiniTest.expect.equality(found_mapping ~= nil, true)
  MiniTest.expect.equality(found_mapping.desc, "Pick Yank (YankBank)")
end

T["YankBank"]["creates and writes to sqlite db successfully upon yanking"] = function()
  -- Settle state, get the correct expected db path
  local db_file = child.lua_get("vim.fn.stdpath('data') .. '/yankbank.db'")
  
  -- Clear any existing yankbank.db file in child environment to ensure a clean write test
  os.remove(db_file)
  
  -- Verify the file does not exist
  local initial_exists = child.lua_get("vim.fn.filereadable(vim.fn.stdpath('data') .. '/yankbank.db') == 1")
  MiniTest.expect.equality(initial_exists, false)
  
  -- Create a new buffer, yank some text, triggering TextYankPost
  child.api.nvim_command("new")
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "YankMeTest123" })
  child.api.nvim_command("normal! yy")
  
  -- Verify that TextYankPost executes successfully and sqlite.lua writes the database file
  child.api.nvim_command("sleep 100m")
  
  local final_exists = child.lua_get("vim.fn.filereadable(vim.fn.stdpath('data') .. '/yankbank.db') == 1")
  MiniTest.expect.equality(final_exists, true)
  
  -- Cleanup the created db file so we leave a pristine test state
  os.remove(db_file)
end

return T
