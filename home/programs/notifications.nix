# notifications: idle-nudge + daily reminders + pomodoro.
#
# Packages: uair (pomodoro timer), terminal-notifier (macOS banners).
# Launchd agents: checkin, checkout, daily-review (calendar), idle-nudge (interval),
#   uair-bar (runs uair directly, pipes stdout → sketchybar, no polling).
# Uair config: ~/.config/uair/uair.toml
{ pkgs, ... }:
let
  timew = "${pkgs.timewarrior}/bin/timew";
  task = "${pkgs.taskwarrior3}/bin/task";

  dailyReviewScript = pkgs.writeShellScript "daily-review" ''
    count=$(${task} rc.verbose=nothing +PENDING count 2>/dev/null || echo "?")
    /usr/bin/osascript -e "display notification \"Review today: $count open tasks\" with title \"Daily Review\""
  '';

  # Fire every 20 min; skip outside 09:30–18:30 in the script so a single
  # StartInterval covers all work hours without 60+ plist entries.
  idleNudgeScript = pkgs.writeShellScript "idle-nudge" ''
    time_mins=$(( 10#$(date +%H) * 60 + 10#$(date +%M) ))
    [ $time_mins -lt $(( 12 * 60 + 30 )) ] && exit 0
    [ $time_mins -gt $(( 21 * 60 + 0 )) ]  && exit 0
    active=$(${timew} get dom.active 2>/dev/null)
    [ "$active" = "1" ] && exit 0
    /usr/bin/osascript -e 'display notification "No timer running — start tracking something" with title "Focus"'
  '';

  atTime =
    hour: minute:
    map
      (d: {
        Weekday = d;
        Hour = hour;
        Minute = minute;
      })
      [
        1
        2
        3
        4
        5
      ];

  # Runs uair directly (same pattern as the polybar integration in the uair
  # README). uair's own stdout is clean newline-delimited time strings —
  # no null bytes, no polling. uairctl toggle/pause/resume controls it via
  # the socket while this script owns the process.
  uairBarScript = pkgs.writeShellScript "uair-bar" ''
    sketchybar="${pkgs.sketchybar}/bin/sketchybar"
    uair="${pkgs.uair}/bin/uair"

    while true; do
      "$uair" | while IFS= read -r line; do
        line="''${line%"''${line##*[![:space:]]}"}"
        [ -n "$line" ] && "$sketchybar" --set uair drawing=on \
          label="○ $line" label.color=0xfffab387
      done
      sleep 1
    done
  '';
in
{
  home.packages = [ pkgs.uair ];

  xdg.configFile."uair/uair.toml".text = ''
    loop_on_end = false

    [[sessions]]
    id = "work"
    name = "Work"
    duration = "25m"
    command = "/usr/bin/osascript -e 'display notification \"Break time — well done\" with title \"Pomodoro\"'"
    autostart = false

    [[sessions]]
    id = "break"
    name = "Break"
    duration = "5m"
    command = "/usr/bin/osascript -e 'display notification \"Back to work\" with title \"Pomodoro\"'"
  '';

  launchd.agents = {
    checkin = {
      enable = true;
      config = {
        ProgramArguments = [
          "/usr/bin/osascript"
          "-e"
          ''display notification "Start the day — check in" with title "Day Start"''
        ];
        StartCalendarInterval = atTime 12 30;
      };
    };

    checkout = {
      enable = true;
      config = {
        ProgramArguments = [
          "/usr/bin/osascript"
          "-e"
          ''display notification "Wrap up — check out" with title "Day End"''
        ];
        StartCalendarInterval = atTime 21 0;
      };
    };

    daily-review = {
      enable = true;
      config = {
        ProgramArguments = [ "${dailyReviewScript}" ];
        StartCalendarInterval = atTime 20 30;
      };
    };

    idle-nudge = {
      enable = true;
      config = {
        ProgramArguments = [ "${idleNudgeScript}" ];
        StartInterval = 1200;
      };
    };

    uair-bar = {
      enable = true;
      config = {
        ProgramArguments = [ "${uairBarScript}" ];
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  };
}
