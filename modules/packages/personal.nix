{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Audiophile music stack: MPD daemon + clients + library manager.
    # MPD outputs through Core Audio in exclusive mode for bit-perfect
    # playback to the external DAC. See docs/cli-stacks.md section 1.
    # `mpd-small` drops CD audio support (libcdio-paranoia is broken on
    # aarch64-darwin in current nixpkgs); we don't need it for file playback.
    mpd-small
    mpc
    ncmpcpp
    rmpc
    # Music tagger: wrtag (Go, MusicBrainz-backed). beets is NOT used
    # because its closure pulls chromaprint + aacgain, both broken on
    # aarch64-darwin in current nixpkgs.
    wrtag

    # Universal media player + downloader (YouTube, one-off files, video).
    mpv
    yt-dlp

    # RSS / news reader.
    newsboat

    # Terminal browsers. w3m is required by aerc to render HTML email parts.
    w3m
    lynx
  ];
}
