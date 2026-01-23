---@type LazyPluginSpec
return {
  "nvimtools/none-ls.nvim",
  lazy = false,
  config = function()
    local nls = require("null-ls")
    local formatting = nls.builtins.formatting
    local diagnostics = nls.builtins.diagnostics

    nls.setup({
      -- diagnostics_format = "#{m} (#{s}: #{c})",
      sources = {
        formatting.clang_format,
        formatting.prettierd.with({
          prefer_local = "node_modules/.bin",
        }),
        diagnostics.cfn_lint,
        diagnostics.hadolint,
      },
    })
  end,
}
