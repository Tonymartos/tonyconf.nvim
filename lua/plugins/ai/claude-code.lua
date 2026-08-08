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
      { "<leader>Cc", "<cmd>ClaudeCodeToggle<cr>", desc = "Claude Code toggle" },
      { "<leader>Cn", "<cmd>ClaudeCodeNew<cr>", desc = "Claude Code nueva sesion" },
      { "<leader>Cv", "<cmd>ClaudeCodeVsplit<cr>", desc = "Claude Code vsplit" },
      { "<leader>Cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude Code enviar seleccion" },
      { "<leader>CS", "<cmd>ClaudeCodeSaveSession<cr>", desc = "Claude Code guardar sesion" },
      { "<leader>Cb", "<cmd>ClaudeCodeSessions<cr>", desc = "Claude Code ver sesiones" },
    },
  },
}
