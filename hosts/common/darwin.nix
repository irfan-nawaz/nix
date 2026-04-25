{ config, pkgs, lib, username, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      # Temporary compatibility alias for nix-homebrew on current nixpkgs.
    })
  ];

  sops = {
    defaultSopsFile = ./../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
    validateSopsFiles = true;
    secrets = { };
  };

  nix = {
    enable = false;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@admin" username ];
      warn-dirty = false;
    };
    # optimise.automatic = true;
    gc = {
      # automatic = true;
      # interval = { Weekday = 0; Hour = 3; Minute = 15; };
      # options = "--delete-older-than 14d";
    };
  };

  programs.zsh.enable = true;
  system.primaryUser = username;

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    git
    gnupg
    jq
    nixfmt-rfc-style
    vim
    wget
  ];

  networking.computerName = lib.mkDefault "${username}-mac";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
  };

  system.stateVersion = 5;
}
