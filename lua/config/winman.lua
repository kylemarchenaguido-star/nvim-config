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

local src = vim.fn.stdpath("config") .. "\\scripts\\man-wsl\\man.c"
-- (re)build when missing, or when man.c has changed since the last build
local stale = vim.fn.executable(exe) == 0 or vim.fn.getftime(src) > vim.fn.getftime(exe)

if stale then
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

  -- man.exe caches lookups/renders for 3 days (see man.c). Pages that already
  -- exist never change, so that is safe; this clears it if you ever need to.
  vim.api.nvim_create_user_command("ManCacheClear", function()
    local dir = vim.fn.stdpath("data") .. "\\man-cache"
    local n = 0
    for _, f in ipairs(vim.fn.glob(dir .. "\\*", false, true)) do
      if vim.fn.delete(f) == 0 then
        n = n + 1
      end
    end
    vim.notify(("man cache cleared (%d entries)"):format(n))
  end, { desc = "Clear the Windows man.exe lookup cache" })
end
