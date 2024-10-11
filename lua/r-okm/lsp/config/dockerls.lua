local SERVER_NAME = "dockerls"
local default_config = require("r-okm.lsp.config").get_default_config(SERVER_NAME)
local deep_table_concat = require("r-okm.util").deep_table_concat

return deep_table_concat(default_config, {
  buffer_config = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
})
