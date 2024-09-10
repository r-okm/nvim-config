return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "jay-babu/mason-null-ls.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local nls = require("null-ls")
    local formatting = nls.builtins.formatting
    local diagnostics = nls.builtins.diagnostics

    nls.setup({
      -- diagnostics_format = "#{m} (#{s}: #{c})",
      sources = {
        formatting.prettierd.with({
          prefer_local = "node_modules/.bin",
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/prettier/.prettierrc.json"),
          },
        }),
        formatting.stylua,
        diagnostics.cfn_lint,
        diagnostics.hadolint,
        diagnostics.markdownlint,
      },
    })
  end,
}
