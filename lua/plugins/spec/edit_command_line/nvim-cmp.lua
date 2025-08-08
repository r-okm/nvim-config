local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "hrsh7th/nvim-cmp",
  branch = "main",
  dependencies = {
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-cmdline" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/vim-vsnip" },
    { "hrsh7th/cmp-vsnip" },
    { "zbirenbaum/copilot.lua" },
  },
  event = { "CmdlineEnter", "InsertEnter" },
  config = function()
    local cmp = require("cmp")

    cmp.setup({
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end,
      },
      sources = cmp.config.sources({
        { name = "lazydev" },
        { name = "nvim_lsp" },
        { name = "vsnip" },
      }, {
        { name = "buffer" },
      }),
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        -- https://github.com/zbirenbaum/copilot.lua/issues/91#issuecomment-1345190310
        ["<Tab>"] = cmp.mapping(function(fallback)
          if require("copilot.suggestion").is_visible() then
            cmp.abort()
            require("copilot.suggestion").accept()
          elseif not cmp.abort() then
            fallback()
          end
        end),
      }),
      window = {
        completion = {
          border = "rounded",
          winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        },
        documentation = {
          border = "rounded",
        },
      },
    })
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "buffer" },
      }),
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
    })

    util.keymap({ "i", "s" }, "<C-w>", "<Plug>(vsnip-jump-next)")
    util.keymap({ "i", "s" }, "<C-b>", "<Plug>(vsnip-jump-prev)")
    vim.g["vsnip_snippet_dirs"] = { "$HOME/.config/nvim/snippets", util.get_project_nvim_config_dir() .. "/snippets" }
    vim.g["vsnip_filetypes"] = {
      javascriptreact = { "javascript" },
      typescriptreact = { "typescript" },
    }
  end,
}
