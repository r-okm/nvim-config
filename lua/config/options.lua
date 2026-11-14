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

-- On Windows, run :! and system() through Git Bash instead of cmd.exe.
-- Resolve bash from the Git for Windows install: a bare "bash" can hit System32\bash.exe (the WSL launcher).
local function git_bash()
  local git = vim.fn.exepath("git")
  if git == "" then
    return nil
  end
  -- A scoop shim is a launcher next to a .shim file that names the real binary
  local shim = git:gsub("%.[eE][xX][eE]$", ".shim")
  if vim.uv.fs_stat(shim) then
    git = (vim.fn.readfile(shim)[1] or ""):match('^path%s*=%s*"?([^"]+)"?') or git
  end
  -- git.exe sits in cmd\ or <mingw>\bin\ depending on PATH; the install root holds git-bash.exe and bin\bash.exe
  for dir in vim.fs.parents(git) do
    local bash = vim.fs.joinpath(dir, "bin", "bash.exe")
    if vim.uv.fs_stat(vim.fs.joinpath(dir, "git-bash.exe")) and vim.fn.executable(bash) == 1 then
      return bash
    end
  end
end

if vim.fn.has("win32") == 1 then
  local bash = git_bash()
  if bash then
    vim.o.shell = bash
    vim.o.shellcmdflag = "-c"
    -- The Windows defaults wrap the command in literal quotes, which bash would treat as part of the command name.
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
    vim.o.shellpipe = "2>&1 | tee"
    vim.o.shellredir = ">%s 2>&1"
  end
end

-- sync register with system clipboard
local yank_command = "clipboard --yank"
local paste_command = "clipboard --put"
vim.g.clipboard = {
  name = "system_clipboard",
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
  jump = {
    on_jump = function()
      vim.diagnostic.open_float({ scope = "cursor", focus = false, border = "single" })
    end,
  },
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

-- filetypes
vim.filetype.add({
  pattern = {
    ["[tj]sconfig*.json"] = "jsonc",
    ["*/.vscode/*.json"] = "jsonc",
    ["*/.devcontainer/*.json"] = "jsonc",
    [".eslintrc.json"] = "jsonc",
    ["*cspell.json"] = "jsonc",
    ["compose.*%.ya?ml"] = "yaml.docker-compose",
    ["docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
  },
})
