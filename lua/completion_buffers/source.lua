local matching = require("completion.matching")
local buffer_to_words = {}
local ignored_fts = nil
local function get_option(bufnr, name, default)
  local ok, value = nil, nil
  local function _1_()
    return vim.api.nvim_buf_get_var(bufnr, name)
  end
  ok, value = pcall(_1_)
  if not ok then
    local global_ok, g_value = nil, nil
    local function _2_()
      return vim.api.nvim_get_var(name)
    end
    global_ok, g_value = pcall(_2_)
    if not global_ok then
      return default
    else
      return g_value
    end
  else
    return value
  end
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
local function get_words(bufnr)
  local separator = get_option(bufnr, "completion_word_separator", "[^a-zA-Z0-9\\-_]")
  local min_length = get_option(bufnr, "completion_word_min_length", 3)
  local lines = nil
  if (bufnr >= 0) then
    lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
  else
    lines = {}
  end
  local parts = vim.fn.split(vim.fn.join(lines), separator)
  local words = {}
  for _, part in ipairs(parts) do
    if ((#part >= min_length) and not words[part]) then
      words[part] = true
    end
  end
  return words
end
local function caching_buffer_words()
  local bufs = vim.fn.getbufinfo({buflisted = 1})
  for _, buf in ipairs(bufs) do
    local ft = vim.api.nvim_buf_get_option(buf.bufnr, "ft")
    local is_ignored = is_ignored_ft(ft, buf.bufnr)
    if (not is_ignored and not buffer_to_words[buf.bufnr]) then
      buffer_to_words[buf.bufnr] = get_words(buf.bufnr)
    end
  end
  return nil
end
local function unload_buffer_words(bufnr)
  if buffer_to_words[bufnr] then
    buffer_to_words[bufnr] = nil
    return nil
  end
end
local function get_all_buffer_words()
  local current_buf = vim.api.nvim_get_current_buf()
  local bufs = vim.fn.getbufinfo({buflisted = 1})
  local result = {}
  buffer_to_words[current_buf] = get_words(current_buf)
  for _, buf in ipairs(bufs) do
    if buffer_to_words[buf.bufnr] then
      result = vim.tbl_extend("keep", buffer_to_words[buf.bufnr], result)
    end
  end
  return result
end
local function get_completion_items(words, prefix, kind)
  local custom_labels = vim.g.completion_customize_lsp_label
  local complete_items = {}
  for _, word in ipairs(words) do
    if (word ~= prefix) then
      matching.matching(complete_items, prefix, {dup = 0, empty = 0, icase = 1, kind = (custom_labels[kind] or kind), word = word})
    end
  end
  return complete_items
end
local function get_buffers_completion_items(prefix)
  return get_completion_items(vim.tbl_keys(get_all_buffer_words()), prefix, "Buffers")
end
local function get_buffer_completion_items(prefix)
  return get_completion_items(vim.tbl_keys(get_words(vim.api.nvim_get_current_buf())), prefix, "Buffer")
end
return {caching_buffer_words = caching_buffer_words, get_buffer_completion_items = get_buffer_completion_items, get_buffers_completion_items = get_buffers_completion_items, unload_buffer_words = unload_buffer_words}