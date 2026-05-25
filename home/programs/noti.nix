# noti: desktop notifications when long commands finish.
# `noti make build` -> banner on completion. Default backend on macOS
# is the native banner; no extra config needed.
{
  programs.noti.settings = {
    nsuser.soundName = "Ping";
    say.voice = "Samantha";
  };
}
