{ hostname, lib, ... }:
{
  imports = [
    ../common/default.nix
    ../../modules/home
  ];

  mySystem.home = {
    tui.enable = lib.mkDefault true;
    gui.enable = lib.mkDefault true;
    desktop-mac.enable = lib.mkDefault true;
    ai.enable = lib.mkDefault true;
  };

  home.sessionVariables.GITHUB_TOKEN_FILE = "/run/secrets/github_token";

  xdg.configFile = {
    "starship.toml".source = ../starship/starship.toml;
    "ghostty/config".source = ../ghostty/config;
    "procs/config.toml".source = ../configs/procs/config.toml;
    # atuin's HM module only writes ~/.config/atuin/config.toml when
    # programs.atuin.settings is set. Keeping the TOML form as the
    # source of truth instead of translating ~370 lines to a Nix attrset.
    "atuin/config.toml".source = ../configs/atuin/config.toml;
    # allowed_signers maps committer email -> public SSH key body so
    # `git log --show-signature` can verify SSH-signed commits locally.
    # Public halves only; safe to live in plaintext in the Nix store.
    "git/allowed_signers".text = ''
      shaikmd.irfannawaz2020@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2ZO1/YR/bAgxPFfWvwLU2oIOljgT684bDT4YOiJVe2
      irfan.nawaz@geekyants.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMo3yIVsdzADsAMg41v4bI4PvmCrurGWTTlQOWzWYWj+
      irfan.nawaz@geekyants.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM2EMJd+smznpvUBuGZBByWhpdauNvbJn46QFhpwzWOb
      inawaz.ctr@tzero.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOs553WHdyGIvsg/7ODUuJps2AuYIo1BjDyvtxDw8eyT
    '';
  };

  home.file.".curlrc".source = ../configs/curl/.curlrc;

  programs.zsh.shellAliases = {
    rebuild = "sudo darwin-rebuild switch --flake ~/nix#${hostname}";
    testbuild = "darwin-rebuild build --flake ~/nix#${hostname}";
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--color=auto"
    ];
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
    defaultOptions = [ "--no-mouse" ];
  };

  programs.htop = {
    enable = true;
    settings.show_program_path = true;
  };

  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.gpg.enable = true;
  programs.lf.enable = true;

  programs.bat = {
    enable = true;
    config.theme = "Nord";
  };

  programs.git = {
    enable = true;
    signing = {
      format = "ssh";
      signByDefault = true;
      # Fail-loud default: a repo whose remote URL does not match any
      # include below will refuse to sign, rather than silently signing
      # with whichever key happens to be the global default. Every real
      # repo must be covered by one of the includes.
      key = "/dev/null";
    };

    settings = {
      user = {
        name = "irfan-ga";
        email = "irfan.nawaz@geekyants.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      merge.conflictStyle = "diff3";
      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
    };

    includes = [
      {
        condition = "hasconfig:remote.*.url:git@github-personal:";
        contents.user = {
          name = "irfan-nawaz";
          email = "shaikmd.irfannawaz2020@gmail.com";
          signingkey = "~/.ssh/id_ed25519_github_personal.pub";
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:";
        contents.user = {
          name = "irfan-ga";
          email = "irfan.nawaz@geekyants.com";
          signingkey = "~/.ssh/id_ed25519_github_geekyants.pub";
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@git.geekyants.com:";
        contents.user = {
          name = "irfan.nawaz";
          email = "irfan.nawaz@geekyants.com";
          signingkey = "~/.ssh/id_ed25519_gitlab_geekyants.pub";
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@gitlab.com:";
        contents.user = {
          name = "inawaz.ctr";
          email = "inawaz.ctr@tzero.com";
          signingkey = "~/.ssh/id_ed25519_gitlab_tzero.pub";
        };
      }
    ];
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        identitiesOnly = true;
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github_geekyants";
      };
      "github-personal" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github_personal";
      };
      "git.geekyants.com" = {
        hostname = "git.geekyants.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_gitlab_geekyants";
      };
      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_gitlab_tzero";
      };
    };
  };
}
