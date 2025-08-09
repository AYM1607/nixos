require('settings')
require('nv-globals')
require('plugins')
require('colorscheme')
require('settings')

-- Must go after plugins.
require("oil").setup()

-- LSP
require('lsp')
require('lsp.typescript-ls')
require('lsp.python-ls')
require('lsp.lua-ls')
require('lsp.go-ls')
require('lsp.ocaml-ls')
require('lsp.sml-ls')
require('lsp.arduino-ls')
require('lsp.roc-ls')
require('lsp.zls-ls')
require('lsp.clang-ls')

-- Completion
require('completion')

require('nv-prettier')

require('nv-telescope')

require('langs.roc')

-- Set up keymaps after everything is configured.
require('keymappings')
