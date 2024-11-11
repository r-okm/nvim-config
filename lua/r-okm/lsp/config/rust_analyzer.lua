return {
  setup_args = {
    settings = {
      ["rust-analyzer"] = {
        check = {
          command = "clippy",
        },
      },
    },
  },
  buffer_config = {
    format_enable = true,
    buf_write_pre_enable = true,
  },
}
