-- LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("r-okm.LspAttach", {}),
  callback = require("r-okm.lsp.handler").on_lsp_attach,
})

-- terminal mode hook
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function(_)
    -- set nonumber
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "yes"
    -- start insert mode
    vim.cmd("startinsert")
  end,
})

-- yaml.docker-compose filetype を設定する
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "docker-compose.yaml", "docker-compose.yml", "compose.yaml", "compose.yml" },
  callback = function()
    vim.bo.filetype = "yaml.docker-compose"
  end,
})
