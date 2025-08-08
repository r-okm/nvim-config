return {
  "gbprod/substitute.nvim",
  keys = {
    { ",", mode = { "n", "x" } },
  },
  config = function()
    local substitute = require("substitute")
    substitute.setup({
      highlight_substituted_text = {
        enabled = false,
      },
    })
    vim.keymap.set({ "n", "x" }, ",", function()
      substitute.operator()
    end)
  end,
}
