# curl is pre-XDG; it reads ~/.curlrc from $HOME, not $XDG_CONFIG_HOME.
{
  home.file.".curlrc".source = ./curl/.curlrc;
}
