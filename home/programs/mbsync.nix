# mbsync (isync): IMAP -> local Maildir sync. Pulls all flags + folders
# offline so notmuch/meli/himalaya can index without network round-trips.
#
# TODO: replace PLACEHOLDER values and flip enable to true.
# Pattern is per-account; copy the block below per inbox you sync.
#
# Secrets convention here: never inline passwords. Use one of
#   passwordCommand = [ "${pkgs.coreutils}/bin/cat" "/run/secrets/mail_work" ];
# wired through sops-nix, or an app-password file under ~/.config/mail/.
_: {
  # accounts.email.maildirBasePath = "Mail";
  # accounts.email.accounts.work = {
  #   primary = true;
  #   address = "PLACEHOLDER@example.com";
  #   userName = "PLACEHOLDER@example.com";
  #   realName = "PLACEHOLDER Name";
  #   imap.host = "imap.example.com";
  #   smtp.host = "smtp.example.com";
  #   passwordCommand = "cat /run/secrets/mail_work";
  #   mbsync = {
  #     enable = true;
  #     create = "maildir";
  #     expunge = "both";
  #   };
  # };
  # programs.mbsync.enable = false;
}
