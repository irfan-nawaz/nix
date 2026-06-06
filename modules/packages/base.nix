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
    # broot installed via home/programs/broot.nix (HM owns its config).

    # Disk usage
    gdu
    dust

    # CLI personal knowledge management
    nb

    # Downloads & transfer
    rsync
    magic-wormhole
    # rclone installed via home/programs/rclone.nix (HM owns its remotes block).

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
    cmatrix
    choose
    skim
    gum
    dialog
    # television installed via home/programs/television.nix (HM owns its theme).

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
    nixfmt

    # Optional / situational
    chafa
    figurine

    # macOS housekeeping.
    pinentry_mac
    rmtrash
  ];
}
