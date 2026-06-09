return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "mason-org/mason.nvim",
    },
    config = function()
      local dap = require("dap")
      local ui = require("dapui")
      local registry = require("mason-registry")

      local function get_pkg_path(name)
        local ok, pkg = pcall(registry.get_package, name)
        if ok and pkg and pkg:is_installed() then
          return pkg:get_install_path()
        end
      end

      require("dapui").setup()
      require("dap-go").setup()

      -- JS/TS: node2 debug adapter
      local node2_path = get_pkg_path("node-debug2-adapter")
      if node2_path then
        dap.adapters.node2 = {
          type = "executable",
          command = "node",
          args = { node2_path .. "/out/src/nodeDebug.js" },
        }
      end

      if node2_path then
        for _, language in pairs({ "javascript", "typescript" }) do
          dap.configurations[language] = {
            {
              name = "Launch Node (current file)",
              type = "node2",
              request = "launch",
              program = "${file}",
              cwd = "${workspaceFolder}",
              sourceMaps = true,
              protocol = "inspector",
              console = "integratedTerminal",
            },
            {
              name = "Attach to Node process",
              type = "node2",
              request = "attach",
              processId = require("dap.utils").pick_process,
              console = "integratedTerminal",
            },
          }
        end

        for _, language in pairs({ "javascriptreact", "typescriptreact" }) do
          dap.configurations[language] = {
            {
              name = "Launch Node (current file)",
              type = "node2",
              request = "launch",
              program = "${file}",
              cwd = "${workspaceFolder}",
              sourceMaps = true,
              protocol = "inspector",
              console = "integratedTerminal",
            },
          }
        end
      end

      -- C#: netcoredbg adapter
      local netcoredbg_path = get_pkg_path("netcoredbg")
      if netcoredbg_path then
        dap.adapters.coreclr = {
          type = "executable",
          command = netcoredbg_path .. "/netcoredbg",
          args = { "--interpreter=vscode" },
        }

        dap.configurations.cs = {
          {
            name = "Launch .NET (netcoredbg)",
            type = "coreclr",
            request = "launch",
            program = function()
              return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
            end,
          },
          {
            name = "Attach .NET (netcoredbg)",
            type = "coreclr",
            request = "attach",
            processId = require("dap.utils").pick_process,
          },
        }
      end

      -- Rust: codelldb adapter
      local codelldb_path = get_pkg_path("codelldb")
      if codelldb_path then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = {
            command = codelldb_path .. "/codelldb",
            args = { "--port", "${port}" },
          },
        }

        dap.configurations.rust = {
          {
            name = "Launch Rust (codelldb)",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
        }
      end

      -- nvim-dap-virtual-text config
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
        display_callback = function(variable, buf, stackframe, node, options)
          local name = string.lower(variable.name)
          local value = string.lower(variable.value)
          if name:match("secret") or name:match("api") or value:match("secret") or value:match("api") then
            return "*****"
          end
          if #variable.value > 15 then
            return " " .. string.sub(variable.value, 1, 15) .. "... "
          end
          if options.virt_text_pos == "inline" then
            return " = " .. variable.value:gsub("%s+", " ")
          else
            return variable.name .. " = " .. variable.value:gsub("%s+", " ")
          end
        end,
        virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil,
      })

      -- Keymaps
      vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
      vim.keymap.set("n", "<space>gb", dap.run_to_cursor)
      vim.keymap.set("n", "<space>?", function()
        require("dapui").eval(nil, { enter = true })
      end)

      vim.keymap.set("n", "<F1>", dap.continue)
      vim.keymap.set("n", "<F2>", dap.step_into)
      vim.keymap.set("n", "<F3>", dap.step_over)
      vim.keymap.set("n", "<F4>", dap.step_out)
      vim.keymap.set("n", "<F5>", dap.step_back)
      vim.keymap.set("n", "<F13>", dap.restart)

      -- Auto open/close dap-ui
      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end,
  },
}
