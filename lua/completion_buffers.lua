local M = {}
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

return M
