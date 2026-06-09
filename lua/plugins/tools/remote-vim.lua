return {
  "amitds1997/remote-nvim.nvim",
  version = "0.3.11",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    ssh_config = {
      enabled = true,
    },
    client_callback = function(port, workspace_config)
      vim.print("Remote nvim started on port " .. port)
    end,
  },
  keys = {
    { "<leader>Rs", "<cmd>RemoteStart<cr>", desc = "Remote SSH: conectar" },
    { "<leader>Rx", "<cmd>RemoteStop<cr>", desc = "Remote SSH: desconectar" },
    { "<leader>Rc", "<cmd>RemoteConfig edit<cr>", desc = "Remote SSH: editar config" },
    { "<leader>Ri", "<cmd>RemoteInfo<cr>", desc = "Remote SSH: info conexion" },
  },
}
