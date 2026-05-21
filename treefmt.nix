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
    "home/configs/refs/*"
    "home/ghostty/config"
    "home/starship/starship.toml"
  ];
}
