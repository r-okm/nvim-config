local deep_table_concat = require("r-okm.util").deep_table_concat
local default_config = require("r-okm.lsp.config").get_default_config("vtsls")

return deep_table_concat(default_config, {
  setup_args = {
    settings = {
      vtsls = {
        autoUseWorkspaceTsdk = true,
        experimental = {
          completion = {
            enableServerSideFuzzyMatch = true,
          },
        },
      },
      typescript = {
        preferences = {
          importModuleSpecifierPreference = "non-relative",
          importModuleSpecifier = "non-relative",
        },
      },
    },
    on_attach = function(_, bufnr)
      vim.keymap.set("n", "go", function()
        local vtsls = require("vtsls")
        vtsls.commands.add_missing_imports(bufnr)
        vtsls.commands.organize_imports(bufnr)
      end, { buffer = bufnr })
    end,
  },
  buffer_config = {
    format_enable = false,
    buf_write_pre_enable = true,
    buf_write_pre_callback = function()
      pcall(function()
        vim.cmd("EslintFixAll")
      end)
      vim.lsp.buf.format({
        async = false,
        filter = function(format_client)
          return format_client.name == "null-ls"
        end,
      })
    end,
  },
})
