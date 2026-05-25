# vdirsyncer: CalDAV/CardDAV sync into local vdir storage. Feeds khal
# (calendar) and khard (contacts) which both read the vdir on disk.
#
# TODO: configure pair blocks per remote calendar/contact source.
# Run `vdirsyncer discover` once after first enable.
_: {
  # programs.vdirsyncer.enable = false;
  #
  # xdg.configFile."vdirsyncer/config".text = ''
  #   [general]
  #   status_path = "~/.local/share/vdirsyncer/status/"
  #
  #   [pair work_calendar]
  #   a = "work_calendar_local"
  #   b = "work_calendar_remote"
  #   collections = ["from a", "from b"]
  #
  #   [storage work_calendar_local]
  #   type = "filesystem"
  #   path = "~/.local/share/calendars/work/"
  #   fileext = ".ics"
  #
  #   [storage work_calendar_remote]
  #   type = "caldav"
  #   url = "https://PLACEHOLDER.example.com/dav/"
  #   username = "PLACEHOLDER"
  #   password.fetch = ["command", "cat", "/run/secrets/caldav_work"]
  # '';
}
