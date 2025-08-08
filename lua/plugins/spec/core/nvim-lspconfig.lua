---@type LazyPluginSpec
return {
  "neovim/nvim-lspconfig",
  branch = "master",
  dependencies = {
    { "yioneko/nvim-vtsls" },
    { "b0o/schemastore.nvim" },
    { "mfussenegger/nvim-jdtls" }, -- ftplugin/java で使用
    { "nanotee/sqls.nvim" },
  },
  lazy = false,
}
