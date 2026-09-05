--- Tests for native tabout functionality (replacing abecodes/tabout.nvim).
--- Verifies delimiter navigation in Insert mode, boundary detection,
--- multistep integration, and buffer matrix resilience using isolated child Neovim processes.

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

-- ---------------------------------------------------------------------------
-- Tabout Test Suite
-- ---------------------------------------------------------------------------
T["Tabout"] = MiniTest.new_set()

T["Tabout"]["can_tabout_forward detects closing delimiters on current line"] = function()
  child.lua([[
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "local x = (1 + 2)",
      "local y = 3",
    })
    vim.api.nvim_win_set_cursor(0, { 1, 14 })
    vim.cmd("startinsert")
  ]])

  local can_forward = child.lua_get([[require("plugins.tabout").can_tabout_forward()]])
  MiniTest.expect.equality(can_forward, true)

  -- Move cursor to line with no closing delimiters
  child.lua([[
    vim.api.nvim_win_set_cursor(0, { 2, 5 })
  ]])
  local can_forward_none = child.lua_get([[require("plugins.tabout").can_tabout_forward()]])
  MiniTest.expect.equality(can_forward_none, false)
end

T["Tabout"]["tabout_forward jumps past closing delimiters sequentially"] = function()
  child.lua([[
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      'local msg = foo("bar")',
    })
    -- Position inside "bar": row 1, col 18 (at 'r')
    vim.api.nvim_win_set_cursor(0, { 1, 18 })
    vim.cmd("startinsert")

    local tabout = require("plugins.tabout")
    local act1 = tabout.tabout_forward()
    act1()
  ]])

  -- In 'local msg = foo("bar")', 'r' is col 18, closing quote is col 19, ')' is col 20.
  -- After 1st tabout, cursor should be at col 20 (past quote)
  local cursor1 = child.lua_get("vim.api.nvim_win_get_cursor(0)")
  MiniTest.expect.equality(cursor1[1], 1)
  MiniTest.expect.equality(cursor1[2], 20)

  -- After 2nd tabout, cursor should be at col 21 (past ')')
  child.lua([[
    local tabout = require("plugins.tabout")
    local act2 = tabout.tabout_forward()
    act2()
  ]])
  local cursor2 = child.lua_get("vim.api.nvim_win_get_cursor(0)")
  MiniTest.expect.equality(cursor2[1], 1)
  MiniTest.expect.equality(cursor2[2], 21)
end

T["Tabout"]["can_tabout_backward and tabout_backward jump before opening delimiters"] = function()
  child.lua([[
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      'local msg = foo("bar")',
    })
    -- Position past closing ')': row 1, col 21
    vim.api.nvim_win_set_cursor(0, { 1, 21 })
    vim.cmd("startinsert")
  ]])

  local can_back = child.lua_get([[require("plugins.tabout").can_tabout_backward()]])
  MiniTest.expect.equality(can_back, true)

  child.lua([[
    local tabout = require("plugins.tabout")
    local act = tabout.tabout_backward()
    act()
  ]])

  -- Should jump before closing quote: col 19
  local cursor = child.lua_get("vim.api.nvim_win_get_cursor(0)")
  MiniTest.expect.equality(cursor[1], 1)
  MiniTest.expect.equality(cursor[2], 19)
end

T["Tabout"]["multistep <Tab> and <S-Tab> key integration in Insert mode"] = function()
  child.lua([[
    require("plugins.mini")
    local tabout = require("plugins.tabout")
    local mk = require("mini.keymap")

    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      'print("test")',
    })
    -- Set cursor inside "test" (at 't')
    vim.api.nvim_win_set_cursor(0, { 1, 10 })
  ]])

  -- Enter insert mode and type <Tab>
  child.type_keys("i", "<Tab>")
  local col_after_tab1 = child.lua_get("vim.api.nvim_win_get_cursor(0)[2]")
  MiniTest.expect.equality(col_after_tab1, 12) -- after quote

  -- Type <Tab> again
  child.type_keys("<Tab>")
  local col_after_tab2 = child.lua_get("vim.api.nvim_win_get_cursor(0)[2]")
  MiniTest.expect.equality(col_after_tab2, 13) -- after ')'

  -- Type <S-Tab> to step back
  child.type_keys("<S-Tab>")
  local col_after_stab = child.lua_get("vim.api.nvim_win_get_cursor(0)[2]")
  MiniTest.expect.equality(col_after_stab, 12) -- before ')'
end

T["Tabout"]["matrix: handles terminal and nofile buffers gracefully"] = function()
  child.lua([[
    local tabout = require("plugins.tabout")

    -- 1. nofile buffer: should work normally
    local nofile_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(nofile_buf)
    vim.api.nvim_buf_set_lines(nofile_buf, 0, -1, false, { "(active)" })
    vim.api.nvim_win_set_cursor(0, { 1, 3 })
    vim.cmd("startinsert")
    _G.nofile_can_forward = tabout.can_tabout_forward()

    -- 2. terminal buffer: should return false and not error
    local term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(term_buf)
    vim.api.nvim_open_term(term_buf, {})
    vim.api.nvim_buf_set_lines(term_buf, 0, -1, false, { "(terminal)" })
    vim.api.nvim_win_set_cursor(0, { 1, 3 })
    vim.cmd("startinsert")
    _G.term_can_forward = tabout.can_tabout_forward()
  ]])

  local nofile_ok = child.lua_get("_G.nofile_can_forward")
  local term_ok = child.lua_get("_G.term_can_forward")

  MiniTest.expect.equality(nofile_ok, true)
  MiniTest.expect.equality(term_ok, false)
end

return T
