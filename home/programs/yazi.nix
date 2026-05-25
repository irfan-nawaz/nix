# yazi: defaults are good; tweak the opener so media files use mpv and
# images preview via chafa-equivalent. Keymap stays default.
{
  programs.yazi.settings = {
    manager = {
      ratio = [
        1
        4
        3
      ];
      sort_by = "natural";
      sort_dir_first = true;
      sort_sensitive = false;
      show_hidden = false;
      show_symlink = true;
    };
    preview = {
      tab_size = 2;
      max_width = 600;
      max_height = 900;
      image_delay = 30;
    };
    opener = {
      play = [
        {
          run = ''mpv "$@"'';
          orphan = true;
          desc = "Play with mpv";
          for = "unix";
        }
      ];
      edit = [
        {
          run = ''$EDITOR "$@"'';
          block = true;
          for = "unix";
        }
      ];
      open = [
        {
          run = ''open "$@"'';
          desc = "Open with macOS default";
          for = "macos";
        }
      ];
    };
    open.rules = [
      {
        mime = "image/*";
        use = [ "open" ];
      }
      {
        mime = "video/*";
        use = [ "play" ];
      }
      {
        mime = "audio/*";
        use = [ "play" ];
      }
      {
        mime = "text/*";
        use = [ "edit" ];
      }
      {
        mime = "*";
        use = [ "open" ];
      }
    ];
  };
}
