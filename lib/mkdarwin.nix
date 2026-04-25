{ inputs }:
{ system, hostname, username, extraModules ? [ ] }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
inputs.darwin.lib.darwinSystem {
  inherit system;

  specialArgs = {
    inherit inputs hostname username pkgs-unstable;
  };

  modules =
    [
      ./../hosts/common/darwin.nix
      ./../hosts/darwin/${hostname}/default.nix

      inputs.home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit inputs hostname username pkgs-unstable;
        };
        home-manager.users.${username} = import ./../home/users/${username}.nix;
      }

      inputs.nix-homebrew.darwinModules.nix-homebrew
      inputs.sops-nix.darwinModules.sops
    ]
    ++ extraModules;
}
