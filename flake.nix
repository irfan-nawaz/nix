{
  description = "Irfan's macOS Nix platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-direnv.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, ... }:
    let
      lib = import ./lib { inherit inputs; };
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" ];
    in
    {
      darwinConfigurations = {
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

      checks = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          flake-eval = pkgs.runCommand "flake-eval" { } ''
            touch $out
          '';
        });
    };
}
