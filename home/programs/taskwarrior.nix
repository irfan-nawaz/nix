# taskwarrior: CLI todo manager. HM owns the taskrc; data lives at
# ~/.local/share/task (XDG via the HM module). The `tasks` sesh session
# opens `taskwarrior-tui`, which has no HM module of its own and is
# installed system-wide via modules/packages/productivity.nix.
#
# Sync is intentionally off -- single-machine. Add a `sync.server.*`
# block under `config` when you have a taskchampion server URL +
# credentials (via sops, not inline).
{ pkgs, ... }:
{
  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    config = {
      # Dismiss the v3 migration nag on first run.
      news.version = "3.0.0";

      # Standard 3-tier priority (H/M/L) with empty default.
      uda.priority.values = "H,M,L,";

      # Boost urgency for tasks tagged `+next` -- common GTD pattern.
      urgency.user.tag.next.coefficient = 15.0;

      # Monday-start weeks.
      weekstart = "monday";
    };
  };
}
