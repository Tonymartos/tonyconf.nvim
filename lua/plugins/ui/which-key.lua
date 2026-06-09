return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = function(_, opts)
      local spec = opts.spec or {}
      vim.list_extend(spec, {
        { "<leader>a", group = "OpenCode", icon = { icon = "", color = "green" } },
        { "<leader>ai", group = "Avante", icon = { icon = "󰚩", color = "yellow" } },
        { "<leader>c", group = "Claude Code", icon = { icon = "", color = "orange" } },
        { "<leader>R", group = "Remote SSH", icon = { icon = "󰒋", color = "cyan" } },
        { "<leader>u", group = "Temas", icon = { icon = "󰔎", color = "magenta" } },
      })
      opts.spec = spec
    end,
  },
}
