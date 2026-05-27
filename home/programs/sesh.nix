# Single source of truth for the tmux session ecosystem.
#
# Each entry in `sessions` below produces three coordinated artifacts:
#
#   1. A `[[session]]` block in ~/.config/sesh/sesh.toml so the session
#      appears in the fuzzy picker (`prefix s`, bound in tmux.nix).
#   2. If the entry has a `command`, a `case` branch in the dispatcher
#      script `tmux-session-launcher` that `respawn-pane -k`s the
#      session's pane to that command directly.
#   3. A tmux `session-created` hook that invokes the dispatcher.
#
# Why dispatch via hook + `respawn-pane` instead of sesh's own
# `startup_command`? sesh's `startup_command` uses `tmux send-keys` --
# it types the command into the freshly-spawned shell. With many
# eval-based zsh plugins (atuin, carapace, intelli-shell, ...) the
# shell isn't ready when the keystrokes land, init swallows the
# input, and the command never runs. `respawn-pane -k` replaces the
# pane's command directly: no shell, no typing, no race.
#
# Add a session only when its tool is in `home.packages` and its
# data dir is declared. There is no shell fallback -- if a tool
# fails the pane dies (textbook tmux semantics). Failing-loud forces
# us to declare preconditions instead of papering over them.

{ pkgs, lib, ... }:
# Note: the `notes` session's `zk edit --interactive` needs a notebook
# marker at ~/Documents/zk/.zk. That activation lives in zk.nix
# (alongside the rest of zk's config), not here.

let
  sessions = {
    main    = { path = "~"; };
    nix     = { path = "~/nix"; command = "nvim ."; };
    claude  = { path = "~/nix"; command = "claude"; };
    notes   = { path = "~/Documents/zk"; command = "sh -c 'while zk edit --interactive; do true; done'"; };
    tasks   = { path = "~"; command = "taskwarrior-tui"; };
    habits  = { path = "~"; command = "dijo"; };
    journal = { path = "~/Documents/journal"; command = "jrnl --edit"; };
    sys     = { path = "~"; command = "btop"; };
    clock   = { path = "~"; command = "clock-rs"; };
    zones   = { path = "~"; command = "tz -w -m"; };
  };

  toToml = name: s: ''
    [[session]]
    name = "${name}"
    path = "${s.path}"
  '';

  toCase = name: s:
    lib.optionalString (s ? command)
      "  ${name}) exec tmux respawn-pane -k -t \"$name\" ${lib.escapeShellArg s.command} ;;";

  seshToml = lib.concatStringsSep "\n" (lib.mapAttrsToList toToml sessions);

  dispatcherCases = lib.concatStringsSep "\n"
    (lib.filter (s: s != "") (lib.mapAttrsToList toCase sessions));

  tmuxSessionLauncher = pkgs.writeShellScriptBin "tmux-session-launcher" ''
    name="$1"
    case "$name" in
    ${dispatcherCases}
    esac
  '';
in
{
  home.packages = [ tmuxSessionLauncher ];

  xdg.configFile."sesh/sesh.toml".text = seshToml;

  # The tmux hook lives next to the sessions it dispatches. HM merges
  # `programs.tmux.extraConfig` across modules, so this appends to
  # the tmux config defined in tmux.nix.
  programs.tmux.extraConfig = ''
    set-hook -ga session-created 'run-shell "tmux-session-launcher #{hook_session_name}"'
  '';
}
