# wtfutil: TUI personal dashboard (calendar, gcal, jira, github, etc.).
# Config is YAML at ~/.config/wtf/config.yml.
#
# TODO: edit ./wtfutil/config.yml with real creds (or use sops) then
# uncomment the xdg.configFile line below.
# Reference: https://wtfutil.com/posts/configuration/
_: {
  # xdg.configFile."wtf/config.yml".source = ./wtfutil/config.yml;
  #
  # Minimal skeleton (YAML):
  #   wtf:
  #     grid:
  #       columns: [40, 40]
  #       rows: [10, 10]
  #     refreshInterval: 1
  #     mods:
  #       clocks:
  #         enabled: true
  #         position: { top: 0, left: 0, height: 1, width: 1 }
  #         locations:
  #           Local:  "America/Denver"
  #           Mumbai: "Asia/Kolkata"
}
