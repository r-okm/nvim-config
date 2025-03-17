local getVisualSelection = require("r-okm.util").getVisualSelection

return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    { "nvim-lua/plenary.nvim", branch = "master" },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-tree/nvim-web-devicons" },
    { "atusy/qfscope.nvim" },
    {
      "Allianaab2m/telescope-kensaku.nvim",
      dependencies = {
        { "vim-denops/denops.vim", lazy = false },
        { "lambdalisue/vim-kensaku", lazy = false },
      },
      config = function()
        require("telescope").load_extension("kensaku") -- :Telescope kensaku
      end,
    },
  },
  keys = {
    { "zp", mode = { "n" } },
    { "zf", mode = { "n" } },
    { "#", mode = { "n", "x" } },
  },
  cmd = { "Telescope" },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")
    local qfs_actions = require("qfscope.actions")

    telescope.setup({
      defaults = {
        mappings = {
          n = {
            ["q"] = actions.close,
          },
          i = {
            ["<esc>"] = actions.close,
            ["<C-o>"] = actions.cycle_history_prev,
            ["<C-i>"] = actions.cycle_history_next,
            ["<C-G><C-G>"] = qfs_actions.qfscope_search_filename,
            ["<C-G><C-F>"] = qfs_actions.qfscope_grep_filename,
            ["<C-G><C-L>"] = qfs_actions.qfscope_grep_line,
            ["<C-G><C-T>"] = qfs_actions.qfscope_grep_text,
          },
        },
        layout_config = {
          horizontal = {
            height = 0.9,
            preview_cutoff = 120,
            prompt_position = "bottom",
            width = 0.9,
            preview_width = 0.7,
          },
        },
        layout_strategy = "vertical",
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--line-number",
          "--column",
          "--only-matching",
          "--hidden",
          "--smart-case",
          "--trim",
          "--ignore-file",
          ".nvim/.rgignore",
          "--glob",
          "!.git",
          "--glob",
          "!*.svg",
          "--glob",
          "!**/package-lock.json",
          "--glob",
          "!*.lock",
        },
        path_display = function(_, path)
          local tail = require("telescope.utils").path_tail(path)
          return string.format("%s (%s)", tail, path)
        end,
      },
      pickers = {
        find_files = {
          find_command = {
            "fd",
            "--type",
            "f",
            "--hidden",
            "--exclude",
            ".git",
            "--ignore-file",
            ".nvim/.fdignore",
          },
        },
        grep_string = { initial_mode = "normal" },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
        },
      },
    })

    telescope.load_extension("fzf")

    local keymap = function(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true })
    end
    keymap({ "n" }, "zp", builtin.find_files)
    keymap({ "n" }, "zf", ":<C-u>Telescope kensaku<CR>")
    keymap({ "n" }, "#", builtin.grep_string)
    keymap({ "x" }, "#", function()
      local text = getVisualSelection()
      builtin.grep_string({ search = text })
    end)
  end,
}
