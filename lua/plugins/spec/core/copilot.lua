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

    -- tab keymap
    -- https://github.com/zbirenbaum/copilot.lua/issues/91#issuecomment-1345190310
    local accept_or_feedkey = function(key)
      if require("copilot.suggestion").is_visible() then
        require("copilot.suggestion").accept()
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
      end
    end
    vim.keymap.set("i", "<Tab>", function()
      accept_or_feedkey("<Tab>")
    end, { noremap = true, silent = true })

    --[[ vim.keymap.set("i", "<C-k>", function()
      require("copilot.panel").open()
    end, { noremap = true, silent = true }) ]]
  end,
}
