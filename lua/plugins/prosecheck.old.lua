return {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local null_ls = require("null-ls")

        local function span_len_from(d)
            local s, e = tonumber(d.start_pos), tonumber(d.end_pos)
            return (s and e and e > s) and (e - s) or 1
        end

        local function char_to_byte_0(line_text, char_col_1)
            local idx0 = math.max(0, (char_col_1 or 1) - 1)
            return vim.str_byteindex(line_text or "", idx0)
        end

        local function char_to_byte_1(line_text, char_col_1b)
            return char_to_byte_0(line_text, char_col_1b) + 1
        end

        local function get_line(bufnr, row0)
            return vim.api.nvim_buf_get_lines(bufnr, row0, row0 + 1, false)[1] or ""
        end

        -- Wrapper: build a generator with shared opts + custom on_output
        local function make_generator(on_output)
            return null_ls.generator({
                command = "proselint",
                args = { "check", "-o", "json" },
                to_stdin = true,
                from_stderr = true,
                format = "json",
                check_exit_code = function(code)
                    return code <= 1
                end,
                on_output = on_output,
            })
        end

        local proselint_dev_diag = {
            name = "proselint-dev",
            method = null_ls.methods.DIAGNOSTICS,
            filetypes = { "markdown", "text", "rst", "asciidoc" },
            generator = make_generator(function(params)
                local out = params.output
                if not (out and out.status == "success") then
                    return {}
                end

                local errors = (out.data and out.data.errors) or {}
                local sev = { error = 1, warning = 2, suggestion = 4 }
                local diags = {}

                for _, d in ipairs(errors) do
                    local row = tonumber(d.line) or 1
                    local start_char = tonumber(d.column) or 1
                    local end_char = math.max(start_char + span_len_from(d), start_char + 1)

                    local line_text = (params.content and params.content[row]) or ""
                    local start_b = char_to_byte_1(line_text, start_char)
                    local end_b = char_to_byte_1(line_text, end_char)
                    if end_b <= start_b then end_b = start_b + 1 end

                    table.insert(diags, {
                        row = row,
                        col = start_b,
                        end_col = end_b,
                        message = d.message or "",
                        code = d.check_path or "proselint",
                        severity = sev[d.severity] or 2,
                        source = "proselint",
                    })
                end

                return diags
            end),
        }

        local proselint_dev_actions = {
            name = "proselint-dev-actions",
            method = null_ls.methods.CODE_ACTION,
            filetypes = { "markdown", "text", "rst", "asciidoc" },
            generator = make_generator(function(params)
                local out = params.output
                if not (out and out.status == "success") then
                    return {}
                end

                local errors = (out.data and out.data.errors) or {}
                local actions = {}

                local bufnr = params.bufnr
                -- Use actual cursor line (0-based)
                local row0 = vim.api.nvim_win_get_cursor(0)[1] - 1

                for _, d in ipairs(errors) do
                    local repl = d.replacements
                    if repl ~= vim.NIL and repl ~= nil then
                        local line1 = tonumber(d.line) or 1
                        if (line1 - 1) == row0 then
                            local start_char = tonumber(d.column) or 1
                            local end_char = math.max(start_char + span_len_from(d), start_char + 1)

                            local line = get_line(bufnr, row0)
                            local cb = char_to_byte_0(line, start_char)
                            local ce = char_to_byte_0(line, end_char)
                            if ce <= cb then ce = cb + 1 end

                            local list = type(repl) == "table" and repl or { tostring(repl) }
                            for _, r in ipairs(list) do
                                table.insert(actions, {
                                    title = (d.message or "Apply fix") .. (r and (" → " .. r) or ""),
                                    action = function()
                                        vim.api.nvim_buf_set_text(bufnr, row0, cb, row0, ce, { r or "" })
                                    end,
                                })
                            end
                        end
                    end
                end

                return actions
            end),
        }

        null_ls.register({ proselint_dev_diag, proselint_dev_actions })

        null_ls.setup({
            debug = true,
        })
    end,
}
