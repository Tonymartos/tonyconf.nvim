return {
  "Pocco81/auto-save.nvim",
  config = function()
    require("auto-save").setup({
      enabled = true,
      debounce_delay = 135, -- ← NECESARIO para evitar el error
      execution_message = {
        message = function()
          return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
        end,
        dim = 0.18,
        cleaning_interval = 1250,
      },
      trigger_events = { "InsertLeave", "TextChanged" },
      conditions = {
        exists = true,
        modifiable = true,
        filename_is_not = {},
        filetype_is_not = { "NvimTree", "TelescopePrompt", "neo-tree", "lazy", "dashboard" },
      },
      write_all_buffers = true, -- o false, como prefieras
    })
  end,
}
