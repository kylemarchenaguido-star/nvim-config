-- markdownlint-cli2's default ruleset is very strict about style (line length,
-- blank lines around headings/lists, single top-level heading, etc.), so it
-- surfaces a different MD0xx rule almost every time you open an unrelated md
-- file. Disable it outright instead of tuning rules one at a time, so nvim
-- behaves like a setup with no markdownlint at all. `condition` always
-- returning false takes effect regardless of any filetype linter list.
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          condition = function()
            return false
          end,
        },
      },
    },
  },
}
