local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

local is_macos = wezterm.target_triple:find("apple") ~= nil

-- ═══════════════════════════════════════════════════════════════════════════════
-- APARIENCIA
-- ═══════════════════════════════════════════════════════════════════════════════
config.color_scheme = "kanagawa (Gogh)"

config.window_padding = { left = 4, right = 4, top = 8, bottom = 4 }
config.window_background_opacity = 0.92
config.window_decorations = "TITLE | RESIZE | INTEGRATED_BUTTONS"

-- ═══════════════════════════════════════════════════════════════════════════════
-- FUENTE
-- ═══════════════════════════════════════════════════════════════════════════════
local emoji_font = is_macos and "Apple Color Emoji" or "Noto Color Emoji"
config.font = wezterm.font_with_fallback({
  "CaskaydiaCove Nerd Font",
  emoji_font,
})
config.font_size = 13.0
config.harfbuzz_features = { "calt", "liga", "dlig", "zero" }

-- ═══════════════════════════════════════════════════════════════════════════════
-- RENDIMIENTO
-- ═══════════════════════════════════════════════════════════════════════════════
config.front_end = "WebGpu"
config.max_fps = 120

-- ═══════════════════════════════════════════════════════════════════════════════
-- TERMINAL
-- ═══════════════════════════════════════════════════════════════════════════════
config.scrollback_lines = 10000
config.term = "wezterm"
config.enable_scroll_bar = true

-- ═══════════════════════════════════════════════════════════════════════════════
-- CURSOR
-- ═══════════════════════════════════════════════════════════════════════════════
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500

-- ═══════════════════════════════════════════════════════════════════════════════
-- TABLINE (tabline.wez)
-- ═══════════════════════════════════════════════════════════════════════════════
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

tabline.setup({
  options = {
    icons_enabled = true,
    tabs_enabled = true,
    tab_and_status_padding = 0,
    section_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left = wezterm.nerdfonts.pl_left_soft_divider,
      right = wezterm.nerdfonts.pl_right_soft_divider,
    },
    tab_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
  },
  sections = {
    tabline_a = { "mode" },
    tabline_b = { "workspace" },
    tabline_c = { "hostname" },
    tab_active = {
      "index",
      { "parent", padding = 0 },
      "/",
      { "cwd", padding = { left = 0, right = 1 } },
      { "zoomed", padding = 0 },
    },
    tab_inactive = {
      "index",
      { "process", padding = { left = 0, right = 1 } },
    },
    tabline_x = { "ram", "cpu" },
    tabline_y = {
      {
        "datetime",
        style = "%a %d %b %H:%M",
      },
    },
    tabline_z = { "domain" },
  },
  extensions = {},
})

tabline.apply_to_config(config)

-- ═══════════════════════════════════════════════════════════════════════════════
-- HYPERLINKS
-- ═══════════════════════════════════════════════════════════════════════════════
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = is_macos and "CMD" or "CTRL",
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- SMART-SPLITS (Neovim ↔ WezTerm pane navigation)
-- ═══════════════════════════════════════════════════════════════════════════════
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
smart_splits.apply_to_config(config, {
  direction_keys = { "h", "j", "k", "l" },
  modifiers = { move = "CTRL", resize = "META" },
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- KEYBINDINGS
-- ═══════════════════════════════════════════════════════════════════════════════
wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

table.insert(config.keys, { key = "+", mods = "CTRL", action = wezterm.action.IncreaseFontSize })
table.insert(config.keys, { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize })
table.insert(config.keys, { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize })
table.insert(config.keys, { key = "v", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") })
table.insert(config.keys, { key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") })

return config
