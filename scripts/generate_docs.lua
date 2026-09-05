local function generate()
  local mini_doc = require('mini.doc')
  
  -- Define the files to process
  local files = {
    'lua/core/packs.lua',
    'lua/plugins/tabline.lua',
    'lua/plugins/mini.lua',
    'lua/plugins/treesitter.lua',
    'lua/plugins/lsp.lua',
    'lua/plugins/hardtime.lua',
    'lua/plugins/spellfile.lua',
    'lua/plugins/markdown.lua',
    'lua/plugins/ansible.lua',
    'lua/plugins/yaml-revealer.lua',
    'lua/plugins/yankbank.lua',
    'lua/plugins/cmdline.lua',
    'lua/plugins/statuscolumn.lua',
    'lua/plugins/hlsearch_lens.lua',
  }
  
  -- Generate the help file
  mini_doc.generate(files, 'doc/myconfig.txt', {
    annotation_extractor = function(l)
      local f, t, id = string.find(l, '^%-%-%-%s*(@%S*) ?')
      if f then return f, t, id end
      return string.find(l, '^%-%-%-(%S*) ?')
    end,
    write_post = function()
      vim.cmd('helptags doc/')
    end
  })
  
  io.stdout:write("Documentation generated in doc/myconfig.txt\n")
end

generate()
vim.cmd('qa')
