# aerospace: i3-style tiling WM for macOS. Apple-Silicon native, no SIP
# disable. Enable lives in modules/home/desktop-mac.nix (desktop tier);
# this file owns the declarative config that HM compiles to
# ~/.aerospace.toml.
#
# Layer 2 (window management) in the Karabiner -> Hammerspoon -> Aerospace
# -> tmux/sesh stack. See docs/productivity-stack.md for the layer model.
#
# Binding philosophy: vim-like mode.
#
# One global chord (caps+w) enters `wm` mode -- a sticky mode in which
# bare keys do all aerospace ops. Press esc to exit. This is the
# vim-normal-mode pattern: enter once, run several commands, leave.
#
# Why this design? Raycast's Hyper Key event tap interferes with plain
# `alt-X` bindings as a side effect, so we can't use the natural
# `alt-1`-style chord. The user keeps Raycast's hyper for app launching
# (hyper+b -> browser, hyper+s -> slack); aerospace just borrows ONE
# hyper combo (`hyper+w`) as its mode trigger. Everything else inside
# wm-mode is unmodified keys -- no chord conflicts possible.
#
# Reference: https://nikitabobko.github.io/AeroSpace/guide
{ pkgs, lib, ... }:
let
  # App → workspace routing. Each entry: macOS bundle identifier → workspace
  # number. The let-binding shape replaces ~130 lines of multi-line attrset
  # entries that were hard to scan post-nixfmt 2.5.0; adding an app is now
  # one line.
  #
  # Workspace key:
  #   1  terminal     ghostty
  #   2  editor       vscode, cursor
  #   3  browser      chrome (all profiles), brave
  #   4  dev tools    postman, tableplus, docker
  #   5  comms        slack, mail, discord
  #   6  notes        obsidian, joplin, apple notes
  #   7  media        spotify, iina, vlc
  #   8  meetings     zoom, teams, webex
  #   9  utilities    1password, activity monitor, meetingbar
  #
  # Caveat: bundle IDs for Electron / todesktop apps (e.g. Cursor) can
  # change between major versions. If an app stops landing in its
  # workspace after an update, re-check with `aerospace list-apps`.
  workspaceRouting = {
    "com.mitchellh.ghostty" = 1;

    "com.microsoft.VSCode" = 2;
    "com.todesktop.230313mzl4w4u92" = 2;

    "com.google.Chrome" = 3;
    "com.brave.Browser" = 3;

    "com.postmanlabs.mac" = 4;
    "com.tinyapp.TablePlus" = 4;
    "com.docker.docker" = 4;

    "com.tinyspeck.slackmacgap" = 5;
    "com.apple.mail" = 5;
    "com.hnc.Discord" = 5;

    "md.obsidian" = 6;
    "net.cozic.joplin-desktop" = 6;
    "com.apple.Notes" = 6;

    "com.spotify.client" = 7;
    "com.colliderli.iina" = 7;
    "org.videolan.vlc" = 7;

    "us.zoom.xos" = 8;
    "com.microsoft.teams" = 8;
    "com.microsoft.teams2" = 8;
    "Cisco-Systems.Spark" = 8;

    "com.1password.1password" = 9;
    "com.apple.ActivityMonitor" = 9;
    "leits.MeetingBar" = 9;
  };

  # Small dialogs and system utilities that should never tile. `layout
  # floating` rules apply on top of any workspace rule for the same app,
  # so an app listed in BOTH would land on its workspace AND float. No
  # current floating app overlaps workspaceRouting; adding such an app
  # is fine -- the order at the assignment site (workspace rules first)
  # keeps the layering correct.
  floatingApps = [
    "com.apple.systempreferences"
    "com.apple.finder"
    "com.apple.calculator"
    "com.apple.keychainaccess"
    "com.apple.installer"
    "com.apple.screencapture"
  ];

  mkWorkspaceRule = appId: ws: {
    "if".app-id = appId;
    run = [ "move-node-to-workspace ${toString ws}" ];
  };
  mkFloatingRule = appId: {
    "if".app-id = appId;
    run = [ "layout floating" ];
  };
in
{
  # HM owns the launchd agent (single source of truth for startup).
  # `start-at-login = false` below is intentional: aerospace's own
  # autostart registers itself as a macOS Login Item, which spawns a
  # SECOND daemon alongside HM's. Two processes fight for the same
  # hotkey CGEventTap and neither receives input reliably.
  programs.aerospace.launchd.enable = true;

  programs.aerospace.settings = {
    start-at-login = false;

    # Tiles by default; aerospace picks horizontal/vertical from container
    # aspect ratio. Accordion is reserved for explicit toggle.
    default-root-container-layout = "tiles";
    default-root-container-orientation = "auto";

    # Squash redundant single-child containers so the tree stays shallow.
    enable-normalization-flatten-containers = true;
    enable-normalization-opposite-orientation-for-nested-containers = true;

    accordion-padding = 30;

    # When the focused monitor changes, warp the cursor so macOS focus
    # follows the WM focus -- prevents click-to-focus going to a stale
    # monitor.
    on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

    # Notify sketchybar of workspace changes so it can repaint the
    # workspace pills. AEROSPACE_FOCUSED_WORKSPACE is set by aerospace
    # in the env for the spawned process; sketchybar subscribes to the
    # custom `aerospace_workspace_change` event.
    #
    # Absolute path to sketchybar is required: aerospace is started by a
    # launchd agent whose PATH only contains /usr/bin:/bin:/usr/sbin:/sbin,
    # so a bare `sketchybar` invocation fails silently with
    # `command not found` and the pills stay frozen on the last value.
    #
    # `pkgs.sketchybar` (unwrapped) is intentional here -- this call only
    # fires `--trigger`, which doesn't need the extraPackages PATH that
    # programs.sketchybar's wrapper adds for plugin scripts. The same
    # holds for the wm/service mode bindings further down this file.
    exec-on-workspace-change = [
      "/bin/bash"
      "-c"
      "${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
    ];

    gaps = {
      inner.horizontal = 8;
      inner.vertical = 8;
      outer.left = 8;
      outer.bottom = 8;
      # outer.top reserves space for sketchybar (28px bar + 8px breathing
      # room). aerospace already auto-avoids the macOS menu bar, but
      # custom status bars need their height added manually here -- there
      # is no auto-detect. Keep this in sync with `--bar height=` in
      # sketchybar.nix.
      outer.top = 36;
      outer.right = 8;
    };

    # ─── Auto-route apps to workspaces ───────────────────────────────
    # Fires the moment a new window appears (app launch, second window,
    # popped-out modal). The mapping tables live in the let-binding at
    # the top of this file (`workspaceRouting`, `floatingApps`); the
    # helpers below stitch them into the list shape aerospace expects.
    # Workspace rules come first so any floating rule for the same app
    # would layer on top.
    on-window-detected =
      (lib.mapAttrsToList mkWorkspaceRule workspaceRouting) ++ (map mkFloatingRule floatingApps);

    # ─── main mode: only one binding, the WM-mode trigger ────────────
    # Pressing caps+w (Raycast hyper + w) enters wm-mode. Everything else
    # in main mode is unbound, so normal typing is unaffected.
    mode.main.binding = {
      cmd-ctrl-alt-shift-w = [
        "mode wm"
        "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_mode MODE=wm"
      ];
    };

    # ─── wm mode: sticky vim-style normal mode for window ops ────────
    # Stays active until esc / enter. Inside, bare keys run aerospace
    # commands; typing into apps is suspended while in this mode.
    mode.wm.binding = {
      # Focus motion (vim hjkl)
      h = "focus left";
      j = "focus down";
      k = "focus up";
      l = "focus right";

      # Move focused window (shift+hjkl, capital HJKL)
      shift-h = "move left";
      shift-j = "move down";
      shift-k = "move up";
      shift-l = "move right";

      # Workspace switch (bare digit)
      "1" = "workspace 1";
      "2" = "workspace 2";
      "3" = "workspace 3";
      "4" = "workspace 4";
      "5" = "workspace 5";
      "6" = "workspace 6";
      "7" = "workspace 7";
      "8" = "workspace 8";
      "9" = "workspace 9";

      # Send window to workspace (shift+digit)
      shift-1 = "move-node-to-workspace 1";
      shift-2 = "move-node-to-workspace 2";
      shift-3 = "move-node-to-workspace 3";
      shift-4 = "move-node-to-workspace 4";
      shift-5 = "move-node-to-workspace 5";
      shift-6 = "move-node-to-workspace 6";
      shift-7 = "move-node-to-workspace 7";
      shift-8 = "move-node-to-workspace 8";
      shift-9 = "move-node-to-workspace 9";

      # Cycle layout: tiles<->accordion, horizontal<->vertical.
      slash = "layout tiles horizontal vertical";
      comma = "layout accordion horizontal vertical";

      # Resize the focused container. "smart" picks the right axis.
      minus = "resize smart -50";
      equal = "resize smart +50";

      # Fullscreen the focused window (toggle).
      f = "fullscreen";

      # Toggle floating <-> tiling for the focused window.
      space = "layout floating tiling";

      # Hop to the previous workspace (Tab analog).
      tab = "workspace-back-and-forth";

      # Drop into service mode.
      semicolon = [
        "mode service"
        "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_mode MODE=service"
      ];

      # Exit wm-mode back to normal typing.
      esc = [
        "mode main"
        "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_mode MODE=main"
      ];
      enter = [
        "mode main"
        "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_mode MODE=main"
      ];
    };

    # ─── service mode: rare workspace-tree ops ───────────────────────
    # Entered from wm-mode via `;`. esc reloads config, r rebalances.
    mode.service.binding = {
      esc = [
        "reload-config"
        "mode main"
        "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_mode MODE=main"
      ];
      r = [
        "flatten-workspace-tree"
        "mode main"
        "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_mode MODE=main"
      ];
      f = [
        "layout floating tiling"
        "mode main"
        "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_mode MODE=main"
      ];
      backspace = [
        "close-all-windows-but-current"
        "mode main"
        "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_mode MODE=main"
      ];
    };
  };
}
