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

    # Encrypted backups to S3/B2/local.
    restic
  ];
}
