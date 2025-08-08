local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "CopilotC-Nvim/CopilotChat.nvim",
  enabled = false,
  dependencies = {
    { "nvim-telescope/telescope.nvim" },
    { "nvim-lua/plenary.nvim", branch = "master" },
    { "zbirenbaum/copilot.lua" },
  },
  branch = "main",
  build = "make tiktoken",
  cmd = { "CopilotChatModels", "CopilotChatAgents" },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "gitcommit",
      callback = function()
        local ok, _ = pcall(require, "CopilotChat")
        if ok then
          vim.schedule(function()
            vim.cmd.CopilotChatCommit()
          end)
          vim.api.nvim_create_autocmd("QuitPre", {
            command = "CopilotChatClose",
          })
          util.keymap("ca", "qq", "execute 'CopilotChatClose' <bar> wqa")
        end
      end,
    })
  end,
  opts = {
    model = vim.env.GITHUB_COPILOT_MODEL or "claude-3.5-sonnet",
    prompts = require("r-okm.types.prompts").copilot_chat,
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
