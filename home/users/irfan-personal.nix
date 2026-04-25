{ ... }:
{
  imports = [
    ../common/default.nix
  ];

  home.username = "irfan-personal";
  home.homeDirectory = "/Users/irfan-personal";

  xdg.configFile."starship.toml".source = ../starship/starship.toml;
  xdg.configFile."ghostty/config".source = ../ghostty/config;

  programs.git = {
    settings = {
      user.name = "Irfan";
      user.email = "irfan@example.com";
    };
  };

  # Make the path available without exposing secret content in the store.
  home.sessionVariables.GITHUB_TOKEN_FILE = "/run/secrets/github_token";

  programs.zsh.shellAliases = {
    ll = "eza -la";
    rebuild = "darwin-rebuild switch --flake ~/nix#irfan-personal";
    testbuild = "darwin-rebuild build --flake ~/nix#irfan-personal";
  };
}
