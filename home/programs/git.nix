# Git: SSH-signed commits with 4 forge identities routed by `hasconfig:`.
#
# Per-identity bits (signingkey, user.name, user.email) live in the
# `includes` list keyed on the repo's remote URL. The top-level signing
# key is intentionally /dev/null so a repo whose remote does not match
# any include refuses to sign rather than silently signing with the
# wrong key. Background: docs/commit-signing-kt.md.
{
  programs.git = {
    enable = true;

    signing = {
      format = "ssh";
      signByDefault = true;
      key = "/dev/null";
    };

    settings = {
      user = {
        name = "irfan-ga";
        email = "irfan.nawaz@geekyants.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.conflictStyle = "diff3";
      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
    };

    # hasconfig: patterns are matched with wildmatch + WM_PATHNAME, so
    # `*` cannot cross `/`. The only valid cross-path token is `/**`,
    # which must be preceded by `/`. The canonical shape that matches
    # both `<host>:owner/repo.git` (2-deep) and GitLab's nested
    # `<host>:group/sub/repo.git` (N-deep) is `<host>:*/**`:
    #   `*`   -> one path component (the user/group)
    #   `/**` -> the slash plus everything after, any depth
    includes = [
      {
        condition = "hasconfig:remote.*.url:git@github-personal:*/**";
        contents.user = {
          name = "irfan-nawaz";
          email = "shaikmd.irfannawaz2020@gmail.com";
          signingkey = "~/.ssh/id_ed25519_github_personal.pub";
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:*/**";
        contents.user = {
          name = "irfan-ga";
          email = "irfan.nawaz@geekyants.com";
          signingkey = "~/.ssh/id_ed25519_github_geekyants.pub";
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@git.geekyants.com:*/**";
        contents.user = {
          name = "irfan.nawaz";
          email = "irfan.nawaz@geekyants.com";
          signingkey = "~/.ssh/id_ed25519_gitlab_geekyants.pub";
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@gitlab.com:*/**";
        contents.user = {
          name = "inawaz.ctr";
          email = "inawaz.ctr@tzero.com";
          signingkey = "~/.ssh/id_ed25519_gitlab_tzero.pub";
        };
      }
    ];
  };

  # allowed_signers maps committer email -> public SSH key body so
  # `git log --show-signature` can verify SSH-signed commits locally.
  # Public halves only; safe to live in plaintext in the Nix store.
  xdg.configFile."git/allowed_signers".text = ''
    shaikmd.irfannawaz2020@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2ZO1/YR/bAgxPFfWvwLU2oIOljgT684bDT4YOiJVe2
    irfan.nawaz@geekyants.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMo3yIVsdzADsAMg41v4bI4PvmCrurGWTTlQOWzWYWj+
    irfan.nawaz@geekyants.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM2EMJd+smznpvUBuGZBByWhpdauNvbJn46QFhpwzWOb
    inawaz.ctr@tzero.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOs553WHdyGIvsg/7ODUuJps2AuYIo1BjDyvtxDw8eyT
  '';

  # Public halves of the SSH keys whose private halves are deployed via
  # sops-nix. ssh-keygen -Y sign needs the pubkey file alongside the
  # private key at the path referenced by user.signingkey. Public keys
  # are not secrets -- declaring them inline is fine.
  home.file = {
    ".ssh/id_ed25519_github_personal.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2ZO1/YR/bAgxPFfWvwLU2oIOljgT684bDT4YOiJVe2 github-personal\n";
    ".ssh/id_ed25519_github_geekyants.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMo3yIVsdzADsAMg41v4bI4PvmCrurGWTTlQOWzWYWj+ github-geekyants\n";
    ".ssh/id_ed25519_gitlab_geekyants.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM2EMJd+smznpvUBuGZBByWhpdauNvbJn46QFhpwzWOb gitlab-geekyants\n";
    ".ssh/id_ed25519_gitlab_tzero.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOs553WHdyGIvsg/7ODUuJps2AuYIo1BjDyvtxDw8eyT gitlab-tzero\n";
  };
}
