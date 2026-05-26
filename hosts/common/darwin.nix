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

  # Required for: terraform (BSL since v1.6) and _1password-cli at the
  # system layer; slack/raycast/notion-app/code-cursor/postman/tableplus/
  # meetingbar in home/common; vscode + obsidian via modules/home/gui.nix.
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
    # No `taps = [...]`. Brew 5.x reads cask/core formulae directly from
    # formulae.brew.sh in API mode (its default); tapping homebrew/cask,
    # homebrew/core, or homebrew/bundle as explicit taps is unnecessary
    # and conflicts with the API path -- triggers Ruby parse errors like
    # "Cask is unreadable: wrong number of arguments (given 1, expected 0)".
    # `brew bundle` itself is built into brew since 4.x, no tap required.
    brews = [ "mas" ];
    # macOS apps installed via cask rather than nixpkgs. The pattern: anything
    # that requires a stable /Applications/*.app bundle path for macOS-managed
    # permissions/entitlements goes through brew. Nix store paths change every
    # rebuild, which forces macOS to re-prompt for Accessibility / Input
    # Monitoring / Notifications / DriverKit sysext approval on every switch.
    #
    # - hammerspoon: Lua scripting engine. init.lua managed declaratively
    #   from home/programs/hammerspoon.nix. Needs Accessibility +
    #   Notifications grants.
    # - karabiner-elements: physical-key remapper. As of 15.x upstream
    #   restructured into Privileged-Daemons-v2.app + Non-Privileged-Agents-v2.app
    #   + Karabiner-Core-Service.app; nix-darwin's services.karabiner-elements
    #   module is hardcoded for the 14.x layout (separate grabber/observer
    #   processes that no longer exist) and is broken. The upstream-signed
    #   cask handles DriverKit sysext installation/notarization and privileged
    #   helper setup correctly. karabiner.json managed declaratively from
    #   home/programs/karabiner.nix.
    casks = [
      "hammerspoon"
      "karabiner-elements"
    ];
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
  # configured via Determinate's /etc/nix/nix.custom.conf, which it loads
  # via `!include` from /etc/nix/nix.conf. Manage that file declaratively
  # from docs/nix.custom.conf.example so the on-disk copy can't drift.
  nix.enable = false;
  environment.etc."nix/nix.custom.conf".source = ../../docs/nix.custom.conf.example;

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

  # Karabiner-Elements installation moved to homebrew.casks above (see the
  # block comment there for the full rationale). nix-darwin's
  # services.karabiner-elements module targets the pre-15.x process layout
  # and the upstream rewrite broke it. karabiner.json itself stays in HM
  # (home/programs/karabiner.nix) -- only the binary install moved.

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
