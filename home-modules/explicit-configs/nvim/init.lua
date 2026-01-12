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
require('lsp.zls-ls')
require('lsp.clang-ls')
require('lsp.rust-analyzer')

-- Completion
require('completion')

require('nv-prettier')

require('nv-telescope')

-- require('langs.roc')

-- Set up keymaps after everything is configured.
require('keymappings')
