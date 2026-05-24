{ config, lib, ... }:
let
  cfg = config.mySystem.home.desktop-mac;
in
{
  options.mySystem.home.desktop-mac.enable =
    lib.mkEnableOption "macOS desktop integration (tiling WM, status bar, file associations)";

  config = lib.mkIf cfg.enable {
    programs.aerospace.enable = true;
    programs.infat.enable = true;
    programs.sketchybar.enable = true;
  };
}
