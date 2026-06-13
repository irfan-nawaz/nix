{
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true;
    statix.enable = true;
    deadnix.enable = true;
  };
  settings.global.excludes = [
    "flake.lock"
    "*.lock"
    "secrets/secrets.yaml"
    "statix.toml"
    "docs/notes/*"
    "home/programs/procs/config.toml"
    "home/programs/curl/.curlrc"
    "home/programs/ghostty/config"
    "home/programs/starship/starship.toml"
  ];
}
