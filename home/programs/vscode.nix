# vscode: this repo installs the Cursor fork (`code-cursor`) for daily
# use. Stock VS Code is not declared as a system package. Leave this
# stub disabled; the HM `programs.vscode` module manages settings,
# keybindings, and extensions declaratively if you ever flip back.
#
# TODO: install pkgs.vscode (or pkgs.vscode-fhs) before enabling.
_: {
  # programs.vscode = {
  #   enable = false;
  #   profiles.default = {
  #     userSettings = {
  #       "editor.fontFamily"     = "JetBrainsMono Nerd Font";
  #       "editor.fontSize"       = 14;
  #       "editor.formatOnSave"   = true;
  #       "editor.tabSize"        = 2;
  #       "files.trimTrailingWhitespace" = true;
  #       "workbench.colorTheme"  = "Default Dark Modern";
  #     };
  #     # extensions = with pkgs.vscode-extensions; [
  #     #   bbenoist.nix
  #     #   jnoortheen.nix-ide
  #     #   eamodio.gitlens
  #     # ];
  #   };
  # };
}
