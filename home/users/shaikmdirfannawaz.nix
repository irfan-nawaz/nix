{ hostname, ... }:
{
  imports = [
    ../common/default.nix
  ];

  home.username = "shaikmdirfannawaz";
  home.homeDirectory = "/Users/shaikmdirfannawaz";

  # Make the path available without exposing secret content in the store.
  home.sessionVariables.GITHUB_TOKEN_FILE = "/run/secrets/github_token";

  xdg.configFile = {
    "starship.toml".source = ../starship/starship.toml;
    "ghostty/config".source = ../ghostty/config;
    # "atuin/config.toml".source = ../atuin/config.toml;
    # "bat/config".source = ../bat/config;
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
    defaultOptions = [
      "--no-mouse"
    ];
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

  programs.home-manager.enable = true;

  programs.nix-index.enable = true;

  programs.bat.enable = true;

  programs.bat.config.theme = "Nord";

  programs.git = {
    enable = true;
    signing.format = null;

    # fallback (just in case)
    settings = {
      user = {
        name = "irfan-ga";
        email = "irfan.nawaz@geekyants.com";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      merge.conflictStyle = "diff3";
    };

 includes = [
      # ==========================================
      # GitHub PERSONAL
      # ==========================================
      {
        condition = "hasconfig:remote.*.url:git@github-personal:";
        contents = {
          user = {
            name = "irfan-nawaz";
            email = "shaikmd.irfannawaz2020@gmail.com";
          };
        };
      }

      # ==========================================
      # GitHub WORK
      # ==========================================
      {
        condition = "hasconfig:remote.*.url:git@github.com:";
        contents = {
          user = {
            name = "irfan-ga";
            email = "irfan.nawaz@geekyants.com";
          };
        };
      }

      # ==========================================
      # GitLab GeekyAnts
      # ==========================================
      {
        condition = "hasconfig:remote.*.url:git@git.geekyants.com:";
        contents = {
          user = {
            name = "irfan.nawaz";
            email = "irfan.nawaz@geekyants.com";
          };
        };
      }

      # ==========================================
      # GitLab TZero
      # ==========================================
      {
        condition = "hasconfig:remote.*.url:git@gitlab.com:";
        contents = {
          user = {
            name = "inawaz.ctr";
            email = "inawaz.ctr@tzero.com";
          };
        };
      }
    ];
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {

      # ==========================================
      # Global defaults
      # ==========================================
      "*" = {
        addKeysToAgent = "yes";
        identitiesOnly = true;
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };

      # ==========================================
      # GitHub WORK (default github.com)
      # ==========================================
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github_geekyants";
      };

      # ==========================================
      # GitHub PERSONAL (alias only)
      # ==========================================
      "github-personal" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github_personal";
      };

      # ==========================================
      # GitLab GeekyAnts
      # ==========================================
      "git.geekyants.com" = {
        hostname = "git.geekyants.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_gitlab_geekyants";
      };

      # ==========================================
      # GitLab TZero (default gitlab.com)
      # ==========================================
      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_gitlab_tzero";
      };
    };
  };
}
