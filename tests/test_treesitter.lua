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
-- nvim-treesitter & Textobjects Integration
-- -----------------------------------------------------------------------------

T["Treesitter"] = MiniTest.new_set()

T["Treesitter"]["enables highlighting and textobjects"] = function()
  -- Verify that TS highlighting is active
  child.api.nvim_command("edit lua/plugins/treesitter.lua")
  local has_ts = child.lua_get([[
    vim.wait(5000, function()
      return vim.treesitter.get_parser() ~= nil
    end)
  ]])
  MiniTest.expect.equality(has_ts, true)

  -- Check module availability
  local can_require = child.lua_get("pcall(require, 'nvim-treesitter-textobjects.select')")
  MiniTest.expect.equality(can_require, true)
end

T["Treesitter"]["PackTSUpdate command exists"] = function()
  -- Try to see if it's there after a short wait
  local exists = child.lua_get([[
    vim.wait(1000, function()
        return vim.fn.exists(':PackTSUpdate') == 2
    end)
  ]])
  MiniTest.expect.equality(exists, true)
end

T["Treesitter"]["Repeatable Moves override ; and ,"] = function()
  -- Use child.lua_get directly, but we need to wait because TS might do this async or on attach
  -- Actually, in our config, we call setup_repeatable_moves() right away, but it
  -- might fail if the parser isn't ready. Let's force it to load.
  
  local res = child.lua([[
    -- Force load
    require('plugins.treesitter')
    -- Wait for mappings to settle
    vim.wait(500, function() return vim.fn.maparg(';', 'n') ~= '' end)
    
    local semi = vim.fn.maparg(';', 'n')
    local comma = vim.fn.maparg(',', 'n')
    local next_diag = vim.fn.maparg(']d', 'n')
    
    if semi == '' then return "FAIL: ; mapping missing" end
    if comma == '' then return "FAIL: , mapping missing" end
    if next_diag == '' then return "FAIL: ]d mapping missing" end
    
    return "SUCCESS"
  ]])
  
  MiniTest.expect.equality(res, "SUCCESS")
end

T["Treesitter"]["vim.treesitter.select is provided in Neovim v0.12.3"] = function()
  local has_select = child.lua_get("type(vim.treesitter.select) == 'function'")
  MiniTest.expect.equality(has_select, true)
end

return T
