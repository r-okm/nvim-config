local util = require("r-okm.util")

local _project_nvim_config_dir = util.get_project_nvim_config_dir()

---@type vim.lsp.Config
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
    local previewers = require("telescope.previewers")
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
          _project_nvim_config_dir .. "/.rgignore",
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
        set_env = {
          LESS = "",
          DELTA_PAGER = "less",
        },
      },
      pickers = {
        find_files = {
          find_command = {
            "fd",
            "--type",
            "f",
            "--hidden",
            "--ignore-file",
            _project_nvim_config_dir .. "/.fdignore",
            "--exclude",
            "{.git,*.exe,*.png,*.jpg,*.svg}",
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

    -- https://github.com/nvim-telescope/telescope.nvim/issues/605
    local delta_previewer = previewers.new_termopen_previewer({
      get_command = function(entry)
        if entry.status == "??" or "A " then
          return { "git", "diff", entry.value }
        end

        return { "git", "diff", entry.value .. "^!" }
      end,
    })

    local keymap = function(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true })
    end
    keymap({ "n" }, "zp", builtin.find_files)
    keymap({ "n" }, "zo", function()
      builtin.git_status({ previewer = delta_previewer, layout_strategy = "vertical" })
    end)
    keymap({ "n" }, "zf", ":<C-u>Telescope kensaku<CR>")
    keymap({ "n" }, "#", builtin.grep_string)
    keymap({ "x" }, "#", function()
      local text = util.get_visual_selection()
      builtin.grep_string({ search = text })
    end)
  end,
}
