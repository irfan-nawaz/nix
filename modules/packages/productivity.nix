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
    # taskwarrior3 is managed via home/programs/taskwarrior.nix (HM module
    # owns ~/.taskrc); only taskwarrior-tui stays here -- no HM module.
    taskwarrior-tui
    dijo

    # Encrypted backups to S3/B2/local.
    restic
  ];
}
