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
    "home/configs/atuin/config.toml"
    "home/configs/procs/config.toml"
    "home/configs/curl/.curlrc"
    "home/ghostty/config"
    "home/starship/starship.toml"
  ];
}
