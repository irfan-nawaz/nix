# sketchybar: scriptable macOS status bar. The HM module installs the
# rc to ~/.config/sketchybar/sketchybarrc (chmod +x, shebang auto-added)
# and owns the launchd agent at ~/Library/Logs/sketchybar/sketchybar.{out,err}.log.
#
# Bar layout:
#   left:  workspace pills 1..9 (subscribed to aerospace_workspace_change,
#          which aerospace.nix triggers via exec-on-workspace-change)
#   right: task-count, timew tracker, clock, battery
#
# Plugins live next to the rc as xdg.configFile entries (no extra dirs,
# all paths declarative). External CLIs the plugins need (aerospace,
# timew, task) are wired through `extraPackages` so they end up on the
# wrapped sketchybar's PATH and are inherited by spawned scripts.
#
# Cross-app triggering:
#   - aerospace_workspace_change: fired from aerospace.nix
#     (exec-on-workspace-change). Picked up by the workspace pills.
#   - timew_update: fired by the taskwarrior on-modify hook below and
#     also usable from any script (`sketchybar --trigger timew_update`).
#     Picked up by the timew + task_count items so `task start/stop`
#     repaints the bar instantly instead of waiting for the poll.
#
# Colors: Catppuccin Mocha (matches our nvim/tmux/btop theme).
{ pkgs, ... }:
{
  programs.sketchybar = {
    extraPackages = [
      pkgs.aerospace
      pkgs.timewarrior
      pkgs.taskwarrior3
    ];

    config.text = ''
      # ─── Catppuccin Mocha ──────────────────────────────────────────
      export BAR_BG=0xff1e1e2e
      export FG=0xffcdd6f4
      export DIM=0xff6c7086
      export ACCENT=0xff89b4fa
      export SURFACE=0xff313244
      export RED=0xfff38ba8

      PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

      # ─── Custom events ─────────────────────────────────────────────
      # Sketchybar requires custom events to be declared before items
      # can subscribe / `--trigger` can fire them.
      sketchybar --add event aerospace_workspace_change
      sketchybar --add event aerospace_mode
      sketchybar --add event timew_update

      # ─── Bar ───────────────────────────────────────────────────────
      sketchybar --bar height=28 \
                       position=top \
                       padding_left=8 padding_right=8 \
                       color=$BAR_BG \
                       blur_radius=0 \
                       shadow=off

      # ─── Defaults applied to every item ────────────────────────────
      sketchybar --default updates=when_shown \
                           icon.font="SF Pro:Semibold:13.0" \
                           icon.color=$FG \
                           label.font="SF Pro:Semibold:13.0" \
                           label.color=$FG \
                           padding_left=2 padding_right=2 \
                           label.padding_left=6 label.padding_right=6 \
                           icon.padding_left=6 icon.padding_right=4

      # ─── Workspace pills (left) ────────────────────────────────────
      # Each pill subscribes to the custom event aerospace.nix triggers
      # on workspace change. The script repaints based on
      # $FOCUSED_WORKSPACE (set by aerospace --trigger).
      for sid in 1 2 3 4 5 6 7 8 9; do
        sketchybar --add item space.$sid left \
                   --subscribe space.$sid aerospace_workspace_change \
                   --set space.$sid \
                       label="$sid" \
                       click_script="aerospace workspace $sid" \
                       script="$PLUGIN_DIR/aerospace.sh $sid"
      done

      # ─── WM mode indicator (left, between workspace pills and app) ───
      # Hidden in main mode; shows "WM" (yellow) or "SVC" (red) otherwise.
      # Driven by aerospace_mode event fired from aerospace.nix bindings.
      sketchybar --add item wm_mode left \
                 --subscribe wm_mode aerospace_mode \
                 --set wm_mode drawing=off \
                       updates=on \
                       script="$PLUGIN_DIR/wm_mode.sh"

      # ─── Front app (left, after workspace pills) ───────────────────
      # Shows the currently-focused app's name. Sketchybar emits the
      # built-in `front_app_switched` event whenever macOS focus changes
      # and passes the app name in $INFO -- near-zero overhead, no poll.
      # The script also runs once on item creation (no $INFO yet), so
      # fall back to lsappinfo for the initial paint.
      sketchybar --add item front_app left \
                 --subscribe front_app front_app_switched \
                 --set front_app \
                       icon.drawing=off \
                       label.color=$ACCENT \
                       label.padding_left=10 \
                       script="$PLUGIN_DIR/front_app.sh"

      # ─── Right side ────────────────────────────────────────────────
      # Items added to "right" stack right-to-left in declaration order,
      # so visual order on the bar will be:
      #   [task] [timew]   [clock]   [battery]
      sketchybar --add item battery right \
                 --subscribe battery system_woke power_source_change \
                 --set battery update_freq=60 \
                       script="$PLUGIN_DIR/battery.sh"

      # Clock label must be set via `sketchybar --set` -- sketchybar does
      # NOT capture a script's stdout as the label, so a bare `date ...`
      # only prints to the launchd log and the bar stays empty. Wrap the
      # date call in an explicit set on $NAME instead.
      sketchybar --add item clock right \
                 --set clock update_freq=10 \
                       script="sketchybar --set \$NAME label=\"\$(date '+%a %b %d  %H:%M')\""

      sketchybar --add item timew right \
                 --subscribe timew timew_update \
                 --set timew update_freq=30 \
                       script="$PLUGIN_DIR/timew.sh" \
                       click_script="timew stop"

      sketchybar --add item uair right \
                 --set uair drawing=off

      sketchybar --add item task_count right \
                 --subscribe task_count timew_update \
                 --set task_count update_freq=60 \
                       script="$PLUGIN_DIR/task_count.sh"

      sketchybar --update
    '';
  };

  # ─── Plugins ─────────────────────────────────────────────────────
  # Sketchybar invokes plugin scripts with NAME=<item-name> (and SENDER
  # for event-driven runs). We only need NAME here.
  xdg.configFile."sketchybar/plugins/aerospace.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Highlight pill if its workspace id matches the focused workspace.
      # $FOCUSED_WORKSPACE comes from `--trigger ... FOCUSED_WORKSPACE=N`.
      # On first paint (script runs once at item creation), the env var
      # is absent -- fall back to querying aerospace directly.
      SID="$1"
      FOCUSED="''${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

      if [[ "$FOCUSED" == "$SID" ]]; then
        sketchybar --set "$NAME" \
          background.color=0xff89b4fa \
          background.drawing=on \
          background.corner_radius=4 \
          background.height=20 \
          label.color=0xff1e1e2e
      else
        sketchybar --set "$NAME" \
          background.drawing=off \
          label.color=0xff6c7086
      fi
    '';
  };

  xdg.configFile."sketchybar/plugins/wm_mode.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      case "$MODE" in
        wm)
          sketchybar --set "$NAME" drawing=on label="WM" label.color=0xfffab387
          ;;
        service)
          sketchybar --set "$NAME" drawing=on label="SVC" label.color=0xfff38ba8
          ;;
        *)
          sketchybar --set "$NAME" drawing=off
          ;;
      esac
    '';
  };

  xdg.configFile."sketchybar/plugins/front_app.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # On a front_app_switched event sketchybar sets $INFO to the app
      # name. On initial item creation no event has fired yet, so query
      # lsappinfo directly for the current frontmost app.
      APP="$INFO"
      if [[ -z "$APP" ]]; then
        APP=$(/usr/bin/lsappinfo info -only name "$(/usr/bin/lsappinfo front)" 2>/dev/null \
              | awk -F\" '/LSDisplayName/{print $4}')
      fi
      sketchybar --set "$NAME" label="''${APP:-—}"
    '';
  };

  xdg.configFile."sketchybar/plugins/timew.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Show "tag · 23m" while a timew interval is active; hide otherwise.
      # `dom.active.start` is ISO 8601 extended LOCAL time
      # ("2026-05-26T23:44:45") -- parsed with BSD `date -j -f` (no -u; the
      # input has no zone marker so we treat it as local, matching timew).
      # If parsing fails (empty EPOCH), bail out -- else arithmetic treats
      # empty as 0 and ELAPSED becomes the entire unix epoch (~494000h).
      if [[ "$(timew get dom.active 2>/dev/null)" != "1" ]]; then
        sketchybar --set "$NAME" drawing=off
        exit 0
      fi

      TAG=""
      if [[ "$(timew get dom.active.tags.count 2>/dev/null)" -gt 0 ]]; then
        TAG="$(timew get dom.active.tags.1 2>/dev/null)"
      fi

      START="$(timew get dom.active.start 2>/dev/null)"
      EPOCH=$(date -j -f '%Y-%m-%dT%H:%M:%S' "$START" '+%s' 2>/dev/null)
      if [[ -z "$EPOCH" ]]; then
        sketchybar --set "$NAME" drawing=off
        exit 0
      fi
      ELAPSED=$(( $(date '+%s') - EPOCH ))
      H=$(( ELAPSED / 3600 ))
      M=$(( (ELAPSED % 3600) / 60 ))
      if (( H > 0 )); then ETXT="''${H}h''${M}m"; else ETXT="''${M}m"; fi

      LABEL="''${TAG:+$TAG · }''${ETXT}"
      sketchybar --set "$NAME" drawing=on label="$LABEL" label.color=0xfff9e2af
    '';
  };

  xdg.configFile."sketchybar/plugins/task_count.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Pending task count, hidden when zero so an empty inbox stays quiet.
      # `rc.verbose=nothing` strips taskwarrior's "1 task" footer chatter.
      COUNT=$(task rc.verbose=nothing +PENDING count 2>/dev/null)
      if [[ -z "$COUNT" || "$COUNT" == "0" ]]; then
        sketchybar --set "$NAME" drawing=off
      else
        sketchybar --set "$NAME" drawing=on label="[$COUNT]" label.color=0xff89b4fa
      fi
    '';
  };

  # ─── Taskwarrior -> sketchybar bridge ───────────────────────────
  # Stock taskwarrior hook contract: read original + modified JSON lines
  # from stdin, echo the modified one back. We do that, then fire the
  # custom sketchybar event so `task <id> start` repaints the bar instantly
  # instead of waiting for the next 30s poll. `command -v` guards the
  # build-time hook execution where sketchybar may not be on PATH.
  xdg.configFile."task/hooks/on-modify.sketchybar" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      read -r original
      read -r modified
      echo "$modified"
      command -v sketchybar >/dev/null 2>&1 && \
        sketchybar --trigger timew_update >/dev/null 2>&1
      exit 0
    '';
  };

  xdg.configFile."sketchybar/plugins/battery.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # pmset is the macOS canonical source; no nerd-font deps -- plain
      # text label. Turns red below 20% on battery.
      PCT=$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
      STATE=$(pmset -g batt | grep -Eo 'charging|discharging|charged|AC attached' | head -1)

      if [[ "$STATE" == "charging" || "$STATE" == "AC attached" || "$STATE" == "charged" ]]; then
        PREFIX="+"
        COLOR=0xffa6e3a1
      else
        PREFIX=""
        if (( PCT <= 20 )); then COLOR=0xfff38ba8; else COLOR=0xffcdd6f4; fi
      fi

      sketchybar --set "$NAME" label="''${PREFIX}''${PCT}%" label.color="$COLOR"
    '';
  };
}
