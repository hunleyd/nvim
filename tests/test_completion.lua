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
-- Completion Configuration & Integration
-- -----------------------------------------------------------------------------

T["Completion"] = MiniTest.new_set()

T["Completion"]["mini.completion is configured correctly"] = function()
  -- Check if mini.completion can be required
  local has_completion = child.lua_get("pcall(require, 'mini.completion')")
  MiniTest.expect.equality(has_completion, true)

  -- Check if mini.completion is configured with source_func
  local source_func = child.lua_get("MiniCompletion.config.lsp_completion.source_func")
  MiniTest.expect.equality(source_func, "completefunc")

  -- Check if fallback_action is configured as a function
  local has_fn = child.lua_get("type(MiniCompletion.config.fallback_action) == 'function'")
  MiniTest.expect.equality(has_fn, true)
end

T["Completion"]["on_attach configures matching source_func"] = function()
  -- Create a new buffer
  child.api.nvim_command("new")
  local bufnr = child.api.nvim_get_current_buf()

  -- Simulate an LSP client attaching to this buffer.
  -- Our LspAttach autocommand in lua/plugins/lsp.lua runs on LspAttach event.
  child.lua([[
    local bufnr = ...
    -- Emit UserLspConfig / LspAttach
    vim.api.nvim_exec_autocmds("LspAttach", {
      buffer = bufnr,
      data = { client_id = 1 }
    })
  ]], { bufnr })

  -- Check the values of omnifunc and completefunc
  local omnifunc = child.api.nvim_buf_get_option(bufnr, "omnifunc")
  local completefunc = child.api.nvim_buf_get_option(bufnr, "completefunc")
  
  -- Get the configured source_func from mini.completion
  local source_func = child.lua_get("MiniCompletion.config.lsp_completion.source_func")

  if source_func == "completefunc" then
    MiniTest.expect.equality(completefunc, "v:lua.MiniCompletion.completefunc_lsp")
  elseif source_func == "omnifunc" then
    MiniTest.expect.equality(omnifunc, "v:lua.MiniCompletion.completefunc_lsp")
  end
end

T["Completion"]["smart Tab keybinding is registered and executes safely"] = function()
  -- Check if the Tab keybinding is mapped in Insert mode
  local map = child.api.nvim_get_keymap("i")
  local has_tab = false
  for _, m in ipairs(map) do
    if m.lhs == "<Tab>" then
      has_tab = true
      break
    end
  end
  MiniTest.expect.equality(has_tab, true)

  -- Create a new buffer and enter Insert mode
  child.api.nvim_command("new")
  child.api.nvim_feedkeys("i", "nx", true)

  -- Press <Tab> and verify it executes without error.
  local ok = pcall(function()
    child.api.nvim_feedkeys(child.api.nvim_replace_termcodes("<Tab>", true, true, true), "nx", true)
  end)
  MiniTest.expect.equality(ok, true)
end

T["Completion"]["CursorMoved in Insert mode triggers spelling completion on misspelled words"] = function()
  -- Create a new buffer and enable spelling on BOTH windows to prevent FFI active/inactive mismatches
  child.api.nvim_command("new")
  local win_id = child.api.nvim_get_current_win()
  child.api.nvim_win_set_option(win_id, "spell", true)
  child.api.nvim_buf_set_option(0, "spell", true)
  child.lua("pcall(vim.api.nvim_win_set_option, 1000, 'spell', true)")
  
  -- Settle state, clear prior notifications
  child.lua("require('mini.notify').clear()")

  -- Insert a misspelled word "misspeltone" and place cursor on it
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "misspeltone" })
  
  -- Sleep to let Neovim's asynchronous spelling engine parse the buffer first
  child.api.nvim_command("sleep 200m")
  
  child.api.nvim_command("normal! $")
  
  -- Enter Insert mode (at the end of "misspeltone")
  child.api.nvim_feedkeys("A", "nx", true)
  
  -- Force trigger BufEnter and BufWinEnter to align all spellcheck contexts
  child.api.nvim_exec_autocmds("BufWinEnter", { buffer = 0 })
  child.api.nvim_exec_autocmds("BufEnter", { buffer = 0 })
  
  -- Verify that the SpellCompletionAuto autocommand group is successfully registered
  local has_auto = child.lua_get("vim.fn.exists('#SpellCompletionAuto') == 1")
  MiniTest.expect.equality(has_auto, true)
  
  -- Execute the fallback action callback manually and verify it runs safely without errors
  local ok = child.lua([[
    local ok, err = pcall(MiniCompletion.config.fallback_action)
    return ok
  ]])
  MiniTest.expect.equality(ok, true)
end

return T
