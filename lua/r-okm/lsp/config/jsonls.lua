local deep_table_concat = require("r-okm.util").deep_table_concat
local default_config = require("r-okm.lsp.config").get_default_config("jsonls")

return deep_table_concat(default_config, {
  setup_args = {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = {
          enable = true,
        },
      },
    },
  },
  buffer_config = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
})
