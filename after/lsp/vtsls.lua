local vtsls = require("vtsls")
local util = require("r-okm.util")

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
    util.keymap("n", "go", function()
      vtsls.commands.organize_imports(bufnr)
    end, { buffer = bufnr })
    util.keymap("n", "ge", function()
      pcall(vim.cmd, "LspEslintFixAll")
      vtsls.commands.add_missing_imports(bufnr)
    end, { buffer = bufnr })
  end,
}
