--- Tests for native search lens functionality (replacing nvim-hlslens).
--- Verifies extmark rendering, count indexing, clearing on cursor movement,
--- and cross-buftype resilience using isolated child Neovim processes.

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
-- SearchLens Test Suite
-- ---------------------------------------------------------------------------
T["SearchLens"] = MiniTest.new_set()

T["SearchLens"]["displays extmark with match count on search navigation"] = function()
  child.lua([[
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "first match target",
      "second match target",
      "third match target",
    })
    vim.fn.setreg('/', 'match')
    vim.v.hlsearch = 1
    vim.api.nvim_win_set_cursor(0, { 1, 6 })

    local lens = require("plugins.hlsearch_lens")
    lens.show()
  ]])

  local extmarks = child.lua_get("vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace('hlsearch_lens'), 0, -1, { details = true })")

  MiniTest.expect.equality(#extmarks, 1)
  local virt_text = extmarks[1][4].virt_text[1][1]
  MiniTest.expect.equality(virt_text, " [1/3]")
end

T["SearchLens"]["updates match index when jumping with n and N"] = function()
  child.lua([[
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "item one",
      "item two",
      "item three",
    })
    vim.fn.setreg('/', 'item')
    vim.v.hlsearch = 1
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    require("plugins.hlsearch_lens")
    vim.cmd("normal! n")
    require("plugins.hlsearch_lens").show()
  ]])

  local virt_text = child.lua_get("vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace('hlsearch_lens'), 0, -1, { details = true })[1][4].virt_text[1][1]")
  MiniTest.expect.equality(virt_text, " [2/3]")

  -- Jump backward with N
  child.lua([[
    vim.cmd("normal! N")
    require("plugins.hlsearch_lens").show()
  ]])

  local virt_text_prev = child.lua_get("vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace('hlsearch_lens'), 0, -1, { details = true })[1][4].virt_text[1][1]")
  MiniTest.expect.equality(virt_text_prev, " [1/3]")
end

T["SearchLens"]["clears extmark when clear() is called"] = function()
  child.lua([[
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "match here" })
    vim.fn.setreg('/', 'match')
    vim.v.hlsearch = 1
    local lens = require("plugins.hlsearch_lens")
    lens.show()
    lens.clear()
  ]])

  local count = child.lua_get("#vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace('hlsearch_lens'), 0, -1, {})")
  MiniTest.expect.equality(count, 0)
end

T["SearchLens"]["clears extmark on cursor movement away from match"] = function()
  child.lua([[
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "match on line 1",
      "no match on line 2",
    })
    vim.fn.setreg('/', 'match')
    vim.v.hlsearch = 1
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    local lens = require("plugins.hlsearch_lens")
    lens.show()
    -- Move cursor to line 2
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
    vim.api.nvim_exec_autocmds("CursorMoved", { buffer = 0 })
  ]])

  local count = child.lua_get("#vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace('hlsearch_lens'), 0, -1, {})")
  MiniTest.expect.equality(count, 0)
end

T["SearchLens"]["works across different buftypes gracefully"] = function()
  child.lua([[
    -- Test in a nofile buffer
    local nofile_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[nofile_buf].buftype = "nofile"
    vim.api.nvim_set_current_buf(nofile_buf)
    vim.api.nvim_buf_set_lines(nofile_buf, 0, -1, false, { "test line" })
    local lens = require("plugins.hlsearch_lens")
    lens.show()
    lens.clear()

    -- Test in a terminal buffer
    local term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_term(term_buf, {})
    vim.api.nvim_set_current_buf(term_buf)
    _G.term_show_result = lens.show()
    lens.clear()
  ]])

  local ok = child.lua_get([[type(require("plugins.hlsearch_lens")) == "table"]])
  MiniTest.expect.equality(ok, true)

  local is_nil = child.lua_get("_G.term_show_result == nil")
  MiniTest.expect.equality(is_nil, true)

  local term_marks = child.lua_get("#vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace('hlsearch_lens'), 0, -1, {})")
  MiniTest.expect.equality(term_marks, 0)
end

return T
