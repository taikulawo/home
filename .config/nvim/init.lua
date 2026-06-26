if vim.tbl_add_reverse_lookup == nil then
  vim.tbl_add_reverse_lookup = function(tbl)
    for key, value in pairs(tbl) do
      tbl[value] = key
    end
    return tbl
  end
end

if vim.tbl_islist == nil then
  vim.tbl_islist = function(tbl)
    if type(tbl) ~= "table" then
      return false
    end

    for key, _ in pairs(tbl) do
      if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
        return false
      end
    end

    return true
  end
end

vim.tbl_flatten = function(tbl)
  local result = {}
  local function flatten(value)
    if type(value) == "table" then
      for _, item in ipairs(value) do
        flatten(item)
      end
    else
      table.insert(result, value)
    end
  end
  flatten(tbl)
  return result
end

if not vim.api._user_exec_autocmds_compat then
  local nvim_exec_autocmds = vim.api.nvim_exec_autocmds
  vim.api.nvim_exec_autocmds = function(event, opts)
    opts = opts or {}
    if type(event) == "string" then
      local user_pattern = event:match("^User%s+(.+)$")
      if user_pattern then
        opts.pattern = opts.pattern or user_pattern
        event = "User"
      end
    end
    return nvim_exec_autocmds(event, opts)
  end
  vim.api._user_exec_autocmds_compat = true
end

if vim.lsp and not vim.lsp.get_active_clients and vim.lsp.get_clients then
  vim.lsp.get_active_clients = function(opts)
    opts = opts or {}
    if opts.buffer and not opts.bufnr then
      opts.bufnr = opts.buffer
      opts.buffer = nil
    end
    return vim.lsp.get_clients(opts)
  end
end

if vim.lsp and not vim.lsp.buf_get_clients and vim.lsp.get_clients then
  vim.lsp.buf_get_clients = function(bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr or 0 })
    local by_id = {}
    for _, client in ipairs(clients) do
      by_id[client.id] = client
    end
    return by_id
  end
end

if vim.lsp and vim.lsp.util and not vim.lsp.util._trim and vim.trim then
  vim.lsp.util._trim = function(lines)
    local start = 1
    local finish = #lines
    while start <= finish and vim.trim(lines[start]) == "" do
      start = start + 1
    end
    while finish >= start and vim.trim(lines[finish]) == "" do
      finish = finish - 1
    end
    return vim.list_slice(lines, start, finish)
  end
end

if vim.treesitter and vim.treesitter.query then
  local query = vim.treesitter.query

  if query.add_predicate and not query._user_duplicate_safe_add_predicate then
    local add_predicate = query.add_predicate
    query.add_predicate = function(...)
      local ok, err = pcall(add_predicate, ...)
      if not ok and type(err) == "string" and err:match("Overriding existing predicate") then
        return
      end
      if not ok then
        error(err)
      end
    end
    query._user_duplicate_safe_add_predicate = true
  end

  if query.add_directive and not query._user_duplicate_safe_add_directive then
    local add_directive = query.add_directive
    query.add_directive = function(name, handler, ...)
      local safe_handler = handler
      if name == "exclude_children!" then
        safe_handler = function(match, pattern, bufnr, pred, metadata)
          local capture_id = pred and pred[2]
          if not capture_id or not match or not match[capture_id] then
            return
          end
          return handler(match, pattern, bufnr, pred, metadata)
        end
      elseif name == "trim!" then
        safe_handler = function(match, pattern, bufnr, pred, metadata)
          if not pred then
            return
          end
          for _, id in ipairs({ select(2, unpack(pred)) }) do
            if not match or not match[id] then
              return
            end
          end
          return handler(match, pattern, bufnr, pred, metadata)
        end
      end

      local ok, err = pcall(add_directive, name, safe_handler, ...)
      if not ok and type(err) == "string" and err:match("Overriding existing directive") then
        return
      end
      if not ok then
        error(err)
      end
    end
    query._user_duplicate_safe_add_directive = true
  end
end

if vim.treesitter and vim.treesitter.start and not vim.treesitter._user_safe_start then
  local treesitter_start = vim.treesitter.start
  vim.treesitter.start = function(bufnr, lang, ...)
    local ok, result = pcall(treesitter_start, bufnr, lang, ...)
    if ok then
      return result
    end

    if type(result) == "string" and result:match("Parser could not be created") then
      local target = bufnr == nil or bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
      pcall(vim.api.nvim_set_option_value, "syntax", "ON", { buf = target })
      return
    end

    error(result)
  end
  vim.treesitter._user_safe_start = true
end

require "user.options"
require "user.keymaps"
require "user.plugins"
require "user.colorscheme"
require "user.cmp"
require "user.lsp"
require "user.telescope"
require "user.gitsigns"
require "user.treesitter"
require "user.autopairs"
require "user.comment"
require "user.nvim-tree"
require "user.bufferline"
require "user.lualine"
require "user.toggleterm"
require "user.project"
require "user.impatient"
require "user.indentline"
require "user.alpha"
require "user.whichkey"
require "user.autocommands"
