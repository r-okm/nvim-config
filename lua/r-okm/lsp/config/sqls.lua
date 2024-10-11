local SERVER_NAME = "sqls"
local default_config = require("r-okm.lsp.config").get_default_config(SERVER_NAME)
local deep_table_concat = require("r-okm.util").deep_table_concat

return deep_table_concat(default_config, {
  setup_args = {
    cmd = { "sqls", "-config", vim.loop.cwd() .. "/.nvim/sqls.config.yml" },
    on_attach = function(client, bufnr)
      require("sqls").on_attach(client, bufnr)
    end,
  },
  buffer_config = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
})
