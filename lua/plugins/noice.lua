-- Keep noice.nvim (cmdline icons/highlighting, completion popup, messages) but
-- draw the cmdline at the bottom of the screen like vanilla nvim, instead of
-- the floating box LazyVim places in the upper middle.
return {
  "folke/noice.nvim",
  opts = {
    cmdline = { view = "cmdline" },
    presets = { command_palette = false },
  },
}
