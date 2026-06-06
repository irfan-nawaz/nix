{
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.statix.enable = true;
  programs.deadnix.enable = true;
  settings.global.excludes = [
    "flake.lock"
    "*.lock"
    "secrets/secrets.yaml"
    "docs/notes/*"
    "home/programs/procs/config.toml"
    "home/programs/curl/.curlrc"
    "home/programs/ghostty/config"
    "home/programs/starship/starship.toml"
  ];
}
