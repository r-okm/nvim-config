local null_ls_ft_configs = {
  ["css"] = {
    format_enable = true,
    buf_write_pre_enable = true,
  },
  ["lua"] = {
    format_enable = true,
    buf_write_pre_enable = true,
  },
  ["javascript"] = {
    format_enable = true,
    buf_write_pre_enable = false,
  },
  ["javascriptreact"] = {
    format_enable = true,
    buf_write_pre_enable = false,
  },
  ["json"] = {
    format_enable = true,
    buf_write_pre_enable = true,
  },
  ["jsonc"] = {
    format_enable = true,
    buf_write_pre_enable = true,
  },
  ["markdown"] = {
    format_enable = true,
    buf_write_pre_enable = true,
  },
  ["typescript"] = {
    format_enable = true,
    buf_write_pre_enable = false,
  },
  ["typescriptreact"] = {
    format_enable = true,
    buf_write_pre_enable = false,
  },
  ["yaml"] = {
    format_enable = true,
    buf_write_pre_enable = true,
  },
}

local M = {
  ["bashls"] = {
    format_enable = true,
    buf_write_pre_enable = false,
  },
  ["cssls"] = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
  ["docker_compose_language_service"] = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
  ["dockerls"] = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
  ["eslint"] = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
  ["jsonls"] = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
  ["lemminx"] = {
    format_enable = true,
    buf_write_pre_enable = false,
  },
  ["lua_ls"] = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
  ["null-ls"] = {
    format_enable = function(bufnr)
      local result = false
      for ft, config in pairs(null_ls_ft_configs) do
        if vim.bo[bufnr].filetype == ft then
          result = config.format_enable
          break
        end
      end
      return result
    end,
    buf_write_pre_enable = function(bufnr)
      local result = false
      for ft, config in pairs(null_ls_ft_configs) do
        if vim.bo[bufnr].filetype == ft then
          result = config.buf_write_pre_enable
          break
        end
      end
      return result
    end,
  },
  ["rust_analyzer"] = {
    format_enable = true,
    buf_write_pre_enable = true,
  },
  ["sqls"] = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
  ["vtsls"] = {
    format_enable = false,
    buf_write_pre_enable = true,
    override = {
      buf_write_pre_callback = function(bufnr)
        return function()
          pcall(function()
            vim.cmd("EslintFixAll")
          end)
          vim.lsp.buf.format({
            async = false,
            bufnr = bufnr,
            filter = function(format_client)
              return format_client.name == "null-ls"
            end,
          })
        end
      end,
    },
  },
  ["yamlls"] = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
}

return M
