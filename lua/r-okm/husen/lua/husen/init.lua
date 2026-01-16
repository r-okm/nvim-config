local ui = require("husen.ui")

local M = {}

local function is_menu_buffer(bufnr)
  local ok, val = pcall(vim.api.nvim_buf_get_var, bufnr, "husen_menu")
  return ok and val
end

local function setup_autocmds()
  local augroup = vim.api.nvim_create_augroup("HusenRefresh", { clear = true })

  -- Buffer add/enter events - check buftype
  vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter", "WinEnter" }, {
    group = augroup,
    callback = function(args)
      if is_menu_buffer(args.buf) then
        return
      end
      if vim.api.nvim_buf_is_valid(args.buf) then
        local buftype = vim.bo[args.buf].buftype
        if buftype ~= "" and buftype ~= "terminal" then
          return
        end
      end
      ui.refresh_menu()
    end,
    desc = "Refresh husen menu on buffer add/enter",
  })

  -- Buffer delete/wipeout - always refresh (buffer may be invalid)
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = augroup,
    callback = function(args)
      if is_menu_buffer(args.buf) then
        return
      end
      vim.schedule(function()
        ui.refresh_menu()
      end)
    end,
    desc = "Refresh husen menu on buffer delete",
  })

  -- bufdelete.nvim fires User BDeletePost after deleting buffer
  vim.api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = "BDeletePost *",
    callback = function()
      vim.schedule(function()
        ui.refresh_menu()
      end)
    end,
    desc = "Refresh husen menu after bufdelete.nvim",
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    callback = function()
      ui.refresh_menu()
    end,
    desc = "Refresh husen menu on window resize",
  })
end

---@param opts table?
function M.setup(opts)
  opts = opts or {}

  ui.set_config(opts)
  setup_autocmds()

  vim.defer_fn(function()
    ui.open_menu()
  end, 100)
end

return M
