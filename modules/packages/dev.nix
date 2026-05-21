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

    # Bookmarks
    bmm

    # Documentation / writing / slides
    slides
    runme
    presenterm
    tui-journal
  ];
}
