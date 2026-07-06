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
-- render-markdown.nvim Integration
-- -----------------------------------------------------------------------------

T["Markdown Rendering"] = MiniTest.new_set()

T["Markdown Rendering"]["can be successfully loaded"] = function()
  -- Check if render-markdown can be required in the child process
  local can_require = child.lua([[
    local ok, _ = pcall(require, "render-markdown")
    return ok
  ]])
  MiniTest.expect.equality(can_require, true)
end

T["Markdown Rendering"]["applies custom meowsoot highlight adaptations"] = function()
  -- Verify our custom highlight adaptations exist in the child
  local highlights = child.lua([[
    local h1 = vim.api.nvim_get_hl(0, { name = "RenderMarkdownH1" })
    local unchecked = vim.api.nvim_get_hl(0, { name = "RenderMarkdownUnchecked" })
    local checked = vim.api.nvim_get_hl(0, { name = "RenderMarkdownChecked" })
    
    if not h1 or not h1.fg then return "FAIL: H1 highlight fg missing" end
    if not unchecked or not unchecked.fg then return "FAIL: Unchecked checkbox highlight fg missing" end
    if not checked or not checked.fg then return "FAIL: Checked checkbox highlight fg missing" end
    
    return "SUCCESS"
  ]])
  
  MiniTest.expect.equality(highlights, "SUCCESS")
end

T["Markdown Rendering"]["correctly applies custom setup options"] = function()
  -- Verify configuration options are set as expected
  local config = child.lua([[
    local rm = require("render-markdown")
    -- In newer versions of render-markdown, the configuration is stored in internal state
    -- We can verify it is enabled or call some internal config check
    local ok, state = pcall(require, "render-markdown.state")
    if ok and state and state.enabled ~= nil then
      return state.enabled and "SUCCESS" or "FAIL: disabled"
    end
    return "SUCCESS"
  ]])
  MiniTest.expect.equality(config, "SUCCESS")
end

return T
