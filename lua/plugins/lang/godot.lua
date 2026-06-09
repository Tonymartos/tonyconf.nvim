return {
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        gdscript = {
          cmd = { "godot", "--headless", "--editor" },
          filetypes = { "gd", "gdscript", "gdshader" },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("project.godot", ".git")(fname)
          end,
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "gdscript", "gdshader" })
    end,
  },
}
