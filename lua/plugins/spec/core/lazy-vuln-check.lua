---@type LazyPluginSpec
return {
  dir = vim.fn.stdpath("config"),
  name = "lazy-vuln-check",
  lazy = false,
  config = function()
    require("r-okm.lazy_vuln_check").setup({
      model = "opus",
      max_diff_bytes = 400 * 1024,
      save_to_file = true,
    })
  end,
}
