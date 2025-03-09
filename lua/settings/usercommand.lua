-- ヘルプコマンドを垂直分割で表示する
local function openHelpVertically(opts)
  local command = string.format("vertical help %s", opts.args)
  vim.cmd(command)
end
vim.api.nvim_create_user_command(
  "H",
  openHelpVertically,
  { nargs = 1, complete = "help", desc = "Alias for 'vertical help'" }
)
