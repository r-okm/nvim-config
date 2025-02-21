return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "nvim-telescope/telescope.nvim" },
    { "nvim-lua/plenary.nvim", branch = "master" },
    { "github/copilot.vim" },
  },
  branch = "main",
  event = { "BufReadPost" },
  keys = {
    { "zu", mode = { "n" } },
  },
  config = function()
    local chat = require("CopilotChat")
    local select = require("CopilotChat.select")
    local actions = require("CopilotChat.actions")
    local prompts = require("CopilotChat.config.prompts")
    local telescope = require("CopilotChat.integrations.telescope")

    prompts.Japanese = "Translate the provided English sentence into Japanese."
    prompts.English = "Translate the provided Japanese sentence into English."
    prompts.CommitEditmsg = {
      prompt = "Write commit message for the change. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit. Proper nouns should be enclosed in backquotes. Use bullet points for descrptions. Summay must begin with a simple topic name followed by a colon.",
      selection = select.buffer,
    }

    prompts.Review.callback = function(_, _)
      -- highlight を無効にするため、何もしない
      -- https://github.com/CopilotC-Nvim/CopilotChat.nvim/issues/362#issuecomment-2241158016
    end

    chat.setup({
      model = "o3-mini",
      prompts = prompts,
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
