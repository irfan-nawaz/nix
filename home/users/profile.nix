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
  };

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
      key = "~/.ssh/id_ed25519_github_geekyants.pub";
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
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:";
        contents.user = {
          name = "irfan-ga";
          email = "irfan.nawaz@geekyants.com";
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@git.geekyants.com:";
        contents.user = {
          name = "irfan.nawaz";
          email = "irfan.nawaz@geekyants.com";
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@gitlab.com:";
        contents.user = {
          name = "inawaz.ctr";
          email = "inawaz.ctr@tzero.com";
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
