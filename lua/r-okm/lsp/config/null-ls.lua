local deep_table_concat = require("r-okm.util").deep_table_concat
local default_config = require("r-okm.lsp.config").get_default_config("null-ls")

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

return deep_table_concat(default_config, {
  -- null-ls は lspconfig.setup で設定しない
  setup_args = {},
  buffer_config = {
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
})
