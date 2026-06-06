{
  imports = [
    # Tier 0 — already-configured core
    ./atuin.nix
    ./bat.nix
    ./colima.nix
    ./curl.nix
    ./diff-so-fancy.nix
    ./direnv.nix
    ./eza.nix
    ./fzf.nix
    ./ghostty.nix
    ./git.nix
    ./gpg.nix
    ./htop.nix
    ./lf.nix
    ./neovim.nix
    ./procs.nix
    ./ssh.nix
    ./starship.nix
    ./zsh.nix

    # Tier B — quality-of-life with working defaults
    ./aliae.nix
    ./broot.nix
    ./btop.nix
    ./carapace.nix
    ./chawan.nix
    ./clock-rs.nix
    ./fastfetch.nix
    ./git-cliff.nix
    ./hstr.nix
    ./jrnl.nix
    ./lazydocker.nix
    ./lazygit.nix
    ./less.nix
    ./mpv.nix
    ./navi.nix
    ./noti.nix
    ./ripgrep.nix
    ./sesh.nix
    ./tealdeer.nix
    ./tmux.nix
    ./yazi.nix
    ./yt-dlp.nix
    ./tz.nix
    ./zk.nix

    # Tier A — user-data-dependent active modules
    # (productivity OS, k8s clusters, etc -- need imperative setup outside Nix)
    ./aerospace.nix
    ./hammerspoon.nix
    ./karabiner.nix
    ./k9s.nix
    ./kind.nix
    ./sketchybar.nix

    # Tier C — specialised active modules
    ./notifications.nix
    ./taskwarrior.nix
    ./vscode.nix

    # Stubs — commented-out skeletons awaiting first activation.
    # Each file lives under ./stubs and ships a TODO + config template.
    # See docs/stubs.md for the per-tool blocker list.
    ./stubs

    # Tier 1 — high-QoL shell/files/dev configs for already-enabled tools
    ./aria2.nix
    ./difftastic.nix
    ./fd.nix
    ./intelli-shell.nix
    ./jq.nix
    ./man.nix
    ./mc.nix
    ./parallel.nix
    ./pay-respects.nix
    ./radio-active.nix
    ./rclone.nix
    ./readline.nix
    ./script-directory.nix
    ./television.nix
    ./tmate.nix
    ./translate-shell.nix
    ./ttyper.nix
    ./zoxide.nix

    # Tier 2 — AI clients (auth via env vars / sops, not nix store)
    ./aichat.nix
    ./claude-code.nix
    ./fabric-ai.nix
    ./opencode.nix

    # Tier 3 — desktop GUI apps (mostly enable-only on darwin)
    ./brave.nix
    ./dbeaver.nix
    ./freetube.nix
    ./joplin-desktop.nix
    ./obsidian.nix
    ./sioyek.nix

    # Tier 4 — system packages with HM modules layered on top
    ./awscli.nix
    ./gh.nix
    ./glab.nix
    ./presenterm.nix
    ./runme.nix
  ];
}
