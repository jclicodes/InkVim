return {
    {
        "reedes/vim-pencil",
        ft = { "markdown", "text" },
        config = function()
            vim.g["pencil#wrapModeDefault"] = "soft"

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "markdown", "text" },
                callback = function()
                    vim.cmd("PencilSoft")
                    vim.opt_local.spell = true
                    vim.opt_local.spelllang = "en_gb"
                end,
            })
        end,
    },
}
