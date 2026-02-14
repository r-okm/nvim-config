local util = require("r-okm.util")
local CLAUDE_DEFAULT_MODEL = "sonnet"

---@type LazyPluginSpec
return {
  "https://github.com/akinsho/toggleterm.nvim",
  keys = {
    { "zg", "<cmd>lua LazygitToggle()<CR>", mode = { "n" }, noremap = true, silent = true },
    { "<C-k><C-n>", "<cmd>1ToggleTerm direction=tab<CR>", mode = { "n" }, noremap = true, silent = true },
  },
  cmd = { "ToggleTerm", "Claude" },
  init = function()
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      callback = function(opts)
        util.keymap("n", "<CR>", "i", { buffer = opts.buf })
        util.keymap("t", [[<C-\>]], [[<C-\><C-n>]], { buffer = opts.buf })
        util.keymap("t", "<C-w><C-w>", [[<Cmd>wincmd w<CR>]], { buffer = opts.buf })
        util.keymap("t", "<C-w>w", [[<Cmd>wincmd w<CR>]], { buffer = opts.buf })
        util.keymap("t", "<C-k><C-n>", [[<Esc><Cmd>1ToggleTerm<CR>]], { buffer = opts.buf })
      end,
    })
  end,
  config = function()
    local Terminal = require("toggleterm.terminal").Terminal

    local lazygit = Terminal:new({
      count = 3,
      cmd = "lazygit",
      direction = "tab",
      hidden = true,
    })
    function LazygitToggle()
      lazygit:toggle()
    end

    vim.api.nvim_create_user_command("Claude", function(opts)
      local parts = {}

      local filepath = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
      if filepath ~= "" then
        table.insert(parts, "@" .. filepath)
      end

      if opts.range == 2 then
        local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
        local selection = table.concat(lines, "\n")
        local ft = vim.bo.filetype or ""
        table.insert(parts, "```" .. ft .. "\n" .. selection .. "\n```")
      end

      if opts.args and opts.args ~= "" then
        table.insert(parts, opts.args)
      end

      local cmd = "claude --model " .. CLAUDE_DEFAULT_MODEL
      if #parts > 0 then
        cmd = cmd .. " " .. vim.fn.shellescape(table.concat(parts, "\n"))
      end

      local claude_term = Terminal:new({
        count = 2,
        cmd = cmd,
        direction = "vertical",
        close_on_exit = true,
        on_open = function(term)
          util.keymap("t", "<C-k><C-m>", [[<Esc><Cmd>2ToggleTerm direction=vertical<CR>]], { buffer = term.bufnr })
        end,
      })

      util.keymap("n", "<C-k><C-m>", function()
        if not claude_term:is_open() then
          claude_term:open()
        end
      end, { noremap = true, silent = true })

      claude_term:open()
    end, {
      nargs = "*",
      range = true,
      desc = "Open Claude in vertical split with current file context",
    })

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
