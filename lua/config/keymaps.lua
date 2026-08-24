-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left, keep selection" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right, keep selection" })
vim.keymap.set("n", "gH", "H", { desc = "Jump to top of window" })
vim.keymap.set("n", "gL", "L", { desc = "Jump to bottom of window" })
vim.keymap.set("n", "<leader>jj", "<cmd>lua require('pdfview.renderer').next_page()<CR>", { desc = "PDFview: Next page" })
vim.keymap.set("n", "<leader>kk", "<cmd>lua require('pdfview.renderer').previous_page()<CR>", { desc = "PDFview: Previous page" })

-- Plain `zz` can't actually center the last few lines of a file, since vim
-- won't scroll blank space in below the last line -- it just puts the
-- cursor as low as the remaining lines allow. Bump scrolloff only for this
-- one action (scrollEOF.nvim reads it to size its EOF padding) so zz really
-- centers, even at EOF, then restore it so normal scrolling is untouched.
vim.keymap.set("n", "zz", function()
  local scrolloff = vim.o.scrolloff
  vim.o.scrolloff = 999
  vim.cmd("normal! zz")
  vim.o.scrolloff = scrolloff
end, { desc = "Center cursor line (works at EOF)" })
