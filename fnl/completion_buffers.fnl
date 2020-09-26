(local completion (require "completion"))
(local buffers (require "completion_buffers.source"))
(local cmd vim.api.nvim_command)

(fn add-sources []
  (completion.addCompletionSource "buffers" {:item buffers.get_buffers_completion_items})
  (completion.addCompletionSource "buffer" {:item buffers.get_buffer_completion_items})
  (cmd "augroup RefreshBufferWords")
  (cmd "autocmd! *")
  (cmd "autocmd BufEnter * lua require'completion_buffers'.refresh_buffers_word()")
  (cmd "autocmd BufUnload * call luaeval('require\"completion_buffers\".unload_buffer_words(_A)', expand('<abuf>'))")
  (cmd "augroup END"))

(fn refresh-buffers-word [] (buffers.caching_buffer_words))
(fn unload-buffer-words [bufnr] (buffers.unload_buffer_words bufnr))

{:add_sources add-sources
 :refresh_buffers_word refresh-buffers-word
 :unload_buffer_words unload-buffer-words}
