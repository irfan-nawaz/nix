# Single source of truth for the tmux session ecosystem.
#
# Layer 3 (sessions inside the terminal) in the Karabiner -> Hammerspoon
# -> Aerospace -> tmux/sesh stack. See docs/productivity-stack.md for
# the layer model and ritual flow.
#
# Each entry in `sessions` below produces two coordinated artifacts:
#
#   1. A `[[session]]` block in ~/.config/sesh/sesh.toml so the session
#      appears in the fuzzy picker (`prefix s`, bound in tmux.nix).
#   2. If the entry has a `command`, a `case` branch in the dispatcher
#      script `tmux-session-launcher` that `respawn-pane -k`s the
#      session's pane to that command directly.
#
# Project sessions (~/cp/*, ~/pp/*) are handled differently:
#   - sesh auto-discovers them via [[path]] config — no per-project entry.
#   - The dispatcher detects them by path prefix and applies ONE standard
#     4-window layout: shell · claude · git · run.
#   - Adding a project = mkdir. No nix change needed.
#   - When moving to nvim, update standardProjectLayout in one place.
#
# Why dispatch via hook + `respawn-pane` instead of sesh's own
# `startup_command`? sesh's `startup_command` uses `tmux send-keys` --
# it types the command into the freshly-spawned shell. With many
# eval-based zsh plugins (atuin, carapace, intelli-shell, ...) the
# shell isn't ready when the keystrokes land, init swallows the
# input, and the command never runs. `respawn-pane -k` replaces the
# pane's command directly: no shell, no typing, no race.

{ pkgs, lib, ... }:
let
  sessions = {
    main = {
      path = "~";
    };
    nix = {
      path = "~/nix";
      command = "nvim .";
    };
    claude = {
      path = "~/nix";
      command = "claude";
    };
    notes = {
      path = "~/Documents/zk";
      command = "sh -c 'while zk edit --interactive; do true; done'";
    };
    tasks = {
      path = "~";
    };
    habits = {
      path = "~";
      command = "dijo";
    };
    journal = {
      path = "~/Documents/journal";
      command = "jrnl --edit";
    };
    sys = {
      path = "~";
      command = "btop";
    };
    clock = {
      path = "~";
      command = "clock-rs";
    };
    zones = {
      path = "~";
      command = "tz -w -m";
    };
  };

  # Standard 4-window project layout applied to every ~/cp/* and ~/pp/* session.
  # Uses $pane_path (resolved in dispatcher before this runs) for working dirs.
  # Uses :^ (first window) instead of :0 so base-index 1 is respected.
  # Window 0 is shell today; swap the rename line to respawn nvim when ready.
  standardProjectLayout = ''
    lock() {
      tmux set-window-option -t "$1" allow-rename    off
      tmux set-window-option -t "$1" automatic-rename off
    }
    new_locked() {
      local win
      win=$(tmux new-window -t "$name:" -n "$1" -c "$pane_path" -P -F '#{window_index}')
      lock "$name:$win"
      echo "$win"
    }

    tmux rename-window -t "$name:^" shell
    lock "$name:^"

    claude_win=$(new_locked claude)
    tmux respawn-pane -k -t "$name:$claude_win" claude

    git_win=$(new_locked git)
    tmux respawn-pane -k -t "$name:$git_win" lazygit

    new_locked run

    tmux select-window -t "$name:^"
  '';

  toToml = name: s: ''
    [[session]]
    name = "${name}"
    path = "${s.path}"
  '';

  toCase =
    name: s:
    lib.optionalString (
      s ? command
    ) "  ${name}) exec tmux respawn-pane -k -t \"$name\" ${lib.escapeShellArg s.command} ;;";

  seshToml = lib.concatStringsSep "\n" (lib.mapAttrsToList toToml sessions);

  dispatcherCases = lib.concatStringsSep "\n" (
    lib.filter (s: s != "") (lib.mapAttrsToList toCase sessions)
  );

  tmuxSessionLauncher = pkgs.writeShellScriptBin "tmux-session-launcher" ''
    name="$1"

    # Project sessions: any session whose starting pane lives under ~/cp or ~/pp.
    # One standard layout applied to all — no per-project case needed.
    pane_path=$(tmux display-message -p -t "$name" '#{pane_current_path}' 2>/dev/null)
    home="$HOME"
    case "$pane_path" in
      "$home"/cp/*|"$home"/pp/*)
        ${standardProjectLayout}
        exit 0
        ;;
    esac

    # tasks session: two windows — tui (taskwarrior-tui) and vit.
    if [[ "$name" == "tasks" ]]; then
      tmux rename-window -t "$name:^" tui
      tmux respawn-pane -k -t "$name:^" taskwarrior-tui
      vit_win=$(tmux new-window -t "$name:" -n vit -c "$HOME" -P -F '#{window_index}')
      tmux respawn-pane -k -t "$name:$vit_win" vit
      tmux select-window -t "$name:^"
      exit 0
    fi

    # Named sessions with dedicated tools.
    case "$name" in
    ${dispatcherCases}
    esac
  '';
in
{
  home.packages = [ tmuxSessionLauncher ];

  xdg.configFile."sesh/sesh.toml".text = ''
    ${seshToml}

    # Auto-discover all immediate subdirectories of ~/cp and ~/pp as sessions.
    [[path]]
    paths = ["~/cp", "~/pp"]
  '';

  # mkAfter: append this hook after tmux.nix's base extraConfig so the
  # final tmux.conf reads top-to-bottom (base settings, then this hook).
  # The hook itself is order-independent at runtime, but pinning the
  # merge order keeps the generated conf readable and stops future
  # contributors from wondering whether the hook needs tmux's `set -g`
  # lines to land first.
  programs.tmux.extraConfig = lib.mkAfter ''
    set-hook -ga session-created 'run-shell "tmux-session-launcher #{hook_session_name}"'
  '';
}
