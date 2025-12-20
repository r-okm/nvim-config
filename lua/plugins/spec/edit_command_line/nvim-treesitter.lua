---@type LazyPluginSpec
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = { ":TSUpdate" },
  lazy = false,
  init = function()
    vim.treesitter.language.register("bash", { "sh", "zsh" })
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("vim-treesitter-start", {}),
      pattern = {
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
      callback = function(ctx)
        if vim.api.nvim_buf_line_count(ctx.buf) > 5000 then
          return
        end

        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
