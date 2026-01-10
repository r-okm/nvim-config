local ui = require("husen.ui")

local M = {}

local function setup_autocmds()
  local function is_menu_buffer(bufnr)
    local ok, val = pcall(vim.api.nvim_buf_get_var, bufnr, "husen_menu")
    return ok and val
  end

  local augroup = vim.api.nvim_create_augroup("HusenRefresh", { clear = true })

  vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufWipeout", "BufEnter", "WinEnter" }, {
    group = augroup,
    callback = function(args)
      if is_menu_buffer(args.buf) then
        return
      end
      if vim.bo[args.buf].buftype ~= "" and vim.bo[args.buf].buftype ~= "terminal" then
        return
      end

      ui.refresh_menu()
    end,
    desc = "Refresh husen menu on buffer changes",
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    callback = function()
      ui.refresh_menu()
    end,
    desc = "Refresh husen menu on window resize",
  })
end

function M.setup(_opts)
  setup_autocmds()
  ui.open_menu()
end

return M
