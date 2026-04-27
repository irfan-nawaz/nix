{ ... }:
{
  imports = [
    ../common/default.nix
  ];

  home.username = "irfan-personal";
  home.homeDirectory = "/Users/irfan-personal";

  xdg.configFile."starship.toml".source = ../starship/starship.toml;
  xdg.configFile."ghostty/config".source = ../ghostty/config;

  # Make the path available without exposing secret content in the store.
  home.sessionVariables.GITHUB_TOKEN_FILE = "/run/secrets/github_token";

  programs.zsh.shellAliases = {
    ll = "eza -la";
    rebuild = "darwin-rebuild switch --flake ~/nix#irfan-personal";
    testbuild = "darwin-rebuild build --flake ~/nix#irfan-personal";
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

  programs.zoxide.enable = true;

  programs.git = {
    enable = true;
    signing.format = null;

    # fallback (just in case)
    settings = {
      user = {
        name = "irfan.nawaz";
        email = "irfan.nawaz@geekyants.com";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      merge.conflictStyle = "diff3";
    };

    includes = [
      # 🏢 GitLab Work
      {
        condition = "hasconfig:remote.*.url:git.geekyants.com:";
        contents = {
          user = {
            name = "irfan.nawaz";
            email = "irfan.nawaz@geekyants.com";
          };
        };
      }

      # 🐙 GitHub Work
      {
        condition = "hasconfig:remote.*.url:git@github.com:";
        contents = {
          user = {
            name = "irfan-ga";
            email = "irfan.nawaz@geekyants.com";
          };
        };
      }

      # 🌍 GitHub Personal
      {
        condition = "hasconfig:remote.*.url:git@github-personal:";
        contents = {
          user = {
            name = "Your Personal Name";
            email = "your.personal@email.com";
          };
        };
      }
    ];
  };

programs.ssh = {
  enable = true;
  enableDefaultConfig = false;

  matchBlocks = {
    # ✅ Defaults
    "*" = {
      addKeysToAgent = "yes";
      identitiesOnly = true;
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
    };

    # 🐙 GitHub WORK (via 443 - corp safe)
    "github.com" = {
      hostname = "ssh.github.com";
      port = 443;
      user = "git";
      identityFile = "~/.ssh/id_ed25519_github_work";
    };

    # 🐙 GitHub PERSONAL
    "github-personal" = {
      hostname = "ssh.github.com";
      port = 443;
      user = "git";
      identityFile = "~/.ssh/id_ed25519_github_personal";
    };

    # 🏢 Company GitLab (self-hosted)
    "git.geekyants.com" = {
      hostname = "git.geekyants.com";
      user = "git";
      identityFile = "~/.ssh/id_ed25519_gitlab";
    };
  };
};
}
