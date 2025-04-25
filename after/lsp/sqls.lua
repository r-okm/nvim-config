return {
  cmd = { "sqls", "-config", vim.loop.cwd() .. "/.nvim/sqls.config.yml" },
  on_attach = function(client, bufnr)
    require("sqls").on_attach(client, bufnr)
  end,
}
