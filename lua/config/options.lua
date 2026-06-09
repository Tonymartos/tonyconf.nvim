-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Fix locale false-positive in checkhealth (Linux: LANG env, macOS: export LANG)
if vim.env.LANG and vim.env.LANG:match("UTF%-8$") then
  vim.env.LC_ALL = vim.env.LANG
elseif vim.fn.has("mac") == 1 then
  vim.env.LC_ALL = "en_US.UTF-8"
end
