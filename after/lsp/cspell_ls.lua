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

local disabled_filetypes = {
  "toggleterm",
  "DiffviewFileHistory",
}

---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    -- Disable LSP for specified filetypes
    if vim.tbl_contains(disabled_filetypes, vim.bo[bufnr].filetype) then
      return
    end

    -- Only enable LSP when cspell config file exists
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.root(fname, markers)
    -- If no config file found, don't call on_dir to disable LSP
    if root then
      on_dir(root)
    end
  end,
}
