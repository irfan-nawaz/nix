# yt-dlp: default to ≤1440p mp4-mergeable, write metadata + thumbnail,
# archive seen videos to avoid re-downloads.
{
  programs.yt-dlp.settings = {
    format = "bestvideo[height<=?1440][ext=mp4]+bestaudio[ext=m4a]/best";
    embed-thumbnail = true;
    embed-metadata = true;
    embed-chapters = true;
    write-sub = true;
    write-auto-sub = true;
    sub-lang = "en.*";
    convert-subs = "srt";
    output = "~/Downloads/yt-dlp/%(uploader)s/%(title)s [%(id)s].%(ext)s";
    download-archive = "~/.local/share/yt-dlp/archive.txt";
    no-mtime = true;
  };
}
