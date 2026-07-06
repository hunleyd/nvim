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
-- Status Column Integration
-- -----------------------------------------------------------------------------

T["Statuscol"] = MiniTest.new_set()

T["Statuscol"]["plugin is loadable and configured"] = function()
  -- The plugin is required and sets vim.o.statuscolumn
  local has_statuscol = child.lua_get("pcall(require, 'statuscol')")
  MiniTest.expect.equality(has_statuscol, true)
  
  -- Test setting it manually if it wasn't set globally by the setup
  local stc = child.lua_get("vim.o.statuscolumn")
  if stc == nil or stc == "" then
     child.lua("require('statuscol').setup({})")
     stc = child.lua_get("vim.o.statuscolumn")
  end
  
  MiniTest.expect.equality(stc ~= "", true)
end

T["Statuscol"]["separator highlight exists"] = function()
  -- Check our custom highlight
  local hl = child.lua_get("vim.api.nvim_get_hl(0, { name = 'StatusColSeparator' })")
  MiniTest.expect.equality(hl.fg ~= nil, true)
end

T["Statuscol"]["renders extmark-based diff signs in the gutter"] = function()
  -- Create a new buffer and set lines
  child.api.nvim_command("new")
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "local a = 1" })
  local win_id = child.api.nvim_get_current_win()
  
  -- Create namespaces simulating MiniDiffViz and diagnostic/spelling extmarks
  local diff_ns = child.lua_get("vim.api.nvim_create_namespace('MiniDiffViz')")
  local diag_ns = child.lua_get("vim.api.nvim_create_namespace('diagnostic/signs')")
  
  -- Place an extmark sign simulating mini_diff's '+' (add) sign on line 1
  -- Neovim's extmark sign options: sign_text = "+", sign_hl_group = "MiniDiffSignAdd"
  child.lua([[
    local ns_id, win_id = ...
    vim.api.nvim_buf_set_extmark(0, ns_id, 0, 0, {
      sign_text = "+",
      sign_hl_group = "MiniDiffSignAdd",
    })
  ]], { diff_ns, win_id })

  -- Place an extmark sign simulating a diagnostic spelling '*' sign on the same line
  child.lua([[
    local ns_id, win_id = ...
    vim.api.nvim_buf_set_extmark(0, ns_id, 0, 0, {
      sign_text = "*",
      sign_hl_group = "DiagnosticSignHint",
    })
  ]], { diag_ns, win_id })
  
  -- Evaluate the statuscolumn format string for line 1 of our window
  local stc_format = child.lua_get("vim.o.statuscolumn")
  local rendered = child.lua([[
    local stc, win_id = ...
    vim.v.lnum = 1
    return vim.api.nvim_eval_statusline(stc, { winid = win_id }).str
  ]], { stc_format, win_id })
  
  -- We expect that BOTH the '+' (git) sign and the '*' (diagnostic) sign are rendered!
  local has_diff_sign = rendered:find("+", 1, true) ~= nil
  local has_diag_sign = rendered:find("*", 1, true) ~= nil
  
  if not has_diff_sign or not has_diag_sign then
    error(string.format(
      "STATUSCOL COEXISTENCE RENDER FAIL:\n" ..
      "  Rendered statuscolumn: '%s'\n" ..
      "  has_diff: %s, has_diag: %s\n" ..
      "  stc format: '%s'",
      rendered, tostring(has_diff_sign), tostring(has_diag_sign), stc_format
    ))
  end
  
  MiniTest.expect.equality(has_diff_sign, true)
  MiniTest.expect.equality(has_diag_sign, true)
end

return T
