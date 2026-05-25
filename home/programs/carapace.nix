# carapace: cross-shell completion bridge. With zsh integration on,
# `carapace _carapace` is loaded automatically and bash-spec
# completions become available to zsh.
{
  programs.carapace.enableZshIntegration = true;
}
