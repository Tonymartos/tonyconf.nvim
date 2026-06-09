return {
  {
    "carlos-rodrigo/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("claude-code").setup({
        window = {
          type = "vsplit",
        },
        auto_save = true,
      })
    end,
    keys = {
      { "<leader>cc", "<cmd>ClaudeCodeToggle<cr>", desc = "Claude Code toggle" },
      { "<leader>cn", "<cmd>ClaudeCodeNew<cr>", desc = "Claude Code nueva sesion" },
      { "<leader>cv", "<cmd>ClaudeCodeVsplit<cr>", desc = "Claude Code vsplit" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude Code enviar seleccion" },
      { "<leader>cS", "<cmd>ClaudeCodeSaveSession<cr>", desc = "Claude Code guardar sesion" },
      { "<leader>cb", "<cmd>ClaudeCodeSessions<cr>", desc = "Claude Code ver sesiones" },
    },
  },
}
