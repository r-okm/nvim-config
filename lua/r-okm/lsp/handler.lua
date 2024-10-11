local M = {}

---各言語サーバーの nvim-lspconfig.setup をで実行する.
function M.setup_nvim_lspconfig()
  require("lspconfig.configs").vtsls = require("vtsls").lspconfig

  local LSP_CONFIG_MODULE = "r-okm.lsp.config"
  require("lazy.core.util").lsmod(LSP_CONFIG_MODULE, function(mod_name, _)
    if mod_name == LSP_CONFIG_MODULE then
      return
    end

    local server_name = mod_name:sub(LSP_CONFIG_MODULE:len() + 2)

    -- null-ls は lspconfig.setup で設定しない
    if server_name == "null-ls" then
      return
    end

    local ok, config = pcall(require, mod_name)
    if not ok then
      vim.notify("[r-okm.lsp.handler] Failed to load config " .. mod_name, vim.log.levels.ERROR)
      return
    end
    require("lspconfig")[server_name].setup(config.setup_args)
  end)
end

---LspAttach イベントハンドラー.
function M.on_lsp_attach(args)
  local tb = require("telescope.builtin")

  local bufnr = args.buf
  local client = vim.lsp.get_client_by_id(args.data.client_id)

  if client.name == "GitHub Copilot" then
    return
  end

  local module_name = "r-okm.lsp.config." .. client.name
  local ok, config = pcall(require, module_name)
  if not ok then
    vim.notify("[r-okm.lsp.handler] Failed to load config " .. module_name, vim.log.levels.ERROR)
    return
  end

  local bc = config.buffer_config
  local format_callback = bc.format_callback
  local buf_write_pre_callback = bc.buf_write_pre_callback
  local format_enable = type(bc.format_enable) == "function" and bc.format_enable(bufnr) or bc.format_enable
  local buf_write_pre_enable = type(bc.buf_write_pre_enable) == "function" and bc.buf_write_pre_enable(bufnr)
    or bc.buf_write_pre_enable

  -- set keymap to current buffer
  local set_buf_key = function(modes, lhs, rhs)
    vim.keymap.set(modes, lhs, rhs, { buffer = bufnr })
  end

  -- diagnostic
  set_buf_key("n", "g.", "<cmd>Lspsaga diagnostic_jump_next<CR>")
  set_buf_key("n", "g,", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
  set_buf_key("n", "gw", function()
    tb.diagnostics({ bufnr = 0 })
  end)
  set_buf_key("n", "gW", function()
    tb.diagnostics({ bufnr = nil })
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
    set_buf_key("n", "K", "<cmd>Lspsaga hover_doc<CR>")
  end
  -- symbol rename
  set_buf_key("n", "grn", "<cmd>Lspsaga rename<CR>")
  -- code action
  set_buf_key({ "n", "v" }, "ga", "<cmd>Lspsaga code_action<CR>")
  -- format
  if format_enable then
    set_buf_key("n", "gf", format_callback)
  end
  if buf_write_pre_enable then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("PreWrite" .. client.name .. bufnr, {}),
      buffer = bufnr,
      callback = buf_write_pre_callback,
    })
  end
end

return M
