local M = {}

---通常 visual モード時の選択範囲のテキストを取得する
---@return string|nil selected_text 選択範囲のテキスト
function M.getVisualSelection()
  -- Visualモードの確認
  local mode = vim.fn.mode()

  if mode ~= "v" then
    return nil
  else
    -- ヤンク前のテキスト
    local previous_register = vim.fn.getreg("z")
    -- Visualモードで選択された範囲をzレジスタにヤンク
    vim.cmd('noautocmd normal! "zy')
    -- zレジスタからテキストを取得
    local selected_text = vim.fn.getreg("z")
    -- 改行コードを取り除く
    selected_text = string.gsub(selected_text, "\n", "")
    -- zレジストの内容をリセット
    vim.fn.setreg("z", previous_register)

    return selected_text
  end
end

--- Splits a string into a table using comma as a delimiter
--- @param str string The string to be split
--- @return table result A table containing the split string parts
function M.split_string(str)
  local result = {}
  for word in str:gmatch("[^,]+") do
    table.insert(result, word)
  end
  return result
end

return M
