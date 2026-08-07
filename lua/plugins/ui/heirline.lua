return {
  {
    "rebelot/heirline.nvim",
    lazy = false,
    dependencies = {
      "SmiteshP/nvim-navic",
      { "nvim-mini/mini.icons", version = false },
    },
    config = function()
      local conditions = require("heirline.conditions")

      local colors = {
        bg = "#1F1F28",
        fg = "#DCD7BA",
        red = "#C34043",
        green = "#76946A",
        yellow = "#C0A36E",
        blue = "#7E9CD8",
        magenta = "#957FB8",
        cyan = "#6A9589",
        dark = "#16161D",
      }

      local ViMode = {
        init = function(self)
          self.mode = vim.fn.mode(1):lower()
        end,
        static = {
          mode_icons = {
            n = "NORMAL", v = "VISUAL", V = "V-LINE", ["\22"] = "V-BLOCK",
            s = "SELECT", S = "S-LINE", ["\19"] = "S-BLOCK",
            i = "INSERT", R = "REPLACE", c = "COMMAND",
            ["!"] = "SHELL", t = "TERMINAL",
          },
          mode_colors = {
            n = colors.green, i = colors.blue, v = colors.yellow,
            ["\22"] = colors.cyan, s = colors.yellow, ["\19"] = colors.yellow,
            R = colors.magenta, c = colors.red, ["!"] = colors.red, t = colors.green,
          },
        },
        provider = function(self)
          return " " .. (self.mode_icons[self.mode] or self.mode:upper()) .. " "
        end,
        hl = function(self)
          return { bg = self.mode_colors[self.mode:sub(1, 1)] or colors.blue, fg = colors.dark, bold = true }
        end,
      }

      local FileIcon = {
        init = function(self)
          local f = vim.api.nvim_buf_get_name(0)
          local e = vim.fn.fnamemodify(f, ":e")
          self.icon, self.icon_hl = require("mini.icons").get("file", e)
        end,
        provider = function(self)
          return self.icon and (self.icon .. " ") or ""
        end,
        hl = function(self)
          if not self.icon_hl then
            return { fg = colors.fg }
          end
          local ok, resolved = pcall(vim.api.nvim_get_hl, 0, { name = self.icon_hl, link = false })
          if ok and resolved and resolved.fg then
            return { fg = string.format("#%06x", resolved.fg) }
          end
          return { fg = colors.fg }
        end,
      }

      local FileName = {
        provider = function()
          local name = vim.fn.expand("%:t")
          return (name ~= "" and name or "[No Name]") .. " "
        end,
        hl = { fg = colors.fg, bold = true },
      }

      local FileFlags = {
        {
          condition = function() return vim.bo.modified end,
          provider = " [+]",
          hl = { fg = colors.yellow },
        },
        {
          condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
          provider = " ",
          hl = { fg = colors.red },
        },
      }

      local GitBranch = {
        condition = conditions.is_git_repo,
        init = function(self)
          self.status_dict = vim.b.gitsigns_status_dict
        end,
        {
          provider = "  ",
          hl = { fg = colors.yellow },
        },
        {
          provider = function()
            return (self.status_dict and self.status_dict.head or "") .. " "
          end,
          hl = { fg = colors.fg },
        },
      }

      local Diagnostics = {
        condition = conditions.has_diagnostics,
        {
          provider = function()
            local err = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
            local warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
            local info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
            local hint = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
            local parts = {}
            if err > 0 then table.insert(parts, " " .. err) end
            if warn > 0 then table.insert(parts, " " .. warn) end
            if info > 0 then table.insert(parts, " " .. info) end
            if hint > 0 then table.insert(parts, " " .. hint) end
            if #parts == 0 then return "" end
            return " " .. table.concat(parts, "  ") .. " "
          end,
          hl = { fg = colors.fg },
        },
      }

      local LSPActive = {
        condition = conditions.lsp_attached,
        provider = function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients == 0 then return "" end
          local names = vim.tbl_map(function(c) return c.name end, clients)
          return "  " .. table.concat(names, ", ") .. " "
        end,
        hl = { fg = colors.cyan },
      }

      local FileType = {
        provider = function()
          return " " .. string.upper(vim.bo.filetype) .. " "
        end,
        hl = { fg = colors.magenta },
      }

      local FilePosition = {
        provider = function()
          return string.format(" %3d:%2d ", vim.fn.line("."), vim.fn.col("."))
        end,
        hl = { fg = colors.fg },
      }

      local StatusLine = {
        hl = { bg = colors.bg, fg = colors.fg },
        ViMode,
        { provider = " " },
        FileIcon,
        FileName,
        FileFlags,
        { provider = " " },
        GitBranch,
        { provider = "%=" },
        Diagnostics,
        LSPActive,
        FileType,
        FilePosition,
      }

      require("heirline").setup({
        statusline = StatusLine,
      })
    end,
  },
}
