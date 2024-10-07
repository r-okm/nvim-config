local deep_table_concat = require("r-okm.util").deep_table_concat
local default_config = require("r-okm.lsp.config").get_default_config("lemminx")

return deep_table_concat(default_config, {
  buffer_config = {
    format_enable = true,
    buf_write_pre_enable = false,
  },
})
