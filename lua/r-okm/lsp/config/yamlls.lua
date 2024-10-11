local SERVER_NAME = "yamlls"
local default_config = require("r-okm.lsp.config").get_default_config(SERVER_NAME)
local deep_table_concat = require("r-okm.util").deep_table_concat

return deep_table_concat(default_config, {
  setup_args = {
    settings = {
      yaml = {
        schemaStore = {
          -- You must disable built-in schemaStore support if you want to use
          -- this plugin and its advanced options like `ignore`.
          enable = false,
          -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
          url = "",
        },
        schemas = require("schemastore").yaml.schemas(),
        customTags = {
          "!Base64 scalar",
          "!Cidr scalar",
          "!And sequence",
          "!Equals sequence",
          "!If sequence",
          "!Not sequence",
          "!Or sequence",
          "!Condition scalar",
          "!FindInMap sequence",
          "!GetAtt scalar",
          "!GetAtt sequence",
          "!GetAZs scalar",
          "!ImportValue scalar",
          "!Join sequence",
          "!Select sequence",
          "!Split sequence",
          "!Sub scalar",
          "!Transform mapping",
          "!Ref scalar",
        },
      },
    },
  },
  buffer_config = {
    format_enable = false,
    buf_write_pre_enable = false,
  },
})
