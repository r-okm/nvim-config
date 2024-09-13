return {
  "iamcco/markdown-preview.nvim",
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  init = function()
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  config = function()
    vim.keymap.set({ "n" }, "<c-k><c-v>", ":<c-u>MarkdownPreviewToggle<cr>", { silent = true })
  end,
}
