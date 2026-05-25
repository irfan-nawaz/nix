{ lib, ... }:
{
  services.colima = {
    enable = true;

    profiles.default = {
      isService = true;
      isActive = true;
      setDockerHost = false;

      settings = {
        cpu = lib.mkDefault 4;
        memory = lib.mkDefault 8;
        disk = lib.mkDefault 100;

        vmType = "vz";
        mountType = "virtiofs";
        mountInotify = true;

        network.address = true;
        forwardAgent = true;

        runtime = "docker";
      };
    };
  };
}
