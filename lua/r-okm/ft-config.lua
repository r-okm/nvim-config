local M = {
  ["java"] = {
    format_language_server = "jdtls",
    enable_format_on_save = false,
  },
  ["lua"] = {
    format_language_server = "stylua",
    enable_format_on_save = true,
  },
  ["python"] = {
    format_language_server = "pyright",
    enable_format_on_save = false,
  },
  ["rust"] = {
    format_language_server = "rust_analyzer",
    enable_format_on_save = true,
  },
  ["sh"] = {
    format_language_server = "bashls",
    enable_format_on_save = false,
  },
  ["terraform,terraform-vars"] = {
    format_language_server = "terraformls",
    enable_format_on_save = true,
  },
  ["toml"] = {
    format_language_server = "taplo",
    enable_format_on_save = true,
  },
  ["xml"] = {
    format_language_server = "lemminx",
    enable_format_on_save = false,
  },
  ["css,javascript,javascriptreact,javascript.jsx,typescript,typescriptreact,typescript.tsx"] = {
    format_language_server = "null-ls",
    enable_format_on_save = true,
  },
  ["json,jsonc,markdown,yaml"] = {
    format_language_server = "null-ls",
    enable_format_on_save = false,
  },
}

return M
