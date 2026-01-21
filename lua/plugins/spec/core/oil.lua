local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "stevearc/oil.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
  },
  branch = "master",
  lazy = false,
  config = function()
    -- 削除されたファイルのバッファを自動的に閉じる
    vim.api.nvim_create_autocmd("User", {
      pattern = "OilActionsPost",
      callback = function(args)
        if args.data.err then
          return
        end
        for _, action in ipairs(args.data.actions) do
          if action.type == "delete" then
            local path = action.url:gsub("^oil://", "")
            local bufnr = vim.fn.bufnr(path)
            if bufnr ~= -1 then
              vim.api.nvim_buf_delete(bufnr, { force = true })
            end
          end
        end
      end,
    })

    local oil = require("oil")
    oil.setup({
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<CR>"] = "actions.select",
        ["<C-l>"] = "actions.preview",
        ["q"] = { "actions.close", mode = "n" },
        ["<C-h>"] = { "actions.parent", mode = "n" },
        ["-"] = { "actions.open_cwd", mode = "n" },
      },
      use_default_keymaps = false,
      view_options = {
        show_hidden = true,
      },
    })
    util.keymap({ "n" }, "<leader>e", function()
      oil.open(nil, {
        preview = { vertical = true },
      })
    end)
    util.keymap({ "n" }, "<leader>E", function()
      oil.open()
    end)
    util.keymap("ca", "os", "e oil-ssh://")
  end,
}
