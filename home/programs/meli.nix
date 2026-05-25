# meli: TUI mail client (Rust). No HM module — config lives at
# ~/.config/meli/config.toml. Reads the same Maildir mbsync writes.
#
# TODO: drop a real config at ./meli/config.toml then uncomment the
# xdg.configFile line below. Reference: https://meli.delivery/documentation.html
_: {
  # xdg.configFile."meli/config.toml".source = ./meli/config.toml;
  #
  # Minimal example (TOML):
  #   [accounts.work]
  #   root_mailbox = "/Users/PLACEHOLDER/Mail/work"
  #   format = "Maildir"
  #   identity = "PLACEHOLDER@example.com"
  #   display_name = "PLACEHOLDER"
  #   send_mail = "msmtp --read-recipients --read-envelope-from"
}
