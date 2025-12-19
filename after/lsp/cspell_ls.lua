local markers = {
  "cspell.json",
  ".cspell.json",
  ".cSpell.json",
  "cSpell.json",
  "cspell.config.js",
  "cspell.config.cjs",
  "cspell.config.json",
  "cspell.config.yaml",
  "cspell.config.yml",
  "cspell.yaml",
  "cspell.yml",
}

---@type vim.lsp.Config
return {
  -- Only enable LSP when cspell config file exists
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.root(fname, markers)
    -- If no config file found, don't call on_dir to disable LSP
    if root then
      on_dir(root)
    end
  end,
}
