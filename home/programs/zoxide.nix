# zoxide: smarter `cd`. With `--cmd cd` it transparently shadows the
# real cd so muscle memory works (frecency-ranked jump on every call).
# Zsh integration is auto-on through home-manager because the user's
# zsh module is enabled.
_: {
  programs.zoxide.options = [ "--cmd cd" ];
}
