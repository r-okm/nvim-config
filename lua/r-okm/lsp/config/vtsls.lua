local SERVER_NAME = "vtsls"
local default_config = require("r-okm.lsp.config").get_default_config(SERVER_NAME)
local deep_table_concat = require("r-okm.util").deep_table_concat

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
      end, { buffer = bufnr })
    end,
  },
  buffer_config = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
})
