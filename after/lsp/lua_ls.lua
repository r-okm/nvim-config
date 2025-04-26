---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      workspace = {
        library = {
          vim.fn.stdpath("data") .. "/lazy",
        },
      },
    },
  },
}
