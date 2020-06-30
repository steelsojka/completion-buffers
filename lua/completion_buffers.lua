local M = {}
local api = vim.api
local completion = require "completion"
local buffers = require "completion_buffers.source"

function M.add_sources()
  completion.addCompletionSource("buffers", {
    item = buffers.get_buffers_completion_items;
  })
  completion.addCompletionSource("buffer", {
    item = buffers.get_buffer_completion_items;
  })

  -- Register autocommands for caching buffer words
  api.nvim_command("augroup RefreshBufferWords")
  api.nvim_command("autocmd! *")
  api.nvim_command("autocmd BufEnter * lua require 'completion_buffers'.refresh_buffers_word()")
  api.nvim_command([[autocmd BufUnload * call luaeval('require "completion_buffers".unload_buffer_words(_A)', expand('<abuf>'))]])
  api.nvim_command("augroup end")
end

function M.refresh_buffers_word()
  buffers.caching_buffers_word()
end

function M.unload_buffer_words(bufnr)
  buffers.unload_buffer_words(bufnr)
end

return M
