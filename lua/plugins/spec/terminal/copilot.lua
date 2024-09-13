return {
  "github/copilot.vim",
  cond = os.getenv("GITHUB_COPILOT_ENABLED") == "1",
  event = { "BufReadPost", "CmdlineEnter" },
  config = function()
    vim.keymap.set({ "i" }, "<C-K>", "<Plug>(copilot-suggest)")
    vim.keymap.set({ "i" }, "<C-N>", "<Plug>(copilot-next)")
    vim.keymap.set({ "i" }, "<C-P>", "<Plug>(copilot-previous)")
    vim.keymap.set({ "i" }, "<Tab>", "copilot#Accept('<Tab>')", {
      expr = true,
      replace_keycodes = false,
    })
  end,
}
