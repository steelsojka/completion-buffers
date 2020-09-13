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

The source is automatically registered. You just need to add the source to your completion configuration.

```
let g:completion_chain_complete_list = [ 
  \{ complete_items = ['lsp', 'snippet'] },
  \{ complete_items = ['buffers'] },
  \{ mode = '<c-p>' },
  \{ mode = '<c-n>' }
\ ]
```

### Configuration

- `g:completion_word_separator` - Matcher or string to split words on. Defaults to `[^a-zA-Z0-9\-_]`.
- `g:completion_word_min_length` - Matcher or string to split words on. Defaults to 3.

Note these can be specified as buffer variables as well.
