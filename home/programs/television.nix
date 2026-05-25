# television: fuzzy TUI launcher built on top of skim/fzf primitives.
# Default keymap is fine; theme overrides + a couple of extra channels
# go here when you start adding custom pickers.
_: {
  programs.television.settings = {
    ui = {
      use_nerd_font_icons = true;
      show_help_bar = true;
      show_preview_panel = true;
    };
    keybindings = { };
  };
}
