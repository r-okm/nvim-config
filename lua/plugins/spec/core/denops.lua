---@type LazyPluginSpec
return {
  "https://github.com/vim-denops/denops.vim",
  lazy = false,
  config = function()
    vim.cmd("let g:denops_server_addr = '127.0.0.1:32123'")
  end,
}
