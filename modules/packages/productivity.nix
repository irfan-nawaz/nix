{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Time tracking + clocks + task management
    peaclock
    carl
    hours
    timewarrior
    tasktimer
    tz
    basilk
    taskbook
    taskwarrior3
    taskwarrior-tui
    dijo
  ];
}
