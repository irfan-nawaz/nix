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

  # nixpkgs.config.allowUnfree lives in lib/mkdarwin.nix (single source
  # of truth shared with the pkgs-unstable import). Overlays stay here
  # because they're stable-graph-specific.

  # wrtag's test suite includes a cover-art filename check that assumes
  # a case-sensitive filesystem; macOS (APFS default) is case-insensitive
  # so the test fails. The binary works fine -- skip tests on darwin.
  nixpkgs.overlays = [
    (_: prev: {
      wrtag = prev.wrtag.overrideAttrs (_: {
        doCheck = false;
      });
      # intelli-shell 3.4.1: test_default_config fails across stable + unstable
      # due to a changed default config expectation. Upstream bug.
      intelli-shell = prev.intelli-shell.overrideAttrs (_: {
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
      # Dock
      dock.autohide = true;
      dock.autohide-delay = 0.0;
      dock.autohide-time-modifier = 0.2;
      dock.show-recents = false;
      dock.mru-spaces = false; # don't reorder spaces by recent use
      dock.minimize-to-application = true;
      dock.persistent-apps = [
        "/Users/${username}/Applications/Home Manager Apps/Ghostty.app"
        "/Users/${username}/Applications/Home Manager Apps/Brave Browser.app"
        "/Users/${username}/Applications/Home Manager Apps/Slack.app"
        "/Users/${username}/Applications/Home Manager Apps/Cursor.app"
        "/Users/${username}/Applications/Home Manager Apps/Obsidian.app"
        "/Users/${username}/Applications/Home Manager Apps/Notion.app"
      ];

      # Finder
      finder.AppleShowAllExtensions = true;
      finder.AppleShowAllFiles = true; # show hidden files
      finder.ShowPathbar = true;
      finder.ShowStatusBar = true;
      finder.FXDefaultSearchScope = "SCcf"; # search current folder by default
      finder.FXPreferredViewStyle = "clmv"; # column view
      finder.FXEnableExtensionChangeWarning = false;
      finder._FXShowPosixPathInTitle = true;
      finder.CreateDesktop = false; # hide desktop icons

      # Global — appearance & input
      NSGlobalDomain.AppleInterfaceStyle = "Dark";
      NSGlobalDomain.ApplePressAndHoldEnabled = false;
      NSGlobalDomain.KeyRepeat = 2;
      NSGlobalDomain.InitialKeyRepeat = 15;
      NSGlobalDomain.AppleKeyboardUIMode = 3; # full keyboard navigation
      NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
      NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
      NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
      NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
      NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
      NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;

      # Trackpad
      trackpad.Clicking = true; # tap to click
      trackpad.TrackpadThreeFingerDrag = true;

      # Screensaver / lock
      screensaver.askForPassword = true;
      screensaver.askForPasswordDelay = 0;

      # Screenshots — dedicated folder, PNG format
      screencapture.location = "/Users/${username}/Desktop/screenshots";
      screencapture.type = "png";

      # Menu bar
      controlcenter.BatteryShowPercentage = true;

      # Login
      loginwindow.GuestEnabled = false;

      # Scrollbar click jumps to position
      NSGlobalDomain.AppleScrollerPagingBehavior = true;

      # Graphite accent — neutral, doesn't compete with Catppuccin Mocha colors
      CustomUserPreferences."NSGlobalDomain".AppleAccentColor = -1;
      CustomUserPreferences."NSGlobalDomain".AppleHighlightColor = "0.705882 0.745098 0.996078 Other";

      # Clear dark icon and widget style (requires logout to apply)
      NSGlobalDomain.AppleIconAppearanceTheme = "ClearDark";

      # Each display has its own independent spaces (essential with Aerospace)
      spaces.spans-displays = false;

      # No surprise OS updates mid-work
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

      # Removes "are you sure?" quarantine prompt on downloaded apps
      LaunchServices.LSQuarantine = false;

      # F1-F12 work as real function keys — better for dev shortcuts
      hitoolbox.AppleFnUsageType = "Do Nothing";

      # Show CPU graph in dock when Activity Monitor is open
      ActivityMonitor.IconType = 5;
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
    nerd-fonts.hack
    nerd-fonts.meslo-lg
    nerd-fonts.symbols-only
  ];

  # Weekly garbage collection. Determinate Nix ignores nix-darwin's nix.gc
  # block, so we drive nix-collect-garbage with a launchd agent instead.
  # 30d retention preserves the rollback option for ~4 weeks of switches;
  # binary cache hits keep rebuild cost low if more aggressive cleanup is
  # ever needed via `just gc`.
  launchd.user.agents.nix-gc = {
    command = "/run/current-system/sw/bin/nix-collect-garbage --delete-older-than 30d";
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

  # Set up ~/.ssh BEFORE sops-nix mounts secrets into it. sops-install-secrets
  # uses `mkdir -p` for the parent dir, which leaves an existing user-owned
  # 0700 dir untouched. Creating it here removes the race where ~/.ssh would
  # otherwise be created by sops-nix as root:0755 first and then patched by
  # postActivation -- a sequence that breaks if activation phases ever reorder.
  system.activationScripts.preActivation.text = ''
    mkdir -p "/Users/${username}/.ssh"
    chown ${username}:staff "/Users/${username}/.ssh"
    chmod 0700 "/Users/${username}/.ssh"
  '';

  # Safety net for the preActivation block above: if any script between
  # preActivation and HM still managed to chown ~/.ssh to root (older nix-darwin
  # behaviour, third-party module surprise), restore correct perms before HM
  # tries to write ~/.ssh/config. Also ensures the screenshots dir exists for
  # the system.defaults.screencapture.location setting.
  system.activationScripts.postActivation.text = ''
    if [ -d "/Users/${username}/.ssh" ]; then
      chown ${username}:staff "/Users/${username}/.ssh"
      chmod 0700 "/Users/${username}/.ssh"
    fi
    mkdir -p "/Users/${username}/Desktop/screenshots"
  '';
}
