# wrtag: MusicBrainz-driven tagger/organiser. CLI-only; config is a TOML
# at ~/.config/wrtag/config.toml. Path templating decides on-disk layout.
#
# TODO: edit ./wrtag/config.toml then uncomment xdg.configFile below.
# Reference: https://github.com/sentriz/wrtag
_: {
  # xdg.configFile."wrtag/config.toml".source = ./wrtag/config.toml;
  #
  # Skeleton:
  #   path-format = "{{ .Album.AlbumArtist }}/{{ .Album.Title }}/{{ printf \"%02d\" .Track.Position }} - {{ .Track.Title }}{{ .Track.Ext }}"
  #   keep-files  = [ "cover.jpg" ]
}
