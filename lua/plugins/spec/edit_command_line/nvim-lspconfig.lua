---@type LazyPluginSpec
return {
  "https://github.com/neovim/nvim-lspconfig",
  branch = "master",
  dependencies = {
    { "https://github.com/yioneko/nvim-vtsls" },
    { "https://github.com/b0o/schemastore.nvim" },
    { "https://github.com/mfussenegger/nvim-jdtls" }, -- ftplugin/java で使用
    { "https://github.com/nanotee/sqls.nvim" },
  },
  lazy = false,
}
