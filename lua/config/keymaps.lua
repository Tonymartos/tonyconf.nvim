-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local themes = {
  "kanagawa",
  "catppuccin-mocha",
  "catppuccin-macchiato",
  "catppuccin-frappe",
  "catppuccin-latte",
  "onedark",
}

local onedark_styles = { "darker", "dark", "cool", "deep", "warm", "warmer", "light" }

local kanagawa_themes = { "wave", "dragon", "lotus" }

-- Theme rotator
vim.keymap.set("n", "<leader>ut", function()
  local current = vim.g.colors_name or ""
  if current:match("^onedark") then
    local style = current:match("onedark%-(.+)") or "darker"
    local idx = 1
    for i, s in ipairs(onedark_styles) do
      if s == style then idx = i break end
    end
    local next_style = onedark_styles[idx % #onedark_styles + 1]
    require("onedark").setup({ style = next_style, transparent = true })
    require("onedark").load()
    vim.notify("OneDark: " .. next_style, vim.log.levels.INFO, { title = "Theme" })
  elseif current == "kanagawa" then
    vim.cmd.colorscheme("catppuccin-mocha")
    vim.notify("Tema: catppuccin-mocha", vim.log.levels.INFO, { title = "Theme" })
  else
    local idx = 1
    for i, t in ipairs(themes) do
      if t == current or (current == "catppuccin" and i == 1) then
        idx = i
        break
      end
    end
    local next_theme = themes[idx % #themes + 1]
    if next_theme == "onedark" then
      require("onedark").setup({ style = "darker", transparent = true })
      require("onedark").load()
    else
      vim.cmd.colorscheme(next_theme)
    end
    vim.notify("Tema: " .. next_theme, vim.log.levels.INFO, { title = "Theme" })
  end
end, { desc = "Rotate theme" })

-- Transparency toggle
vim.keymap.set("n", "<leader>ug", function()
  local current = vim.g.colors_name or ""

  if current == "catppuccin" or current:match("catppuccin%-") then
    local opts = require("catppuccin.config").options
    opts.transparent_background = not opts.transparent_background
    vim.cmd.colorscheme(current)
    vim.notify("Transparencia: " .. (opts.transparent_background and "ON" or "OFF"), vim.log.levels.INFO, { title = "Theme" })
  elseif current == "onedark" then
    local onedark = require("onedark")
    local config = onedark.config or {}
    config.transparent = not config.transparent
    onedark.setup(config)
    onedark.load()
    vim.notify("Transparencia: " .. (config.transparent and "ON" or "OFF"), vim.log.levels.INFO, { title = "Theme" })
  elseif current == "kanagawa" then
    local ok, kanagawa = pcall(require, "kanagawa")
    if ok then
      local current_opts = kanagawa.config.options or {}
      local new_trans = not current_opts.transparent
      kanagawa.setup({ transparent = new_trans })
      vim.cmd.colorscheme("kanagawa")
      vim.notify("Transparencia: " .. (new_trans and "ON" or "OFF"), vim.log.levels.INFO, { title = "Theme" })
    end
  end
end, { desc = "Toggle transparency" })
