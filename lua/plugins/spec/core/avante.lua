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
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = "copilot",
    copilot = {
      model = vim.env.GITHUB_COPILOT_MODEL or "claude-3.5-sonnet",
    },
    system_prompt = function()
      local base_prompt = [[
        You are a helpful assistant. You will be given a prompt and you should respond with the best possible answer.
        Please provide a detailed and accurate response to the prompt.
        If you are unsure about something, please let the user know that you are not sure.
        If the prompt is not clear, please ask for clarification.
        Do not provide any personal opinions or beliefs.
        Do not include any sensitive information in your response.
        You must respond in Japanese.
      ]]
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
      sidebar = {
        close_from_input = { normal = "<Esc>", insert = "<C-c>" },
      },
    },
    hints = {
      enabled = false,
    },
  },
}
