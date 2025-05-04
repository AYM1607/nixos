require'lspconfig'.roc_ls.setup{
  offset_encoding = "utf-8",
}

-- Should get rid of this once semantic highlighting gets better!
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})
