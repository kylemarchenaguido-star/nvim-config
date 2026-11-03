-- Man pages on Windows: make nvim's :Man, K and the man-page picker read the
-- man pages installed in WSL (C library, POSIX, C++ via cppman).
--
-- nvim looks for an executable called "man". Windows has none, so a tiny
-- man.exe (scripts/man-wsl/man.c) forwards to `wsl.exe -e man`. It is compiled
-- once, on first start, into nvim's data dir, and that dir is put on nvim's
-- PATH. Windows only -- on Linux/WSL the real `man` is used.
if vim.fn.has("win32") == 0 then
  return
end

local bin_dir = vim.fn.stdpath("data") .. "\\bin"
local exe = bin_dir .. "\\man.exe"

if vim.fn.executable(exe) == 0 then
  local src = vim.fn.stdpath("config") .. "\\scripts\\man-wsl\\man.c"
  if vim.fn.executable("gcc") == 1 and vim.fn.filereadable(src) == 1 then
    vim.fn.mkdir(bin_dir, "p")
    vim.fn.system({ "gcc", "-O2", "-o", exe, src })
  end
end

if vim.fn.executable(exe) == 1 then
  vim.env.PATH = bin_dir .. ";" .. vim.env.PATH
  -- :Man sets MANPAGER=cat and MANWIDTH for the man it runs; wsl.exe only
  -- forwards variables named in WSLENV.
  local wslenv = (vim.env.WSLENV or ""):gsub(":+$", "")
  vim.env.WSLENV = (wslenv ~= "" and (wslenv .. ":") or "") .. "MANPAGER:MANWIDTH"
end
