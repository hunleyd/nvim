-- =============================================================================
-- Plugin: nvim-lspconfig
-- =============================================================================

--- Language Server Protocol (LSP) configuration
---
--- This module configures Neovim's built-in LSP client using `nvim-lspconfig`.
--- It integrates with `mini.completion` for code intelligence and routes
--- diagnostics through the project's floating notification system.
--- @tag lsp

local M = {}

-- Load the plugin using the built-in package manager.
vim.pack.add({
  {
    name = "nvim-lspconfig",
    src = "https://github.com/neovim/nvim-lspconfig",
  },
  {
    name = "mason.nvim",
    src = "https://github.com/williamboman/mason.nvim",
  },
  {
    name = "mason-lspconfig.nvim",
    src = "https://github.com/williamboman/mason-lspconfig.nvim",
  },
})

-- -----------------------------------------------------------------------------
-- Diagnostic Configuration (High-Fidelity)
-- -----------------------------------------------------------------------------

-- Configure diagnostics to align with the 'meowsoot' aesthetic:
-- - Globally disable inline virtual text (managed dynamically per-line instead).
-- - Use icons in the sign column.
vim.diagnostic.config({
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN]  = "󰀪 ",
      [vim.diagnostic.severity.INFO]  = "󰋽 ",
      [vim.diagnostic.severity.HINT]  = "󰌶 ",
    },
  },
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focused = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- Intercept open_float to dynamically format spelling diagnostics on-demand
local diag_float_win = nil
local original_open_float = vim.diagnostic.open_float
vim.diagnostic.open_float = function(bufnr, opts)
  opts = opts or {}
  local original_format = opts.format
  opts.format = function(diagnostic)
    local msg = original_format and original_format(diagnostic) or diagnostic.message
    if diagnostic.source == "Spell" then
      local bad_word = msg:match("Spelling error: '([^']+)'")
      if bad_word then
        local suggestions = vim.fn.spellsuggest(bad_word, 5)
        if #suggestions > 0 then
          msg = msg .. " -> " .. table.concat(suggestions, ", ")
        end
      end
    end
    return msg
  end
  local float_bufnr, winid = original_open_float(bufnr, opts)
  diag_float_win = winid
  return float_bufnr, winid
end

-- -----------------------------------------------------------------------------
-- LSP Handlers & Redirection
-- -----------------------------------------------------------------------------

-- Route LSP progress and messages through mini.notify via vim.notify.
-- Note: mini.notify already has a built-in LSP progress handler, so we 
-- primarily ensure window/showMessage is captured.
vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local title = client and string.format(" LSP (%s) ", client.name) or " LSP "
  vim.notify(result.message, result.type, { title = title })
end

-- -----------------------------------------------------------------------------
-- LSP Attach (Keybindings & Integration)
-- -----------------------------------------------------------------------------

--- Set up buffer-local LSP features when a server attaches
--- @private
local on_attach = function(client, bufnr)
  -- 1. Enable completion triggered by LSP.
  -- We dynamically set whichever source_func is configured in mini.completion
  -- (either 'completefunc' or 'omnifunc') to completefunc_lsp to avoid configuration mismatches.
  local ok_minicomplete, minicomplete = pcall(require, "mini.completion")
  local source_func = ok_minicomplete and minicomplete.config.lsp_completion.source_func or "completefunc"
  vim.bo[bufnr][source_func] = "v:lua.MiniCompletion.completefunc_lsp"

  -- 2. Standard LSP Mappings
  local opts = { buffer = bufnr }
  
  -- Navigation
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Go to Definition", buffer = bufnr })
  vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "LSP: Show References", buffer = bufnr })
  vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "LSP: Go to Implementation", buffer = bufnr })
  vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "LSP: Type Definition", buffer = bufnr })
  
  -- Information
  vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover Documentation", buffer = bufnr })
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "LSP: Signature Help", buffer = bufnr })
  
  -- Editing
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename Symbol", buffer = bufnr })
  vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code Action", buffer = bufnr })
  vim.keymap.set("n", "<leader>f", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
  end, { desc = "Format Buffer", buffer = bufnr })

  -- 3. Diagnostic Navigation
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "LSP: Prev Diagnostic", buffer = bufnr })
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "LSP: Next Diagnostic", buffer = bufnr })
  vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "LSP: Open Diagnostic List", buffer = bufnr })
end

-- Register the global LspAttach autocmd
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    on_attach(client, ev.buf)
  end,
})

-- -----------------------------------------------------------------------------
-- Cursor Line Diagnostic Redraw
-- -----------------------------------------------------------------------------

-- Force redraw of diagnostics on cursor line changes. Since we globally disable
-- inline virtual text to prevent screen clutter, we maintain a dedicated namespace
-- ('CurrentLineDiagnosticsVText') that dynamically captures and displays virtual text with
-- a lightbulb icon ('󰌶 ') ONLY for the active cursor line on the fly.
local current_line_ns = vim.api.nvim_create_namespace("CurrentLineDiagnosticsVText")
local lsp_diag_group = vim.api.nvim_create_augroup("LspCurrentLineDiagnostics", { clear = true })
local last_line = -1
local is_updating_vtext = false

local function update_current_line_vtext()
  if is_updating_vtext then return end
  is_updating_vtext = true

  local ok, err = pcall(function()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].buftype ~= "" then
      return
    end

    local ok_win, current_win = pcall(vim.api.nvim_get_current_win)
    if not ok_win then return end

    local ok_cursor, cursor = pcall(vim.api.nvim_win_get_cursor, current_win)
    if not ok_cursor then return end

    local current_line = cursor[1] - 1

    -- Get all diagnostics on the current cursor line across all namespaces
    local diags = vim.diagnostic.get(bufnr, { lnum = current_line })
    local filtered_diags = {}
    for _, d in ipairs(diags) do
      if d.namespace ~= current_line_ns then
        local msg = d.message
        if d.source == "Spell" then
          local bad_word = msg:match("Spelling error: '([^']+)'")
          if bad_word then
            local suggestions = vim.fn.spellsuggest(bad_word, 5)
            if #suggestions > 0 then
              msg = msg .. " -> " .. table.concat(suggestions, ", ")
            end
          end
        end

        table.insert(filtered_diags, {
          bufnr = bufnr,
          lnum = d.lnum,
          col = d.col,
          end_col = d.end_col,
          severity = d.severity,
          message = msg,
          source = "CurrentLineDiag",
        })
      end
    end

    -- Clear previous current line virtual text
    vim.diagnostic.set(current_line_ns, bufnr, {})

    -- Close active diagnostic float window if no diagnostics are left on the current line
    if #filtered_diags == 0 then
      if diag_float_win and vim.api.nvim_win_is_valid(diag_float_win) then
        pcall(vim.api.nvim_win_close, diag_float_win, true)
        diag_float_win = nil
      end
    end

    -- Set the new virtual text diagnostics ONLY for the active line
    if #filtered_diags > 0 then
      vim.diagnostic.set(current_line_ns, bufnr, filtered_diags, {
        virtual_text = {
          prefix = "󰌶 ", -- Lightbulb icon matching the gutter sign
          spacing = 4,   -- Sane spacing from the end of the line
        },
        signs = false,     -- Disable duplicate signs
        underline = false, -- Disable duplicate underlines
      })
    end
  end)

  is_updating_vtext = false
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "DiagnosticChanged" }, {
  group = lsp_diag_group,
  callback = function(ev)
    if is_updating_vtext then
      return
    end

    local ok_win, current_win = pcall(vim.api.nvim_get_current_win)
    if ok_win then
      local ok_cursor, cursor = pcall(vim.api.nvim_win_get_cursor, current_win)
      if ok_cursor then
        local current_line = cursor[1]
        if ev.event == "DiagnosticChanged" then
          update_current_line_vtext()
        elseif current_line ~= last_line or vim.v.event.changedtick then
          last_line = current_line
          update_current_line_vtext()
        end
      end
    end
  end,
})

-- Auto-open diagnostic floating window on CursorHold
vim.api.nvim_create_autocmd("CursorHold", {
  group = lsp_diag_group,
  callback = function()
    -- Only show if we are in normal mode and there's no active popup menu (completion)
    if vim.api.nvim_get_mode().mode == "n" and vim.fn.pumvisible() == 0 then
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == "" then
        -- Open float window dynamically. Focusable is false so cursor doesn't jump in.
        pcall(vim.diagnostic.open_float, nil, { focusable = false, scope = "cursor" })
      end
    end
  end,
})


-- -----------------------------------------------------------------------------
-- Server Configurations
-- -----------------------------------------------------------------------------

-- Capabilities for mini.completion
local capabilities = {}
local ok_completion, mini_completion = pcall(require, "mini.completion")
if ok_completion then
  capabilities = mini_completion.get_lsp_capabilities()
end

--- Configure a language server
--- @param name string: Server name (must be known by lspconfig)
--- @param config table|nil: Optional server-specific settings
M.setup_server = function(name, config)
  config = config or {}
  config.capabilities = vim.tbl_deep_extend("force", capabilities, config.capabilities or {})
  
  -- Neovim 0.11+ style: use built-in vim.lsp functions
  -- lspconfig provides the default configurations for these names.
  vim.lsp.config(name, config)
end

-- -----------------------------------------------------------------------------
-- Mason Integration
-- -----------------------------------------------------------------------------

--- Set up Mason and its LSP integration
---
--- @private
local ok_mason, mason = pcall(require, "mason")
local ok_mason_lsp, mason_lsp = pcall(require, "mason-lspconfig")

if ok_mason and ok_mason_lsp then
  mason.setup({
    ui = {
      border = "rounded",
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
      }
    }
  })

  -- Configure the server via our wrapper
  M.setup_server("lua_ls", {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    }
  })

  -- Set up mason-lspconfig to ensure installation and automatically enable
  mason_lsp.setup({
    ensure_installed = { "lua_ls" }, -- Example default
    automatic_enable = true,
  })
else
  -- Fallback: Enable lua_ls if available on the system but Mason is not present
  M.setup_server("lua_ls", {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  })
  
  if vim.fn.executable("lua-language-server") == 1 then
    vim.lsp.enable("lua_ls")
  end
end

return M
