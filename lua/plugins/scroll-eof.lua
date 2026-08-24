-- Lets scrolloff's margin extend past the end of the buffer instead of
-- getting cut off at the last line (default options everywhere -- this
-- does NOT change everyday scrolling, it just stops it from behaving
-- differently once you're near EOF). Actual "center the screen" is a
-- deliberate action via zz, see the keymap override in keymaps.lua.
return {
  {
    "Aasim-A/scrollEOF.nvim",
    event = { "CursorMoved", "WinScrolled" },
    opts = {},
  },
}
