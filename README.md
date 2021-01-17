completion-buffers
==================

A buffer completion source for [completion-nvim](https://github.com/haorenW1025/completion-nvim)

Features
--------

- Word completion from current buffer. `buffer` source.
- Word completion from listed buffers. `buffers` source.
- Configurable word separator and min length per buffer.

Install
-------

- Install with any plugin manager

`Plug 'steelsojka/completion-buffers'`

Setup
-----

The source is automatically registered. You just need to add the source to your completion configuration. See the detail in [wiki][].

[wiki]: https://github.com/nvim-lua/completion-nvim/wiki/chain-complete-support

```lua
vim.g.completion_chain_complete_list = {
  default = {
    { complete_items = { 'lsp' } },
    { complete_items = { 'buffers' } },
    { mode = { '<c-p>' } },
    { mode = { '<c-n>' } }
  },
}
```

### Configuration

- `g:completion_word_separator` - Matcher or string to split words on. Defaults to `[^a-zA-Z0-9\-_]`.
- `g:completion_word_min_length` - Matcher or string to split words on. Defaults to 3.
- `g:completion_word_ignored_ft` - A list of filetypes that should be ignored from caching/gathering words. EX logfiles.

Note these can be specified as buffer variables as well.
