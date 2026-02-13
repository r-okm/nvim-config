---@type LazyPluginSpec
return {
  "https://github.com/vim-denops/denops-shared-server.vim",
  cmd = { "DenopsSharedServerInstall", "DenopsSharedServerUninstall" },
  config = function()
    local function install()
      vim.cmd(":call denops_shared_server#install()")
    end
    local function uninstall()
      vim.cmd(":call denops_shared_server#uninstall()")
    end

    vim.api.nvim_create_user_command("DenopsSharedServerInstall", install, { desc = "denops: Install shared server" })
    vim.api.nvim_create_user_command(
      "DenopsSharedServerUninstall",
      uninstall,
      { desc = "denops: Uninstall shared server" }
    )
  end,
}
