return {
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
}
