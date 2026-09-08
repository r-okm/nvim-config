---@type LazyPluginSpec
return {
  "https://github.com/iamcco/markdown-preview.nvim",
  build = "cd app && yarn install --frozen-lockfile",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  keys = {
    { "<C-k><C-v>", "<cmd>MarkdownPreviewToggle<cr>", mode = { "n", "x" }, desc = "Markdown Preview Toggle" },
  },
  init = function()
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_browserfunc = "OpenMarkdownPreview"
    vim.g.mkdp_preview_options = { disable_sync_scroll = 1 }
    vim.cmd([[
      function OpenMarkdownPreview(url)
        execute 'silent !xdg-open' a:url
      endfunction
    ]])
  end,
}
