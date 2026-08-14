-- Disable the intro dashboard and the file explorer sidebar.
-- persistence.nvim (see plugins/persistence.lua) already auto-restores the
-- last session when nvim is opened on a project, so with the dashboard gone
-- that's what you land in instead of an intro screen.
return {
  {
    "snacks.nvim",
    opts = {
      dashboard = { enabled = false },
      explorer = { enabled = false },
    },
  },
}
