local SERVER_NAME = "eslint"
local default_config = require("r-okm.lsp.config").get_default_config(SERVER_NAME)
local deep_table_concat = require("r-okm.util").deep_table_concat

return deep_table_concat(default_config, {
  setup_args = {
    on_attach = function(_, bufnr)
      vim.keymap.set("n", "ge", function()
        vim.cmd.EslintFixAllAsync()
      end, { buffer = bufnr })
    end,
  },
  buffer_config = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
})
