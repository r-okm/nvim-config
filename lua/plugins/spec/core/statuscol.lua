return {
  "luukvbaal/statuscol.nvim",
  event = { "BufReadPre" },
  config = function()
    require("statuscol").setup({
      bt_ignore = { "terminal", "nofile", "fern" },

      relculright = true,
      segments = {
        {
          sign = {
            name = { "Diagnostic.*" },
            maxwidth = 1,
          },
        },
        {
          sign = {
            namespace = { "gitsigns" },
            maxwidth = 1,
            colwidth = 1,
            wrap = true,
          },
        },
        { text = { " " } },
        { text = { require("statuscol.builtin").lnumfunc } },
        { text = { " " } },
      },
    })
  end,
}
