# msmtp: SMTP send-only client. Pairs with mbsync (receive) so the
# notmuch/meli/himalaya stack stays fully local with a thin send path.
#
# TODO: configure per accounts.email.accounts.<name> block in mbsync.nix
# then set the matching `msmtp.enable = true;` on each account.
_: {
  # accounts.email.accounts.work.msmtp.enable = false;
  # programs.msmtp.enable = false;
}
