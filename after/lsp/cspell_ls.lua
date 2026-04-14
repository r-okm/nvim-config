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

    -- Workaround: cspell-lsp crashes with URIError on paths containing '%'
    -- https://github.com/r-okm/project-ignores/blob/a51a5e7279c7cf021ae1a759782a1ee277d18d5f/projects/%25github.com%25r-okm%25nvim-config/.ignore/ai/cspell-lsp-uri-malformed-bug.md
    if fname:find("%%") then
      return
    end

    local root = vim.fs.root(fname, markers)
    -- If no config file found or root is not absolute, don't call on_dir to disable LSP
    if root and vim.startswith(root, "/") then
      on_dir(root)
    end
  end,
}
