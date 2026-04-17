---@type LazyPluginSpec
return {
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    { "https://github.com/nvim-treesitter/nvim-treesitter" },
    { "https://github.com/nvim-tree/nvim-web-devicons" },
  },
  ft = { "markdown" },
  cmd = { "RenderMarkdown" },
  keys = {
    {
      "<C-k><C-p>",
      function()
        local preview = require("render-markdown.core.preview")
        local manager = require("render-markdown.core.manager")
        local cur_buf = vim.api.nvim_get_current_buf()

        -- (a) カレントバッファがソースで preview が開いている場合
        if preview.buffers[cur_buf] then
          preview.open(cur_buf)
          manager.set_buf(cur_buf, false)
          return
        end

        -- (b) 別バッファに切り替え済みだが preview が残っている場合
        local src_buf = next(preview.buffers)
        if src_buf then
          if vim.api.nvim_buf_is_valid(src_buf) then
            preview.open(src_buf)
            manager.set_buf(src_buf, false)
          end
          return
        end

        -- (c) preview を新規に開く
        preview.open(cur_buf)
        local dst_buf = preview.buffers[cur_buf]
        if dst_buf then
          -- preview ウィンドウの行番号を非表示にする
          local wins = vim.fn.win_findbuf(dst_buf)
          if #wins > 0 then
            vim.wo[wins[1]].number = false
            vim.wo[wins[1]].relativenumber = false
          end
          -- ユーザーが手動で preview ウィンドウに移動した際にフォーカスを戻す
          vim.api.nvim_create_autocmd("BufEnter", {
            buffer = dst_buf,
            callback = function()
              vim.cmd("wincmd p")
            end,
          })
          -- :bdelete 等での閉じに備えてソースのレンダリングを再無効化
          vim.api.nvim_create_autocmd("BufWipeout", {
            buffer = dst_buf,
            once = true,
            callback = function()
              vim.schedule(function()
                if vim.api.nvim_buf_is_valid(cur_buf) then
                  manager.set_buf(cur_buf, false)
                end
              end)
            end,
          })
        end
      end,
      mode = { "n" },
      desc = "Render Markdown Preview Toggle",
    },
  },
  opts = {
    enabled = false,
    overrides = {
      preview = {
        enabled = true,
        render_modes = true,
      },
    },
  },
}
