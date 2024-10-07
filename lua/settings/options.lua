vim.opt.clipboard = "unnamedplus"
vim.opt.whichwrap = "b,s,h,l,<,>,~,[,]"
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.o.termguicolors = true
vim.opt.list = true
vim.opt.listchars = { tab = "»-", trail = "●", space = " " }
vim.opt.fillchars = vim.opt.fillchars + "diff: "
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.signcolumn = "yes"
vim.opt.splitright = true

-- os のクリップボードと同期
local yank_command = os.getenv("YANK_COMMAND")
local paste_command = os.getenv("PASTE_COMMAND")
vim.g.clipboard = {
  name = "osClipboard",
  copy = {
    ["+"] = yank_command,
    ["*"] = yank_command,
  },
  paste = {
    ["+"] = paste_command,
    ["*"] = paste_command,
  },
  cache_enable = 0,
}

-- diagnostics
local signs = {
  Error = " ",
  Warn = " ",
  Info = " ",
  Hint = " ",
}
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local function diagnostic_formatter(diagnostic)
  return string.format("[%s] %s (%s)", diagnostic.message, diagnostic.source, diagnostic.code)
end
vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  underline = true,
  signs = true,
  update_in_insert = false,
  float = { format = diagnostic_formatter },
})
