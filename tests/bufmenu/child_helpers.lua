-- 子 nvim 側に注入する観測ヘルパー。@DIR@ は harness が実行時に置換する。
-- 現在タブの bufmenu フロートの行内容・extmark ハイライト・周辺状態をファイルに書き出す
local dir = "@DIR@"

_G.MenuDump = function()
  local out = {}
  -- 現在タブのウィンドウのみ対象 (nvim_list_wins は全タブを返すため)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative ~= "" then
      local buf = vim.api.nvim_win_get_buf(win)
      for _, l in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        table.insert(out, "row:" .. l)
      end
      local ns = vim.api.nvim_get_namespaces()["r_okm_bufmenu"]
      if ns then
        local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })
        for _, m in ipairs(marks) do
          table.insert(out, string.format("hl:%d:%s", m[2], m[4].hl_group))
        end
      end
    end
  end
  if #out == 0 then
    out = { "(no menu)" }
  end
  table.insert(out, "cur:" .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t"))
  table.insert(out, "wins:" .. tostring(#vim.fn.filter(vim.api.nvim_tabpage_list_wins(0), function(_, w)
    return vim.api.nvim_win_get_config(w).relative == ""
  end)))
  table.insert(out, "loaded:" .. tostring(package.loaded["r-okm.bufmenu"] ~= nil))
  table.insert(out, "line:" .. tostring(vim.fn.line(".")))
  vim.fn.writefile(out, dir .. "/menu_dump.txt")
end
