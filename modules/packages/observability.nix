{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Dashboards / system performance
    macmon
    zenith
    wtfutil

    # Logging
    lnav
  ];
}
