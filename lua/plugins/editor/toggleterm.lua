return {
  {
    "akinsho/toggleterm.nvim",
    config = true,
    cmd = "ToggleTerm",
    build = function()
      if vim.fn.has("headless") ~= 1 then
        vim.cmd("ToggleTerm")
      end
    end,
    keys = { { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" } },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "horizontal",
      shade_filetypes = {},
      hide_numbers = true,
      insert_mappings = true,
      terminal_mappings = true,
      start_in_insert = true,
      close_on_exit = true,
    },
  },
}
