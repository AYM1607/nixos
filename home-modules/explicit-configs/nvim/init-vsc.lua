-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
------------- VSCode specific config ----------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------

vim.api.nvim_set_keymap('n', '<Space>', '<NOP>', {noremap = true, silent = true})
vim.g.mapleader = ' '

-- Exit insert mode with ,h.
vim.api.nvim_set_keymap('i', ',h', '<ESC>', {noremap = true, silent = true})

-- Quick save.
vim.api.nvim_set_keymap('n', '<Leader>fw', ':w<CR>', {silent = true})

-- Remap for colemak-dhm.
-- Left.
vim.api.nvim_set_keymap('', 'm', 'h', {noremap = true, silent = true})
vim.api.nvim_set_keymap('', 'h', 'm', {noremap = true, silent = true})
-- Down.
vim.api.nvim_set_keymap('', 'j', 'n', {noremap = true, silent = true})
vim.api.nvim_set_keymap('', 'n', 'j', {noremap = true, silent = true})
-- Up.
vim.api.nvim_set_keymap('', 'k', 'e', {noremap = true, silent = true})
vim.api.nvim_set_keymap('', 'e', 'k', {noremap = true, silent = true})
-- Right.
vim.api.nvim_set_keymap('', 'l', 'i', {noremap = true, silent = true})
vim.api.nvim_set_keymap('', 'i', 'l', {noremap = true, silent = true})

-- C-g as ESC
vim.api.nvim_set_keymap('n', '<C-g>', '<ESC>', {silent = true})
vim.api.nvim_set_keymap('i', '<C-g>', '<ESC>', {silent = true})
vim.api.nvim_set_keymap('v', '<C-g>', '<ESC>', {silent = true})
vim.api.nvim_set_keymap('s', '<C-g>', '<ESC>', {silent = true})
vim.api.nvim_set_keymap('x', '<C-g>', '<ESC>', {silent = true})
vim.api.nvim_set_keymap('c', '<C-g>', '<ESC>', {silent = true})
vim.api.nvim_set_keymap('o', '<C-g>', '<ESC>', {silent = true})
vim.api.nvim_set_keymap('l', '<C-g>', '<ESC>', {silent = true})
vim.api.nvim_set_keymap('t', '<C-g>', '<ESC>', {silent = true})

-- Move right when in insert mode.
vim.api.nvim_set_keymap("i", '<C-l>', '<Right>', {noremap = true, silent = true})

-- Lsp
vim.api.nvim_set_keymap('n', '<Leader>lgd', "<cmd>lua require('vscode-neovim').call('editor.action.goToDeclaration')<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>lgr', "<cmd>lua require('vscode-neovim').call('editor.action.referenceSearch.trigger')<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>lr', "<cmd>lua require('vscode-neovim').call('editor.action.rename')<CR>", {noremap = true, silent = true})

-- Tab movement.
vim.api.nvim_set_keymap('n', '<Leader>m', "<cmd>lua require('vscode-neovim').call('workbench.action.previousEditorInGroup')<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>i', "<cmd>lua require('vscode-neovim').call('workbench.action.nextEditorInGroup')<CR>", {noremap = true, silent = true})
