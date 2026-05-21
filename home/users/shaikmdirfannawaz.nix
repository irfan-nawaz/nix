{ username, ... }:
{
  imports = [ ./profile.nix ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
}
