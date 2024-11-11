local M = {}

local _capabilities = vim.lsp.protocol.make_client_capabilities()
_capabilities = require("cmp_nvim_lsp").default_capabilities(_capabilities)

local _default_config = {
  setup_args = {
    capabilities = _capabilities,
  },
  buffer_config = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
}

local _lsp_config_module = "r-okm.lsp.config"

require("lazy.core.util").lsmod(_lsp_config_module, function(mod_name, _)
  if mod_name == _lsp_config_module then
    return
  end

  local server_name = mod_name:sub(_lsp_config_module:len() + 2)
  local _, server_config = pcall(require, mod_name)

  local buffer_config = {
    format_callback = function()
      vim.lsp.buf.format({
        async = true,
        filter = function(format_client)
          return format_client.name == server_name
        end,
      })
    end,
    buf_write_pre_callback = function()
      vim.lsp.buf.format({
        async = false,
        filter = function(format_client)
          return format_client.name == server_name
        end,
      })
    end,
  }

  M[server_name] = vim.tbl_deep_extend("force", _default_config, { buffer_config = buffer_config }, server_config)
end)

return M

---@class LspConfig
---@field setup_args table
---@field buffer_config BufferConfig

---@class BufferConfig
---@field format_enable boolean|(fun():boolean)
---@field format_callback function
---@field buf_write_pre_enable boolean|(fun():boolean)
---@field buf_write_pre_callback function
