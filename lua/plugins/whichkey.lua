return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = { enabled = true, suggestions = 20 } },
      win = { border = "rounded" },
      trigger = { mode = "auto" },
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      -- Optional: register groups for your mappings
      wk.add({
        { "<leader>t", group = "Thesaurus/Dictionary" },
        { "<leader>p", group = "Projects" },
        { "<leader>l", group = "LLM" },
        { "<leader>z", desc = "Zen Mode" },
      })
    end,
  },
}
