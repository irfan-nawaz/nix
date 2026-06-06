# notmuch: tag-based mail indexer. Runs against the local Maildir mbsync
# populates. Tags drive virtual folders in meli/himalaya/alot.
#
# TODO: enable after mbsync has pulled at least once. First-time setup:
#   $ notmuch new   # builds the initial xapian index
_: {
  # programs.notmuch = {
  #   enable = false;
  #   hooks = {
  #     preNew  = "mbsync --all";
  #     postNew = "afew --tag --new";
  #   };
  #   new.tags = [ "unread" "inbox" ];
  # };
}
