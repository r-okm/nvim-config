vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = {
    "[tj]sconfig*.json",
    "*/.vscode/*.json",
    "*/.devcontainer/*.json",
    ".eslintrc.json",
    "*cspell.json",
  },
  callback = function()
    vim.bo.filetype = "jsonc"
  end,
})
