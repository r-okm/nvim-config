local vtsls = require("vtsls")

---@type vim.lsp.Config
return {
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
    typescript = {
      preferences = {
        importModuleSpecifierPreference = "non-relative",
        importModuleSpecifier = "non-relative",
      },
    },
  },
  on_attach = function(_, bufnr)
    vim.keymap.set("n", "go", function()
      vtsls.commands.organize_imports(bufnr)
    end, { buffer = bufnr })
    vim.keymap.set("n", "ge", function()
      pcall(vim.cmd, "EslintFixAll")
      vtsls.commands.add_missing_imports(bufnr)
    end, { buffer = bufnr })
  end,
}
