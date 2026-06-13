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
    programs = {
      brave.enable = true;
      dbeaver.enable = true;
      freetube.enable = true;
      joplin-desktop.enable = true;
      obsidian.enable = true;
      sioyek.enable = true;
      vscode.enable = true;
    };

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
