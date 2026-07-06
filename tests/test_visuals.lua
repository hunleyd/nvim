local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "tests/minimal_init.lua" })
      -- Aggressively disable anything that might draw in the child UI
      child.lua([[
        vim.opt.laststatus = 0
        vim.opt.showmode = false
        vim.opt.ruler = false
        vim.opt.number = true
        vim.opt.relativenumber = false
        -- Disable statuscol specifically for this visual test to avoid gutter rendering issues
        vim.opt.statuscolumn = ""
        pcall(vim.api.nvim_del_augroup_by_name, 'StarterStatusline')
        pcall(vim.api.nvim_del_augroup_by_name, 'NumberToggle')
        pcall(require, 'mini.map'); if MiniMap then MiniMap.close(); MiniMap.setup({ enabled = false }) end
        pcall(require, 'mini.notify'); if MiniNotify then MiniNotify.clear() end
      ]])
    end,
    post_once = function()
      child.stop()
    end,
  },
})

-- -----------------------------------------------------------------------------
-- Tabline Visuals (Screenshot Testing)
-- -----------------------------------------------------------------------------

T["Tabline Visuals"] = MiniTest.new_set()

T["Tabline Visuals"]["matches reference exactly"] = function()
  -- Setup a standard state
  child.api.nvim_command("enew")
  child.api.nvim_buf_set_name(0, "active.lua")
  child.api.nvim_command("enew")
  child.api.nvim_buf_set_name(0, "dirty.lua")
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "modified" })
  child.api.nvim_command("enew")
  child.api.nvim_buf_set_name(0, "clean.lua")
  
  -- Force tabline visible
  child.api.nvim_set_option("showtabline", 2)
  
  -- Final cleanup
  child.lua("require('mini.notify').clear()")
  
  -- Use screenshot testing to verify the entire TUI state of the tabline
  -- Note: We only check the first line (the tabline itself)
  MiniTest.expect.reference_screenshot(child.get_screenshot({ lines = { 1, 1 } }))
end

return T
