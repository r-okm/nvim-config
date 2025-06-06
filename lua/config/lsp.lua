local _ENALBED_LANGUAGE_SERVERS = {
  "bashls",
  "buf_ls",
  "cssls",
  "docker_compose_language_service",
  "dockerls",
  "eslint",
  "jdtls",
  "jsonls",
  "lemminx",
  "lua_ls",
  "pyright",
  "rust_analyzer",
  "sqls",
  "taplo",
  "terraformls",
  "vtsls",
  "yamlls",
}

vim.lsp.config("*", {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

vim.lsp.enable(_ENALBED_LANGUAGE_SERVERS)
