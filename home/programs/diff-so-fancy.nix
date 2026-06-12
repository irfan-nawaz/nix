{
  programs.diff-so-fancy = {
    enable = true;
    # delta now owns core.pager (git.nix). Keep the package available for
    # explicit `diff-so-fancy` invocations but don't wire it into git.
    enableGitIntegration = false;
  };
}
