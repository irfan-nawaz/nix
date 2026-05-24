{ username, ... }:
{
  imports = [ ./profile.nix ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # M4, 48 GB RAM — give colima more headroom for k8s/dev experiments.
  services.colima.profiles.default.settings = {
    cpu = 8;
    memory = 16;
    disk = 150;
  };
}
