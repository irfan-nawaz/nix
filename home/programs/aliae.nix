# aliae: cross-shell alias + env manager. Enabled via modules/home/tui.nix.
# Most aliases live in programs/zsh/aliases.nix (zsh-specific). When you
# adopt a second interactive shell (bash/fish/nu), add cross-shell aliases
# here:
#   programs.aliae.settings.alias = [
#     { name = "ll"; value = "eza -lh --icons --git"; }
#   ];
# Schema reference: https://aliae.dev/docs/reference
_: { }
