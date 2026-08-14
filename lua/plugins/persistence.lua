-- Auto-restore the session when you open a project.
--
-- persistence.nvim already ships with LazyVim and already SAVES on exit — one
-- session file per cwd under ~/.local/state/nvim/sessions/. What it does not do by
-- default is load one; you have to press <leader>qs. This adds the automatic load,
-- deliberately only for the "open the project" case.
--
-- Kept from LazyVim's defaults (do not set these unless you mean it):
--   need   = 1     only save when >=1 real file buffer is open, so quitting out of
--                  an empty nvim can never overwrite a good session with nothing
--   branch = true  a separate session per git branch, EXCEPT on main/master
return {
  {
    "folke/persistence.nvim",
    init = function()
      -- `git diff | nvim -` puts stdin in the buffer; restoring on top is wrong.
      local from_stdin = false
      vim.api.nvim_create_autocmd("StdinReadPre", {
        group = vim.api.nvim_create_augroup("persistence_autoload", { clear = true }),
        callback = function()
          from_stdin = true
        end,
      })

      vim.api.nvim_create_autocmd("VimEnter", {
        group = "persistence_autoload",
        nested = true, -- sourcing the session opens buffers; they need their own autocmds
        callback = function()
          if from_stdin then
            return
          end

          -- Restore only when nvim was pointed at a PROJECT, not at a file:
          --   nvim       -> argc 0            restore
          --   nvim .     -> argc 1, directory restore
          --   nvim foo.c -> argc 1, file      leave alone, opening one file is an explicit ask
          local argc = vim.fn.argc(-1)
          local project = argc == 0
            or (argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1)
          if not project then
            return
          end

          require("persistence").load()

          -- Only clean up if a session actually loaded — with no session file this
          -- is a fresh project and `nvim .` should keep its directory buffer so the
          -- explorer still opens. The session sets v:this_session when it sources.
          if vim.v.this_session == "" then
            return
          end

          -- `nvim .` leaves a buffer for the directory itself. mksession's own
          -- wipe-the-startup-buffer guard only catches UNNAMED buffers, so this one
          -- survives the restore and shows up in the bufferline as ".".
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.fn.buflisted(b) == 1 then
              local name = vim.api.nvim_buf_get_name(b)
              if name ~= "" and vim.fn.isdirectory(name) == 1 then
                pcall(vim.api.nvim_buf_delete, b, { force = true })
              end
            end
          end
        end,
      })
    end,
  },
}
