# aria2: multi-connection downloader. The defaults are conservative
# (5 connections, ~/Downloads). Bump parallelism for big files and
# enable session resume so a Ctrl-C survives a reboot.
{ config, ... }:
{
  programs.aria2.settings = {
    dir = "${config.home.homeDirectory}/Downloads";
    file-allocation = "none";
    continue = true;
    max-connection-per-server = 16;
    split = 16;
    min-split-size = "1M";
    max-concurrent-downloads = 5;
    summary-interval = 0;
    console-log-level = "warn";
    save-session = "${config.xdg.dataHome}/aria2/session.txt";
    input-file = "${config.xdg.dataHome}/aria2/session.txt";
    save-session-interval = 60;
  };
}
