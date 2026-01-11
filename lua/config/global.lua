-- Vim option
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = ";"

-- UI - LSP
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

