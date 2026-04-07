---@type LazyPluginSpec
return {
  "https://github.com/zbirenbaum/copilot.lua",
  cmd = { "Copilot" },
  event = { "InsertEnter" },
  config = function()
    require("copilot").setup({
      panel = {
        enabled = false,
      },
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = false,
          next = false,
          prev = false,
        },
      },
      filetypes = {
        markdown = true,
        gitcommit = true,
      },
    })

    -- Workaround: copilot attaches to quickfix buffers before buftype is set
    -- (e.g. Telescope <C-q> triggers BufEnter in insert mode with empty buftype).
    -- Detach copilot once FileType qf fires and properties are available.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "qf",
      callback = function(args)
        local client = require("copilot.client")
        if client.buf_is_attached(args.buf) then
          vim.lsp.buf_detach_client(args.buf, client.id)
        end
      end,
    })
  end,
}
