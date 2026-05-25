{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Databases
    usql
    sqlite

    # Dev-heavy media
    ffmpeg
    smassh
    sampler

    # AI tools
    yai
    pi-coding-agent

    # Terminal recording / sharing
    asciinema
    t-rec

    # Forge CLIs (GitHub + GitLab) -- repo / PR / SSH-key management.
    gh
    glab

    # tmux session manager: fuzzy picker (prefix s) + declarative
    # session set in ~/.config/sesh/sesh.toml. See home/programs/sesh.nix.
    sesh

    # Bookmarks
    bmm

    # Documentation / writing / slides
    slides
    runme
    presenterm
    tui-journal
  ];
}
