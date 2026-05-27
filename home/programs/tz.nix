# tz: multi-timezone viewer. Config at ~/.config/tz/conf.toml.
# Run with -w to refresh every minute; -m for 24h format.
# Note: tz 0.8.0 renamed the zone field from `tz` to `id` (docs lag the binary).
# Note: New Jersey = America/New_York (same EST/EDT as New York), no separate entry.
{ ... }:
{
  xdg.configFile."tz/conf.toml".text = ''
    [[zones]]
    name = "Bengaluru"
    id   = "Asia/Kolkata"

    [[zones]]
    name = "London"
    id   = "Europe/London"

    [[zones]]
    name = "Toronto"
    id   = "America/Toronto"

    [[zones]]
    name = "New York"
    id   = "America/New_York"

    [[zones]]
    name = "San Francisco"
    id   = "America/Los_Angeles"

    [[zones]]
    name = "Vancouver"
    id   = "America/Vancouver"
  '';
}
