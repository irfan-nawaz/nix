# jrnl: single default journal at ~/Documents/journal/.
#
# programs.jrnl.settings is intentionally NOT used — the HM module writes
# a read-only nix store symlink and jrnl tries to write back to its config
# at runtime, causing a PermissionError. Instead, home.activation writes
# the config as a real mutable file on first run. jrnl can then update it
# freely; subsequent rebuilds leave the existing mutable file untouched.
{ pkgs, lib, ... }:
let
  jrnlConfig = pkgs.writeText "jrnl.yaml" ''
    default_hour: 9
    default_minute: 0
    editor: nvim
    encrypt: false
    highlight: true
    journals:
      default:
        journal: ~/Documents/journal/default.txt
    linewrap: 79
    template: false
    timeformat: '%Y-%m-%d %H:%M'
  '';
in
{
  home.activation.jrnlSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Write mutable jrnl config on first run. If a read-only symlink exists
    # from a previous HM generation, replace it with a writable copy.
    config_dir="$HOME/.config/jrnl"
    config_file="$config_dir/jrnl.yaml"
    if [ ! -f "$config_file" ] || [ -L "$config_file" ]; then
      mkdir -p "$config_dir"
      rm -f "$config_file"
      cp ${jrnlConfig} "$config_file"
      chmod 644 "$config_file"
    fi

    # Ensure the journal directory exists for the default journal path.
    mkdir -p "$HOME/Documents/journal"
  '';
}
