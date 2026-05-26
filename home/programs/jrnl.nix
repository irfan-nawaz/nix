# jrnl: single default journal at ~/Documents/journal/. Multiple
# journals can be added later under `journals.<name>`.
{ lib, ... }:
{
  programs.jrnl.settings = {
    editor = "nvim";
    encrypt = false;
    template = false;
    default_hour = 9;
    default_minute = 0;
    timeformat = "%Y-%m-%d %H:%M";
    highlight = true;
    linewrap = 79;
    journals.default.journal = "~/Documents/journal/default.txt";
  };

  # The `journal` sesh session sets path = ~/Documents/journal, so the
  # directory must exist before tmux tries to chdir into it. jrnl itself
  # creates the .txt file lazily on first entry; the parent dir is on us.
  home.activation.jrnlJournalDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/Documents/journal"
  '';
}
