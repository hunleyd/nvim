# Neovim Configuration Project Instructions

- **Target Version**: Neovim v0.12+ with UI2 support.
- **Package Management**: Use built-in `vim.pack`.
- **Modularity**: Place logic in `lua/core/` and individual plugin configurations in `lua/plugins/`.
- **Documentation**: Heavily comment all changes with "why" and "how".
- **Git**: Commit every change with a descriptive message.
- **Visual Consistency**: All UI elements, highlight groups, and color adjustments **MUST** align with the `meowsoot` colorscheme.
- **Error Resolution**: For every error encountered, you **MUST**:
    1.  Perform a thorough Root Cause Analysis (RCA).
    2.  Empirically replicate the failure state.
    3.  Verify that the proposed fix actually resolves the issue before committing.
