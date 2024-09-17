local M = {}

M.is_session_enable = function()
  return os.getenv("NEOVIM_SESSION_ENABLE") and os.getenv("NEOVIM_SESSION_ENABLE") ~= "0"
end

M.get_session_file_name = function()
  return os.getenv("NEOVIM_SESSION_FILE_NAME") or ".session.vim"
end

return M
