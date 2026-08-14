-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- ~/.local/bin is put on PATH by ~/.profile and ~/.bashrc, but neither is sourced
-- when nvim starts outside an interactive shell (WSL launcher, desktop shortcut).
-- Jobs nvim spawns inherit vim.env.PATH, so without this the claude CLI, LSP
-- servers and formatters installed there are invisible to jobstart().
local local_bin = vim.fn.expand("~/.local/bin")
if not string.find(":" .. vim.env.PATH .. ":", ":" .. local_bin .. ":", 1, true) then
  vim.env.PATH = local_bin .. ":" .. vim.env.PATH
end

-- Hide the tabline (tab bar) to reclaim vertical space for code.
vim.o.showtabline = 0
