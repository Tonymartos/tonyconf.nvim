return {
  {
    "stevearc/dressing.nvim",
    opts = {
      input = {
        enabled = true,
        default_prompt = "Input",
        trim_prompt = true,
        title_pos = "left",
        start_mode = "insert",
        border = "rounded",
        relative = "cursor",
        prefer_width = 40,
        max_width = { 140, 0.9 },
        min_width = { 20, 0.2 },
        win_options = {
          wrap = false,
          list = true,
          listchars = "precedes:…,extends:…",
          sidescrolloff = 0,
        },
        mappings = {
          n = {
            ["<Esc>"] = "Close",
            ["<CR>"] = "Confirm",
          },
          i = {
            ["<C-c>"] = "Close",
            ["<CR>"] = "Confirm",
            ["<Up>"] = "HistoryPrev",
            ["<Down>"] = "HistoryNext",
          },
        },
      },
      select = {
        enabled = true,
        backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
        trim_prompt = true,
        builtin = {
          show_numbers = true,
          border = "rounded",
          relative = "editor",
          win_options = {
            cursorline = true,
            cursorlineopt = "both",
          },
          max_width = { 140, 0.8 },
          min_width = { 40, 0.2 },
          max_height = 0.9,
          min_height = { 10, 0.2 },
          mappings = {
            ["<Esc>"] = "Close",
            ["<C-c>"] = "Close",
            ["<CR>"] = "Confirm",
          },
        },
      },
    },
  },
}
