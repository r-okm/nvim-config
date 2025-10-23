local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "akinsho/toggleterm.nvim",
  keys = {
    { "zg", mode = { "n" } },
    -- { "<C-k><C-n>", mode = { "n" } },
  },
  config = function()
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({
      cmd = "lazygit",
      direction = "tab",
      hidden = true,
    })
    function LazygitToggle()
      lazygit:toggle()
    end
    util.keymap({ "n" }, "zg", "<cmd>lua LazygitToggle()<CR>")

    -- require("toggleterm").setup({
    --   open_mapping = { "<C-k><C-n>" },
    --   hide_numbers = true,
    --   start_in_insert = true,
    --   persist_size = true,
    --   persist_mode = false,
    --   direction = "tab",
    --   close_on_exit = true,
    --   auto_scroll = true,
    -- })
    -- vim.api.nvim_create_autocmd("TermOpen", {
    --   pattern = "term://*",
    --   callback = function(opts)
    --     util.keymap("t", [[<C-\>]], [[<C-\><C-n>]], { buffer = opts.buf })
    --   end,
    -- })
  end,
}
