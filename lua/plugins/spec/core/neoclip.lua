---@type LazyPluginSpec
return {
  "https://github.com/AckslD/nvim-neoclip.lua",
  -- setup() registers the recording autocmd, so loading on the picker key
  -- alone would lose every yank made before the first gh
  event = "TextYankPost",
  keys = {
    {
      "gh",
      function()
        -- neoclip's picker actions index the selection with no nil check
        if #require("neoclip.storage").get().yanks == 0 then
          vim.notify("Yank history is empty", vim.log.levels.INFO)
          return
        end
        require("telescope").extensions.neoclip.default()
      end,
      mode = { "n" },
      desc = "Neoclip: Yank history",
    },
  },
  config = function()
    require("neoclip").setup({
      history = 200,
      -- Keep the OS clipboard untouched; gy/gp stay the only bridge to it
      default_register = '"',
      -- <esc> closes the picker in insert mode, leaving p/P/d/e unreachable
      initial_mode = "normal",
      -- Replaying a yank feeds it back as normal mode keys into the previous
      -- buffer, and the keys shadow q = close and <c-q> = send_to_qflist
      keys = {
        telescope = {
          n = { replay = false },
          i = { replay = false },
        },
      },
    })
  end,
}
