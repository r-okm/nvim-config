local request = require("r-okm.lsp.request")

return {
  setup_args = {
    commands = {
      EslintFixAllSync = {
        function()
          request.execute_command({
            command = "eslint.applyAllFixes",
            client = "eslint",
            sync = true,
          })
        end,
        description = "Run eslint --fix on the current buffer",
      },
      EslintFixAllAsync = {
        function()
          request.execute_command({
            command = "eslint.applyAllFixes",
            client = "eslint",
            sync = false,
          })
        end,
        description = "Run eslint --fix on the current buffer",
      },
    },
    on_attach = function(_, bufnr)
      vim.keymap.set("n", "ge", function()
        vim.cmd.EslintFixAllAsync()
      end, { buffer = bufnr })
    end,
  },
  buffer_config = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
}
