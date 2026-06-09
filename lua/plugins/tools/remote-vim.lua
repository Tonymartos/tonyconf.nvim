return {
  "Tonymartos/remote-nvim.nvim",
  -- Fork con fix: AppImage download con arquitectura correcta
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
    remote = {
      copy_dirs = {
        config = { dirs = {}, compression = { enabled = true } },
      },
    },
  },
  keys = {
    { "<leader>Rs", "<cmd>RemoteStart<cr>", desc = "Remote SSH: conectar" },
    { "<leader>Rx", "<cmd>RemoteStop<cr>", desc = "Remote SSH: desconectar" },
    { "<leader>Rc", "<cmd>RemoteConfig edit<cr>", desc = "Remote SSH: editar config" },
    { "<leader>Ri", "<cmd>RemoteInfo<cr>", desc = "Remote SSH: info conexion" },
  },
}
