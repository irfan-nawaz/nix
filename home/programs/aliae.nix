# aliae: cross-shell alias + env manager. Most aliases already live in
# programs/zsh/aliases.nix (zsh-specific). Use this file for anything
# you want shared with bash/fish/nu later.
#
# Schema reference: https://aliae.dev/docs/reference
{
  programs.aliae.settings = {
    alias = [
      # placeholder -- migrate cross-shell aliases here when adopting a
      # second interactive shell.
    ];
    env = [ ];
  };
}
