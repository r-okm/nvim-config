local M = {}

---通常 visual モード時の選択範囲のテキストを取得する
---@return string|nil selected_text 選択範囲のテキスト
function M.get_visual_selection()
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

--- Gets the path to the project-specific Neovim configuration directory
--- The project-specific configuration directory is located in the current working directory
--- @return string dir path to the project-specific Neovim configuration directory
function M.get_project_nvim_config_dir()
  local dir_name = ".nvim"
  return vim.fn.getcwd() .. "/" .. dir_name
end

return M
