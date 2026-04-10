---@type LazyPluginSpec
return {
  "https://github.com/vim-jp/vimdoc-ja",
  branch = "master",
  build = "git restore doc/tags-ja",
}
