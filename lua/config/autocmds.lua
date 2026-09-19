-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ---------------------------------------------------------------------------
-- Autosave — the equivalent of VS Code's  files.autoSave = "afterDelay"
--
-- Writes every eligible modified buffer once you stop typing for `delay` ms,
-- so `:wall` is no longer needed. Toggle at runtime with <leader>uW.
-- ---------------------------------------------------------------------------
local autosave = {
  enabled = true,
  delay = 1000, -- ms of idle before the write. VS Code's own default is 1000.
}

-- Formatting is deliberately SKIPPED on an autosave write.
--
-- That is what VS Code does too — formatOnSave does not run for `afterDelay`
-- autosaves, only for an explicit save. It matters more here: LazyVim turns
-- format-on-save on by default, and a repo with no `.clang-format` makes
-- clangd fall back to LLVM style, so autosave would silently reformat the whole
-- C++ file every second while you are mid-edit. An explicit `:w` still formats.
local function write(buf)
  local saved = vim.b[buf].autoformat
  vim.b[buf].autoformat = false
  vim.api.nvim_buf_call(buf, function()
    -- lockmarks: an automated write must not move the marks you set by hand
    vim.cmd("silent! lockmarks write")
  end)
  vim.b[buf].autoformat = saved
end

local function eligible(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].modified then
    return false
  end
  -- buftype ~= "" covers terminal, quickfix, help, prompt and the file explorer
  if vim.bo[buf].buftype ~= "" then
    return false
  end
  if not vim.bo[buf].modifiable or vim.bo[buf].readonly then
    return false
  end
  -- an unnamed buffer has nowhere to be written to
  if vim.api.nvim_buf_get_name(buf) == "" then
    return false
  end
  local ft = vim.bo[buf].filetype
  return ft ~= "gitcommit" and ft ~= "gitrebase"
end

local function save_all()
  if not autosave.enabled then
    return
  end
  -- a write landing mid-macro becomes part of what the recording replays
  if vim.fn.reg_recording() ~= "" then
    return
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if eligible(buf) then
      pcall(write, buf)
    end
  end
end

local timer = assert((vim.uv or vim.loop).new_timer())

vim.api.nvim_create_autocmd({
  "TextChanged", -- changed in normal mode
  "TextChangedI", -- changed in insert mode; drop this one if you would rather
  -- only save on leaving insert
  "InsertLeave",
}, {
  group = vim.api.nvim_create_augroup("autosave", { clear = true }),
  callback = function()
    if not autosave.enabled then
      return
    end
    -- restarting the timer on every keystroke is the point: the write lands
    -- `delay` ms after you STOP, not every `delay` ms while you type
    timer:stop()
    timer:start(autosave.delay, 0, vim.schedule_wrap(save_all))
  end,
})

-- Deferred to VeryLazy: this file is loaded from LazyVim's setup(), which runs
-- before snacks.nvim has set the global, so registering the toggle inline throws
-- "attempt to index global 'Snacks'" and takes the whole file down with it.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    Snacks.toggle({
      name = "Auto Save",
      get = function()
        return autosave.enabled
      end,
      set = function(state)
        autosave.enabled = state
        if not state then
          timer:stop()
        end
      end,
    }):map("<leader>uW")
  end,
})


-- Every filetype's ftplugin sets 'formatoptions' with `r`/`o`, which is why
-- hitting <Enter> after (or pressing `o`/`O` on) a `//`/`#`/etc. comment line
-- auto-inserts the same comment leader on the next line. Strip them back out
-- on every FileType event -- this fires after the language ftplugin has
-- already set them, so it wins regardless of language (cpp, python, lua...).
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  group = vim.api.nvim_create_augroup("no_auto_comment_leader", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})
