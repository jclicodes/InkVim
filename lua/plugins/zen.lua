return {
    "folke/zen-mode.nvim",
    opts = {
        window = {
            width = 80,
            options = {
                number = false,
                relativenumber = false,
                signcolumn = "no",
                colorcolumn = "0",
            },
        },
        plugins = {
            -- add twilight later
            twilight = { enabled = false },
        },
        on_open = function()
            -- typewriter feel
            vim.wo.wrap = true
            vim.wo.linebreak = true
            vim.o.scrolloff = 999 -- keep cursor vertically centered
        end,
        on_close = function()
            vim.o.scrolloff = 8
        end,
    },
    config = function(_, opts)
        require("zen-mode").setup(opts)

        -- Auto-enter Zen for prose files
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
            pattern = { "*.md", "*.markdown", "*.txt" },
            callback = function()
                if vim.bo.buftype == "" then
                    vim.schedule(function()
                        pcall(vim.cmd, "ZenMode")
                    end)
                end
            end,
        })

        -- Optional toggle
        vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<cr>", { desc = "Zen Mode" })
    end,
}
