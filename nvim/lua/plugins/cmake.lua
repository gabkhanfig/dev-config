return {
    {
        "Civitasv/cmake-tools.nvim",
        dependencies = {
        "nvim-lua/plenary.nvim",
        },
        config = function()
        require("cmake-tools").setup({
        cmake_command = "cmake",
        cmake_build_directory = "build",
        cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
        cmake_build_options = { "--parallel" },
        cmake_console_size = 10,
        cmake_show_console = "always",
        cmake_environment = function()
            if vim.fn.has("win32") == 0 and vim.fn.has("win64") == 0 then
                return {}
            end

            -- vswhere to find visual studio stuff
            local vswhere = "C:\\Program Files (x86)\\Microsoft Visual Studio\\Installer\\vswhere.exe"
            if vim.fn.executable(vswhere) == 0 then
                return {}
            end

            local vs_path = vim.fn.system(vswhere .. " -latest -property installationPath"):gsub("%s+", "")
            if vs_path == "" then
                return {}
            end

            local vc_tools_path = vs_path .. "\\VC\\Tools\\MSVC"
            local msvc_versions = vim.fn.systemlist('cmd /c "dir /b /on \\"' .. vc_tools_path .. '\\""')
            local msvc_latest = msvc_versions[#msvc_versions]
            if not msvc_latest then
                return {}
            end
            msvc_latest = msvc_latest:gsub("%s+", "")

            -- 10 should be fine for win11
            local sdk_base = "C:\\Program Files (x86)\\Windows Kits\\10"
            local sdk_include = sdk_base .. "\\Include"
            local sdk_versions = vim.fn.systemlist('cmd /c "dir /b /on \\"' .. sdk_include .. '\\""')
            local sdk_latest = sdk_versions[#sdk_versions]
            if not sdk_latest then
                return {}
            end
            sdk_latest = sdk_latest:gsub("%s+", "")

            local msvc_path = vc_tools_path .. "\\" .. msvc_latest

            local env_path = msvc_path .. "\\bin\\Hostx64\\x64;" .. sdk_base .. "\\bin\\" .. sdk_latest .. "\\x64;" .. (vim.env.PATH or "")
            local env_include = msvc_path .. "\\include;" .. sdk_include .. "\\" .. sdk_latest .. "\\ucrt;" .. sdk_include .. "\\" .. sdk_latest .. "\\um;" .. sdk_include .. "\\" .. sdk_latest .. "\\shared"
            local env_lib = msvc_path .. "\\lib\\x64;" .. sdk_base .. "\\Lib\\" .. sdk_latest .. "\\ucrt\\x64;" .. sdk_base .. "\\Lib\\" .. sdk_latest .. "\\um\\x64"

            return {
                PATH = env_path,
                INCLUDE = env_include,
                LIB = env_lib,
            }
        end,
        cmake_dap_configuration = {
            name = "cpp",
            type = "codelldb",
            request = "launch",
            stopOnEntry = false,
            runInTerminal = true,
            console = "integratedTerminal",
        },
        cmake_variants_message = {
            short = { show = true },
            long = { show = true, max_length = 40 },
        },
        cmake_executor = {
            name = "terminal",
            opts = {},
        },
        cmake_runner = {
            name = "terminal",
            opts = {},
        },
        cmake_notifications = {
            runner = { enabled = true },
            executor = { enabled = true },
        },
        cmake_virtual_text_support = true,
        cmake_regenerate_on_save = false,
        cmake_soft_link_compile_commands = false,
        })
        end,
        keys = {
            { "<F5>", "<cmd>CMakeRun<cr>", desc = "CMake Run (F5)" },
            { "<F6>", "<cmd>CMakeDebug<cr>", desc = "CMake Debug (F6)" },
        },
    },

    -- clangd can be funky with MSVC.
    {
        "neovim/nvim-lspconfig",
        opts = {
        servers = {
            clangd = {
            cmd = {
                "clangd",
                "--background-index",
                "--header-insertion=never",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--fallback-style=llvm",
                "--compile-commands-dir=.",
            },
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
            },
            },
        },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
        vim.list_extend(opts.ensure_installed, {
            "cmake",
            "cpp",
            "c",
        })
        end,
    },
}
