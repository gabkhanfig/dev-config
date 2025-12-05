-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- After CMakeGenerate, copy the compile_commands.json to the root to be used by LSP like clangd
vim.api.nvim_create_autocmd("User", {
  pattern = "CMakeGenerate",
  callback = function()
    local root = vim.fn.getcwd()
    local build_dirs = vim.fn.glob(root .. "/build/*", false, true)

    -- Find most recently modified compile_commands.json
    local latest_compile_cmds = nil
    local latest_time = 0

    for _, build_dir in ipairs(build_dirs) do
      local compile_cmds = build_dir .. "/compile_commands.json"
      if vim.fn.filereadable(compile_cmds) == 1 then
        local ftime = vim.fn.getftime(compile_cmds)
        if ftime > latest_time then
          latest_time = ftime
          latest_compile_cmds = compile_cmds
        end
      end
    end

    if latest_compile_cmds then
      local target = root .. "/compile_commands.json"

      if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
        os.execute("copy /y \"" .. latest_compile_cmds:gsub("/", "\\") .. "\" \"" .. target:gsub("/", "\\") .. "\" >nul 2>&1")
      else
        os.execute("cp -f \"" .. latest_compile_cmds .. "\" \"" .. target .. "\"")
      end

      print("Updated compile_commands.json from " .. latest_compile_cmds)
      vim.defer_fn(function()
        vim.cmd("LspRestart")
      end, 500)
    end
  end,
})
