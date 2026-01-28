local prompt = require("r-okm.types.prompts").avante
local util = require("r-okm.util")

local work_github_org_active = vim.env.WORK_GITHUB_ORG_ACTIVE or "0"

---@type LazyPluginSpec
return {
  "yetone/avante.nvim",
  version = false,
  build = "make",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-tree/nvim-web-devicons",
    "zbirenbaum/copilot.lua",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "Avante", "AvanteInput" },
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      opts = {
        file_types = { "Avante" },
      },
    },
  },
  cmd = { "AvanteAsk", "AvanteChat", "AvanteModels", "AvanteHistory" },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "gitcommit",
      callback = function()
        pcall(require, "avante")

        util.keymap("ca", "qq", "execute 'AvanteStop' <bar> wqa")
        util.keymap("ca", "ai", function()
          vim.schedule(function()
            local avante_api = require("avante.api")
            avante_api.switch_provider("copilot_light")
            avante_api.ask({
              question = prompt.Commit,
              new_chat = true,
            })
          end)
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
        -- model = work_github_org_active == "1" and "claude-haiku-4.5" or "gpt-4.1",
        model = "gpt-4.1",
      },
    },
    system_prompt = function()
      return prompt.Base
    end,
    selector = {
      provider = "telescope",
    },
    mappings = {
      ask = nil,
      edit = nil,
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
