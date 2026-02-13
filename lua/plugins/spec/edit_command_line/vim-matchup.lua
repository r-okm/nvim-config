---@type LazyPluginSpec
return {
  "https://github.com/andymass/vim-matchup",
  init = function()
    vim.g.matchup_treesitter_stopline = 500
    vim.g.matchup_treesitter_enable_quotes = true
    vim.g.matchup_treesitter_disable_virtual_text = true
    vim.g.matchup_treesitter_include_match_words = true
  end,
}
