{ inputs }:
{
  system,
  hostname,
  username,
}:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
inputs.darwin.lib.darwinSystem {
  inherit system;

  specialArgs = {
    inherit
      inputs
      hostname
      username
      pkgs-unstable
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
      # Rename any pre-existing target file to `<name>.backup` instead
      # of aborting the activation. Lets HM take ownership of paths
      # that were created imperatively (e.g. `gh config set …` writing
      # ~/.config/gh/config.yml before HM was wired up to manage it).
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {
        inherit
          inputs
          hostname
          username
          pkgs-unstable
          ;
      };
      home-manager.users.${username} = import ./../home/users/${username}.nix;
    }

    # Nix HomeBrew
    inputs.nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        enable = true;
        # Apple Silicon only: also install brew under the Intel prefix
        # so Rosetta x86_64 casks/bottles work.
        enableRosetta = true;
        user = username;
        autoMigrate = true;

        # Intentionally no `taps = { ... }` / `mutableTaps = false`.
        #
        # Brew 5.x ships in full API-mode by default (formulae.brew.sh):
        # it fetches cask/core JSON on demand and never needs a local tap
        # clone. Pinning taps to read-only Nix-store symlinks (no .git)
        # made brew 5's cask parser explode with
        #   "Cask '<name>' is unreadable: wrong number of arguments
        #    (given 1, expected 0)"
        # because the parser tries to walk the tap as a git checkout and
        # fails halfway through stanza eval. Letting brew use the API is
        # both the upstream default and the community workaround.
      };
    }

    # SOPS Secrets Management
    inputs.sops-nix.darwinModules.sops
  ];
}
