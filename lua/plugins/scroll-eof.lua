-- Vim's `scrolloff` (set to 999 in options.lua for a centered cursor) is
-- ignored once you're near the end of the buffer, since vim won't scroll
-- blank space in below the last line -- that's the "stuck, can't center the
-- last lines without padding them with blank lines" behavior. This plugin
-- fakes that trailing blank space so scrolloff keeps working right up to EOF.
return {
  {
    "Aasim-A/scrollEOF.nvim",
    event = { "CursorMoved", "WinScrolled" },
    opts = {
      -- Also center while typing, since that's when this matters most.
      insert_mode = true,
    },
  },
}
