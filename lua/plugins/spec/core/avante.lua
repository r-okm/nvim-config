local prompt = require("r-okm.types.prompts").avante

---@type LazyPluginSpec
return {
  "yetone/avante.nvim",
  version = false,
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-tree/nvim-web-devicons",
    "zbirenbaum/copilot.lua",
    "ravitemer/mcphub.nvim",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "Avante" },
      opts = {
        file_types = { "markdown", "Avante" },
      },
    },
  },
  event = "BufReadPost",
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "gitcommit",
      callback = function()
        local ok, avante_api = pcall(require, "avante.api")
        if ok then
          vim.schedule(function()
            avante_api.ask({
              question = prompt.Commit,
              new_chat = true,
            })
          end)
          vim.keymap.set("ca", "qq", "execute 'AvanteStop' <bar> wqa")
        end
      end,
    })
  end,
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = "copilot",
    copilot = {
      model = vim.env.GITHUB_COPILOT_MODEL or "claude-3.5-sonnet",
    },
    system_prompt = function()
      local base_prompt = prompt.Base
      local hub = require("mcphub").get_hub_instance()
      local additional_prompt = hub and hub:get_active_servers_prompt() or ""

      return base_prompt .. additional_prompt
    end,
    custom_tools = function()
      return {
        require("mcphub.extensions.avante").mcp_tool(),
      }
    end,
    disabled_tools = {
      "list_files",
      "search_files",
      "read_file",
      "create_file",
      "rename_file",
      "delete_file",
      "create_dir",
      "rename_dir",
      "delete_dir",
      "bash",
    },
    selector = {
      provider = "telescope",
    },
    mappings = {
      ask = "zu",
      edit = "zi",
      sidebar = {
        close_from_input = {
          normal = "<Esc>",
          insert = "<C-c>",
        },
      },
    },
    hints = {
      enabled = false,
    },
    windows = {
      width = 40,
    },
  },
}
