local SERVER_NAME = "rust_analyzer"
local default_config = require("r-okm.lsp.config").get_default_config(SERVER_NAME)
local deep_table_concat = require("r-okm.util").deep_table_concat

return deep_table_concat(default_config, {
  setup_args = {
    settings = {
      ["rust-analyzer"] = {
        check = {
          command = "clippy",
        },
      },
    },
  },
  buffer_config = {
    format_enable = true,
    buf_write_pre_enable = true,
  },
})
