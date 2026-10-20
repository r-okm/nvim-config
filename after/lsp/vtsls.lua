local vtsls = require("vtsls")
local util = require("r-okm.util")

---@type vim.lsp.Config
return {
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
      tsserver = {
        globalPlugins = {
          {
            name = "@css-modules-kit/ts-plugin",
            location = "",
            enableForWorkspaceTypeScriptVersions = true,
          },
        },
      },
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
    -- Checked at keypress so the result doesn't depend on whether biome attaches before or after vtsls.
    local function biome_attached()
      return #vim.lsp.get_clients({ bufnr = bufnr, name = "biome" }) > 0
    end
    local function biome_action(kind)
      vim.lsp.buf.code_action({ context = { only = { kind }, diagnostics = {} }, apply = true })
    end

    util.keymap("n", "ga", function()
      vtsls.commands.add_missing_imports(bufnr)
    end, { buffer = bufnr })
    util.keymap("n", "go", function()
      if biome_attached() then
        biome_action("source.organizeImports.biome")
      else
        vtsls.commands.organize_imports(bufnr)
      end
    end, { buffer = bufnr })
    util.keymap("n", "ge", function()
      if biome_attached() then
        biome_action("source.fixAll.biome")
      else
        pcall(vim.cmd, "LspEslintFixAll")
      end
    end, { buffer = bufnr })
  end,
}
