# parallel: GNU parallel. Suppress the academic-citation nag once
# globally; without it every first run prints a wall of text.
{ config, ... }:
{
  home.file."${config.xdg.dataHome}/parallel/will-cite".text = "";
}
