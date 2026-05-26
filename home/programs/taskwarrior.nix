# taskwarrior: CLI todo manager. HM owns the taskrc; data lives at
# ~/.local/share/task (XDG via the HM module). The `tasks` sesh session
# opens `taskwarrior-tui`, which has no HM module of its own and is
# installed system-wide via modules/packages/productivity.nix.
#
# Sync is intentionally off -- single-machine. Add a `sync.server.*`
# block under `config` when you have a taskchampion server URL +
# credentials (via sops, not inline).
{ config, pkgs, ... }:
let
  # Standard timewarrior-shipped hook. Pure stdlib python3 -- shebang is
  # `/usr/bin/env python3`, which resolves to macOS system python (3.9+,
  # has json + subprocess). No extra deps needed.
  timewHook = "${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior";
in
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

      # Point taskwarrior at an HM-managed hooks dir so the timewarrior
      # bridge below is picked up. Default would be
      # ~/.local/share/task/hooks (under data.location), which isn't a
      # natural xdg.configFile target.
      hooks.location = "${config.xdg.configHome}/task/hooks";
    };
  };

  # taskwarrior <-> timewarrior bridge: `task <id> start` auto-starts a
  # timew interval tagged with the task's project + tags + description;
  # `task <id> stop|done` stops it. Stock script shipped by timewarrior
  # upstream -- no fork, no patching.
  xdg.configFile."task/hooks/on-modify.timewarrior" = {
    source = timewHook;
    executable = true;
  };
}
