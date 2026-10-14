-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- ~/.local/bin is put on PATH by ~/.profile and ~/.bashrc, but neither is sourced
-- when nvim starts outside an interactive shell (WSL launcher, desktop shortcut).
-- Jobs nvim spawns inherit vim.env.PATH, so without this the claude CLI, LSP
-- servers and formatters installed there are invisible to jobstart().
-- Unix only: on Windows the ":" separator here corrupts %PATH% (which uses ";"),
-- turning C:\Windows\System32 into a broken entry and hiding curl/tar/etc.
if vim.fn.has("win32") == 0 then
  local local_bin = vim.fn.expand("~/.local/bin")
  if not string.find(":" .. vim.env.PATH .. ":", ":" .. local_bin .. ":", 1, true) then
    vim.env.PATH = local_bin .. ":" .. vim.env.PATH
  end
end

-- Hide the tabline (tab bar) to reclaim vertical space for code.
vim.o.showtabline = 0

-- Perl and Ruby host providers are unused here; disabling them silences the
-- optional :checkhealth warnings. Node and Python providers stay enabled
-- (pynvim / npm "neovim" package are installed).
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Make :terminal open PowerShell 7 (pwsh.exe) instead of cmd.exe or legacy
-- Windows PowerShell 5.1, so the profile
-- (Documents\PowerShell\Microsoft.PowerShell_profile.ps1, e.g. the
-- vsdev function that loads the MSVC dev environment) is available inside
-- nvim's terminal. Only applies on Windows -- WSL/Linux nvim keeps $SHELL.
--
-- The Store build of pwsh is only reachable through an app-execution alias, and
-- executable("pwsh") is 0 for it, so jobstart() (:terminal, Snacks terminal)
-- refuses to launch plain "pwsh". The real path under Program Files\WindowsApps
-- is versioned and can't be globbed, so it is looked up once through the Appx
-- package, cached, and only looked up again when the cached path stops existing
-- (after a PowerShell update). Falls back to Windows PowerShell 5.1.
local function find_pwsh()
  local msi = "C:\\Program Files\\PowerShell\\7\\pwsh.exe"
  if vim.fn.executable(msi) == 1 then
    return msi
  end
  local cache = vim.fn.stdpath("data") .. "\\pwsh_path.txt"
  local ok, lines = pcall(vim.fn.readfile, cache)
  if ok and lines[1] and vim.fn.executable(lines[1]) == 1 then
    return lines[1]
  end
  local out = vim.fn.system({
    "powershell",
    "-NoLogo",
    "-NoProfile",
    "-Command",
    "(Get-AppxPackage Microsoft.PowerShell).InstallLocation",
  })
  local path = vim.trim(out) .. "\\pwsh.exe"
  if vim.v.shell_error == 0 and vim.fn.executable(path) == 1 then
    pcall(vim.fn.writefile, { path }, cache)
    return path
  end
  return "powershell"
end

if vim.fn.has("win32") == 1 then
  -- quoted: nvim splits 'shell' on spaces, and the Store path has some
  vim.o.shell = '"' .. find_pwsh() .. '"'
  vim.o.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  vim.o.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
  vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
end
