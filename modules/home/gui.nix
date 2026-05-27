{
  config,
  lib,
  pkgs,
  ...
}:
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

    # macOS GUI casks installed via home-manager (no home-manager program
    # module exists for these). Gated behind gui.enable so a leaner
    # profile (e.g. server-style work machine) can drop them all.
    home.packages = with pkgs; [
      slack
      tableplus
      raycast
      meetingbar
      postman
      notion-app
      ghostty-bin
    ];
  };
}
