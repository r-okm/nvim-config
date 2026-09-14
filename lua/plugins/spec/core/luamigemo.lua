---@type LazyPluginSpec
return {
  "https://github.com/delphinus/luamigemo",
  dependencies = {
    -- The bundled BSD dictionary lacks compound nouns (議事録, 設計書, ...); this SKK-derived one has them
    "https://github.com/oguna/migemo-compact-dict-latest",
  },
  -- The dictionary load takes ~60ms; pay it after startup rather than on the first `?`
  event = "VeryLazy",
  keys = {
    { "?", ":<C-u>Kensaku ", mode = { "n" } },
  },
  config = function()
    local migemo = require("luamigemo")
    local dict_path = vim.api.nvim_get_runtime_file("migemo-compact-dict", false)[1]
    if not dict_path then
      vim.notify(
        "luamigemo: migemo-compact-dict-latest is not installed, falling back to the bundled dictionary",
        vim.log.levels.WARN
      )
    end
    -- Not migemo.query(): it re-creates the singleton with the bundled dictionary
    local m = migemo.get(dict_path)

    vim.api.nvim_create_user_command("Kensaku", function(opts)
      local pattern = migemo.VIM_PREFIX .. m:query(opts.args, migemo.RXOP_VIM)
      vim.fn.setreg("/", pattern)
      vim.fn.histadd("/", pattern)
      vim.v.errmsg = ""
      vim.cmd("silent! normal! n")
      if vim.v.errmsg ~= "" then
        vim.notify(vim.v.errmsg, vim.log.levels.ERROR)
      end
    end, { nargs = "+", desc = "kensaku: search Japanese text in the buffer with romaji (migemo)" })
  end,
}
