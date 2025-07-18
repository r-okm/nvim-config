-- LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("r-okm.LspAttach", {}),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client == nil or client.name == "copilot" then
      return
    end

    -- set keymap to current buffer
    local set_buf_key = function(modes, lhs, rhs)
      vim.keymap.set(modes, lhs, rhs, { buffer = bufnr })
    end

    -- diagnostic
    local tb = require("telescope.builtin")

    set_buf_key("n", "g.", function()
      vim.cmd("Lspsaga diagnostic_jump_next")
    end)
    set_buf_key("n", "g,", function()
      vim.cmd("Lspsaga diagnostic_jump_prev")
    end)
    set_buf_key("n", "gw", function()
      tb.diagnostics({ bufnr = 0 })
    end)
    set_buf_key("n", "gW", function()
      vim.cmd("Lspsaga show_workspace_diagnostics")
    end)
    -- code navigation
    set_buf_key("n", "gd", function()
      tb.lsp_definitions()
    end)
    set_buf_key("n", "gD", function()
      tb.lsp_implementations()
    end)
    set_buf_key("n", "gt", function()
      tb.lsp_type_definitions()
    end)
    set_buf_key("n", "grr", function()
      tb.lsp_references()
    end)
    -- hover document
    if client.supports_method("textDocument/hover") then
      set_buf_key("n", "K", function()
        vim.lsp.buf.hover({
          border = "single",
        })
      end)
    end
    -- symbol rename
    set_buf_key("n", "grn", function()
      vim.cmd("Lspsaga rename")
    end)
    -- code action
    set_buf_key({ "n", "v" }, "ga", function()
      vim.cmd("Lspsaga code_action")
    end)
  end,
})

-- FileType format config
for ft_str, config in pairs(require("r-okm.ft-config")) do
  local ft_table = require("r-okm.util").split_string(ft_str, ",")
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("r-okm.FileType" .. ft_str, {}),
    pattern = ft_table,
    callback = function(args)
      local bufnr = args.buf

      -- Set keymap to format
      vim.keymap.set({ "n" }, "gf", function()
        vim.lsp.buf.format({
          async = true,
          filter = function(format_client)
            return format_client.name == config.format_language_server
          end,
        })
      end, { noremap = true, silent = true, buffer = bufnr })

      -- set autocmd BufWritePre to format
      if config.enable_format_on_save then
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = vim.api.nvim_create_augroup("r-okm.BufWritePre" .. bufnr, {}),
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({
              async = false,
              filter = function(format_client)
                return format_client.name == config.format_language_server
              end,
            })
          end,
        })
      end
    end,
  })
end

-- Switch relativenumber
local number_group = vim.api.nvim_create_augroup("r-okm.Number", {})
vim.api.nvim_create_autocmd({ "WinEnter" }, {
  group = number_group,
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = true
    end
  end,
})
vim.api.nvim_create_autocmd({ "WinLeave" }, {
  group = number_group,
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
    end
  end,
})
