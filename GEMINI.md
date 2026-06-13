# Neovim Configuration Project Instructions

- **Target Version**: Neovim v0.12+ with UI2 support.
- **Package Management**: Use built-in `vim.pack`.
- **Modularity**: Place logic in `lua/core/` and individual plugin configurations in `lua/plugins/`.
- **Visual Consistency**: All UI elements, highlight groups, and color adjustments **MUST** align with the `meowsoot` colorscheme.
- **Message Handling**: All messages (handled via `print` and `vim.notify`) **MUST** be routed through the transient floating popup system (`Utils.notify`).
- **Module Reviews**: When adding new `mini.nvim` modules, you **MUST** review `mini.extra` to see if there are any complementary features (like pickers or textobjects) that should be enabled and present them for approval.
