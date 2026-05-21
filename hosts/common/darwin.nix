{ pkgs, lib, username, ... }:
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
  ];

  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
      upgrade = false;
    };
    brews = [ "mas" ];
    casks = [ ];
    masApps = { };
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
  # nix-darwin from fighting it. As a side effect, every `nix.*` option below
  # is inert -- substituters, trusted-users, and GC must be configured via
  # Determinate's /etc/nix/nix.custom.conf and a launchd agent respectively
  # (see Phase 4).
  nix.enable = false;

  networking.computerName = lib.mkDefault "${username}-mac";

  security.pam.services.sudo_local.touchIdAuth = true;
}
