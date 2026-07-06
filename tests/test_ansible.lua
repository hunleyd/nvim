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
-- pearofducks/ansible-vim Integration
-- -----------------------------------------------------------------------------

T["Ansible"] = MiniTest.new_set()

T["Ansible"]["applies configured global variables"] = function()
  -- Check that global options are set correctly on startup
  local extra_kw = child.lua_get("vim.g.ansible_extra_keywords_highlight")
  local attr_hl = child.lua_get("vim.g.ansible_attribute_highlight")
  local name_hl = child.lua_get("vim.g.ansible_name_highlight")
  local unindent = child.lua_get("vim.g.ansible_unindent_after_newline")
  
  MiniTest.expect.equality(extra_kw, 1)
  MiniTest.expect.equality(attr_hl, "ob")
  MiniTest.expect.equality(name_hl, "d")
  MiniTest.expect.equality(unindent, 1)
end

T["Ansible"]["detects ansible playbooks and tasks files correctly"] = function()
  -- Trigger filetype detection for a standard playbook file
  child.cmd("edit /tmp/playbook.yml")
  local ft = child.lua_get("vim.bo.filetype")
  MiniTest.expect.equality(ft, "ansible")

  -- Trigger filetype detection for a main playbook
  child.cmd("edit /tmp/main.yaml")
  local ft_main = child.lua_get("vim.bo.filetype")
  MiniTest.expect.equality(ft_main, "ansible")

  -- Trigger filetype detection for a nested task file
  child.cmd("edit /tmp/roles/web/tasks/main.yml")
  local ft_task = child.lua_get("vim.bo.filetype")
  MiniTest.expect.equality(ft_task, "ansible")
end

T["Ansible"]["detects ansible templates and maps syntax correctly"] = function()
  -- Trigger filetype detection for a j2 shell template
  child.cmd("edit /tmp/test.sh.j2")
  local ft = child.lua_get("vim.bo.filetype")
  MiniTest.expect.equality(ft, "sh.jinja2")

  -- Trigger filetype detection for a j2 ruby template
  child.cmd("edit /tmp/test.rb.j2")
  local ft_rb = child.lua_get("vim.bo.filetype")
  MiniTest.expect.equality(ft_rb, "ruby.jinja2")
end

return T
