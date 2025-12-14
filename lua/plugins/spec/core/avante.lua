local prompt = require("r-okm.types.prompts").avante
local util = require("r-okm.util")

local work_github_org_active = vim.env.WORK_GITHUB_ORG_ACTIVE or "0"

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
  event = { "BufReadPost" },
  cmd = { "AvanteAsk", "AvanteChat", "AvanteModels", "AvanteHistory" },
  keys = {
    "zu",
    mode = { "n" },
  },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "gitcommit",
      callback = function()
        util.keymap("ca", "qq", "execute 'AvanteStop' <bar> wqa")
        util.keymap("ca", "ai", function()
          local ok, avante_api = pcall(require, "avante.api")
          if not ok then
            vim.notify("Avante.nvim is not installed", vim.log.levels.ERROR)
            return
          end

          avante_api.switch_provider("copilot_light")
          avante_api.ask({
            question = prompt.Commit,
            new_chat = true,
          })
        end)
      end,
    })
  end,
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = "copilot",
    providers = {
      copilot = {
        model = work_github_org_active == "1" and "claude-opus-4.5" or "gpt-4.1",
      },
      copilot_light = {
        __inherited_from = "copilot",
        model = work_github_org_active == "1" and "claude-haiku-4.5" or "gpt-4.1",
      },
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
    selection = {
      enabled = false,
    },
    windows = {
      width = 40,
    },
  },
}
