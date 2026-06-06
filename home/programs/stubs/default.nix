# Stubs: HM modules that ship a commented-out config skeleton and a TODO
# explaining what unblocks activation. The bodies evaluate to no-ops --
# they exist so the skeleton is in version control and easy to find.
#
# To activate a stub:
#   1. Uncomment the skeleton in the relevant file and fill PLACEHOLDERs.
#   2. If the tool belongs to a mySystem.home.<tier> group, wire its
#      `programs.<tool>.enable` into modules/home/<tier>.nix. Otherwise
#      the stub's own `programs.<tool>.enable = true` is enough.
#   3. Optionally `git mv` the file back to home/programs/ once the
#      module is no longer a stub.
#
# See docs/stubs.md for the full per-tool blocker list.
{
  imports = [
    ./himalaya.nix
    ./khal.nix
    ./khard.nix
    ./mbsync.nix
    ./meli.nix
    ./mpd.nix
    ./msmtp.nix
    ./ncmpcpp.nix
    ./newsboat.nix
    ./notmuch.nix
    ./restic.nix
    ./rmpc.nix
    ./vdirsyncer.nix
    ./wrtag.nix
    ./wtfutil.nix
    ./xplr.nix
  ];
}
