return {
  {
    "MagicDuck/grug-far.nvim",
    config = function()
      local opts = require("config.grug-file-options")
      require("grug-far").setup(vim.tbl_deep_extend("force", opts.defaultOptions, {}))
    end,
    keys = {
      { "<leader>sr", "<cmd>GrugFar<cr>", desc = "Search and Replace (GrugFar)" },
    },
  },
}
