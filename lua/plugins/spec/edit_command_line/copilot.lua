---@type LazyPluginSpec
return {
  "zbirenbaum/copilot.lua",
  cmd = { "Copilot" },
  event = { "InsertEnter" },
  config = function()
    require("copilot").setup({
      panel = {
        enabled = false,
      },
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = false,
          next = "<C-k>",
          prev = false,
        },
      },
      filetypes = {
        markdown = true,
        gitcommit = true,
      },
    })
  end,
}
