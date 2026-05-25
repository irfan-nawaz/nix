# translate-shell (`trans`): CLI front-end for Google/Bing/Yandex
# translate. Default target language = English; tweak `hl` (UI) and
# `tl` (target) if you want a different pair.
_: {
  programs.translate-shell.settings = {
    hl = "en";
    tl = [ "en" ];
    verbose = true;
    play = false;
    show-original = "y";
    show-translation = "y";
    show-languages = "y";
    show-prompt-message = "y";
    indent = "4";
  };
}
