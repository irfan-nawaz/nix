# tmux: prefix=C-a (Ctrl-b is a strain), vi-mode for copy-mode,
# 256-color + true-color, mouse on, sane indices. Enable lives in
# modules/home/tui.nix (dev tier).
#
# The session ecosystem (sesh + dispatcher + auto-launch hook) is
# owned by home/programs/sesh.nix as a single source of truth -- it
# appends its hook line to programs.tmux.extraConfig via HM merge.
{ pkgs, ... }:
{
  programs.tmux = {
    prefix = "C-a";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    historyLimit = 50000;
    terminal = "tmux-256color";
    clock24 = true;

    extraConfig = ''
      # true-color passthrough for ghostty + alacritty
      set -ga terminal-overrides ",*256col*:Tc"

      # easier split bindings
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "tmux.conf reloaded"

      # vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # keep tmux server alive when all sessions detach so lazily-created
      # background sessions survive across ghostty closes
      set -g exit-empty off

      # sesh picker. -H hides the currently-attached session. Don't add
      # -i (icons add ANSI bytes that break `sesh connect`) or -d
      # (path-dedupe hides sessions sharing ~).
      bind-key "s" run-shell "sesh connect $(sesh list -H | fzf-tmux -p 55%,60%)"
      bind-key "K" run-shell "sesh last"
    '';

    # sesh + the session-created hook (in sesh.nix) own session
    # lifecycle now, so resurrect/continuum are intentionally absent --
    # two persistence mechanisms fight over restored sessions after a
    # darwin-rebuild switch.
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
    ];
  };
}
