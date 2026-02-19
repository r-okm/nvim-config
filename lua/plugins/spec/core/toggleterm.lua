local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "https://github.com/akinsho/toggleterm.nvim",
  keys = {
    { "<C-k><C-n>", mode = { "n" } },
    { "<C-k><C-m>", mode = { "n" } },
    { "zg", mode = { "n" } },
  },
  cmd = { "ToggleTerm" },
  init = function()
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      callback = function(opts)
        util.keymap("n", "<CR>", "i", { buffer = opts.buf })
        util.keymap("t", [[<C-\>]], [[<C-\><C-n>]], { buffer = opts.buf })
        util.keymap("t", "<C-w><C-w>", [[<Cmd>wincmd w<CR>]], { buffer = opts.buf })
        util.keymap("t", "<C-w>w", [[<Cmd>wincmd w<CR>]], { buffer = opts.buf })
      end,
    })
  end,
  config = function()
    local Terminal = require("toggleterm.terminal").Terminal

    local TERM_COUNT = {
      TAB = 1,
      VERTICAL = 2,
      LAZYGIT = 3,
    }

    local terminal_tab = Terminal:new({
      count = TERM_COUNT.TAB,
      direction = "tab",
      on_open = function(term)
        util.keymap("t", "<C-k><C-n>", "<Esc><Cmd>" .. TERM_COUNT.TAB .. "ToggleTerm<CR>", { buffer = term.bufnr })
      end,
    })
    local terminal_vertical = Terminal:new({
      count = TERM_COUNT.VERTICAL,
      direction = "vertical",
      on_open = function(term)
        util.keymap("t", "<C-k><C-m>", "<Esc><Cmd>" .. TERM_COUNT.VERTICAL .. "ToggleTerm<CR>", { buffer = term.bufnr })
      end,
    })
    local terminal_lazygit = Terminal:new({
      count = TERM_COUNT.LAZYGIT,
      cmd = "lazygit",
      direction = "tab",
      hidden = true,
    })

    local is_open_any_term = function()
      return terminal_tab:is_open() or terminal_vertical:is_open() or terminal_lazygit:is_open()
    end

    util.keymap("n", "<C-k><C-n>", function()
      if not is_open_any_term() then
        terminal_tab:open()
      end
    end)
    util.keymap({ "n" }, "<C-k><C-m>", function()
      if not is_open_any_term() then
        terminal_vertical:open()
      elseif terminal_vertical:is_open() then
        terminal_vertical:focus()
      end
    end)
    util.keymap("n", "zg", function()
      if not is_open_any_term() then
        terminal_lazygit:open()
      end
    end)

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
          return vim.o.columns * 0.4
        else
          return 20
        end
      end,
    })
  end,
}
