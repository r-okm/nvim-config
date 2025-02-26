local M = {}

local _lsp_configs = require("r-okm.lsp.config")

---各言語サーバーの nvim-lspconfig.setup を実行する.
function M.setup_nvim_lspconfig()
  require("lspconfig.configs").vtsls = require("vtsls").lspconfig

  for server_name, config in pairs(_lsp_configs) do
    if server_name == "null-ls" then
      goto continue
    end
    require("lspconfig")[server_name].setup(config.setup_args)
    ::continue::
  end
end

---LspAttach イベントハンドラー.
function M.on_lsp_attach(args)
  local bufnr = args.buf
  local client = vim.lsp.get_client_by_id(args.data.client_id)

  if client.name == "copilot" then
    return
  end

  local config = _lsp_configs[client.name]

  local bc = config.buffer_config
  local format_enable = type(bc.format_enable) == "function" and bc.format_enable(bufnr) or bc.format_enable
  local buf_write_pre_enable = type(bc.buf_write_pre_enable) == "function" and bc.buf_write_pre_enable(bufnr)
    or bc.buf_write_pre_enable

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
      vim.cmd("Lspsaga hover_doc")
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
  -- format
  if format_enable then
    set_buf_key("n", "gf", config.buffer_config.format_callback)
  end
  if buf_write_pre_enable then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("PreWrite" .. client.name .. bufnr, {}),
      buffer = bufnr,
      callback = config.buffer_config.buf_write_pre_callback,
    })
  end
end

return M
