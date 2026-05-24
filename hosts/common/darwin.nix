{
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [
    ../../modules/packages/base.nix
    ../../modules/packages/network.nix
    ../../modules/packages/observability.nix
    ../../modules/packages/security.nix
    ../../modules/packages/iac.nix
    ../../modules/packages/k8s.nix
    ../../modules/packages/cloud.nix
    ../../modules/packages/dev.nix
    ../../modules/packages/productivity.nix
    ../../modules/packages/personal.nix
    ../../modules/packages/comms.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # wrtag's test suite includes a cover-art filename check that assumes
  # a case-sensitive filesystem; macOS (APFS default) is case-insensitive
  # so the test fails. The binary works fine -- skip tests on darwin.
  nixpkgs.overlays = [
    (_: prev: {
      wrtag = prev.wrtag.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
      upgrade = false;
    };
    taps = [
      "homebrew/bundle"
      "homebrew/cask"
      "homebrew/core"
    ];
    brews = [ "mas" ];
  };

  system = {
    primaryUser = username;
    stateVersion = 6;
    defaults = {
      dock.autohide = true;
      finder.AppleShowAllExtensions = true;
      NSGlobalDomain.ApplePressAndHoldEnabled = false;
    };
  };

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
    validateSopsFiles = true;
    secrets = {
      github_geekyants_ssh_key = {
        path = "/Users/${username}/.ssh/id_ed25519_github_geekyants";
        mode = "0600";
        owner = username;
      };
      github_personal_ssh_key = {
        path = "/Users/${username}/.ssh/id_ed25519_github_personal";
        mode = "0600";
        owner = username;
      };
      gitlab_geekyants_ssh_key = {
        path = "/Users/${username}/.ssh/id_ed25519_gitlab_geekyants";
        mode = "0600";
        owner = username;
      };
      gitlab_tzero_ssh_key = {
        path = "/Users/${username}/.ssh/id_ed25519_gitlab_tzero";
        mode = "0600";
        owner = username;
      };
    };
  };

  # Nix is managed by Determinate Nix here, so `nix.enable = false` keeps
  # nix-darwin from fighting it. As a side effect, every `nix.*` option is
  # inert -- substituters, trusted-users, and experimental-features must be
  # configured via Determinate's /etc/nix/nix.custom.conf (see
  # docs/nix.custom.conf.example).
  nix.enable = false;

  # nix-darwin tooling that improves rebuild ergonomics and shell completion.
  environment.systemPackages = with pkgs; [
    nh
    nix-output-monitor
    nvd
  ];
  programs.nix-index.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
  ];

  # Weekly garbage collection. Determinate Nix ignores nix-darwin's nix.gc
  # block, so we drive nix-collect-garbage with a launchd agent instead.
  launchd.user.agents.nix-gc = {
    command = "/run/current-system/sw/bin/nix-collect-garbage --delete-older-than 14d";
    serviceConfig.StartCalendarInterval = [
      {
        Hour = 3;
        Minute = 15;
        Weekday = 0;
      }
    ];
    serviceConfig.RunAtLoad = false;
  };

  networking.computerName = lib.mkDefault "${username}-mac";

  security.pam.services.sudo_local.touchIdAuth = true;

  # sops-nix creates ~/.ssh as root (mode 0755) when dropping secret
  # symlinks. home-manager later writes ~/.ssh/config into it but does
  # not fix ownership. Reassert correct owner + 0700 on every switch.
  system.activationScripts.postActivation.text = ''
    if [ -d "/Users/${username}/.ssh" ]; then
      chown ${username}:staff "/Users/${username}/.ssh"
      chmod 0700 "/Users/${username}/.ssh"
    fi
  '';
}
