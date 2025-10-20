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

--- Splits a string into a table using the specified delimiter
--- @param str string The string to be split
--- @param delimiter string The delimiter to use for splitting
--- @return table result A table containing the split string parts
function M.split_string(str, delimiter)
  local result = {}
  local pattern = "[^" .. delimiter .. "]+"
  for word in str:gmatch(pattern) do
    table.insert(result, word)
  end
  return result
end

--- Gets the path to the project-specific Neovim configuration directory
--- The project-specific configuration directory is located in the current working directory
--- @return string dir path to the project-specific Neovim configuration directory
function M.get_project_nvim_config_dir()
  local dir_name = ".ignore/nvim"
  return vim.fn.getcwd() .. "/" .. dir_name
end

--- Creates a keymap with default options (noremap=true, silent=true)
--- This is a wrapper around vim.keymap.set that provides sensible defaults
--- @param mode string|string[] Mode "short-name" (see |nvim_set_keymap()|), or a list thereof.
--- @param lhs string           Left-hand side |{lhs}| of the mapping.
--- @param rhs string|function  Right-hand side |{rhs}| of the mapping, can be a Lua function.
--- @param opts? vim.keymap.set.Opts Optional keymap options that will be merged with defaults
function M.keymap(mode, lhs, rhs, opts)
  local default_opts = {
    noremap = true,
    silent = true,
  }
  local merged_opts = vim.tbl_deep_extend("force", default_opts, opts or {})
  vim.keymap.set(mode, lhs, rhs, merged_opts)
end

--- Opens the given URL in the default web browser
--- @param url string The URL to open
function M.open_in_browser(url)
  local open_cmd
  if vim.fn.has("mac") == 1 then
    open_cmd = "open"
  elseif vim.fn.has("unix") == 1 then
    open_cmd = "xdg-open"
  elseif vim.fn.has("win32") == 1 then
    open_cmd = "start"
  else
    vim.notify("Unsupported operating system", vim.log.levels.ERROR)
    return
  end

  local browser_cmd = string.format("%s '%s'", open_cmd, url)
  vim.fn.system(browser_cmd)
end

return M
