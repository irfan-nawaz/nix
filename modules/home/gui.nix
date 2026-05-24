{ config, lib, ... }:
let
  cfg = config.mySystem.home.gui;
in
{
  options.mySystem.home.gui.enable = lib.mkEnableOption "Heavyweight desktop / GUI programs";

  config = lib.mkIf cfg.enable {
    programs.brave.enable = true;
    programs.dbeaver.enable = true;
    programs.freetube.enable = true;
    programs.joplin-desktop.enable = true;
    programs.obsidian.enable = true;
    programs.sioyek.enable = true;
    programs.vscode.enable = true;
  };
}
