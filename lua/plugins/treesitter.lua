-- =============================================================================
-- Plugin: nvim-treesitter
-- =============================================================================

--- Tree-sitter configurations and abstraction layer
---
--- nvim-treesitter provides a simple way to use the Tree-sitter library in 
--- Neovim, offering high-fidelity syntax highlighting and structural understanding.
--- @tag treesitter

local M = {}

-- Load the plugin and its extensions using the built-in package manager.
vim.pack.add({
  {
    name = "nvim-treesitter",
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
  },
  {
    name = "nvim-treesitter-textobjects",
    src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  },
})

-- Register the global LspAttach autocmd (handled in lsp.lua, but we configure TS here)

-- -----------------------------------------------------------------------------
-- Repeatable Moves (Demicolon behavior)
-- -----------------------------------------------------------------------------

--- Configure repeatable moves
---
--- Uses the `repeatable_move` module from `nvim-treesitter-textobjects` to 
--- overload `;` and `,`. This allows repeating structural jumps (like `]m`)
--- and diagnostic jumps just like character searches.
--- @private
local function setup_repeatable_moves()
  local ok, ts_repeat_move = pcall(require, "nvim-treesitter-textobjects.repeatable_move")
  if not ok then return end

  -- Repeat movement with ; and ,
  -- ensure ; goes forward and , goes backward regardless of the last direction
  vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
  vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

  -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
  -- (We use mini.jump for 1D jumping, but this ensures TS doesn't fight it)
  vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
  vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
  vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
  vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

  -- Make diagnostic jumps repeatable
  local next_diagnostic = ts_repeat_move.make_repeatable_move(function()
    vim.diagnostic.goto_next()
  end)
  local prev_diagnostic = ts_repeat_move.make_repeatable_move(function()
    vim.diagnostic.goto_prev()
  end)
  
  -- The wrapper needs to handle the 'opts' table that make_repeatable_move passes
  local goto_next_diag = function() next_diagnostic({ forward = true }) end
  local goto_prev_diag = function() prev_diagnostic({ forward = false }) end

  vim.keymap.set("n", "]d", goto_next_diag, { desc = "Next Diagnostic" })
  vim.keymap.set("n", "[d", goto_prev_diag, { desc = "Prev Diagnostic" })
end

-- -----------------------------------------------------------------------------
-- Configuration
-- -----------------------------------------------------------------------------

-- Configure treesitter and its extensions.
-- NOTE: We use the 'nvim-treesitter.config' module as 'configs' is not found
-- in this version of the plugin.
local ok, ts_config = pcall(require, "nvim-treesitter.config")
if ok then
  ts_config.setup({
    -- A list of parser names, or "all"
    ensure_installed = { 
      "lua", 
      "vim", 
      "vimdoc", 
      "markdown", 
      "markdown_inline",
      "bash",
      "python",
      "json",
      "yaml",
    },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    auto_install = true,

    highlight = {
      -- Enable high-fidelity treesitter-based highlighting.
      enable = true,

      -- Use meowsoot's colors.
      -- meowsoot supports treesitter out of the box, but we ensure it's enabled here.
      additional_vim_regex_highlighting = false,
    },
    
    -- Smart indentation based on tree-sitter.
    indent = {
      enable = true,
    },

    -- Extension: nvim-treesitter-textobjects
    -- Provides structural code manipulation (select, move, swap).
    --- @tag treesitter-textobjects
    textobjects = {
      select = {
        enable = true,
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        keymaps = {
          -- f: Function
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          -- c: Class
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          -- l: Loop
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",
          -- i: Conditional (if/else)
          ["ai"] = "@conditional.outer",
          ["ii"] = "@conditional.inner",
          -- p: Parameter
          ["ap"] = "@parameter.outer",
          ["ip"] = "@parameter.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>a"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>A"] = "@parameter.inner",
        },
      },
    },
  })
  
  -- Setup repeatable moves
  setup_repeatable_moves()
else
  vim.notify("Could not load nvim-treesitter.config", vim.log.levels.ERROR)
end

return M
