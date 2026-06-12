# carapace: cross-shell completion bridge. Sole completer for the
# cloud-native toolchain -- gives a consistent UI across kubectl, helm,
# terraform, docker, gh, aws, etc. instead of each tool registering its
# own compdef style.
#
# CARAPACE_BRIDGES: fall back to each tool's native bash/zsh/fish
# completions when carapace has no built-in spec, so nothing regresses.
{
  programs.carapace.enableZshIntegration = true;
  home.sessionVariables.CARAPACE_BRIDGES = "zsh,bash,fish,inshellisense";
}
