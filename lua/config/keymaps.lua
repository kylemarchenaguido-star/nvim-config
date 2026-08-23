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
