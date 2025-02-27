return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "nvim-telescope/telescope.nvim" },
    { "nvim-lua/plenary.nvim", branch = "master" },
    { "zbirenbaum/copilot.lua" },
  },
  branch = "main",
  build = "make tiktoken",
  event = { "BufReadPost" },
  keys = {
    { "zu", mode = { "n" } },
  },
  config = function()
    local select = require("CopilotChat.select")
    local actions = require("CopilotChat.actions")
    local telescope = require("CopilotChat.integrations.telescope")

    require("CopilotChat").setup({
      model = "claude-3.7-sonnet",
      prompts = require("r-okm.types.prompts"),
      question_header = "#  User ",
      answer_header = "#  Copilot ",
      error_header = "#  Error ",
      mappings = {
        complete = {
          detail = "Use @<Tab> or /<Tab> for options.",
          -- Default <Tab> setting conflicts with cmp and coc-nvim
          insert = "<S-Tab>",
        },
      },
      log_level = "warn",
    })

    vim.keymap.set({ "n" }, "zu", function()
      vim.cmd("CopilotChatOpen")
    end)
    vim.keymap.set({ "x" }, "zu", function()
      vim.cmd("CopilotChat")
    end)
    vim.keymap.set({ "n" }, "zi", function()
      telescope.pick(actions.prompt_actions({ selection = select.buffer }))
    end)
    vim.keymap.set({ "x" }, "zi", function()
      telescope.pick(actions.prompt_actions({ selection = select.visual }))
    end)
  end,
}
