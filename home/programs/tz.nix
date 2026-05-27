# tz: multi-timezone viewer. Config at ~/.config/tz/tz.toml.
# Run with -w to refresh every minute; -m for 24h format.
{ ... }:
{
  xdg.configFile."tz/conf.toml".text = ''
    [[zones]]
    name = "Bengaluru"
    tz   = "Asia/Kolkata"

    [[zones]]
    name = "London"
    tz   = "Europe/London"

    [[zones]]
    name = "Toronto"
    tz   = "America/Toronto"

    [[zones]]
    name = "New York"
    tz   = "America/New_York"

    [[zones]]
    name = "Vancouver"
    tz   = "America/Vancouver"
  '';
}
