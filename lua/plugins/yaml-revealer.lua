-- =============================================================================
-- Plugin: Einenlum/yaml-revealer
-- =============================================================================

--- Real-time YAML hierarchy detection and nested key lookup
---
--- Displays the full hierarchical path of the YAML key under your cursor
--- in real-time, making navigation of deeply nested playbooks, hosts,
--- and YAML files incredibly easy.
--- @tag plugins.yaml_revealer

-- Add Einenlum/yaml-revealer to managed packages
vim.pack.add({
  {
    name = "yaml-revealer",
    src = "https://github.com/Einenlum/yaml-revealer",
  },
})

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- Separator used between keys in the nested path string.
vim.g.yaml_revealer_separator = " › "

-- Display mode.
-- "virtual" displays the path as subtle virtual text at the end of the line.
-- "echo" prints the path in the command area at the bottom.
vim.g.yaml_revealer_display_mode = "virtual"

-- Include the key under the cursor in the displayed path.
vim.g.yaml_revealer_include_current_key = 1

-- Include list indices in the path (e.g. users[0] instead of users[]).
vim.g.yaml_revealer_list_item_names = 1

-- Truncate paths to prevent layout overflow ("Press ENTER" prompts).
-- Set to 0 to disable truncation completely.
vim.g.yaml_revealer_max_width = 80
