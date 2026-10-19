-- CSS isn't in LazyVim's default parser list, and without a treesitter parser
-- nvim has no highlighter for it. Listing it here installs it on every machine
-- (LazyVim merges this with its own ensure_installed list).
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "css", "scss" },
    },
  },
}
