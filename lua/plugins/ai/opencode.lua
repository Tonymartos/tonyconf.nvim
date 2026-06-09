return {
  {
    "krmcbride/opencode.nvim",
    dependencies = {
      { "folke/snacks.nvim", opts = { terminal = { enabled = true } } },
    },
    opts = {
      server = {
        url = "http://127.0.0.1:4096",
      },
      auto_reload = true,
      editor_context = {
        enabled = true,
      },
      terminal = {
        width = 0.43,
        env = {
          OPENTUI_GRAPHICS = "0",
        },
      },
    },
    init = function()
      vim.o.autoread = true
    end,
    keys = {
      { "<leader>ac", function() require("opencode").start({ focus = true, continue = true }) end, mode = { "n", "t" }, desc = "OpenCode continuar" },
      { "<leader>an", function() require("opencode").start({ focus = true, continue = false }) end, mode = { "n", "t" }, desc = "OpenCode nueva sesion" },
      { "<leader>aa", function() require("opencode").mention_selection({ focus = true }) end, mode = { "n", "x" }, desc = "OpenCode enviar seleccion" },
      { "<leader>aA", function() require("opencode").prompt("@this", { focus = true }) end, mode = { "n", "x" }, desc = "OpenCode añadir a prompt" },
      { "<leader>ab", function() require("opencode").prompt("@buffer", { focus = true }) end, desc = "OpenCode enviar buffer" },
      { "<leader>ad", function() require("opencode").prompt("@diagnostics", { focus = true }) end, desc = "OpenCode enviar diagnosticos" },
      { "<leader>av", function() require("opencode").review_selection() end, mode = "x", desc = "OpenCode revisar seleccion" },
    },
  },
}
