-- ヘルプコマンドを垂直分割で表示する
local function openHelpVertically(opts)
  local command = string.format("vertical help %s", opts.args)
  vim.cmd(command)
end
vim.api.nvim_create_user_command("HelpVertical", openHelpVertically, { nargs = 1, complete = "help" })
vim.keymap.set("ca", "H", "HelpVertical")

-- プラグインを表示する
local function printPlugins()
  vim.print(vim.tbl_keys(require("lazy.core.config").plugins))
end
vim.api.nvim_create_user_command("PrintPlugins", printPlugins, {})
vim.keymap.set("ca", "PP", "PrintPlugins")
