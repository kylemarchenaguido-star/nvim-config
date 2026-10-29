return {
  "kawre/leetcode.nvim",
  build = ":TSUpdate html",
  cmd = "Leet",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "ibhagwan/fzf-lua",               -- LazyVim's default picker
    -- "nvim-telescope/telescope.nvim", -- use this instead if you prefer telescope
  },
  opts = {
    lang = "cpp",
    -- allow :Leet from a normal session (otherwise it refuses when any buffer is open)
    plugins = { non_standalone = true },
  },
}
