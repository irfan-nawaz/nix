# navi: point at a personal cheats repo. Default cheats import from
# `navi --finder` source. Replace path when you start a private cheats
# directory.
{
  programs.navi = {
    enableZshIntegration = true;
    settings = {
      cheats.paths = [ "~/.local/share/navi/cheats" ];
      finder.command = "fzf";
      shell.command = "zsh";
    };
  };
}
