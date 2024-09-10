vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(args)
    local tb = require("telescope.builtin")

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    local format_enable = false
    local buf_write_pre_enable = false
    local buf_write_pre_callback = function()
      vim.lsp.buf.format({
        async = false,
        bufnr = bufnr,
        filter = function(format_client)
          return format_client.name == client.name
        end,
      })
    end

    local lsp_configs = require("lsp/lsp_configs")
    for lsp_name, config in pairs(lsp_configs) do
      if client.name == lsp_name then
        ---@diagnostic disable-next-line: cast-local-type
        format_enable = type(config.format_enable) == "function" and config.format_enable(bufnr) or config.format_enable
        ---@diagnostic disable-next-line: cast-local-type
        buf_write_pre_enable = type(config.buf_write_pre_enable) == "function" and config.buf_write_pre_enable(bufnr)
          or config.buf_write_pre_enable

        if config.override then
          if config.override.buf_write_pre_callback then
            buf_write_pre_callback = config.override.buf_write_pre_callback(bufnr)
          end
        end
        break
      end
    end

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
      set_buf_key("n", "gf", function()
        vim.lsp.buf.format({
          async = true,
          bufnr = bufnr,
          filter = function(format_client)
            return format_client.name == client.name
          end,
        })
      end)
    end
    if buf_write_pre_enable then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("PreWrite" .. client.name .. bufnr, {}),
        buffer = bufnr,
        callback = buf_write_pre_callback,
      })
    end

    -- setup diagnostic signs
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
  end,
})
