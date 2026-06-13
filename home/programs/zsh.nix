# zsh + the 305-alias bundle. Aliases live in ./zsh/aliases.nix split
# by category; this module wires them in.
#
# Per-user/per-host extras (e.g. rebuild/testbuild that need the active
# username in their target) are added in home/users/<u>.nix via
# `programs.zsh.shellAliases` which merges with these.
{ hostname, pkgs, ... }:
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

    # Multi-step LLM shell functions — too stateful for aliases.
    # Require ollama running + llm-ollama plugin (both wired automatically after rebuild).
    initContent = ''
      # Summarise a file or stdin with the local model: `lms file.txt` or `cmd | lms`
      lms() { cat "''${1:--}" | ${pkgs.llm}/bin/llm -m ollama/personal "summarise this concisely"; }

      # Generate a conventional commit message from staged diff
      gcai() { git diff --cached | ${pkgs.llm}/bin/llm -m ollama/personal "write a conventional commit message for this diff, output only the message with no explanation"; }

      # Run a command and explain its output (captures stderr too): `explain cargo build`
      explain() { "$@" 2>&1 | ${pkgs.llm}/bin/llm -m ollama/personal "explain this output and any errors concisely"; }
    '';

    # Note: starship init is added by programs.starship.enableZshIntegration
    # (set in home/programs/starship.nix). Initialising it again here would
    # double the cost (~50-100ms per shell).
  };
}
