-- Permanently disable LSP inlay hints (the inline type/param hints LazyVim
-- turns on by default). <leader>uh still exists to toggle at runtime if
-- ever wanted, but nvim now starts with them off.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  },
}
