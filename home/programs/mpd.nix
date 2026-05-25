# mpd: music daemon. ncmpcpp and rmpc both attach to it. macOS uses the
# CoreAudio output driver.
#
# TODO: point musicDirectory at your library and flip enable. Then either
# `mpd --no-daemon` manually or wire it as a launchd agent.
_: {
  # services.mpd = {
  #   enable = false;
  #   musicDirectory = "${config.home.homeDirectory}/Music";
  #   playlistDirectory = "${config.home.homeDirectory}/.config/mpd/playlists";
  #   network.startWhenNeeded = true;
  #   extraConfig = ''
  #     audio_output {
  #       type "osx"
  #       name "CoreAudio"
  #     }
  #   '';
  # };
}
