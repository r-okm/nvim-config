local util = require("r-okm.util")

local _project_nvim_config_dir = util.get_project_nvim_config_dir()

---@type LazyPluginSpec
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
    {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      dependencies = { "nvim-lua/plenary.nvim" },
      cmd = { "HarpoonAdd" },
      config = function()
        local harpoon = require("harpoon")
        harpoon.setup({})
        vim.api.nvim_create_user_command("HarpoonAdd", function()
          harpoon:list():add()
        end, {})
      end,
    },
  },
  keys = {
    { "zp", mode = { "n" } },
    { "zo", mode = { "n" } },
    { "zi", mode = { "n" } },
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
        path_display = {
          filename_first = {
            reverse_directories = false,
          },
        },
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

    local harpoon = require("harpoon")
    harpoon:setup({})

    -- basic telescope configuration
    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require("telescope.pickers")
        .new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        })
        :find()
    end

    util.keymap("n", "zi", function()
      toggle_telescope(harpoon:list())
    end, { desc = "Open harpoon window" })

    -- https://github.com/nvim-telescope/telescope.nvim/issues/605
    local delta_previewer = previewers.new_termopen_previewer({
      get_command = function(entry)
        if entry.status == "??" or "A " then
          return { "git", "diff", entry.value }
        end

        return { "git", "diff", entry.value .. "^!" }
      end,
    })

    util.keymap({ "n" }, "zp", builtin.find_files)
    util.keymap({ "n" }, "zo", function()
      builtin.git_status({ previewer = delta_previewer, layout_strategy = "vertical" })
    end)
    util.keymap({ "n" }, "zf", ":<C-u>Telescope kensaku<CR>")
    util.keymap({ "n" }, "#", builtin.grep_string)
    util.keymap({ "x" }, "#", function()
      local text = util.get_visual_selection()
      builtin.grep_string({ search = text })
    end)
  end,
}
