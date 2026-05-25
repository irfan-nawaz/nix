# ghostty has no programs.* HM module yet; the package ships in
# modules/home/gui.nix (ghostty-bin), and the config is a native
# Ghostty-format file linked through XDG.
{
  xdg.configFile."ghostty/config".source = ./ghostty/config;
}
