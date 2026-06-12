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

  # gh + fzf workflows. Shell functions rather than aliases because they
  # use pipes, awk, and xargs -- plain aliases can't span multiple commands.
  programs.zsh.initContent = ''
    # Fuzzy PR checkout: list open PRs, pick with fzf, checkout.
    ghpr() {
      local pr
      pr=$(gh pr list --limit 50 | fzf --preview 'gh pr view {1}' | awk '{print $1}')
      [[ -n "$pr" ]] && gh pr checkout "$pr"
    }

    # Fuzzy issue view: list open issues assigned to me, pick with fzf, open in browser.
    ghis() {
      local issue
      issue=$(gh issue list --assignee @me --limit 50 | fzf | awk '{print $1}')
      [[ -n "$issue" ]] && gh issue view "$issue" --web
    }

    # Fuzzy branch checkout via gh (includes remote branches as PRs).
    ghco() {
      local branch
      branch=$(git branch -a | fzf | sed 's|remotes/origin/||' | tr -d ' ')
      [[ -n "$branch" ]] && git checkout "$branch"
    }
  '';
}
