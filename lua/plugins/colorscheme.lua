-- onedark.nvim repainted as VS Code "Dark+" with the Microsoft C/C++ palette.
--
-- EDIT COLORS HERE. Every highlight below refers to this table, so changing a
-- value in `vs` changes it everywhere it is used. Nothing else needs touching.
local vs = {
  -- editor chrome
  bg = "#1E1E1E", -- editor background
  bg_float = "#252526", -- floats, popup menu, sidebar
  bg_line = "#2A2D2E", -- cursorline / hovered row
  bg_sel = "#264F78", -- visual selection
  bg_sel_soft = "#04395E", -- selected completion row
  border = "#3C3C3C",
  fg = "#D4D4D4", -- default text, operators, punctuation
  line_nr = "#858585",
  line_nr_cur = "#C6C6C6",

  -- syntax (these are the ones you'll actually want to fiddle with)
  keyword = "#569CD6", -- int, void, const, static, class, struct, true/false
  control = "#C586C0", -- if, else, for, while, return + #include / #define
  type = "#4EC9B0", -- class / struct / namespace / typedef names
  func = "#DCDCAA", -- function and method names
  var = "#9CDCFE", -- variables, parameters, members
  string = "#CE9178", -- string and char literals
  number = "#B5CEA8", -- numeric literals, enum members
  comment = "#6A9955", -- comments
  macro = "#BEB7FF", -- preprocessor macros (MS C/C++ extension colour)
  enum = "#B8D7A3", -- enum type names
  operator = "#D4D4D4",

  -- diagnostics
  error = "#F44747",
  warn = "#CCA700",
  info = "#3794FF",
  hint = "#B0B0B0",
}

return {
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "dark",
      transparent = false,
      term_colors = true,
      -- VS Code does not italicise comments; keep everything plain
      code_style = {
        comments = "none",
        keywords = "none",
        functions = "none",
        strings = "none",
        variables = "none",
      },
      diagnostics = { darker = false, undercurl = true, background = false },

      -- Remap onedark's own palette so every UI element it draws that isn't
      -- explicitly overridden below still lands in the VS Code range.
      colors = {
        black = "#181818",
        bg0 = vs.bg,
        bg1 = vs.bg_float,
        bg2 = vs.bg_line,
        bg3 = "#37373D",
        bg_d = "#181818",
        bg_blue = vs.keyword,
        bg_yellow = vs.func,
        fg = vs.fg,
        purple = vs.control,
        green = vs.comment,
        orange = vs.string,
        blue = vs.keyword,
        yellow = vs.func,
        cyan = vs.type,
        red = vs.error,
        grey = "#808080",
        light_grey = vs.line_nr,
        dark_cyan = vs.type,
        dark_red = vs.error,
        dark_yellow = vs.warn,
        dark_purple = vs.macro,
        diff_add = "#294436",
        diff_delete = "#4B1818",
        diff_change = "#1E3A5F",
        diff_text = "#2E5A88",
      },

      highlights = {
        -- ---- editor chrome -------------------------------------------------
        Normal = { fg = vs.fg, bg = vs.bg },
        NormalFloat = { fg = vs.fg, bg = vs.bg_float },
        FloatBorder = { fg = vs.border, bg = vs.bg_float },
        CursorLine = { bg = vs.bg_line },
        CursorLineNr = { fg = vs.line_nr_cur },
        LineNr = { fg = vs.line_nr },
        Visual = { bg = vs.bg_sel },
        Search = { bg = "#613214" },
        IncSearch = { bg = "#9E6A03" },
        CurSearch = { bg = "#9E6A03" },
        Pmenu = { fg = vs.fg, bg = vs.bg_float },
        PmenuSel = { bg = vs.bg_sel_soft },
        WinSeparator = { fg = "#2B2B2B" },
        ColorColumn = { bg = vs.bg_line },
        MatchParen = { bg = "#3A3D41", fmt = "bold" },
        Folded = { fg = vs.line_nr, bg = vs.bg_float },

        -- ---- classic syntax groups ----------------------------------------
        Comment = { fg = vs.comment },
        Constant = { fg = vs.var },
        String = { fg = vs.string },
        Character = { fg = vs.string },
        Number = { fg = vs.number },
        Float = { fg = vs.number },
        Boolean = { fg = vs.keyword },
        Identifier = { fg = vs.var },
        Function = { fg = vs.func },
        Statement = { fg = vs.control },
        Conditional = { fg = vs.control },
        Repeat = { fg = vs.control },
        Label = { fg = vs.var },
        Operator = { fg = vs.operator },
        Keyword = { fg = vs.keyword },
        Exception = { fg = vs.control },
        PreProc = { fg = vs.control },
        Include = { fg = vs.control },
        Define = { fg = vs.control },
        Macro = { fg = vs.macro },
        PreCondit = { fg = vs.control },
        Type = { fg = vs.keyword },
        StorageClass = { fg = vs.keyword },
        Structure = { fg = vs.keyword },
        Typedef = { fg = vs.type },
        Special = { fg = vs.fg },
        Delimiter = { fg = vs.fg },

        -- ---- treesitter ----------------------------------------------------
        ["@comment"] = { fg = vs.comment },
        ["@keyword"] = { fg = vs.keyword },
        ["@keyword.type"] = { fg = vs.keyword },
        ["@keyword.modifier"] = { fg = vs.keyword },
        ["@keyword.operator"] = { fg = vs.keyword },
        ["@keyword.conditional"] = { fg = vs.control },
        ["@keyword.repeat"] = { fg = vs.control },
        ["@keyword.return"] = { fg = vs.control },
        ["@keyword.exception"] = { fg = vs.control },
        ["@keyword.directive"] = { fg = vs.control },
        ["@keyword.directive.define"] = { fg = vs.control },
        ["@keyword.import"] = { fg = vs.control },
        ["@type"] = { fg = vs.type },
        ["@type.builtin"] = { fg = vs.keyword }, -- int/char/void are BLUE, not teal
        ["@type.qualifier"] = { fg = vs.keyword },
        ["@type.definition"] = { fg = vs.type },
        ["@module"] = { fg = vs.type },
        ["@constructor"] = { fg = vs.type },
        ["@function"] = { fg = vs.func },
        ["@function.call"] = { fg = vs.func },
        ["@function.method"] = { fg = vs.func },
        ["@function.method.call"] = { fg = vs.func },
        ["@function.builtin"] = { fg = vs.func },
        ["@function.macro"] = { fg = vs.macro },
        ["@variable"] = { fg = vs.var },
        ["@variable.parameter"] = { fg = vs.var },
        ["@variable.member"] = { fg = vs.var },
        ["@variable.builtin"] = { fg = vs.keyword },
        ["@property"] = { fg = vs.var },
        ["@field"] = { fg = vs.var },
        ["@constant"] = { fg = vs.var },
        ["@constant.builtin"] = { fg = vs.keyword }, -- nullptr, NULL
        ["@constant.macro"] = { fg = vs.macro },
        ["@string"] = { fg = vs.string },
        ["@string.escape"] = { fg = "#D7BA7D" },
        ["@character"] = { fg = vs.string },
        ["@number"] = { fg = vs.number },
        ["@boolean"] = { fg = vs.keyword },
        ["@operator"] = { fg = vs.operator },
        ["@punctuation.delimiter"] = { fg = vs.fg },
        ["@punctuation.bracket"] = { fg = vs.fg },
        ["@punctuation.special"] = { fg = vs.fg },
        ["@attribute"] = { fg = vs.type },
        ["@label"] = { fg = vs.var },

        -- ---- clangd semantic tokens ---------------------------------------
        -- These land ON TOP of treesitter, so without them clangd repaints C++
        -- back to onedark's defaults and none of the above is visible.
        ["@lsp.type.class"] = { fg = vs.type },
        ["@lsp.type.struct"] = { fg = vs.type },
        ["@lsp.type.enum"] = { fg = vs.enum },
        ["@lsp.type.enumMember"] = { fg = vs.number },
        ["@lsp.type.type"] = { fg = vs.type },
        ["@lsp.type.typeParameter"] = { fg = vs.type },
        ["@lsp.type.concept"] = { fg = vs.type },
        ["@lsp.type.namespace"] = { fg = vs.type },
        ["@lsp.type.parameter"] = { fg = vs.var },
        ["@lsp.type.variable"] = { fg = vs.var },
        ["@lsp.type.property"] = { fg = vs.var },
        ["@lsp.type.field"] = { fg = vs.var },
        ["@lsp.type.function"] = { fg = vs.func },
        ["@lsp.type.method"] = { fg = vs.func },
        ["@lsp.type.macro"] = { fg = vs.macro },
        ["@lsp.type.keyword"] = { fg = vs.keyword },
        ["@lsp.type.modifier"] = { fg = vs.keyword },
        ["@lsp.type.comment"] = { fg = vs.comment },
        ["@lsp.type.string"] = { fg = vs.string },
        ["@lsp.type.number"] = { fg = vs.number },
        ["@lsp.type.operator"] = { fg = vs.operator },

        -- ---- diagnostics ---------------------------------------------------
        DiagnosticError = { fg = vs.error },
        DiagnosticWarn = { fg = vs.warn },
        DiagnosticInfo = { fg = vs.info },
        DiagnosticHint = { fg = vs.hint },
      },
    },
  },

  { "LazyVim/LazyVim", opts = { colorscheme = "onedark" } },
}
