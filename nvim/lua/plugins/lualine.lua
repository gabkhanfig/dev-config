return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local cmake = require("cmake-tools")

      -- configure / build preset
      table.insert(opts.sections.lualine_x, 1, {
        function()
          local c = cmake.get_configure_preset()
          if c then
            return "󰔷 " .. c
          else
            local build_type = cmake.get_build_type()
            return build_type and "󰔷 " .. build_type or ""
          end
        end,
        cond = function()
          return cmake.is_cmake_project()
        end,
        on_click = function()
          if cmake.has_cmake_preset() then
            vim.cmd("CMakeSelectConfigurePreset")
          else
            vim.cmd("CMakeSelectBuildType")
          end
        end,
        color = { fg = "#ff9e64" },
      })

      -- build target
      table.insert(opts.sections.lualine_x, 2, {
        function()
          local target = cmake.get_build_target()
          if type(target) == "table" then
            target = target[1] -- such as { "all" }
          end
          if not target or target == "" then
            return "[select]"
          else
            return target
          end
        end,
        cond = function()
          return cmake.is_cmake_project()
        end,
        on_click = function()
          vim.cmd("CMakeSelectBuildTarget")
        end,
        color = { fg = "#7dcfff" },
  })

    
      table.insert(opts.sections.lualine_x, 3, {
        function()
          local launch_target = cmake.get_launch_target()
          if launch_target then
            return " " .. launch_target
          else
            return " [select]"
          end
        end,
        cond = function()
          return cmake.is_cmake_project()
        end,
        on_click = function()
          vim.cmd("CMakeSelectLaunchTarget")
        end,
        color = { fg = "#9ece6a" },
      })

      return opts
    end,
  },
}

