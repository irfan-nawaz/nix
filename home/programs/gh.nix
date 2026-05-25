# gh: GitHub CLI. Auth (per-account) is managed imperatively with
# `gh auth login` -- never put tokens in the nix store. Per the
# multi-account workflow in docs/forge-cli-multi-account.md, switch
# active account with `gh auth switch`.
#
# Note: the dev package set already installs `gh`; enabling the HM
# module here just adds declarative settings on top.
_: {
  programs.gh = {
    enable = true;
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
