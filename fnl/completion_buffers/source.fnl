(local matching (require "completion.matching"))
(local buffer-to-words {})
(var ignored-fts nil)

(fn get-option [bufnr name default]
  (let [(ok value) (pcall #(vim.api.nvim_buf_get_var bufnr name))]
    (if (not ok)
      (let [(global-ok g-value) (pcall #(vim.api.nvim_get_var name))]
        (if (not global-ok) default g-value))
      value)))

(fn is-ignored-ft [ft bufnr]
  (when (not ignored-fts)
    (set ignored-fts {})
    (let [ignored-list (get-option bufnr "completion_word_ignored_ft" [])]
      (each [_ ignored-ft (ipairs ignored-list)]
        (tset ignored-fts ignored-ft true))))
  (. ignored-fts ft))

(fn get-words [bufnr]
  (let [separator (get-option bufnr "completion_word_separator" "[^a-zA-Z0-9\\-_]")
        min-length (get-option bufnr "completion_word_min_length" 3)
        lines (if (>= bufnr 0) (vim.api.nvim_buf_get_lines bufnr 0 -1 true) [])
        parts (-> (vim.fn.join lines) (vim.fn.split separator))
        words {}]
    (each [_ part (ipairs parts)]
      (when (and (-> (length part) (>= min-length)) (not (. words part)))
        (tset words part true)))
    words))

(fn caching-buffer-words []
  (let [bufs (vim.fn.getbufinfo {:buflisted 1})]
    (each [_ buf (ipairs bufs)]
      (let [ft (vim.api.nvim_buf_get_option buf.bufnr "ft")
            is-ignored (is-ignored-ft ft buf.bufnr)]
        (when (and (not is-ignored) (not (. buffer-to-words buf.bufnr)))
          (tset buffer-to-words buf.bufnr (get-words buf.bufnr)))))))

(fn unload-buffer-words [bufnr]
  (when (. buffer-to-words bufnr)
    (tset buffer-to-words bufnr nil)))

(fn get-all-buffer-words []
  (let [current-buf (vim.api.nvim_get_current_buf)
        bufs (vim.fn.getbufinfo {:buflisted 1})]
    (var result {})
    (->> (get-words current-buf) (tset buffer-to-words current-buf))
    (each [_ buf (ipairs bufs)]
      (when (. buffer-to-words buf.bufnr)
        (set result (vim.tbl_extend "keep" (. buffer-to-words buf.bufnr) result))))
    result))

(fn get-completion-items [words prefix kind]
  (let [custom-labels vim.g.completion_customize_lsp_label]
    (var complete-items [])
    (each [_ word (ipairs words)]
      (when (~= word prefix)
        (matching.matching complete-items
                           prefix
                           {: word
                            :icase 1
                            :dup 0
                            :empty 0
                            :kind (or (. custom-labels kind) kind)})))
    complete-items))


(fn get-buffers-completion-items [prefix]
  (-> (get-all-buffer-words)
      (vim.tbl_keys)
      (get-completion-items prefix "Buffers")))

(fn get-buffer-completion-items [prefix]
  (-> (vim.api.nvim_get_current_buf)
      (get-words)
      (vim.tbl_keys)
      (get-completion-items prefix "Buffer")))

{:get_buffer_completion_items get-buffer-completion-items
 :get_buffers_completion_items get-buffers-completion-items
 :caching_buffer_words caching-buffer-words
 :unload_buffer_words unload-buffer-words}
