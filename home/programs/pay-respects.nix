# pay-respects: `thefuck`-style command corrector (Rust port). Zsh
# integration is on by default once the program is enabled; alias is
# `f` so a typo'd command followed by `f` re-runs it corrected.
_: {
  programs.pay-respects = {
    enableZshIntegration = true;
    options = [
      "--alias"
      "f"
    ];
  };
}
