return {
  setup_args = {
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
