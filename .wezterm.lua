local wezterm = require 'wezterm'
local config = {}

-- --- Wygląd okna i przezroczystość ---
config.window_background_opacity = 0.80
config.text_background_opacity = 1.0
config.window_decorations = "NONE" 
config.window_padding = {
  left = 12,
  right = 12,
  top = 12,
  bottom = 12,
}

-- --- Czcionka (Cyberpunk vibe!) ---
config.font = wezterm.font 'BlexMono Nerd Font'
config.font_size = 11.0

config.window_background_opacity = 0.85
-- --- Paleta Kolorów: Catppuccin Macchiato ---
config.colors = {
  background = '#24273a',
  foreground = '#D9E0EE',
  cursor_bg = '#8bd5ca',
  cursor_fg = '#24273a',
  selection_bg = '#494d64',
  selection_fg = '#cad3f5',
  ansi = {
    '#494d64', '#ed8796', '#a6da95', '#eed49f', 
    '#8aadf4', '#f5bde6', '#8bd5ca', '#b8c0e0'
  },
  brights = {
    '#5b6078', '#ed8796', '#a6da95', '#eed49f', 
    '#8aadf4', '#f5bde6', '#8bd5ca', '#a5adcb'
  },
}

-- --- Inne ustawienia ---
config.scrollback_lines = 5000
config.enable_tab_bar = false 
config.check_for_updates = false

return config
