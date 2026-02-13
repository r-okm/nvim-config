---@type LazyPluginSpec
return {
  "https://github.com/sainnhe/gruvbox-material",
  enabled = false,
  config = function()
    vim.o.background = "dark"
    vim.g.gruvbox_material_background = "medium"
    vim.g.gruvbox_material_disable_italic_comment = 1
    vim.g.gruvbox_material_diagnostic_text_highlight = 1
    vim.cmd([[colorscheme gruvbox-material]])
  end,
}
