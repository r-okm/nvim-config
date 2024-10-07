local M = {}

---デフォルトの lsp 設定を取得する.
---@param ls_name string 言語サーバー名
---@return LspConfig
function M.get_default_config(ls_name)
  local _capabilities = vim.lsp.protocol.make_client_capabilities()
  _capabilities = require("cmp_nvim_lsp").default_capabilities(_capabilities)

  return {
    setup_args = {
      capabilities = _capabilities,
    },
    buffer_config = {
      format_enable = false,
      format_callback = function()
        vim.lsp.buf.format({
          async = true,
          filter = function(format_client)
            return format_client.name == ls_name
          end,
        })
      end,
      buf_write_pre_enable = false,
      buf_write_pre_callback = function()
        vim.lsp.buf.format({
          async = false,
          filter = function(format_client)
            return format_client.name == ls_name
          end,
        })
      end,
    },
  }
end

return M

---@class LspConfig
---@field setup_args table
---@field buffer_config BufferConfig

---@class BufferConfig
---@field format_enable boolean|(fun():boolean)
---@field format_callback function
---@field buf_write_pre_enable boolean|(fun():boolean)
---@field buf_write_pre_callback function
