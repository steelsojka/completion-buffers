local M = {}
local api = vim.api
local match = require "completion.matching"

M.buffer_to_words = {}

local ignored_fts = nil

local function get_option(bufnr, name, default)
  local success, value = pcall(function() return api.nvim_buf_get_var(bufnr, name) end)

  if success then
    return value
  end

  success, value = pcall(function() return api.nvim_get_var(name) end)

  if success then
    return value
  end

  return default
end

local function is_ignored_ft(ft, bufnr)
  if not ignored_fts then
    ignored_fts = {}

    local ignored_list = get_option(bufnr, "completion_word_ignored_ft", {})

    for _, ignored_ft in ipairs(ignored_list) do
      ignored_fts[ignored_ft] = true
    end
  end

  return ignored_fts[ft]
end

function M.caching_buffers_word()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })

  for _, buf in ipairs(bufs) do
    local ft = api.nvim_buf_get_option(buf.bufnr, 'ft')

    if not is_ignored_ft(ft, buf.bufnr) and not M.buffer_to_words[buf.bufnr] then
      M.buffer_to_words[buf.bufnr] = M.get_words(buf.bufnr)
    end
  end
end


function M.get_words(bufnr)
  local separator = get_option(bufnr, "completion_word_separator", "[^a-zA-Z0-9\\-_]")
  local min_length = get_option(bufnr, "completion_word_min_length", 3)
  -- safeguard invalid bufnr
  local lines = bufnr>=0 and api.nvim_buf_get_lines(bufnr, 0, -1, true) or {}
  local parts = vim.fn.split(vim.fn.join(lines), separator)
  local words = {}

  for _,part in ipairs(parts) do
    if #part >= min_length and not words[part] then
      words[part] = true
    end
  end

  return words
end

function M.unload_buffer_words(bufnr)
  if M.buffer_to_words[bufnr] then
    M.buffer_to_words[bufnr] = nil
  end
end

function M.get_all_buffer_words()
  local current_buf = api.nvim_get_current_buf()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  local result = {}

  -- only need to refresh current buffers word
  M.buffer_to_words[current_buf] = M.get_words(current_buf)

  for _,buf in ipairs(bufs) do
    if M.buffer_to_words[buf.bufnr] then
      result = vim.tbl_extend("keep", M.buffer_to_words[buf.bufnr], result)
    end
  end

  return result
end

function M.get_completion_items(words, prefix, kind)
  local complete_items = {}
  local customized_labels = vim.g.completion_customize_lsp_label

  for _,word in ipairs(words) do
    if word ~= prefix then
      match.matching(complete_items, prefix, {
        word = word;
        kind = customized_labels[kind] or kind;
        icase = 1;
        dup = 0;
        empty = 0;
      })
    end
  end

  return complete_items
end

function M.get_buffers_completion_items(prefix)
  return M.get_completion_items(vim.tbl_keys(M.get_all_buffer_words()), prefix, "Buffers")
end

function M.get_buffer_completion_items(prefix)
  return M.get_completion_items(vim.tbl_keys(M.get_words(api.nvim_get_current_buf())), prefix, "Buffer")
end

return M
