# aerospace: i3-style tiling WM for macOS. Reads ~/.aerospace.toml (NOT
# $XDG_CONFIG_HOME). No HM module — manage via home.file.
#
# TODO: tune ./aerospace/aerospace.toml then uncomment the home.file line.
# Reference: https://nikitabobko.github.io/AeroSpace/guide
_: {
  # home.file.".aerospace.toml".source = ./aerospace/aerospace.toml;
  #
  # Minimal skeleton (TOML):
  #   start-at-login = true
  #   default-root-container-layout = "tiles"
  #   [mode.main.binding]
  #   alt-h = "focus left"
  #   alt-j = "focus down"
  #   alt-k = "focus up"
  #   alt-l = "focus right"
  #   alt-shift-h = "move left"
  #   alt-shift-j = "move down"
  #   alt-shift-k = "move up"
  #   alt-shift-l = "move right"
}
