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
-- Einenlum/yaml-revealer Integration
-- -----------------------------------------------------------------------------

T["Yaml Revealer"] = MiniTest.new_set()

T["Yaml Revealer"]["applies configured global variables"] = function()
  -- Check that global options are set correctly on startup
  local separator = child.lua_get("vim.g.yaml_revealer_separator")
  local display_mode = child.lua_get("vim.g.yaml_revealer_display_mode")
  local current_key = child.lua_get("vim.g.yaml_revealer_include_current_key")
  local list_items = child.lua_get("vim.g.yaml_revealer_list_item_names")
  local max_width = child.lua_get("vim.g.yaml_revealer_max_width")
  
  MiniTest.expect.equality(separator, " › ")
  MiniTest.expect.equality(display_mode, "virtual")
  MiniTest.expect.equality(current_key, 1)
  MiniTest.expect.equality(list_items, 1)
  MiniTest.expect.equality(max_width, 80)
end

T["Yaml Revealer"]["defines helper functions on startup"] = function()
  -- Open a YAML file to trigger the ftplugin and load the helper functions
  child.cmd("edit /tmp/test.yaml")

  -- Check that standard Vimscript helper functions exist
  local exists_statusline = child.lua_get("vim.fn.exists('*YamlRevealerStatusLine')")
  MiniTest.expect.equality(exists_statusline, 1)
end

return T
