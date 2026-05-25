# mpv: hardware decode where available, YouTube via yt-dlp, sane defaults
# for screenshots and OSD. Bindings stay default; tweak input.conf below
# when you discover what's missing.
{
  programs.mpv = {
    config = {
      profile = "gpu-hq";
      hwdec = "auto-safe";
      vo = "gpu-next";
      ytdl-format = "bestvideo[height<=?1440]+bestaudio/best";
      cache = "yes";
      cache-secs = 60;
      demuxer-max-bytes = "150MiB";

      screenshot-format = "png";
      screenshot-template = "%F-%P";
      screenshot-directory = "~/Pictures/mpv";

      osd-bar = false;
      osd-font-size = 28;
      osd-color = "#bb9af7";

      save-position-on-quit = true;
      sub-auto = "fuzzy";
      keep-open = "yes";
    };

    bindings = {
      "WHEEL_UP" = "seek 10";
      "WHEEL_DOWN" = "seek -10";
      "Alt+0" = "set window-scale 0.5";
      "Alt+1" = "set window-scale 1.0";
      "Alt+2" = "set window-scale 2.0";
    };
  };
}
