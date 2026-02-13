local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "https://github.com/akinsho/toggleterm.nvim",
  keys = {
    { "zg", "<cmd>lua LazygitToggle()<CR>", mode = { "n" }, noremap = true, silent = true },
    { "<C-k><C-n>", "<cmd>ToggleTerm direction=tab<CR>", mode = { "n" }, noremap = true, silent = true },
    { "<C-k><C-m>", "<cmd>ToggleTerm direction=vertical<CR>", mode = { "n" }, noremap = true, silent = true },
  },
  cmd = { "ToggleTerm" },
  init = function()
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      callback = function(opts)
        util.keymap("t", [[<C-\>]], [[<C-\><C-n>]], { buffer = opts.buf })
        util.keymap("t", "<C-w><C-w>", [[<Cmd>wincmd w<CR>]], { buffer = opts.buf })
        util.keymap("t", "<C-w>w", [[<Cmd>wincmd w<CR>]], { buffer = opts.buf })
        util.keymap("t", "<C-k><C-n>", [[<Esc><Cmd>ToggleTerm<CR>]], { buffer = opts.buf })
        util.keymap("t", "<C-k><C-m>", [[<Esc><Cmd>ToggleTerm<CR>]], { buffer = opts.buf })
      end,
    })
  end,
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

    require("toggleterm").setup({
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
          return vim.o.columns * 0.5
        else
          return 20
        end
      end,
    })
  end,
}
