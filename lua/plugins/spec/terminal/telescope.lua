local getVisualSelection = require("utils.buffer").getVisualSelection

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-tree/nvim-web-devicons" },
  },
  keys = {
    { "zp", mode = { "n" } },
    { "zf", mode = { "n" } },
    { "#", mode = { "n", "x" } },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")
    local previewers = require("telescope.previewers")

    telescope.setup({
      defaults = {
        mappings = {
          n = {
            ["q"] = actions.close,
          },
          i = {
            ["<esc>"] = actions.close,
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
          "--glob",
          "!**/.git/*",
          "--glob",
          "!**/node_modules/*",
          "--glob",
          "!**/package-lock.json",
        },
        path_display = function(_opts, path)
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

    local my_git_status = function(opts)
      opts = opts or {}
      opts.previewer = previewers.new_termopen_previewer({
        get_command = function(entry)
          return { "git", "-c", "delta.side-by-side=true", "diff", entry.value }
        end,
      })

      builtin.git_status(opts)
    end

    vim.keymap.set({ "n" }, "zp", builtin.find_files)
    vim.keymap.set({ "n" }, "zf", builtin.live_grep)
    vim.keymap.set({ "n" }, "zo", my_git_status)
    vim.keymap.set({ "n" }, "#", builtin.grep_string)
    vim.keymap.set({ "x" }, "#", function()
      local text = getVisualSelection()
      builtin.grep_string({ search = text })
    end)
  end,
}
