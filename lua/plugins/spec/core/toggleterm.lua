local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "https://github.com/akinsho/toggleterm.nvim",
  keys = {
    { "zg", mode = { "n" } },
    { "zy", mode = { "n" } },
    { "<C-k><C-n>", mode = { "n" } },
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

    local copilot_cli = Terminal:new({
      cmd = "copilot",
      direction = "vertical",
      hidden = true,
    })
    function CopilotCliToggle()
      copilot_cli:toggle()
    end
    util.keymap({ "n" }, "zy", "<cmd>lua CopilotCliToggle()<CR>")

    require("toggleterm").setup({
      open_mapping = { "<C-k><C-n>" },
      hide_numbers = true,
      start_in_insert = true,
      persist_size = true,
      persist_mode = false,
      direction = "tab",
      close_on_exit = true,
      auto_scroll = true,
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        else
          return 20
        end
      end,
    })
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      callback = function(opts)
        util.keymap("t", [[<C-\>]], [[<C-\><C-n>]], { buffer = opts.buf })
        util.keymap("t", "<C-w><C-w>", [[<Cmd>wincmd w<CR>]], { buffer = opts.buf })
        util.keymap("t", "<C-w>w", [[<Cmd>wincmd w<CR>]], { buffer = opts.buf })
      end,
    })
  end,
}
