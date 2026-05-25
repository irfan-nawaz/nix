# script-directory (`sd`): tiny launcher for personal scripts. Pin the
# root so `sd <script>` looks in a stable place across machines.
{ config, ... }:
{
  programs.script-directory.settings = {
    SD_ROOT = "${config.home.homeDirectory}/.local/share/scripts";
    SD_EDITOR = "nvim";
    SD_CAT = "bat";
  };
}
