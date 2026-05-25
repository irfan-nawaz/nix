# atuin -- encrypted, syncable shell history with fuzzy search.
#
# Settings live inline (not as a raw config.toml) because we only set a
# handful of values; HM emits a minimal config.toml from this attrset.
# The full upstream schema is in atuin's git history if ever needed.
#
# Atuin owns Ctrl-R in this setup. hstr's zsh integration is disabled
# (see hstr.nix); fzf still installs a Ctrl-R widget at zsh init, so
# we rebind '^R' after everything else loads — see `initContent` below.
{ lib, ... }:
{
  programs.atuin.settings = {
    enter_accept = true;
    sync.records = true;

    # Render Ctrl-R inside a tmux popup (requires tmux >= 3.2).
    # Integrates cleanly with the sesh-managed session model.
    tmux = {
      enabled = true;
      width = "80%";
      height = "60%";
    };

    # Per-repo / per-dir history surfacing. Inside a git repo Ctrl-R
    # prioritises commands from this workspace first, then current dir,
    # then current session, then host, then global.
    workspaces = true;
    search.filters = [
      "workspace"
      "directory"
      "session"
      "host"
      "global"
    ];
  };

  # Force atuin to own Ctrl-R regardless of HM's module load order.
  # Without this, fzf's zsh integration (which binds ^R) can overwrite
  # atuin's widget depending on which init snippet HM emits last.
  programs.zsh.initContent = lib.mkAfter ''
    bindkey '^R' atuin-search
  '';
}
