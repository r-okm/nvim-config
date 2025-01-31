return {
  "vim-skk/skkeleton",
  dependencies = {
    { "vim-denops/denops.vim" },
    { "skk-dev/dict", lazy = true },
    { "delphinus/skkeleton_indicator.nvim", opts = {} },
  },
  cond = false,
  lazy = false,
  init = function()
    vim.api.nvim_create_autocmd({ "User" }, {
      pattern = { "skkeleton-initialize-pre" },
      callback = function()
        vim.fn["skkeleton#config"]({
          globalDictionaries = {
            vim.fn.stdpath("data") .. "/lazy/dict/SKK-JISYO.L",
          },
          eggLikeNewline = true,
        })
      end,
    })
    vim.api.nvim_create_autocmd({ "User" }, {
      pattern = { "DenopsPluginPost:skkeleton" },
      callback = function()
        vim.fn["skkeleton#initialize"]()
      end,
    })
  end,
  keys = {
    { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c" } },
  },
}
