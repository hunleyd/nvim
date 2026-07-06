-- =============================================================================
-- Plugin: pearofducks/ansible-vim
-- =============================================================================

--- Ansible syntax highlighting and intelligent filetype detection
---
--- Integrates `pearofducks/ansible-vim` to provide robust filetype detection
--- and syntax capabilities for Ansible playbooks, tasks, variables,
--- Jinja2 templates, and hosts files.
--- @tag plugins.ansible

-- Add pearofducks/ansible-vim to managed packages
vim.pack.add({
  {
    name = "ansible-vim",
    src = "https://github.com/pearofducks/ansible-vim",
  },
})

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- Enable highlighting of extra Ansible keywords (e.g., become, become_user, tags).
vim.g.ansible_extra_keywords_highlight = 1

-- Configure attribute key=value highlighting.
-- "ob" means: highlight on newlines only ("o"), brighten ("b").
vim.g.ansible_attribute_highlight = "ob"

-- Dim the common task 'name:' labels.
-- This reduces visual noise and draws your eye directly to the functional modules.
vim.g.ansible_name_highlight = "d"

-- Reset indentation completely after pressing Enter twice in insert mode.
-- Extremely helpful when writing nested lists in YAML.
vim.g.ansible_unindent_after_newline = 1

-- Map custom templates suffixes to their target syntax language.
-- When editing matching files (e.g., *.sh.j2), Neovim will combine
-- Jinja2 and Shell syntax highlighting.
vim.g.ansible_template_syntaxes = {
  ["*.rb.j2"] = "ruby",
  ["*.sh.j2"] = "sh",
  ["*.conf.j2"] = "config",
  ["*.json.j2"] = "json",
  ["*.xml.j2"] = "xml",
}
