return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local ROOT = "/Users/jcli/Documents/Obsidian/writing/writing"
        local STATE_FILE = vim.fn.stdpath("state") .. "/writing_projects.json"

        local builtin = require("telescope.builtin")

        local function load_recent_projects()
            local f = io.open(STATE_FILE, "r")
            if not f then return {} end
            local ok, data = pcall(vim.json.decode, f:read("*a"))
            f:close()
            if ok and type(data) == "table" then
                return data
            end
            return {}
        end

        local function set_project_opened(tbl)
            -- create state file if it doesnt exist
            vim.fn.mkdir(vim.fn.fnamemodify(STATE_FILE, ":h"), "p")
            local f = assert(io.open(STATE_FILE, "w"))
            f:write(vim.json.encode(tbl))
            f:close()
        end

        local function list_projects()
            local cmd = ('find %s -maxdepth 1 -mindepth 1 -type d'):format(
                vim.fn.shellescape(ROOT)
            )
            local out = vim.fn.systemlist(cmd)
            local dirs = {}
            for _, d in ipairs(out) do
                if d ~= ROOT and vim.fn.isdirectory(d) == 1 then
                    table.insert(dirs, d)
                end
            end
            return dirs
        end

        local function open_chapters(project_dir)
            local text_dir = project_dir .. "/text"
            local cwd = vim.fn.isdirectory(text_dir) == 1 and text_dir or project_dir

            builtin.find_files({
                prompt_title = ("Chapters: %s"):format(vim.fn.fnamemodify(project_dir, ":t")),
                cwd = cwd,
                hidden = true,
                follow = true,
                find_command = {
                    "rg",
                    "--files",
                    "--hidden",
                },
                layout_strategy = "vertical",
                layout_config = {
                    width = 0.95,
                    height = 0.95,
                    prompt_position = "top",
                    preview_height = 0.45,
                },
            })
        end

        local function project_picker()
            local by_last_opened = load_recent_projects()
            local projects = list_projects()

            local pickers = require("telescope.pickers")
            local finders = require("telescope.finders")
            local conf = require("telescope.config").values
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            local items = {}

            for _, p in ipairs(projects) do
                table.insert(items, {
                    path = p,
                    name = vim.fn.fnamemodify(p, ":t"),
                    ts = tonumber(by_last_opened[p] or 0),
                })
            end

            table.sort(items, function(a, b)
                if a.ts == b.ts then
                    return a.name:lower() < b.name:lower()
                end
                return a.ts > b.ts
            end)

            if #items == 0 then
                vim.notify("No projects found", vim.log.levels.WARN)
                return
            end

            pickers
                .new({}, {
                    prompt_title = "Projects",
                    finder = finders.new_table({
                        results = items,
                        entry_maker = function(it)
                            return {
                                value = it,
                                display = it.name,
                                ordinal = string.format("%s %s %d", it.name,
                                    it.path, it.ts)
                            }
                        end,
                    }),
                    sorter = conf.generic_sorter({}),
                    previewer = false,
                    layout_strategy = "horizontal",
                    layout_config = {
                        width = 0.8,
                        height = 0.6,
                        prompt_position = "top",
                        preview_width = 0.0,
                    },
                    attach_mappings = function(prompt_bufnr, map)
                        local function open_project()
                            local selection = action_state.get_selected_entry()
                            if not selection then
                                return
                            end
                            local dir = selection.value.path
                            by_last_opened[dir] = os.time()
                            set_project_opened(dir)

                            actions.close(prompt_bufnr)
                            vim.cmd("cd " .. vim.fn.fnameescape(dir))
                            open_chapters(dir)
                        end
                        map("i", "<CR>", open_project)
                        map("n", "<CR>", open_project)
                        return true
                    end,
                })
                :find()
        end

        -- Keymaps
        vim.keymap.set("n", "<leader>pp", project_picker, { desc = "Pick project" })
        vim.keymap.set("n", "<leader>pf", function()
            open_chapters(vim.fn.getcwd())
        end, { desc = "Project chapters" })
    end
}
