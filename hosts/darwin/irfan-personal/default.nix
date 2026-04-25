{ username, ... }:
{
  networking.hostName = "irfan-personal";

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "aarch64-darwin";
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = username;
    autoMigrate = true;
    mutableTaps = true;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
      upgrade = false;
    };

    brews = [
      "mas"
    ];

    casks = [
      "ghostty"
      "raycast"
    ];

    masApps = { };
  };
}
