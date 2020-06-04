local M = {}
local api = vim.api
local completion = require "completion"
local buffers = require "source.buffers"

function M.add_sources()
  completion.addCompletionSource("buffers", {
    item = buffers.get_buffers_completion_items;
  })
  completion.addCompletionSource("buffer", {
    item = buffers.get_buffer_completion_items;
  })
end

function M.refresh_buffers_word()
  buffers.caching_buffers_word()
end

do
  api.nvim_command("augroup RefreshBufferWords")
    api.nvim_command("autocmd! *")
    api.nvim_command("autocmd BufEnter <buffer> lua require'completion_buffers'.refresh_buffers_word()")
  api.nvim_command("augroup end")
end

return M
