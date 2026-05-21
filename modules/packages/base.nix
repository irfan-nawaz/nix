{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core system utilities
    vim
    curl
    wget
    gnupg
    gawk
    gnused
    sd
    procs
    gnutar
    unzip
    p7zip
    lsof
    coreutils
    hyperfine

    # Tree / navigation
    tree
    tre-command
    broot

    # Disk usage
    gdu
    dust

    # CLI personal knowledge management
    nb

    # Downloads & transfer
    rsync
    rclone
    magic-wormhole

    # Remote access
    openssh
    mosh

    # Build tools & automation
    entr
    just
    gnumake
    watchexec
    go-task

    # Terminal / UI / interactive layer
    television
    cmatrix
    choose
    skim
    gum
    dialog

    # Search / data exploration
    fx
    csvlens
    glow
    harlequin
    rainfrog
    sq
    slumber

    # Text processing / inspection
    silicon
    onefetch

    # System info
    cpufetch
    ghfetch

    # Core productivity utilities
    tldr
    delta
    pik
    caffeine
    flameshot
    nixfmt-rfc-style

    # Optional / situational
    chafa
    figurine

    # macOS housekeeping.
    pinentry_mac
    rmtrash
  ];
}
