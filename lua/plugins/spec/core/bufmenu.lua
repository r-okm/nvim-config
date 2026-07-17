---@type LazyPluginSpec
return {
  dir = vim.fn.stdpath("config") .. "/lua/r-okm/bufmenu",
  name = "bufmenu",
  -- BufReadPre は新規 (未作成) ファイルでは発火しないため BufNewFile も必要
  event = { "BufReadPre", "BufNewFile" },
  -- bufmenu はグローバルキーマップを登録しない。キー割当はここで行う
  keys = {
    {
      "<C-l>",
      function()
        require("r-okm.bufmenu").cycle(1)
      end,
      mode = { "n", "x" },
      desc = "BufMenu: Cycle to next buffer",
    },
    {
      "<C-h>",
      function()
        require("r-okm.bufmenu").cycle(-1)
      end,
      mode = { "n", "x" },
      desc = "BufMenu: Cycle to previous buffer",
    },
    {
      "L",
      function()
        require("r-okm.bufmenu").move(1)
      end,
      mode = { "n", "x" },
      desc = "BufMenu: Move buffer right",
    },
    {
      "H",
      function()
        require("r-okm.bufmenu").move(-1)
      end,
      mode = { "n", "x" },
      desc = "BufMenu: Move buffer left",
    },
    {
      -- Shift+; (JIS 配列)
      "+",
      function()
        require("r-okm.bufmenu").toggle_style()
      end,
      mode = { "n" },
      desc = "BufMenu: Toggle style (full/dashed)",
    },
    {
      ";",
      function()
        require("r-okm.bufmenu").jump()
      end,
      mode = { "n" },
      desc = "BufMenu: Jump to buffer by label",
    },
  },
  init = function()
    -- 並び順の永続化 (vim.g.BufMenuOrder) はセッションの globals 保存に依存する
    vim.opt.sessionoptions:append("globals")
  end,
  config = function()
    require("r-okm.bufmenu").setup()
  end,
}
