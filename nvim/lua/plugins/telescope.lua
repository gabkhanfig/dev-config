-- NEED RIPGREP rg

return {
    {
        "nvim-telescope/telescope.nvim",
        priority = 1000,
        opts = function(_, opts)
        opts.defaults = opts.defaults or {}
        opts.defaults.file_ignore_patterns = { "^.git/" }
        opts.defaults.vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--no-ignore",
            "--glob=!.git/",
        }

        opts.pickers = opts.pickers or {}

        opts.pickers.find_files = {
            hidden = true,
            no_ignore = true,
            follow = true,
            find_command = { "rg", "--files", "--hidden", "--no-ignore", "--glob", "!.git/" },
        }

        opts.pickers.live_grep = {
            additional_args = function()
            return { "--hidden", "--no-ignore", "--glob=!.git/" }
            end,
        }

        return opts
        end,
        keys = {
        {
            "<leader><space>",
            function()
            local telescope = require("telescope.builtin")
            local root = vim.fn.getcwd()
            telescope.find_files({
                cwd = root,
                hidden = true,
                no_ignore = true,
                find_command = { "rg", "--files", "--hidden", "--no-ignore", "--glob", "!.git/" },
            })
            end,
            desc = "Find Files (Root Dir)",
        },
        {
            "<leader>ff",
            function()
            local telescope = require("telescope.builtin")
            telescope.find_files({
                hidden = true,
                no_ignore = true,
                find_command = { "rg", "--files", "--hidden", "--no-ignore", "--glob", "!.git/" },
            })
            end,
            desc = "Find Files (cwd)",
        },
        },
    },
}
