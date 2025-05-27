---@type LazyPluginSpec
return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "nvim-telescope/telescope.nvim" },
    { "nvim-lua/plenary.nvim", branch = "master" },
    { "zbirenbaum/copilot.lua" },
  },
  branch = "main",
  build = "make tiktoken",
  cmd = { "CopilotChatModels", "CopilotChatAgents" },
  opts = {
    model = vim.env.GITHUB_COPILOT_MODEL or "claude-3.5-sonnet",
    prompts = require("r-okm.types.prompts"),
    question_header = "#  User ",
    answer_header = "#  Copilot ",
    error_header = "#  Error ",
    log_level = "warn",
  },
  --[[ keys = {
    {
      "zu",
      function()
        vim.cmd("CopilotChatOpen")
      end,
      mode = { "n" },
      desc = "CopilotChat: Open Copilot Chat",
    },
    {
      "zu",
      function()
        vim.cmd("CopilotChat")
      end,
      mode = { "x" },
      desc = "CopilotChat: Open Copilot Chat with selected text",
    },
    {
      "zi",
      function()
        require("CopilotChat").select_prompt({
          selection = require("CopilotChat.select").buffer,
        })
      end,
      mode = { "n" },
      desc = "CopilotChat: Select Copilot Chat prompt",
    },
    {
      "zi",
      function()
        require("CopilotChat").select_prompt({
          selection = require("CopilotChat.select").visual,
        })
      end,
      mode = { "x" },
      desc = "CopilotChat: Select Copilot Chat prompt with selected text",
    },
  }, ]]
}
