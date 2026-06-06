# gh: GitHub CLI. Auth (per-account) is managed imperatively with
# `gh auth login` -- never put tokens in the nix store. Per the
# multi-account workflow in docs/forge-cli-multi-account.md, switch
# active account with `gh auth switch`.
#
# `package` is pinned to `pkgs.gh` to stay coordinated with
# modules/packages/dev.nix (same store path, no duplicate in the closure).
# Mirror the awscli.nix pattern: if dev.nix ever moves gh to unstable,
# update this line so HM keeps tracking the same derivation.
{ pkgs, ... }:
{
  programs.gh = {
    enable = true;
    package = pkgs.gh;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
        prc = "pr create --fill --web";
        rv = "repo view --web";
        is = "issue list --assignee @me";
      };
    };
    gitCredentialHelper.enable = false;
  };
}
