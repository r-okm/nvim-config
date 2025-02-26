return {
  "nvim-treesitter/nvim-treesitter",
  -- dependencies = {
  --   { "nvim-treesitter/nvim-treesitter-textobjects" },
  -- },
  build = { ":TSUpdate" },
  event = { "BufReadPost" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "bash",
        "css",
        "diff",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "html",
        "java",
        "javascript",
        "jq",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "markdown",
        "markdown_inline",
        "proto",
        "python",
        "rust",
        "scss",
        "terraform",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      highlight = {
        disable = function(_, bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > 5000
        end,
      },
      --[[ textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["ap"] = "@parameter.outer",
            ["ip"] = "@parameter.inner",
          },
          selection_modes = {
            ["@function.outer"] = "V",
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<Space>a"] = "@parameter.inner",
          },
          swap_previous = {
            ["<Space>A"] = "@parameter.inner",
          },
        },
      }, ]]
    })

    vim.cmd([[
      set nofoldenable
      set foldmethod=expr
      set foldexpr=nvim_treesitter#foldexpr()
    ]])
  end,
}
