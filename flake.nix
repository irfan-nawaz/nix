{
  description = "Irfan's macOS Nix platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-darwin.url  = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-darwin";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    homebrew-bundle = { url = "github:homebrew/homebrew-bundle"; flake = false; };

    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-direnv.inputs.nixpkgs.follows = "nixpkgs-darwin";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, ... }:
    let
      lib = import ./lib { inherit inputs; };
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" ];
    in
    {
      darwinConfigurations = {
        shaikmdirfannawaz = lib.mkDarwin {
          system = "aarch64-darwin";
          hostname = "shaikmdirfannawaz";
          username = "shaikmdirfannawaz";
        };
        irfan-personal = lib.mkDarwin {
          system = "aarch64-darwin";
          hostname = "irfan-personal";
          username = "irfan-personal";
        };
      };

      templates = {
        default = self.templates.devshell;

        devshell = {
          path = ./templates/devshell;
          description = "General purpose macOS Nix devshell";
        };

        node = {
          path = ./templates/lang/node;
          description = "Node.js development template with direnv";
        };

        python = {
          path = ./templates/lang/python;
          description = "Python development template with direnv";
        };
      };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      checks = forAllSystems (
        system:
        nixpkgs.lib.optionalAttrs (system == "aarch64-darwin") {
          shaikmdirfannawaz = self.darwinConfigurations.shaikmdirfannawaz.system;
          irfan-personal = self.darwinConfigurations.irfan-personal.system;
        }
      );
    };
}
