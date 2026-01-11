local M = {}

-- Core mapper
-- Usage:
--   map("n", "<leader>x", rhs, "Do thing")
--   map({ "n", "v" }, "<leader>x", rhs, "Multi-mode", { silent = false })
--   map("n", "K", rhs, "Buf map", { buffer = 0 })
function M.map(mode, lhs, rhs, desc, opts)
    opts = opts or {}
    if desc then
        opts.desc = desc
    end
    vim.keymap.set(mode, lhs, rhs, opts)
end

return M
