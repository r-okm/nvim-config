vim.opt.clipboard = ""
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
vim.opt.swapfile = false

vim.g.mapleader = " "

-- sync register with system clipboard
local yank_command = "clipboard --yank"
local paste_command = "clipboard --put"
vim.g.clipboard = {
  name = "osClipboard",
  copy = {
    ["+"] = yank_command,
  },
  paste = {
    ["+"] = paste_command,
  },
  cache_enable = 0,
}

-- diagnostics
vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  signs = {
    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
    },
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
})
