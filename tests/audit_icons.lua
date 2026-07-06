
local function audit()
  local lines = {}
  local ok_icons, icons = pcall(require, "mini.icons")
  if ok_icons then
    table.insert(lines, "UI icons:")
    for _, name in ipairs({"branch", "git", "diff", "error", "warn", "info", "hint"}) do
        local icon, hl = icons.get("ui", name)
        table.insert(lines, string.format("%s: %s (%s)", name, icon, hl))
    end
    
    table.insert(lines, "LSP icons:")
    for _, name in ipairs({"Error", "Warning", "Information", "Hint"}) do
        local icon, hl = icons.get("lsp", name)
        table.insert(lines, string.format("%s: %s (%s)", name, icon, hl))
    end
  end
  
  local f = io.open("icons_output.txt", "w")
  if f then
    f:write(table.concat(lines, "\n"))
    f:close()
  end
end

audit()
vim.cmd("qa")
