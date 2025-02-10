return {
  "iamcco/markdown-preview.nvim",
  build = "cd app && yarn install --frozen-lockfile",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  init = function()
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_browserfunc = "OpenMarkdownPreview"
    vim.cmd([[
      function OpenMarkdownPreview(url)
        execute 'silent !xdg-open' a:url
      endfunction
    ]])
  end,
  config = function()
    vim.keymap.set({ "n" }, "<c-k><c-v>", ":<c-u>MarkdownPreviewToggle<cr>", { silent = true })
  end,
}
