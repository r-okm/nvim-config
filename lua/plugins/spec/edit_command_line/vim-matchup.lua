local util = require("r-okm.util")

---@type LazyPluginSpec
return {
  "https://github.com/andymass/vim-matchup",
  init = function()
    vim.g.matchup_treesitter_stopline = 500
    vim.g.matchup_treesitter_enable_quotes = true
    vim.g.matchup_treesitter_disable_virtual_text = true
    vim.g.matchup_treesitter_include_match_words = true

    -- treesitter highlight is skipped for large buffers, which makes matchup's treesitter backend
    -- reparse the whole buffer on every cursor move
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("vim-matchup-large-buffer", {}),
      callback = function(ctx)
        if util.is_large_buffer(ctx.buf) then
          vim.b[ctx.buf].matchup_treesitter_enabled = false
        else
          -- reset to nil (not true) so a buffer that shrinks below the threshold falls back to the global setting
          vim.b[ctx.buf].matchup_treesitter_enabled = nil
        end
      end,
    })
  end,
}
