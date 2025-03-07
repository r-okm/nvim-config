return {
  "zbirenbaum/copilot.lua",
  cmd = { "Copilot" },
  event = { "InsertEnter" },
  config = function()
    require("copilot").setup({
      panel = {
        enabled = false,
        auto_refresh = true,
        layout = {
          position = "vertical",
          ratio = 0.5,
        },
      },
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = false,
          next = "<C-k>",
          prev = false,
        },
      },
    })

    -- disalbe when popup is visible
    require("cmp").event:on("menu_opened", function()
      vim.b.copilot_suggestion_hidden = true
    end)
    require("cmp").event:on("menu_closed", function()
      vim.b.copilot_suggestion_hidden = false
    end)
  end,
}
