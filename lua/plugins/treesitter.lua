return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "markdown", "markdown_inline", "lua", "json", "yaml" },
      highlight = { enable = true, additional_vim_regex_highlighting = { "markdown" } },
    },
  },
}
