# sioyek: keyboard-driven PDF reader (paper-reading focused). Config
# at ~/.config/sioyek/prefs_user.config and bindings at
# keys_user.config. HM module accepts both as attrsets.
_: {
  programs.sioyek = {
    bindings = {
      "move_up" = "k";
      "move_down" = "j";
      "move_left" = "h";
      "move_right" = "l";
      "screen_down" = "<C-d>";
      "screen_up" = "<C-u>";
      "next_page" = "J";
      "previous_page" = "K";
      "goto_beginning" = "gg";
      "goto_end" = "G";
      "toggle_dark_mode" = "F2";
      "toggle_fullscreen" = "F11";
    };
    config = {
      "background_color" = "0.10 0.11 0.15";
      "text_highlight_color" = "1.0 1.0 0.0";
      "dark_mode_background_color" = "0.10 0.11 0.15";
      "dark_mode_contrast" = "0.85";
      "font_size" = "18";
      "page_separator_width" = "2";
      "should_use_multiple_monitors" = "1";
    };
  };
}
