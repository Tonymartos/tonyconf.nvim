return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
      { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
      { "stevearc/dressing.nvim", opts = {} },
      "ravitemer/mcphub.nvim",
    },
    config = function()
      require("codecompanion").setup({
        opts = {
          language = "Spanish",
        },
        log_level = "DEBUG",
        adapters = {
          ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
              env = {
                api_key = os.getenv("OLLAMA_API_KEY"),
                url = os.getenv("OLLAMA_URL"),
              },
              schema = {
                model = {
                  default = "qwen3:latest",
                },
              },
              parameters = { sync = true },
            })
          end,
        },

        strategies = {
          chat = { adapter = "ollama" },
          inline = { adapter = "ollama" },
          agent = { adapter = "ollama" },
        },

        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              make_vars = true,
              make_slash_commands = true,
              make_tools = true,
            },
          },
        },
      })
    end,
  },
}
