local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "https://github.com/AckslD/nvim-neoclip.lua",
  -- setup() is what registers the TextYankPost autocmd that feeds the history,
  -- so deferring the load until the picker key would open an empty list
  lazy = false,
  config = function()
    require("neoclip").setup({
      history = 200,
      -- Keep the OS clipboard untouched; gy/gp stay the only bridge to it
      default_register = '"',
      -- <esc> is mapped to close in insert mode, so the picker's normal mode
      -- keys (p/P/d/e) are only reachable when it starts there
      initial_mode = "normal",
      -- Replaying a yank as a macro feeds the entry back as normal mode keys,
      -- which silently mangles the buffer we came from. Its keys also shadow
      -- q = close and <c-q> = send_to_qflist in the picker.
      keys = {
        telescope = {
          n = { replay = false },
          i = { replay = false },
        },
      },
    })

    -- telescope is required inside the callback so that it stays lazy-loaded.
    -- Indexing telescope.extensions registers and caches the extension on
    -- first use, which is when it captures default_register from the settings
    -- above, so no explicit load_extension is needed here.
    util.keymap({ "n" }, "gh", function()
      -- Every neoclip picker action indexes the selected entry with no nil
      -- check, so an empty picker errors on the first action key pressed
      if #require("neoclip.storage").get().yanks == 0 then
        vim.notify("Yank history is empty", vim.log.levels.INFO)
        return
      end
      require("telescope").extensions.neoclip.default()
    end, { desc = "Neoclip: Yank history" })
  end,
}
