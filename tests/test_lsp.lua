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
-- LSP Integration
-- -----------------------------------------------------------------------------

T["LSP"] = MiniTest.new_set()

T["LSP"]["plugin is loadable and configured"] = function()
  -- Check if nvim-lspconfig is in runtimepath
  local has_lspconfig = child.lua_get("pcall(require, 'lspconfig')")
  MiniTest.expect.equality(has_lspconfig, true)

  -- Check if our custom setup function is available
  local has_setup = child.lua_get("pcall(require, 'plugins.lsp')")
  MiniTest.expect.equality(has_setup, true)
end

T["LSP"]["diagnostics are configured for high-fidelity"] = function()
  local config = child.lua_get("vim.diagnostic.config()")
  MiniTest.expect.equality(config.virtual_text, false)
  MiniTest.expect.equality(config.underline, true)
end

T["LSP"]["LspAttach group exists"] = function()
  local exists = child.lua_get("vim.fn.exists('#UserLspConfig') == 1")
  MiniTest.expect.equality(exists, true)
end

T["LSP"]["mason plugins are loadable"] = function()
  local has_mason = child.lua_get("pcall(require, 'mason')")
  MiniTest.expect.equality(has_mason, true)
  
  local has_mason_lsp = child.lua_get("pcall(require, 'mason-lspconfig')")
  MiniTest.expect.equality(has_mason_lsp, true)
end

return T
