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
-- mini.fuzzy & mini.completion Integration
-- -----------------------------------------------------------------------------

T["Fuzzy Completion"] = MiniTest.new_set()

T["Fuzzy Completion"]["fuzzy-filters completion items"] = function()
  local res = child.lua([[
    local fuzzy = require('mini.fuzzy')
    
    local mock_items = {
      { label = 'apple' },
      { label = 'banana' },
      { label = 'apricot' },
      { label = 'cherry' }
    }
    
    local result_ap = fuzzy.process_lsp_items(mock_items, 'ap')
    if #result_ap ~= 2 then return 'FAIL size ap: ' .. #result_ap end
    
    local result_ao = fuzzy.process_lsp_items(mock_items, 'ao')
    if #result_ao ~= 1 then return 'FAIL size ao: ' .. #result_ao end
    
    return 'SUCCESS'
  ]])
  
  MiniTest.expect.equality(res, 'SUCCESS')
end

return T
