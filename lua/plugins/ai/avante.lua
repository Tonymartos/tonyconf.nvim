return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      provider = "claude",
      providers = {
        claude = {
          model = "claude-sonnet-4-20250514",
          api_key_name = "ANTHROPIC_API_KEY",
        },
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
      },
      windows = {
        wrap = true,
        width = 30,
      },
    },
    keys = {
      { "<leader>aia", function() require("avante.api").ask() end, mode = { "n", "v" }, desc = "Avante ask" },
      { "<leader>air", function() require("avante.api").refresh() end, desc = "Avante refresh" },
      { "<leader>aie", function() require("avante.api").edit() end, mode = { "n", "v" }, desc = "Avante edit" },
    },
  },
}
