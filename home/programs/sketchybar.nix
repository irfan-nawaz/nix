# sketchybar: scriptable macOS status bar. Config is a shell script the
# binary execs on startup: ~/.config/sketchybar/sketchybarrc must be
# executable. Plugins live next to it under plugins/.
#
# TODO: drop ./sketchybar/sketchybarrc (chmod +x) then uncomment below.
# Reference: https://felixkratz.github.io/SketchyBar/setup
_: {
  # xdg.configFile = {
  #   "sketchybar/sketchybarrc" = {
  #     source = ./sketchybar/sketchybarrc;
  #     executable = true;
  #   };
  #   "sketchybar/plugins" = {
  #     source = ./sketchybar/plugins;
  #     recursive = true;
  #   };
  # };
  #
  # Skeleton sketchybarrc:
  #   #!/usr/bin/env bash
  #   sketchybar --bar height=32 position=top blur_radius=30 color=0xff1e1e2e
  #   sketchybar --add item clock right \
  #              --set clock update_freq=10 script="date '+%H:%M'"
  #   sketchybar --update
}
