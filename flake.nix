{
  description = "Irfan's macOS Nix platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # nix-homebrew installs brew itself declaratively; the actual
    # cask/core/bundle taps are NOT pinned -- brew 5.x reads them from
    # formulae.brew.sh on demand (API mode is the default). See the long
    # comment in lib/mkdarwin.nix for why pinning the taps breaks cask
    # parsing under brew 5.
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-direnv.inputs.nixpkgs.follows = "nixpkgs-darwin";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-darwin";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      treefmt-nix,
      ...
    }:
    let
      lib = import ./lib { inherit inputs; };
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" ];
      treefmtFor = system: treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix;
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

      formatter = forAllSystems (system: (treefmtFor system).config.build.wrapper);

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "nix-platform";
            packages = with pkgs; [
              sops
              age
              just
              nh
              nixfmt
              statix
              deadnix
              git
            ];
          };
        }
      );

      checks = forAllSystems (system: {
        shaikmdirfannawaz = self.darwinConfigurations.shaikmdirfannawaz.system;
        irfan-personal = self.darwinConfigurations.irfan-personal.system;
        formatting = (treefmtFor system).config.build.check self;
      });
    };
}
