return {
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
}
