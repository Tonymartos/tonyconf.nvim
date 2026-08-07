return {
  "snacks.nvim",
  opts = function(_, opts)
    vim.tbl_deep_extend("force", opts, {
      image = { enabled = false },
    })
    opts.dashboard = vim.tbl_deep_extend("force", opts.dashboard or {}, {
      preset = {
        header = [[
 ████████╗ ██████╗ ███╗   ██╗██╗   ██╗██╗   ██╗██╗███╗   ███╗
 ╚══██╔══╝██╔═══██╗████╗  ██║╚██╗ ██╔╝██║   ██║██║████╗ ████║
    ██║   ██║   ██║██╔██╗ ██║ ╚████╔╝ ██║   ██║██║██╔████╔██║
    ██║   ██║   ██║██║╚██╗██║  ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║
    ██║   ╚██████╔╝██║ ╚████║   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
    ╚═╝    ╚═════╝ ╚═╝  ╚═══╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    })
    return opts
  end,
}
