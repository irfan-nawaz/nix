# Profile-wide baseline shared by every user:
#   - home-manager stateVersion
#   - XDG basedir pins
#   - environment variables
#   - CLI-only packages
#
# Per-app program configuration lives in ../programs/ (imported from
# home/users/profile.nix). GUI casks live in modules/home/gui.nix.
{
  config,
  pkgs,
  ...
}:
{
  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  home = {
    stateVersion = "26.05";
    sessionVariables = {
      # EDITOR / VISUAL set by programs.neovim.defaultEditor = true in neovim.nix.
      PAGER = "less";
    };
    # CLI tooling that isn't owned by a programs.* module. Anything with
    # its own home-manager module belongs in ../programs/<app>.nix instead.
    packages = with pkgs; [
      docker
      docker-compose
    ];
  };
}
