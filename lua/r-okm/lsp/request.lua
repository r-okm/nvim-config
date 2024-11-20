local M = {}

--- @return vim.lsp.Client
local function _get_active_client_by_name(bufnr, name)
  return require("lspconfig.util").get_active_client_by_name(bufnr, name)
end

local function _validate_bufnr(bufnr)
  return require("lspconfig.util").validate_bufnr(bufnr)
end

local function _default_code_action_handler(err, actions, ctx, config)
  config = config or {}
  if err then
    error(err)
  end
  if not actions or #actions == 0 then
    return
  end

  local function on_action(action)
    if not action then
      return
    end
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    else
      client.request("codeAction/resolve", action, _default_code_action_handler, ctx.bufnr)
    end
  end

  if #actions == 1 then
    on_action(actions[1])
  end
end

--- send `textDocument/codeAction` request to LSP server
--- @param opts CodeActionOpts options
function M.code_action(opts)
  local kinds = opts.kinds
  local client = opts.client
  local bufnr = opts.bufnr

  if type(kinds) == "string" then
    kinds = { kinds }
  end

  if type(client) == "string" then
    client = _get_active_client_by_name(bufnr, client)
  end

  local text_document = vim.lsp.util.make_text_document_params(bufnr)
  local diagnostics = vim.diagnostic.get(bufnr, {
    namespace = vim.lsp.diagnostic.get_namespace(client.id),
  })
  local lsp_diagnostics = vim.tbl_map(function(d)
    return {
      range = {
        start = {
          line = d.lnum,
          character = d.col,
        },
        ["end"] = {
          line = d.end_lnum,
          character = d.end_col,
        },
      },
      severity = d.severity,
      message = d.message,
      source = d.source,
      code = d.code,
      data = d.user_data and (d.user_data.lsp or {}),
    }
  end, diagnostics)

  bufnr = _validate_bufnr(bufnr)
  client.request("textDocument/codeAction", {
    textDocument = text_document,
    range = {
      start = {
        line = 0,
        character = 0,
      },
      ["end"] = {
        line = vim.api.nvim_buf_line_count(bufnr),
        character = 0,
      },
    },
    context = {
      only = kinds,
      triggerKind = 1, -- vim.lsp.protocol.CodeActionTriggerKind.Invoked
      diagnostics = lsp_diagnostics,
    },
  }, _default_code_action_handler, bufnr)
end

--- send `workspace/executeCommand` request to LSP server
--- @param opts ExecuteCommandOpts options
function M.execute_command(opts)
  local client = opts.client
  local bufnr = opts.bufnr or 0

  if type(client) == "string" then
    client = _get_active_client_by_name(bufnr, client)
  end

  local request
  if opts.sync then
    request = function(bufnr_r, method, params)
      client.request_sync(method, params, nil, bufnr_r)
    end
  else
    request = function(bufnr_r, method, params)
      client.request(method, params, nil, bufnr_r)
    end
  end

  bufnr = _validate_bufnr(bufnr)
  request(bufnr, "workspace/executeCommand", {
    command = opts.command,
    arguments = {
      {
        uri = vim.uri_from_bufnr(bufnr),
        version = vim.lsp.util.buf_versions[bufnr],
      },
    },
  })
end

return M

--- @class CodeActionOpts
--- @field kinds string[]
--- @field sync boolean
--- @field client vim.lsp.Client | string
--- @field bufnr? number

--- @class ExecuteCommandOpts
--- @field command string
--- @field sync boolean
--- @field client vim.lsp.Client | string
--- @field bufnr? number

--- @class vim.lsp.Client
--- @field id number
--- @field request function
--- @field request_sync function
