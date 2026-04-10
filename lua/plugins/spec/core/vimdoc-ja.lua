---@type LazyPluginSpec
return {
  "https://github.com/vim-jp/vimdoc-ja",
  branch = "master",
  init = function(plugin)
    local docs = plugin.dir .. "/doc"
    vim.api.nvim_create_autocmd("User", {
      pattern = { "LazySyncPre", "LazyUpdatePre", "LazyInstallPre" },
      callback = function()
        vim.fn.system({ "git", "-C", plugin.dir, "restore", "doc/tags-ja" })
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = { "LazySync", "LazyUpdate", "LazyInstall" },
      callback = function()
        vim.cmd.helptags(docs)
      end,
    })
  end,
}
