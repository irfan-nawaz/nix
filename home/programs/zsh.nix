# zsh + the 305-alias bundle. Aliases live in ./zsh/aliases.nix split
# by category; this module wires them in.
#
# Per-user/per-host extras (e.g. rebuild/testbuild that need the active
# username in their target) are added in home/users/<u>.nix via
# `programs.zsh.shellAliases` which merges with these.
{ hostname, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # -C skips the daily security check on cached completions. On nix
    # systems compinit otherwise rescans every fpath entry every
    # startup (~150-300ms with many pkgs); the cache is rebuilt by
    # home-manager itself whenever modules change.
    completionInit = "autoload -U compinit && compinit -C";

    shellAliases = import ./zsh/aliases.nix { inherit hostname; };

    # Note: starship init is added by programs.starship.enableZshIntegration
    # (set in home/programs/starship.nix). Initialising it again here would
    # double the cost (~50-100ms per shell).
  };
}
