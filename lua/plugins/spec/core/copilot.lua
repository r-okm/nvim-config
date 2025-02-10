return {
  "github/copilot.vim",
  cond = os.getenv("GITHUB_COPILOT_ENABLED") == "1",
  event = { "BufReadPost", "CmdlineEnter" },
  config = function()
    vim.keymap.set({ "i" }, "<Tab>", "copilot#Accept('<Tab>')", {
      expr = true,
      replace_keycodes = false,
    })
    local cwd = vim.fn.getcwd()
    vim.g.copilot_workspace_folders = { cwd }
  end,
}
