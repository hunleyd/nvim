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
-- Spelling & vim-dirtytalk Integration
-- -----------------------------------------------------------------------------

T["Spelling"] = MiniSet or MiniTest.new_set()

T["Spelling"]["enables spelling and sets en_us by default"] = function()
  -- Check the global default for spell checking
  local spell = child.lua_get("vim.go.spell")
  MiniTest.expect.equality(spell, true)

  -- Check that updatetime is responsive (300ms)
  local updatetime = child.lua_get("vim.go.updatetime")
  MiniTest.expect.equality(updatetime, 300)

  -- Since programming spell file is isolated and not in the test child's standard runtimepath,
  -- the global spelllang should only contain "en_us"
  local spelllang = child.lua_get("vim.go.spelllang")
  local has_programming = spelllang:find("programming") ~= nil
  MiniTest.expect.equality(has_programming, false)
end

T["Spelling"]["dynamically adds programming to spelllang on PackChanged event"] = function()
  -- Append the project's config directory to the child's runtimepath.
  -- This allows the child to locate autoload/spellfile.vim (the compatibility bridge) on demand.
  child.lua([[
    vim.opt.runtimepath:append(vim.fn.expand("~/.config/nvim"))
  ]])

  -- Trigger PackChanged for vim-dirtytalk. This will load the real command and compile it.
  child.lua([[
    vim.api.nvim_exec_autocmds("User", {
      pattern = "PackChanged",
      data = {
        kind = "install",
        spec = { name = "vim-dirtytalk" }
      }
    })
  ]])

  -- Verify that "programming" has been added to spelllang
  local spelllang = child.lua_get("vim.go.spelllang")
  local has_programming = spelllang:find("programming") ~= nil
  
  if not has_programming then
    -- If it fails, capture messages/errors to aid debugging
    local msgs = child.cmd_capture("messages")
    error("Failed to add programming spell language. Messages: " .. tostring(msgs))
  end

  MiniTest.expect.equality(has_programming, true)
end

T["Spelling"]["configures leader-p-z keymap for spell suggestions"] = function()
  -- Verify that <leader>pz is mapped to pick spell suggestions in normal mode
  -- Since mapleader is set to Space, <leader>pz resolves to " pz"
  local maparg = child.lua_get("vim.fn.maparg('<leader>pz', 'n')")
  MiniTest.expect.equality(maparg ~= "", true)

  -- Query nvim_get_keymap to inspect the description of the mapping
  local keymap = child.api.nvim_get_keymap("n")
  local found_mapping = nil
  for _, map in ipairs(keymap) do
    if map.lhs == " pz" then
      found_mapping = map
      break
    end
  end

  MiniTest.expect.equality(found_mapping ~= nil, true)
  MiniTest.expect.equality(found_mapping.desc, "Pick Spell Suggestions")
end

T["Spelling"]["generates spelling diagnostics on the fly for misspelled words"] = function()
  -- Create a new buffer and enable spelling on BOTH windows to prevent FFI active/inactive mismatches
  child.api.nvim_command("new")
  child.lua("vim.wo.spell = true")
  child.lua("pcall(vim.api.nvim_win_set_option, 1000, 'spell', true)")
  
  -- Insert some misspelled words
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "thiss is a misspeltone word" })
  
  -- Sleep to let Neovim's asynchronous spelling engine parse the buffer first
  child.api.nvim_command("sleep 100m")
  
  -- Now force trigger BufEnter to run spelling diagnostics synchronously
  child.api.nvim_exec_autocmds("BufEnter", { buffer = 0 })
  
  -- Query the diagnostics for the current buffer
  local diags = child.lua([[
    local res = {}
    for _, d in ipairs(vim.diagnostic.get(0)) do
      if d.source == "Spell" then
        table.insert(res, d)
      end
    end
    return res
  ]])
  
  -- We expect to find the spelling diagnostics for "misspeltone"
  local found_misspelt = false
  for _, diag in ipairs(diags) do
    if diag.message:find("misspeltone") then
      found_misspelt = true
    end
  end
  
  MiniTest.expect.equality(found_misspelt, true)
end

T["Spelling"]["zg and zw keys update dictionary and instantly refresh diagnostics"] = function()
  -- Create a new buffer and enable spelling on BOTH windows to prevent FFI active/inactive mismatches
  child.api.nvim_command("new")
  child.lua("vim.wo.spell = true")
  child.lua("pcall(vim.api.nvim_win_set_option, 1000, 'spell', true)")
  
  -- Insert a misspelled word "misspeltone"
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "misspeltone" })
  
  -- Sleep to let Neovim's asynchronous spelling engine parse the buffer first
  child.api.nvim_command("sleep 100m")
  
  -- Now force trigger BufEnter to run spelling diagnostics synchronously
  child.api.nvim_exec_autocmds("BufEnter", { buffer = 0 })
  
  -- Verify the diagnostic is present initially
  local diags_before = child.lua([[
    local res = {}
    for _, d in ipairs(vim.diagnostic.get(0)) do
      if d.source == "Spell" then
        table.insert(res, d)
      end
    end
    return res
  ]])
  MiniTest.expect.equality(#diags_before, 1)
  
  -- Place cursor on the misspelled word (line 1, column 1)
  child.api.nvim_win_set_cursor(0, { 1, 0 })
  
  -- Trigger the 'zg' key mapping
  child.api.nvim_feedkeys("zg", "mx", true)
  
  -- Verify that the diagnostic has been instantly cleared on the fly!
  local diags_after = child.lua([[
    local res = {}
    for _, d in ipairs(vim.diagnostic.get(0)) do
      if d.source == "Spell" then
        table.insert(res, d)
      end
    end
    return res
  ]])
  MiniTest.expect.equality(#diags_after, 0)
  
  -- Cleanup (use 'zug' to undo adding "misspeltone" so we don't pollute the dictionary!)
  child.api.nvim_feedkeys("zug", "mx", true)
end

T["Spelling"]["switching buffers correctly updates and displays spelling diagnostics"] = function()
  -- Create buffer 1 with a misspelled word and enable spelling on both windows
  child.api.nvim_command("new buffer1.lua")
  child.lua("vim.wo.spell = true")
  child.lua("pcall(vim.api.nvim_win_set_option, 1000, 'spell', true)")
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "misspeltone" })
  
  -- Settle and force diagnostics
  child.api.nvim_command("sleep 100m")
  child.api.nvim_exec_autocmds("BufEnter", { buffer = 0 })

  -- Create buffer 2 with another misspelled word and enable spelling on both windows
  child.api.nvim_command("new buffer2.lua")
  child.lua("vim.wo.spell = true")
  child.lua("pcall(vim.api.nvim_win_set_option, 1000, 'spell', true)")
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "misspeltone" })
  
  -- Settle and force diagnostics
  child.api.nvim_command("sleep 100m")
  child.api.nvim_exec_autocmds("BufEnter", { buffer = 0 })

  -- Switch back to buffer 1 (using :bprevious or [b simulation)
  child.api.nvim_command("bprevious")
  
  -- Settle and force diagnostics
  child.api.nvim_command("sleep 100m")
  child.api.nvim_exec_autocmds("BufEnter", { buffer = 0 })

  -- Verify spelling diagnostics are present in the active buffer
  local diags = child.lua([[
    local res = {}
    for _, d in ipairs(vim.diagnostic.get(0)) do
      if d.source == "Spell" then
        table.insert(res, d)
      end
    end
    return res
  ]])
  MiniTest.expect.equality(#diags, 1)
end

return T
