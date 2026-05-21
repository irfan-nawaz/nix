{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Email stack: mbsync pulls IMAP -> Maildir, notmuch indexes it,
    # meli is the TUI, msmtp sends, himalaya is the scripting CLI.
    # lieer is an alternative Gmail-OAuth sync engine kept available
    # for the OAuth upgrade path.
    # See docs/cli-stacks.md section 2.
    #
    # We use meli (not aerc) because aerc pulls `dante` for SOCKS5
    # support and dante currently fails to build on aarch64-darwin in
    # nixpkgs. meli is a modern Rust TUI, cached on cache.nixos.org.
    meli
    himalaya
    isync
    msmtp
    notmuch
    lieer

    # Calendar + contacts: vdirsyncer talks CalDAV/CardDAV, khal/khard
    # are the TUIs over the local vdir storage.
    # See docs/cli-stacks.md section 3.
    vdirsyncer
    khal
    khard
  ];
}
