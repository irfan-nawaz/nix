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
    # Disabled below by commenting because Nix is managed by Determinate Nix (nix.enable = false),
    # so NixOS options like `nix.gc` and `nix.optimise` will result in error as they reqire nix and we are using Determinate Nix.
    # optimise.automatic = true;
    gc = {
      # automatic = true;
      # interval = { Weekday = 0; Hour = 3; Minute = 15; };
      # options = "--delete-older-than 14d";
    };
  };

  programs.zsh.enable = true;
  # programs.fish.enable = true;
  system.primaryUser = username;

  users.users.${username} = {
    home = "/Users/${username}";
    # shell = pkgs.fish;
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    jq
    gnupg
    btop
    coreutils
    difftastic
    dua
    duf
    entr
    fastfetch
    fd
    ffmpeg
    figurine
    fzf
    gnused
    iperf3
    just
    mc
    mosh
    nmap
    ripgrep
    smartmontools
    tree
    unzip
    zoxide
    bat
    eza
    lsof
    tldr
    atuin
    pass
    delta
    chafa
    nixfmt-rfc-style
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
