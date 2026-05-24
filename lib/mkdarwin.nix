{ inputs }:
{
  system,
  hostname,
  username,
}:
inputs.darwin.lib.darwinSystem {
  inherit system;

  specialArgs = {
    inherit
      inputs
      hostname
      username
      ;
  };

  modules = [
    ./../hosts/common/darwin.nix
    ./../hosts/darwin/${hostname}/default.nix

    # Home Manager
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit
          inputs
          hostname
          username
          ;
      };
      home-manager.users.${username} = import ./../home/users/${username}.nix;
    }

    # Nix HomeBrew
    inputs.nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        # Install Homebrew under the default prefix
        enable = true;

        # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
        enableRosetta = true;

        # User owning the Homebrew prefix
        user = username;

        autoMigrate = true;

        # Optional: Declarative tap management
        taps = with inputs; {
          "homebrew/homebrew-core" = homebrew-core;
          "homebrew/homebrew-cask" = homebrew-cask;
          "homebrew/homebrew-bundle" = homebrew-bundle;
        };

        # Optional: Enable fully-declarative tap management
        #
        # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
        mutableTaps = false;
      };
    }

    # SOPS Secrets Management
    inputs.sops-nix.darwinModules.sops
  ];
}
