-- pyright's default ("standard") mode treats `self.siguiente = None` as "this
-- attribute can only ever be None", so every linked-list / tree style class
-- (Nodo, ListaDoble...) lights up with "X is not a known attribute of None" and
-- "Nodo is not assignable to None" even though the code is correct.
-- "basic" alone does NOT fix it (those rules are errors there too), so the three
-- None-related rules are switched off explicitly. Real checks (undefined names,
-- bad imports, wrong call arguments, None used as iterable/operand...) stay on.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                diagnosticSeverityOverrides = {
                  reportOptionalMemberAccess = "none",
                  reportOptionalOperand = "none",
                  reportAttributeAccessIssue = "none",
                },
              },
            },
          },
        },
      },
    },
  },
}
