return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    { "jay-babu/mason-null-ls.nvim" },
    { "davidmh/cspell.nvim" },
    { "Joakker/lua-json5", name = "json5", build = "./install.sh" },
  },
  event = { "BufReadPost" },
  config = function()
    local nls = require("null-ls")
    local formatting = nls.builtins.formatting
    local diagnostics = nls.builtins.diagnostics

    local cspell = require("cspell")
    local cspell_config = {
      diagnostics_postprocess = function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity["HINT"] -- ERROR, WARN, INFO, HINT
      end,
      config = {
        find_json = function(_)
          -- find project local cspell.json or use global cspell.json
          -- TODO: check file existence
          return vim.fn.expand(".cspell.json") or vim.fn.expand("~/.config/cspell/cspell.json")
        end,
        decode_json = require("json5").parse,
      },
    }

    nls.setup({
      -- diagnostics_format = "#{m} (#{s}: #{c})",
      sources = {
        cspell.code_actions.with(cspell_config),
        cspell.diagnostics.with(cspell_config),
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
