return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    { "davidmh/cspell.nvim" },
    { "Joakker/lua-json5", name = "json5", build = "./install.sh" },
  },
  lazy = false,
  config = function()
    local nls = require("null-ls")
    local formatting = nls.builtins.formatting
    local diagnostics = nls.builtins.diagnostics

    -- https://github.com/davidmh/cspell.nvim/blob/2c29bf573292c8f5053383d1be4ab908f4ecfc47/lua/cspell/helpers.lua#L7-L13
    local CSPELL_CONFIG_FILES = {
      "cspell.json",
      ".cspell.json",
      "cSpell.json",
      ".cSpell.json",
      ".cspell.config.json",
    }

    local cspell_config = {
      diagnostics_postprocess = function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity["HINT"] -- ERROR, WARN, INFO, HINT
      end,
      condition = function(utils)
        return utils.root_has_file(CSPELL_CONFIG_FILES)
      end,
      config = {
        config_file_preferred_name = ".cspell.json",
        cspell_config_dirs = { "." },
        decode_json = require("json5").parse,
      },
    }

    local cspell = require("cspell")
    nls.setup({
      -- diagnostics_format = "#{m} (#{s}: #{c})",
      sources = {
        cspell.code_actions.with(cspell_config),
        cspell.diagnostics.with(cspell_config),
        formatting.prettierd.with({
          prefer_local = "node_modules/.bin",
        }),
        formatting.stylua,
        diagnostics.cfn_lint,
        diagnostics.hadolint,
        diagnostics.markdownlint,
      },
    })
  end,
}
