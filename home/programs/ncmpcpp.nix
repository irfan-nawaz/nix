# ncmpcpp: classic ncurses MPD client. Connects to mpd above.
#
# TODO: enable after mpd is running and has indexed the library.
_: {
  # programs.ncmpcpp = {
  #   enable = false;
  #   settings = {
  #     mpd_host = "localhost";
  #     mpd_port = "6600";
  #     visualizer_fifo_path = "/tmp/mpd.fifo";
  #     visualizer_output_name = "Visualizer";
  #     visualizer_type = "spectrum";
  #     song_columns_list_format = "(20)[blue]{a} (6f)[green]{NE} (50)[]{t|f:Title} (20)[cyan]{b} (7f)[magenta]{l}";
  #   };
  #   bindings = [
  #     { key = "j"; command = "scroll_down"; }
  #     { key = "k"; command = "scroll_up"; }
  #     { key = "J"; command = [ "select_item" "scroll_down" ]; }
  #     { key = "K"; command = [ "select_item" "scroll_up"   ]; }
  #   ];
  # };
}
