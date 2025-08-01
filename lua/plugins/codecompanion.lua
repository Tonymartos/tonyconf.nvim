return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      -- Dependencias principales
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp", -- opcional: slash commands
      "nvim-telescope/telescope.nvim", -- opcional: interfaz más rica
      { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
      { "stevearc/dressing.nvim", opts = {} },

      -- Extensión opcional: mcphub
      "ravitemer/mcphub.nvim",
    },
    config = function()
      require("codecompanion").setup({
        opts = {
          language = "Spanish",
        },
        log_level = "DEBUG",
        -- Adaptador de Ollama
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
              parameters = { sync = true }, -- o false si prefieres async :contentReference[oaicite:2]{index=2}
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
              make_vars = true, -- variables RAG accesibles con `#`
              make_slash_commands = true, -- slash prompts `/mcp:...`
              make_tools = true, -- herramientas -> agentes funcionales :contentReference[oaicite:3]{index=3}
            },
          },
        },
      })
    end,
  },
}
