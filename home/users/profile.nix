# Shared per-user profile. Assembled from:
#   - home/common         -- baseline env, XDG, CLI packages
#   - home/programs       -- one module per configured app
#   - modules/home        -- mySystem.home.{tui,gui,desktop-mac,ai} option layer
#
# Per-user shims (home/users/<username>.nix) only set home.username,
# home.homeDirectory, and any one-off overrides.
{
  hostname,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../common
    ../programs
    ../../modules/home
    inputs.nix-index-database.hmModules.nix-index
  ];

  mySystem.home = {
    tui.enable = lib.mkDefault true;
    gui.enable = lib.mkDefault true;
    desktop-mac.enable = lib.mkDefault true;
    ai.enable = lib.mkDefault true;
  };

  # Use the pre-built nix-index database (shipped by the flake input);
  # no manual `nix-index` run needed. comma enables `, <cmd>` ad-hoc runner.
  programs.nix-index-database.comma.enable = true;

  home.sessionVariables.GITHUB_TOKEN_FILE = "/run/secrets/github_token";

  # Hostname-scoped aliases: every host wants `rebuild` / `testbuild`
  # but the flake target differs per machine. Kept here (not in
  # programs/zsh) because this is where hostname is naturally in scope.
  programs.zsh.shellAliases = {
    rebuild = "sudo darwin-rebuild switch --flake ~/nix#${hostname}";
    testbuild = "darwin-rebuild build --flake ~/nix#${hostname}";
  };
}
