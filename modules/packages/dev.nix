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

    # Bookmarks
    bmm

    # Documentation / writing / slides
    slides
    runme
    presenterm
    tui-journal
  ];
}
