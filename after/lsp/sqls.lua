local util = require("r-okm.util")

return {
  cmd = { "sqls", "-config", util.get_project_nvim_config_dir() .. "/sqls.config.yml" },
  on_attach = function(client, bufnr)
    require("sqls").on_attach(client, bufnr)
  end,
}
