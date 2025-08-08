local util = require("r-okm.util")

---@type vim.lsp.Config
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
    util.keymap({ "n", "x" }, ",", function()
      substitute.operator()
    end)
  end,
}
