return {
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
}
